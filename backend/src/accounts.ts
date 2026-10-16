/** Optional accounts: Sign in with Google / Apple ID tokens are verified here
 * (RS256 against the provider's published keys), then mapped to our own
 * account id. We store no email or name, only a salted hash of the
 * provider's user id. */

export type AccountProvider = "google" | "apple";

const ISSUERS: Record<AccountProvider, string[]> = {
  google: ["https://accounts.google.com", "accounts.google.com"],
  apple: ["https://appleid.apple.com"],
};
const JWKS_URL: Record<AccountProvider, string> = {
  google: "https://www.googleapis.com/oauth2/v3/certs",
  apple: "https://appleid.apple.com/auth/keys",
};

interface Jwk { kid: string; kty: string; n: string; e: string; alg?: string }

function fromB64url(s: string): Uint8Array {
  const pad = "=".repeat((4 - (s.length % 4)) % 4);
  const bin = atob(s.replace(/-/g, "+").replace(/_/g, "/") + pad);
  return Uint8Array.from(bin, (c) => c.charCodeAt(0));
}
const dec = new TextDecoder();
const enc = new TextEncoder();

async function keysFor(provider: AccountProvider, kv: KVNamespace, fetchFn: typeof fetch): Promise<Jwk[]> {
  const cacheKey = `jwks:${provider}`;
  const cached = await kv.get(cacheKey);
  if (cached) return JSON.parse(cached) as Jwk[];
  const res = await fetchFn(JWKS_URL[provider]);
  if (!res.ok) return [];
  const keys = ((await res.json()) as { keys?: Jwk[] }).keys ?? [];
  await kv.put(cacheKey, JSON.stringify(keys), { expirationTtl: 3600 });
  return keys;
}

/** Returns the provider's user id (`sub`) if the token is valid for one of
 * our client ids, else null. Never throws. */
export async function verifyIdToken(
  provider: AccountProvider,
  token: string,
  audiences: string[],
  kv: KVNamespace,
  nowSeconds: number,
  fetchFn: typeof fetch = fetch,
): Promise<string | null> {
  try {
    if (audiences.length === 0) return null;
    const parts = token.split(".");
    if (parts.length !== 3) return null;
    const [h, p, s] = parts as [string, string, string];
    const header = JSON.parse(dec.decode(fromB64url(h))) as { alg?: string; kid?: string };
    if (header.alg !== "RS256" || !header.kid) return null;
    const jwk = (await keysFor(provider, kv, fetchFn)).find((k) => k.kid === header.kid);
    if (!jwk) return null;
    const key = await crypto.subtle.importKey(
      "jwk", { kty: jwk.kty, n: jwk.n, e: jwk.e, alg: "RS256", ext: true },
      { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" }, false, ["verify"],
    );
    const ok = await crypto.subtle.verify("RSASSA-PKCS1-v1_5", key, fromB64url(s), enc.encode(`${h}.${p}`));
    if (!ok) return null;
    const claims = JSON.parse(dec.decode(fromB64url(p))) as {
      iss?: string; aud?: string | string[]; exp?: number; iat?: number; sub?: string;
    };
    if (!claims.iss || !ISSUERS[provider].includes(claims.iss)) return null;
    const aud = Array.isArray(claims.aud) ? claims.aud : [claims.aud];
    if (!aud.some((a) => a && audiences.includes(a))) return null;
    if (typeof claims.exp !== "number" || claims.exp <= nowSeconds) return null;
    if (typeof claims.iat === "number" && claims.iat > nowSeconds + 300) return null;
    if (typeof claims.sub !== "string" || claims.sub === "") return null;
    return claims.sub;
  } catch {
    return null;
  }
}

export interface AccountStore {
  /** The account this install is signed in to, if any. */
  accountFor(installHash: string): Promise<string | null>;
  /** Whether this id is one of our account ids. */
  isAccount(id: string): Promise<boolean>;
  findOrCreate(provider: AccountProvider, subjectHash: string): Promise<string>;
  link(installHash: string, accountId: string): Promise<void>;
  unlink(installHash: string): Promise<void>;
  /** Deletes the account, every install link and its usage rows. */
  delete(accountId: string, usageKey: string): Promise<void>;
}

export class D1AccountStore implements AccountStore {
  constructor(private db: D1Database) {}

  async accountFor(installHash: string): Promise<string | null> {
    const r = await this.db.prepare("SELECT account_id FROM account_installs WHERE install_hash = ?1")
      .bind(installHash).first<{ account_id: string }>();
    return r?.account_id ?? null;
  }

  async isAccount(id: string): Promise<boolean> {
    return !!(await this.db.prepare("SELECT 1 AS x FROM accounts WHERE id = ?1").bind(id).first());
  }

  async findOrCreate(provider: AccountProvider, subjectHash: string): Promise<string> {
    const found = await this.db.prepare("SELECT id FROM accounts WHERE subject_hash = ?1")
      .bind(subjectHash).first<{ id: string }>();
    if (found) return found.id;
    const id = crypto.randomUUID();
    await this.db.prepare("INSERT INTO accounts (id, provider, subject_hash, created_at) VALUES (?1, ?2, ?3, ?4)")
      .bind(id, provider, subjectHash, new Date().toISOString()).run();
    return id;
  }

  async link(installHash: string, accountId: string): Promise<void> {
    await this.db.prepare(
      "INSERT INTO account_installs (install_hash, account_id, linked_at) VALUES (?1, ?2, ?3) " +
      "ON CONFLICT(install_hash) DO UPDATE SET account_id = excluded.account_id, linked_at = excluded.linked_at",
    ).bind(installHash, accountId, new Date().toISOString()).run();
  }

  async unlink(installHash: string): Promise<void> {
    await this.db.prepare("DELETE FROM account_installs WHERE install_hash = ?1").bind(installHash).run();
  }

  async delete(accountId: string, usageKey: string): Promise<void> {
    await this.db.batch([
      this.db.prepare("DELETE FROM account_installs WHERE account_id = ?1").bind(accountId),
      this.db.prepare("DELETE FROM usage WHERE install_hash = ?1").bind(usageKey),
      this.db.prepare("DELETE FROM accounts WHERE id = ?1").bind(accountId),
    ]);
  }
}

export const isAccountProvider = (v: unknown): v is AccountProvider => v === "google" || v === "apple";

export const audiencesFrom = (csv: string | undefined): string[] =>
  (csv ?? "").split(",").map((s) => s.trim()).filter(Boolean);
