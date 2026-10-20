/**
 * Sign in with Apple token revocation (App Store guideline 5.1.1(v): deleting
 * an account must revoke its Apple tokens). At sign-in the app's one-time
 * authorization code is traded for a refresh token, kept in KV; deleting the
 * account revokes it. Needs a Sign in with Apple key from the owner
 * (APPLE_TEAM_ID, APPLE_SIWA_KEY_ID, APPLE_SIWA_PRIVATE_KEY); without it this does nothing.
 */
import type { Env } from "./env";

const APPLE = "https://appleid.apple.com";
type Fetch = typeof fetch;

export const appleTokenKey = (accountId: string) => `apple-rt:${accountId}`;

export function siwaConfigured(env: Env): boolean {
  return !!(env.APPLE_TEAM_ID && env.APPLE_SIWA_KEY_ID && env.APPLE_SIWA_PRIVATE_KEY && env.APPLE_CLIENT_IDS);
}

const b64url = (b: Uint8Array | string) => {
  const bytes = typeof b === "string" ? new TextEncoder().encode(b) : b;
  let s = "";
  for (const x of bytes) s += String.fromCharCode(x);
  return btoa(s).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
};

/** The short-lived ES256 client secret Apple's token endpoints want. */
export async function clientSecret(env: Env, nowSeconds: number): Promise<string> {
  const clientId = env.APPLE_CLIENT_IDS!.split(",")[0]!.trim();
  const der = Uint8Array.from(
    atob(env.APPLE_SIWA_PRIVATE_KEY!.replace(/-----[^-]+-----/g, "").replace(/\s+/g, "")),
    (c) => c.charCodeAt(0),
  );
  const key = await crypto.subtle.importKey("pkcs8", der, { name: "ECDSA", namedCurve: "P-256" }, false, ["sign"]);
  const head = b64url(JSON.stringify({ alg: "ES256", kid: env.APPLE_SIWA_KEY_ID }));
  const body = b64url(JSON.stringify({ iss: env.APPLE_TEAM_ID, iat: nowSeconds, exp: nowSeconds + 300, aud: APPLE, sub: clientId }));
  const sig = await crypto.subtle.sign({ name: "ECDSA", hash: "SHA-256" }, key, new TextEncoder().encode(`${head}.${body}`));
  return `${head}.${body}.${b64url(new Uint8Array(sig))}`;
}

const form = (o: Record<string, string>) => new URLSearchParams(o).toString();

/** Trades the app's authorization code for a refresh token; null on any failure. */
export async function exchangeCode(env: Env, code: string, nowSeconds: number, f: Fetch = fetch): Promise<string | null> {
  try {
    const res = await f(`${APPLE}/auth/token`, {
      method: "POST",
      headers: { "content-type": "application/x-www-form-urlencoded" },
      body: form({
        client_id: env.APPLE_CLIENT_IDS!.split(",")[0]!.trim(),
        client_secret: await clientSecret(env, nowSeconds),
        code,
        grant_type: "authorization_code",
      }),
    });
    if (!res.ok) return null;
    const j = (await res.json()) as { refresh_token?: unknown };
    return typeof j.refresh_token === "string" ? j.refresh_token : null;
  } catch {
    return null;
  }
}

/** Revokes a refresh token. Returns whether Apple accepted it. */
export async function revokeToken(env: Env, token: string, nowSeconds: number, f: Fetch = fetch): Promise<boolean> {
  try {
    const res = await f(`${APPLE}/auth/revoke`, {
      method: "POST",
      headers: { "content-type": "application/x-www-form-urlencoded" },
      body: form({
        client_id: env.APPLE_CLIENT_IDS!.split(",")[0]!.trim(),
        client_secret: await clientSecret(env, nowSeconds),
        token,
        token_type_hint: "refresh_token",
      }),
    });
    return res.ok;
  } catch {
    return false;
  }
}
