// @ts-nocheck - uses Node built-ins (node:crypto, node:fs) that the Workers tsconfig does not type.
import { createHash, createPrivateKey, sign } from "node:crypto";
import { readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";
import { hashId } from "../src/auth";
import {
  APPLE_APP_ATTEST_ROOT_PEM, AttestError, b64ToBytes, bytesToB64, clientDataFor, decodeCbor, parseCert, pemToDer,
  verifyAssertion, verifyAttestation,
} from "../src/appattest";
import type { Env } from "../src/env";
import { createApp, type Deps } from "../src/index";

/** Made by test/fixtures/make-appattest.py: a fake chain with test-only keys. */
const fx = JSON.parse(readFileSync(new URL("./fixtures/appattest.json", import.meta.url), "utf8")) as {
  appId: string; installId: string; challenge: string; keyId: string; attestation: string; rootPem: string; leafPrivatePkcs8: string;
};
const NOW = Date.UTC(2027, 0, 1); // after the fixture certificates were made
const clientData = clientDataFor(fx.installId, fx.challenge);
const base = () => ({
  attestation: b64ToBytes(fx.attestation), keyId: fx.keyId, clientData, appId: fx.appId,
  allowDevelopment: false, nowMs: NOW, rootPem: fx.rootPem,
});

function cbor(v: Uint8Array | string | Record<string, Uint8Array>): Uint8Array {
  const head = (major: number, n: number) =>
    n < 24 ? [major << 5 | n] : n < 256 ? [major << 5 | 24, n] : [major << 5 | 25, n >> 8, n & 255];
  if (v instanceof Uint8Array) return new Uint8Array([...head(2, v.length), ...v]);
  if (typeof v === "string") { const b = new TextEncoder().encode(v); return new Uint8Array([...head(3, b.length), ...b]); }
  const parts = Object.entries(v).flatMap(([k, x]) => [...cbor(k), ...cbor(x)]);
  return new Uint8Array([...head(5, Object.keys(v).length), ...parts]);
}

/** An assertion as the iPhone makes it: signs SHA256(authData || SHA256(clientData)). */
function makeAssertion(counter: number, data: Uint8Array, appId = fx.appId): Uint8Array {
  const authData = Buffer.concat([
    createHash("sha256").update(appId).digest(), Buffer.from([0x40]), Buffer.from([0, 0, 0, counter]),
  ]);
  const nonce = createHash("sha256").update(Buffer.concat([authData, createHash("sha256").update(data).digest()])).digest();
  const signature = sign("sha256", nonce, createPrivateKey(fx.leafPrivatePkcs8));
  return cbor({ signature: new Uint8Array(signature), authenticatorData: new Uint8Array(authData) });
}

describe("App Attest parsing", () => {
  it("reads Apple's real root certificate", () => {
    const root = parseCert(pemToDer(APPLE_APP_ATTEST_ROOT_PEM));
    expect(root.curve).toBe("P-384");
    expect(root.notAfter).toBe(Date.parse("2045-03-15T00:00:00Z"));
  });
  it("rejects malformed CBOR", () => {
    expect(() => decodeCbor(new Uint8Array([0xa1]))).toThrow(AttestError);
    expect(() => decodeCbor(new Uint8Array([0x01, 0x02]))).toThrow(AttestError);
  });
});

describe("verifyAttestation", () => {
  it("accepts a valid attestation and returns the key", async () => {
    const key = await verifyAttestation(base());
    expect(key.environment).toBe("production");
    expect(key.counter).toBe(0);
    const point = b64ToBytes(key.publicKey);
    expect(bytesToB64(new Uint8Array(createHash("sha256").update(point).digest()))).toBe(fx.keyId);
  });
  it("rejects a chain that does not end at the expected root", async () => {
    await expect(verifyAttestation({ ...base(), rootPem: APPLE_APP_ATTEST_ROOT_PEM })).rejects.toThrow(AttestError);
  });
  it("rejects another app, another key, other client data and expired certificates", async () => {
    await expect(verifyAttestation({ ...base(), appId: "TEAMID1234.com.other.app" })).rejects.toThrow(/wrong app/);
    await expect(verifyAttestation({ ...base(), keyId: bytesToB64(new Uint8Array(32)) })).rejects.toThrow(/key id/);
    await expect(verifyAttestation({ ...base(), clientData: clientDataFor(fx.installId, "other") })).rejects.toThrow(/nonce/);
    await expect(verifyAttestation({ ...base(), nowMs: Date.UTC(2099, 0, 1) })).rejects.toThrow(/expired/);
  });
  it("rejects a tampered attestation", async () => {
    const bytes = b64ToBytes(fx.attestation);
    bytes[bytes.length - 40] ^= 1; // inside authData's key id
    await expect(verifyAttestation({ ...base(), attestation: bytes })).rejects.toThrow(AttestError);
  });
});

describe("verifyAssertion", () => {
  it("accepts a signed assertion with a higher counter and refuses replays", async () => {
    const key = await verifyAttestation(base());
    const data = clientDataFor(fx.installId, "c2");
    const counter = await verifyAssertion({ assertion: makeAssertion(1, data), clientData: data, key, appId: fx.appId });
    expect(counter).toBe(1);
    await expect(
      verifyAssertion({ assertion: makeAssertion(1, data), clientData: data, key: { ...key, counter }, appId: fx.appId }),
    ).rejects.toThrow(/counter/);
    await expect(
      verifyAssertion({ assertion: makeAssertion(2, data), clientData: clientDataFor(fx.installId, "c3"), key, appId: fx.appId }),
    ).rejects.toThrow(/signature/);
  });
});

class FakeKV {
  m = new Map<string, string>();
  async get(k: string) { return this.m.get(k) ?? null; }
  async put(k: string, v: string) { this.m.set(k, v); }
  async delete(k: string) { this.m.delete(k); }
}

describe("POST /v1/install with App Attest", () => {
  function setup(allowUnattested: boolean) {
    const kv = new FakeKV();
    const deps = { now: () => NOW, appAttestRoot: fx.rootPem } as unknown as Deps;
    const env = {
      KV: kv, JWT_SECRET: "s".repeat(32), HASH_SALT: "salt", APPLE_APP_ID: fx.appId,
      ALLOW_UNATTESTED_INSTALLS: allowUnattested ? "true" : undefined,
    } as unknown as Env;
    const app = createApp(deps);
    const post = (path: string, body: unknown) =>
      app.request(path, { method: "POST", body: JSON.stringify(body), headers: { "cf-connecting-ip": "9.9.9.9" } }, env);
    return { kv, post };
  }

  it("issues a token for a valid attestation even when unattested installs are off", async () => {
    const s = setup(false);
    await s.kv.put(`att-ch:${fx.challenge}`, "1");
    const res = await s.post("/v1/install", { installId: fx.installId, keyId: fx.keyId, challenge: fx.challenge, attestation: fx.attestation });
    expect(res.status).toBe(200);
    // The challenge is used up.
    const again = await s.post("/v1/install", { installId: fx.installId, keyId: fx.keyId, challenge: fx.challenge, attestation: fx.attestation });
    expect(again.status).toBe(403);
  });

  it("refreshes with an assertion; the install can no longer skip the proof", async () => {
    const s = setup(true);
    await s.kv.put(`att-ch:${fx.challenge}`, "1");
    expect((await s.post("/v1/install", { installId: fx.installId, keyId: fx.keyId, challenge: fx.challenge, attestation: fx.attestation })).status).toBe(200);
    const ch = (await (await s.post("/v1/install/challenge", {})).json()) as { challenge: string };
    const assertion = bytesToB64(makeAssertion(1, clientDataFor(fx.installId, ch.challenge)));
    expect((await s.post("/v1/install", { installId: fx.installId, keyId: fx.keyId, challenge: ch.challenge, assertion })).status).toBe(200);
    const stored = JSON.parse((await s.kv.get(`att:${await hashId(fx.installId, "salt")}`))!) as { counter: number };
    expect(stored.counter).toBe(1);
    // Even with unattested installs allowed, this install must keep proving it.
    expect((await s.post("/v1/install", { installId: fx.installId })).status).toBe(403);
  });

  it("refuses an unknown challenge and a forged attestation", async () => {
    const s = setup(true);
    expect((await s.post("/v1/install", { installId: fx.installId, keyId: fx.keyId, challenge: "nope", attestation: fx.attestation })).status).toBe(403);
    await s.kv.put(`att-ch:${fx.challenge}`, "1");
    const other = "6b0c4b7e-2f1a-4c55-9a7e-0d1f2e3a4b5c"; // attestation was made for a different install id
    expect((await s.post("/v1/install", { installId: other, keyId: fx.keyId, challenge: fx.challenge, attestation: fx.attestation })).status).toBe(403);
  });

  it("still allows unattested installs (Android, old builds) while the flag is on", async () => {
    const s = setup(true);
    expect((await s.post("/v1/install", { installId: "7b0c4b7e-2f1a-4c55-9a7e-0d1f2e3a4b5c" })).status).toBe(200);
    const off = setup(false);
    expect((await off.post("/v1/install", { installId: "7b0c4b7e-2f1a-4c55-9a7e-0d1f2e3a4b5c" })).status).toBe(501);
  });
});
