const enc = new TextEncoder();

export const TOKEN_TTL_SECONDS = 12 * 60 * 60;

function b64url(bytes: ArrayBuffer | Uint8Array): string {
  const arr = bytes instanceof Uint8Array ? bytes : new Uint8Array(bytes);
  let s = "";
  for (const b of arr) s += String.fromCharCode(b);
  return btoa(s).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

function fromB64url(s: string): Uint8Array {
  const pad = "=".repeat((4 - (s.length % 4)) % 4);
  const bin = atob(s.replace(/-/g, "+").replace(/_/g, "/") + pad);
  return Uint8Array.from(bin, (c) => c.charCodeAt(0));
}

async function hmacKey(secret: string, usage: "sign" | "verify"): Promise<CryptoKey> {
  return crypto.subtle.importKey("raw", enc.encode(secret), { name: "HMAC", hash: "SHA-256" }, false, [usage]);
}

/** HS256 JWT whose subject is the anonymous install ID. */
export async function signToken(installId: string, secret: string, nowSeconds: number): Promise<string> {
  const header = b64url(enc.encode(JSON.stringify({ alg: "HS256", typ: "JWT" })));
  const payload = b64url(enc.encode(JSON.stringify({ sub: installId, iat: nowSeconds, exp: nowSeconds + TOKEN_TTL_SECONDS })));
  const sig = await crypto.subtle.sign("HMAC", await hmacKey(secret, "sign"), enc.encode(`${header}.${payload}`));
  return `${header}.${payload}.${b64url(sig)}`;
}

/** Returns the install ID, or null if the token is malformed, forged or expired. */
export async function verifyToken(token: string, secret: string, nowSeconds: number): Promise<string | null> {
  const parts = token.split(".");
  if (parts.length !== 3) return null;
  const [header, payload, sig] = parts as [string, string, string];
  try {
    const ok = await crypto.subtle.verify(
      "HMAC", await hmacKey(secret, "verify"), fromB64url(sig), enc.encode(`${header}.${payload}`),
    );
    if (!ok) return null;
    const h = JSON.parse(new TextDecoder().decode(fromB64url(header)));
    if (h.alg !== "HS256") return null;
    const p = JSON.parse(new TextDecoder().decode(fromB64url(payload)));
    if (typeof p.sub !== "string" || typeof p.exp !== "number" || p.exp <= nowSeconds) return null;
    return p.sub;
  } catch {
    return null;
  }
}

/** Salted hash so the database never holds the raw install ID. */
export async function hashId(value: string, salt: string): Promise<string> {
  const digest = await crypto.subtle.digest("SHA-256", enc.encode(`${salt}:${value}`));
  return [...new Uint8Array(digest)].map((b) => b.toString(16).padStart(2, "0")).join("");
}
