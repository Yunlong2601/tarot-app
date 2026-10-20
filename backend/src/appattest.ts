/**
 * Apple App Attest verification (iOS device proof), with no dependencies.
 *
 * Attestation (once per install key): proves the key lives in the Secure
 * Enclave of a real Apple device running this app (team id + bundle id).
 * Assertion (each token refresh): proves the request was signed by that key.
 * Follows Apple's "Validating apps that connect to your server" steps.
 */

/** Apple App Attestation Root CA (apple.com/certificateauthority), valid to 2045.
 * SHA-256 fingerprint 1C:B9:82:3B:A2:8B:A6:AD:2D:33:A0:06:94:1D:E2:AE:4F:51:3E:F1:D4:E8:31:B9:F7:E0:FA:7B:62:42:C9:32.
 * Same file: backend/certs/apple-app-attestation-root.pem. */
export const APPLE_APP_ATTEST_ROOT_PEM = `-----BEGIN CERTIFICATE-----
MIICITCCAaegAwIBAgIQC/O+DvHN0uD7jG5yH2IXmDAKBggqhkjOPQQDAzBSMSYw
JAYDVQQDDB1BcHBsZSBBcHAgQXR0ZXN0YXRpb24gUm9vdCBDQTETMBEGA1UECgwK
QXBwbGUgSW5jLjETMBEGA1UECAwKQ2FsaWZvcm5pYTAeFw0yMDAzMTgxODMyNTNa
Fw00NTAzMTUwMDAwMDBaMFIxJjAkBgNVBAMMHUFwcGxlIEFwcCBBdHRlc3RhdGlv
biBSb290IENBMRMwEQYDVQQKDApBcHBsZSBJbmMuMRMwEQYDVQQIDApDYWxpZm9y
bmlhMHYwEAYHKoZIzj0CAQYFK4EEACIDYgAERTHhmLW07ATaFQIEVwTtT4dyctdh
NbJhFs/Ii2FdCgAHGbpphY3+d8qjuDngIN3WVhQUBHAoMeQ/cLiP1sOUtgjqK9au
Yen1mMEvRq9Sk3Jm5X8U62H+xTD3FE9TgS41o0IwQDAPBgNVHRMBAf8EBTADAQH/
MB0GA1UdDgQWBBSskRBTM72+aEH/pwyp5frq5eWKoTAOBgNVHQ8BAf8EBAMCAQYw
CgYIKoZIzj0EAwMDaAAwZQIwQgFGnByvsiVbpTKwSga0kP0e8EeDS4+sQmTvb7vn
53O5+FRXgeLhpJ06ysC5PrOyAjEAp5U4xDgEgllF7En3VcE3iexZZtKeYnpqtijV
oyFraWVIyd/dganmrduC1bmTBGwD
-----END CERTIFICATE-----`;

const NONCE_OID = "1.2.840.113635.100.8.2";
const AAGUID_PROD = "appattest\0\0\0\0\0\0\0";
const AAGUID_DEV = "appattestdevelop";

export class AttestError extends Error {}

const fail = (why: string): never => {
  throw new AttestError(why);
};

// ---------- bytes ----------

export function b64ToBytes(s: string): Uint8Array {
  const std = s.replace(/-/g, "+").replace(/_/g, "/");
  const bin = atob(std + "=".repeat((4 - (std.length % 4)) % 4));
  return Uint8Array.from(bin, (c) => c.charCodeAt(0));
}

export function bytesToB64(b: Uint8Array): string {
  let s = "";
  for (const x of b) s += String.fromCharCode(x);
  return btoa(s);
}

function concat(...parts: Uint8Array[]): Uint8Array {
  const out = new Uint8Array(parts.reduce((n, p) => n + p.length, 0));
  let o = 0;
  for (const p of parts) {
    out.set(p, o);
    o += p.length;
  }
  return out;
}

function equal(a: Uint8Array, b: Uint8Array): boolean {
  if (a.length !== b.length) return false;
  let d = 0;
  for (let i = 0; i < a.length; i++) d |= a[i]! ^ b[i]!;
  return d === 0;
}

export async function sha256(b: Uint8Array): Promise<Uint8Array> {
  return new Uint8Array(await crypto.subtle.digest("SHA-256", b));
}

const utf8 = (s: string) => new TextEncoder().encode(s);

// ---------- CBOR (the subset App Attest uses) ----------

type Cbor = number | bigint | string | Uint8Array | Cbor[] | Map<Cbor, Cbor> | boolean | null | undefined;

export function decodeCbor(data: Uint8Array): Cbor {
  let p = 0;
  const byte = () => (p < data.length ? data[p++]! : fail("cbor: truncated"));
  const len = (info: number): number => {
    if (info < 24) return info;
    let n = 0;
    const size = info === 24 ? 1 : info === 25 ? 2 : info === 26 ? 4 : info === 27 ? 8 : fail("cbor: bad length");
    for (let i = 0; i < size; i++) n = n * 256 + byte();
    return n;
  };
  const take = (n: number) => {
    if (p + n > data.length) fail("cbor: truncated");
    const out = data.subarray(p, p + n);
    p += n;
    return out;
  };
  const item = (depth: number): Cbor => {
    if (depth > 16) fail("cbor: too deep");
    const b = byte();
    const major = b >> 5;
    const info = b & 31;
    switch (major) {
      case 0:
        return len(info);
      case 1:
        return -1 - len(info);
      case 2:
        return take(len(info));
      case 3:
        return new TextDecoder().decode(take(len(info)));
      case 4: {
        const n = len(info);
        if (n > 64) fail("cbor: array too long");
        return Array.from({ length: n }, () => item(depth + 1));
      }
      case 5: {
        const n = len(info);
        if (n > 64) fail("cbor: map too long");
        const m = new Map<Cbor, Cbor>();
        for (let i = 0; i < n; i++) m.set(item(depth + 1), item(depth + 1));
        return m;
      }
      case 7:
        return info === 20 ? false : info === 21 ? true : info === 22 ? null : fail("cbor: unsupported simple");
      default:
        return fail("cbor: unsupported type");
    }
  };
  const out = item(0);
  if (p !== data.length) fail("cbor: trailing bytes");
  return out;
}

// ---------- DER / X.509 (just what is needed) ----------

interface Tlv {
  tag: number;
  /** The whole element, header included. */
  raw: Uint8Array;
  value: Uint8Array;
}

function readTlv(buf: Uint8Array, at: number): Tlv & { end: number } {
  if (at + 2 > buf.length) fail("der: truncated");
  const tag = buf[at]!;
  let p = at + 1;
  let n = buf[p++]!;
  if (n & 0x80) {
    const size = n & 0x7f;
    if (size < 1 || size > 3) fail("der: bad length");
    n = 0;
    for (let i = 0; i < size; i++) n = n * 256 + buf[p++]!;
  }
  if (p + n > buf.length) fail("der: truncated");
  return { tag, raw: buf.subarray(at, p + n), value: buf.subarray(p, p + n), end: p + n };
}

function children(t: Tlv): Tlv[] {
  const out: Tlv[] = [];
  let p = 0;
  while (p < t.value.length) {
    const c = readTlv(t.value, p);
    out.push(c);
    p = c.end;
  }
  return out;
}

function oid(bytes: Uint8Array): string {
  const parts = [Math.floor(bytes[0]! / 40), bytes[0]! % 40];
  let v = 0;
  for (const b of bytes.subarray(1)) {
    v = v * 128 + (b & 0x7f);
    if (!(b & 0x80)) {
      parts.push(v);
      v = 0;
    }
  }
  return parts.join(".");
}

function derTime(t: Tlv): number {
  const s = new TextDecoder().decode(t.value);
  const full = t.tag === 0x17 ? (Number(s.slice(0, 2)) >= 50 ? "19" : "20") + s : s; // UTCTime : GeneralizedTime
  const iso = `${full.slice(0, 4)}-${full.slice(4, 6)}-${full.slice(6, 8)}T${full.slice(8, 10)}:${full.slice(10, 12)}:${full.slice(12, 14)}Z`;
  return Date.parse(iso);
}

export interface Cert {
  tbs: Uint8Array;
  sigAlg: string;
  signature: Uint8Array;
  spki: Uint8Array;
  curve: string;
  /** The raw EC point from the public key. */
  point: Uint8Array;
  notBefore: number;
  notAfter: number;
  extensions: Map<string, Uint8Array>;
}

const CURVES: Record<string, string> = { "1.2.840.10045.3.1.7": "P-256", "1.3.132.0.34": "P-384" };
const HASHES: Record<string, string> = { "1.2.840.10045.4.3.2": "SHA-256", "1.2.840.10045.4.3.3": "SHA-384" };

export function parseCert(der: Uint8Array): Cert {
  const top = readTlv(der, 0);
  const [tbsT, algT, sigT] = children(top);
  if (!tbsT || !algT || !sigT) return fail("cert: bad shape");
  const tbsKids = children(tbsT);
  // [0] version is present in v3 certificates.
  const f = tbsKids[0]?.tag === 0xa0 ? tbsKids.slice(1) : tbsKids;
  const validity = children(f[3]!);
  const spkiT = f[5]!;
  const [spkiAlg, spkiBits] = children(spkiT);
  const curveOid = children(spkiAlg!)[1];
  const extensions = new Map<string, Uint8Array>();
  const extWrap = tbsKids.find((k) => k.tag === 0xa3);
  if (extWrap) {
    for (const ext of children(children(extWrap)[0]!)) {
      const parts = children(ext);
      extensions.set(oid(parts[0]!.value), parts[parts.length - 1]!.value);
    }
  }
  return {
    tbs: tbsT.raw,
    sigAlg: oid(children(algT)[0]!.value),
    signature: sigT.value.subarray(1), // BIT STRING: skip the unused-bits byte
    spki: spkiT.raw,
    curve: CURVES[curveOid ? oid(curveOid.value) : ""] ?? fail("cert: unsupported curve"),
    point: spkiBits!.value.subarray(1),
    notBefore: derTime(validity[0]!),
    notAfter: derTime(validity[1]!),
    extensions,
  };
}

export function pemToDer(pem: string): Uint8Array {
  return b64ToBytes(pem.replace(/-----[^-]+-----/g, "").replace(/\s+/g, ""));
}

/** DER ECDSA signature -> raw r||s, as Web Crypto wants it. */
function rawSig(der: Uint8Array, size: number): Uint8Array {
  const [r, s] = children(readTlv(der, 0));
  const fit = (x: Uint8Array) => {
    let v = x;
    while (v.length > size && v[0] === 0) v = v.subarray(1);
    if (v.length > size) fail("sig: bad integer");
    return concat(new Uint8Array(size - v.length), v);
  };
  return concat(fit(r!.value), fit(s!.value));
}

const SIZES: Record<string, number> = { "P-256": 32, "P-384": 48 };

async function verifyEcdsa(
  key: { spki: Uint8Array; curve: string } | { point: Uint8Array; curve: string },
  hash: string,
  derSignature: Uint8Array,
  data: Uint8Array,
): Promise<boolean> {
  const params = { name: "ECDSA", namedCurve: key.curve };
  const k =
    "spki" in key
      ? await crypto.subtle.importKey("spki", key.spki, params, false, ["verify"])
      : await crypto.subtle.importKey("raw", key.point, params, false, ["verify"]);
  try {
    return await crypto.subtle.verify({ name: "ECDSA", hash }, k, rawSig(derSignature, SIZES[key.curve]!), data);
  } catch {
    return false;
  }
}

async function verifyChain(certs: Cert[], root: Cert, nowMs: number): Promise<void> {
  const chain = [...certs, root];
  for (let i = 0; i < chain.length; i++) {
    const c = chain[i]!;
    if (nowMs < c.notBefore || nowMs > c.notAfter) fail("cert: expired or not yet valid");
    const issuer = chain[Math.min(i + 1, chain.length - 1)]!;
    const hash = HASHES[c.sigAlg] ?? fail("cert: unsupported signature");
    if (!(await verifyEcdsa(issuer, hash, c.signature, c.tbs))) fail("cert: bad signature");
  }
}

// ---------- authenticator data ----------

interface AuthData {
  rpIdHash: Uint8Array;
  counter: number;
  aaguid: string;
  credId: Uint8Array;
}

function parseAuthData(b: Uint8Array, withCred: boolean): AuthData {
  if (b.length < 37) fail("authData: too short");
  const counter = ((b[33]! << 24) >>> 0) + (b[34]! << 16) + (b[35]! << 8) + b[36]!;
  if (!withCred) return { rpIdHash: b.subarray(0, 32), counter, aaguid: "", credId: new Uint8Array() };
  if (b.length < 55) fail("authData: too short");
  const n = (b[53]! << 8) + b[54]!;
  if (b.length < 55 + n) fail("authData: truncated");
  return {
    rpIdHash: b.subarray(0, 32),
    counter,
    aaguid: new TextDecoder().decode(b.subarray(37, 53)),
    credId: b.subarray(55, 55 + n),
  };
}

// ---------- public API ----------

export interface AttestedKey {
  /** Uncompressed P-256 point, base64. */
  publicKey: string;
  counter: number;
  /** "production" or "development". */
  environment: string;
}

/**
 * Verifies an attestation object for `keyId` (base64 of the key's SHA-256),
 * where `clientData` is what the app hashed (see clientDataFor).
 */
export async function verifyAttestation(opts: {
  attestation: Uint8Array;
  keyId: string;
  clientData: Uint8Array;
  appId: string;
  allowDevelopment: boolean;
  nowMs: number;
  rootPem?: string;
}): Promise<AttestedKey> {
  const obj = decodeCbor(opts.attestation);
  if (!(obj instanceof Map)) return fail("attestation: not a map");
  if (obj.get("fmt") !== "apple-appattest") fail("attestation: wrong format");
  const stmt = obj.get("attStmt");
  const authData = obj.get("authData");
  if (!(stmt instanceof Map) || !(authData instanceof Uint8Array)) return fail("attestation: bad shape");
  const x5c = stmt.get("x5c");
  if (!Array.isArray(x5c) || x5c.length < 2 || !x5c.every((c) => c instanceof Uint8Array)) {
    return fail("attestation: no certificates");
  }
  const [leaf, ...rest] = (x5c as Uint8Array[]).map(parseCert);
  const root = parseCert(pemToDer(opts.rootPem ?? APPLE_APP_ATTEST_ROOT_PEM));
  // 1. The chain ends at Apple's App Attest root.
  await verifyChain([leaf!, ...rest], root, opts.nowMs);
  // 2-4. The leaf certificate carries SHA256(authData || SHA256(clientData)).
  const nonce = await sha256(concat(authData, await sha256(opts.clientData)));
  const ext = leaf!.extensions.get(NONCE_OID) ?? fail("attestation: no nonce");
  const seq = readTlv(ext, 0);
  const tagged = children(seq).find((c) => c.tag === 0xa1) ?? fail("attestation: bad nonce");
  const inner = readTlv(tagged.value, 0);
  if (!equal(inner.value, nonce)) fail("attestation: nonce mismatch");
  // 5. The key id is the hash of the leaf's public key.
  const keyId = b64ToBytes(opts.keyId);
  if (!equal(await sha256(leaf!.point), keyId)) fail("attestation: key id mismatch");
  // 6-9. Authenticator data: this app, counter 0, App Attest environment, same key.
  const ad = parseAuthData(authData, true);
  if (!equal(ad.rpIdHash, await sha256(utf8(opts.appId)))) fail("attestation: wrong app");
  if (ad.counter !== 0) fail("attestation: counter not zero");
  const env = ad.aaguid === AAGUID_PROD ? "production" : ad.aaguid === AAGUID_DEV ? "development" : fail("attestation: bad aaguid");
  if (env === "development" && !opts.allowDevelopment) fail("attestation: development key");
  if (!equal(ad.credId, keyId)) fail("attestation: credential mismatch");
  return { publicKey: bytesToB64(leaf!.point), counter: 0, environment: env };
}

/** Verifies an assertion made with a previously attested key; returns the new counter. */
export async function verifyAssertion(opts: {
  assertion: Uint8Array;
  clientData: Uint8Array;
  key: AttestedKey;
  appId: string;
}): Promise<number> {
  const obj = decodeCbor(opts.assertion);
  if (!(obj instanceof Map)) return fail("assertion: not a map");
  const signature = obj.get("signature");
  const authData = obj.get("authenticatorData");
  if (!(signature instanceof Uint8Array) || !(authData instanceof Uint8Array)) return fail("assertion: bad shape");
  const nonce = await sha256(concat(authData, await sha256(opts.clientData)));
  const ok = await verifyEcdsa({ point: b64ToBytes(opts.key.publicKey), curve: "P-256" }, "SHA-256", signature, nonce);
  if (!ok) fail("assertion: bad signature");
  const ad = parseAuthData(authData, false);
  if (!equal(ad.rpIdHash, await sha256(utf8(opts.appId)))) fail("assertion: wrong app");
  if (ad.counter <= opts.key.counter) fail("assertion: counter did not increase");
  return ad.counter;
}

/** What the app signs: the server's one-time challenge bound to the install id. */
export function clientDataFor(installId: string, challenge: string): Uint8Array {
  return utf8(`${installId}.${challenge}`);
}
