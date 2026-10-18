// @ts-nocheck - uses Node built-ins (node:crypto) that the Workers tsconfig does not type.
import { generateKeyPairSync } from "node:crypto";
import { describe, expect, it } from "vitest";
import { clientSecret } from "../src/applesignin";
import { signToken } from "../src/auth";
import { createApp } from "../src/index";

class FakeKV {
  m = new Map<string, string>();
  async get(k: string) { return this.m.get(k) ?? null; }
  async put(k: string, v: string) { this.m.set(k, v); }
  async delete(k: string) { this.m.delete(k); }
}

const { privateKey, publicKey } = generateKeyPairSync("ec", { namedCurve: "P-256" });
const PEM = privateKey.export({ type: "pkcs8", format: "pem" }) as string;
const NOW = Date.UTC(2026, 9, 18);
const UUID = "5b0c4b7e-2f1a-4c55-9a7e-0d1f2e3a4b5c";

function setup(withKey: boolean) {
  const calls: { url: string; body: URLSearchParams }[] = [];
  const kv = new FakeKV();
  const links = new Map<string, string>();
  const accounts = {
    accountFor: async (h: string) => links.get(h) ?? null,
    isAccount: async () => true,
    findOrCreate: async () => "acct-1",
    link: async (h: string, id: string) => { links.set(h, id); },
    unlink: async (h: string) => { links.delete(h); },
    installsOf: async () => [],
    delete: async () => { links.clear(); },
  };
  const none = { deleteAllFor: async () => [], deleteAll: async () => {} };
  const deps = {
    now: () => NOW, accounts: () => accounts, credits: () => none, referrals: () => none, creator: () => none, shots: () => null,
    verifyIdToken: async (_p: string, t: string) => (t.startsWith("good:") ? t.slice(5) : null),
    appleFetch: async (url: string, init: RequestInit) => {
      calls.push({ url, body: new URLSearchParams(init.body as string) });
      return new Response(JSON.stringify({ refresh_token: "rt-1" }), { status: 200 });
    },
  };
  const env = {
    KV: kv, JWT_SECRET: "s".repeat(32), HASH_SALT: "salt", APPLE_CLIENT_IDS: "com.example.tarot",
    ...(withKey ? { APPLE_TEAM_ID: "TEAMID1234", APPLE_SIWA_KEY_ID: "KEY123", APPLE_SIWA_PRIVATE_KEY: PEM } : {}),
  };
  const app = createApp(deps as never);
  const post = async (path: string, body: unknown) => {
    const token = await signToken(UUID, env.JWT_SECRET, Math.floor(NOW / 1000));
    return app.request(path, { method: "POST", body: JSON.stringify(body), headers: { authorization: `Bearer ${token}` } }, env as never);
  };
  return { kv, calls, post, env };
}

describe("Sign in with Apple token revocation", () => {
  it("makes a client secret Apple can verify with the key", async () => {
    const s = setup(true);
    const jwt = await clientSecret(s.env as never, 1000);
    const [h, b, sig] = jwt.split(".");
    expect(JSON.parse(atob(h!))).toEqual({ alg: "ES256", kid: "KEY123" });
    expect(JSON.parse(atob(b!))).toMatchObject({ iss: "TEAMID1234", sub: "com.example.tarot", aud: "https://appleid.apple.com", exp: 1300 });
    const key = await crypto.subtle.importKey("spki", publicKey.export({ type: "spki", format: "der" }), { name: "ECDSA", namedCurve: "P-256" }, false, ["verify"]);
    const raw = Uint8Array.from(atob(sig!.replace(/-/g, "+").replace(/_/g, "/")), (c) => c.charCodeAt(0));
    expect(await crypto.subtle.verify({ name: "ECDSA", hash: "SHA-256" }, key, raw, new TextEncoder().encode(`${h}.${b}`))).toBe(true);
  });

  it("trades the code at sign-in and revokes the token when the account is deleted", async () => {
    const s = setup(true);
    expect((await s.post("/v1/account/signin", { provider: "apple", idToken: "good:sub", authorizationCode: "code-1" })).status).toBe(200);
    expect(s.calls[0]!.url).toBe("https://appleid.apple.com/auth/token");
    expect(s.calls[0]!.body.get("code")).toBe("code-1");
    expect(await s.kv.get("apple-rt:acct-1")).toBe("rt-1");
    expect((await s.post("/v1/account/delete", {})).status).toBe(200);
    expect(s.calls[1]!.url).toBe("https://appleid.apple.com/auth/revoke");
    expect(s.calls[1]!.body.get("token")).toBe("rt-1");
    expect(await s.kv.get("apple-rt:acct-1")).toBeNull();
  });

  it("signs in without calling Apple when no key is set", async () => {
    const s = setup(false);
    expect((await s.post("/v1/account/signin", { provider: "apple", idToken: "good:sub", authorizationCode: "code-1" })).status).toBe(200);
    expect(s.calls).toHaveLength(0);
  });
});
