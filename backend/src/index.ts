import { Hono } from "hono";
import { hashId, safeEqual, signToken, verifyToken } from "./auth";
import type { Env } from "./env";
import { callProvider, isAuthError, type LlmFn, type LlmParams, type LlmResult, type LlmTarget } from "./llm";
import { serverTargets, usageModel, userTarget } from "./route";
import { CRISIS_MESSAGE, detectCrisis } from "./knowledge";
import {
  DISCLAIMER, FOLLOWUP_MAX_TOKENS, FOLLOWUP_PROMPT_VERSION, FOLLOWUP_SYSTEM_PROMPT, buildFollowupMessage, checkOutput,
} from "./prompts";
import {
  readingMaxTokens, READING_PROMPT_VERSION, READING_SYSTEM_PROMPT, buildReadingMessage, fallbackReading,
  hitsBannedClaim, leaksOrClaimsHuman, parseModelReply, parseOffTopic, readingProblem, renderReading,
} from "./reading";
import { dominantScript, replyLanguage } from "./language";
import { detectOffTopic, offTopicMessage } from "./offtopic";
import { isPremium, premiumPlan } from "./revenuecat";
import { D1CreditStore, DAILY_BANK_DAYS, MONTHLY_BANK_MONTHS, WELCOME_CREDITS, creditsInProduct, type CreditStore } from "./credits";
import {
  CREDIT_DELAY_DAYS, D1ReferralStore, MAX_CREDITS_PER_YEAR, PLAY_REFERRAL_OFFER_TAG, REFERRAL_CREDITS,
  REFERRAL_CREDIT_FRIENDS_PER_YEAR, grantFreeMonth,
  hasStoreSubscription, newCode, normaliseCode, type ReferralStore,
} from "./referrals";
import {
  D1AccountStore, audiencesFrom, isAccountProvider, verifyIdToken, type AccountProvider, type AccountStore,
} from "./accounts";
import {
  BURST_PER_MINUTE, D1UsageStore, DEFAULT_GLOBAL_DAILY_TOKEN_CAP, FREE_READINGS_PER_DAY,
  DAILY_SPEND_GUARD, DEFAULT_PREMIUM_CREDITS, FREE_DAILY_CREDITS, IP_PER_MINUTE, PLAN_MONTHLY_CREDITS, allowWithinMinute, utcDay, type UsageStore,
} from "./usage";
import {
  CREATOR_CREDITS, CREATOR_MAX_PER_DAY, CREATOR_MAX_PER_MONTH, D1CreatorStore, LIKES_FOR_MONTH, MONTH_COOLDOWN_DAYS,
  MONTHS_PER_YEAR, R2ShotStorage, SCREENSHOT_KEEP_DAYS, SCREENSHOT_MAX_BYTES, SUBMIT_MAX_BODY_CHARS, decodeBase64,
  parsePostUrl, sniffImage, type CreatorStore, type ShotStorage,
} from "./creator";
import { isFreeSpread } from "./spreads";
import { isUuid, parseFollowupRequest, parseReadingRequest } from "./validate";
import { MAX_SPREAD_IMAGE_B64, SPREAD_PROMPT, SPREAD_SCANS_PER_DAY, callVision, isImageB64, parseSpread, type VisionFn } from "./spreadscan";
import { appleTokenKey, exchangeCode, revokeToken, siwaConfigured } from "./applesignin";
import { AttestError, b64ToBytes, bytesToB64, clientDataFor, verifyAssertion, verifyAttestation, type AttestedKey } from "./appattest";

export interface Deps {
  llm: LlmFn;
  usage: (env: Env) => UsageStore;
  /** `appUserId` is the RevenueCat app user id: the account id when signed in, else the install id. */
  premium: (appUserId: string, env: Env, nowMs: number) => Promise<boolean>;
  /** Monthly credits for a Premium user, by plan. */
  premiumMonthly?: (appUserId: string, env: Env, nowMs: number) => Promise<number>;
  now: () => number;
  accounts: (env: Env) => AccountStore;
  referrals: (env: Env) => ReferralStore;
  credits: (env: Env) => CreditStore;
  creator: (env: Env) => CreatorStore;
  /** Screenshot storage, or null when R2 is not bound. */
  shots: (env: Env) => ShotStorage | null;
  /** One free month of Premium (RevenueCat promotional entitlement). */
  grantMonth: (appUserId: string, env: Env) => Promise<boolean>;
  verifyIdToken: (provider: AccountProvider, token: string, audiences: string[], kv: KVNamespace, nowSeconds: number) => Promise<string | null>;
  /** Tests only: a stand-in for Apple's App Attest root certificate. */
  appAttestRoot?: string;
  /** Tests only: replaces fetch for calls to Apple's token endpoints. */
  appleFetch?: typeof fetch;
  /** Names the cards in a spread photo (Claude vision). */
  vision?: VisionFn;
  /** Sends an owner alert (ALERT_WEBHOOK_URL). Optional so tests can capture it. */
  alert?: (message: string, env: Env) => Promise<void>;
}

const defaultDeps: Deps = {
  llm: callProvider,
  usage: (env) => new D1UsageStore(env.DB),
  premium: async (id, env, now) =>
    testerIds(env).includes(id) || isPremium(id, env.REVENUECAT_SECRET_KEY, env.KV, now),
  premiumMonthly: async (id, env, now) => {
    if (testerIds(env).includes(id)) return DEFAULT_PREMIUM_CREDITS;
    const plan = await premiumPlan(id, env.REVENUECAT_SECRET_KEY, env.KV, now);
    return plan && plan !== "other" ? PLAN_MONTHLY_CREDITS[plan] : DEFAULT_PREMIUM_CREDITS;
  },
  now: () => Date.now(),
  accounts: (env) => new D1AccountStore(env.DB),
  referrals: (env) => new D1ReferralStore(env.DB),
  credits: (env) => new D1CreditStore(env.DB),
  creator: (env) => new D1CreatorStore(env.DB),
  shots: (env) => (env.SHOTS ? new R2ShotStorage(env.SHOTS) : null),
  grantMonth: async (appUserId, env) => (env.REVENUECAT_SECRET_KEY ? grantFreeMonth(appUserId, env.REVENUECAT_SECRET_KEY) : false),
  verifyIdToken: (p, t, a, kv, n) => verifyIdToken(p, t, a, kv, n),
};

const MAX_BODY_BYTES = 4096;

/** New install ids allowed per IP per UTC day while installs are unattested.
 * Generous on purpose: shared networks are not treated as abuse. */
export const NEW_INSTALLS_PER_IP_PER_DAY = 30;
/** Share of GLOBAL_DAILY_TOKEN_CAP at which the owner is alerted (once a day). */
export const TOKEN_ALERT_SHARE = 0.8;

/** Install requests carry an App Attest attestation (first time) or assertion (refresh). */
export interface InstallBody {
  installId?: unknown;
  keyId?: unknown;
  challenge?: unknown;
  attestation?: unknown;
  assertion?: unknown;
}

/** Attestation objects are about 5 KB as base64. */
export const MAX_INSTALL_BODY_BYTES = 16_384;
const ATTEST_CHALLENGE_TTL = 300;
/** Attested keys are kept a year past their last use. */
const ATTEST_KEY_TTL = 400 * 86_400;

/** "ok" when the request proves a genuine app on a real Apple device, "failed"
 * when it tried and the proof did not hold, "none" when it carried no proof. */
export async function checkAppAttest(
  env: Env, body: InstallBody, keyName: string, nowMs: number, rootPem?: string,
): Promise<"ok" | "failed" | "none"> {
  const { keyId, challenge, attestation, assertion } = body;
  if (typeof attestation !== "string" && typeof assertion !== "string") return "none";
  if (typeof keyId !== "string" || typeof challenge !== "string" || keyId.length > 100 || challenge.length > 100) {
    return "failed";
  }
  // Each challenge works once.
  const chKey = `att-ch:${challenge}`;
  if (!(await env.KV.get(chKey))) return "failed";
  await env.KV.delete(chKey);
  const appId = env.APPLE_APP_ID!;
  const clientData = clientDataFor(body.installId as string, challenge);
  try {
    let key: AttestedKey;
    if (typeof attestation === "string") {
      key = await verifyAttestation({
        attestation: b64ToBytes(attestation), keyId, clientData, appId,
        allowDevelopment: env.APP_ATTEST_ALLOW_DEVELOPMENT === "true", nowMs, rootPem,
      });
    } else {
      const stored = await env.KV.get(keyName);
      if (!stored) return "failed";
      const saved = JSON.parse(stored) as AttestedKey & { keyId: string };
      if (saved.keyId !== keyId) return "failed";
      const counter = await verifyAssertion({ assertion: b64ToBytes(assertion as string), clientData, key: saved, appId });
      key = { ...saved, counter };
    }
    await env.KV.put(keyName, JSON.stringify({ ...key, keyId }), { expirationTtl: ATTEST_KEY_TTL });
    return "ok";
  } catch (e) {
    if (e instanceof AttestError) {
      console.warn(`app attest: ${e.message}`);
      return "failed";
    }
    throw e;
  }
}

/** Free AI readings a day without Premium: fewer for guests, to encourage
 * sign-in, but only once sign-in is offered (otherwise guests keep the full amount). */
export const GUEST_READINGS_PER_DAY = 1;
export function freeReadingsFor(env: Env, accountId: string | null | undefined): number {
  const signInOffered = !!(env.APPLE_CLIENT_IDS || env.GOOGLE_CLIENT_IDS);
  return accountId || !signInOffered ? FREE_READINGS_PER_DAY : GUEST_READINGS_PER_DAY;
}

/** The owner's release-test key (QA_TOKEN secret, at least 24 characters). */
export const isQa = (env: Env, header: string | undefined): boolean =>
  !!env.QA_TOKEN && env.QA_TOKEN.length >= 24 && !!header && safeEqual(header, env.QA_TOKEN);

/** KV, not atomic: a brake on scripted install farming, not an exact count. */
export async function allowNewInstall(env: Env, installId: string, ip: string, nowMs: number): Promise<boolean> {
  const seenKey = `seen:${await hashId(installId, env.HASH_SALT)}`;
  if (await env.KV.get(seenKey)) return true;
  const dayKey = `ip-new:${await hashId(ip, env.HASH_SALT)}:${utcDay(nowMs)}`;
  const n = Number((await env.KV.get(dayKey)) ?? "0");
  if (n >= NEW_INSTALLS_PER_IP_PER_DAY) return false;
  await env.KV.put(dayKey, String(n + 1), { expirationTtl: 2 * 86_400 });
  await env.KV.put(seenKey, "1", { expirationTtl: 30 * 86_400 });
  return true;
}

/** Posts a plain-text message to ALERT_WEBHOOK_URL (e.g. a Discord/Slack/ntfy
 * webhook the owner chose). Without it, the warning is only in the Worker logs. */
async function postAlert(message: string, env: Env): Promise<void> {
  console.warn(`ALERT: ${message}`);
  if (!env.ALERT_WEBHOOK_URL) return;
  try {
    await fetch(env.ALERT_WEBHOOK_URL, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ text: message, content: message }),
    });
  } catch {
    // An alert failure must never break a reading.
  }
}

/** Alerts once per UTC day when server-paid tokens reach TOKEN_ALERT_SHARE of the cap. */
export async function alertTokenUsage(
  env: Env, used: number, cap: number, day: string, send: (m: string, e: Env) => Promise<void> = postAlert,
): Promise<void> {
  if (used < cap * TOKEN_ALERT_SHARE) return;
  const key = `alert:tokens:${day}`;
  if (await env.KV.get(key)) return;
  await env.KV.put(key, "1", { expirationTtl: 2 * 86_400 });
  await send(`ShenTarot used ${used} of ${cap} AI tokens today (${day}). At the cap, readings pause until 00:00 UTC.`, env);
}

/** Install or account ids treated as Premium for testing before store
 * products exist (TESTER_INSTALL_IDS, comma-separated). Only honoured on beta
 * deployments (ALLOW_UNATTESTED_INSTALLS=true), so a production Worker, which
 * must run with attestation, can never grant Premium this way even if the
 * variable is left set. `scripts/release-check.sh` also refuses to deploy with it. */
export const testerIds = (env: Env): string[] =>
  env.ALLOW_UNATTESTED_INSTALLS === "true"
    ? (env.TESTER_INSTALL_IDS ?? "").split(",").map((s) => s.trim()).filter(Boolean)
    : [];

export function createApp(deps: Deps = defaultDeps) {
  const app = new Hono<{ Bindings: Env }>();

  /** One credit buys a reading or a follow-up. Everyone receives 2 credits the
   * first time they use the app each UTC day; Premium also receives monthly
   * credits by plan (annual 150, 3 months 120, monthly 90) the first time in each
   * UTC month. Unused credits roll over and never expire, with a bank of 10
   * days' worth of daily and 2 months' worth of monthly credits. No one can spend
   * more than 50 credits a day. Before the wallet is switched on
   * (CREDITS_ENABLED), free gets 2 readings a day and Premium up to 50. */
  type Charge = { ok: true; lot: number | null } | { ok: false; limit: number };
  const walletOn = (env: Env) => env.CREDITS_ENABLED === "true";
  const monthlyFor = async (who: { appUserId: string }, env: Env, premium: boolean, now: number) =>
    premium ? await (deps.premiumMonthly?.(who.appUserId, env, now) ?? DEFAULT_PREMIUM_CREDITS) : 0;
  const spentToday = async (usage: UsageStore, key: string, day: string) =>
    (await usage.count(key, day, "reading")) + (await usage.count(key, day, "followup"));
  /** Grants today's daily credits and, for Premium, this month's; returns how many were added. */
  const grantCredits = async (who: { appUserId: string; usageKey: string }, env: Env, premium: boolean, day: string, now: number) => {
    const store = deps.credits(env);
    // One-time welcome gift per owner (the txn id makes it idempotent).
    let granted = (await store.add(who.usageKey, WELCOME_CREDITS, `welcome:${who.usageKey}`, "welcome")) ? WELCOME_CREDITS : 0;
    granted += await store.claimDaily(who.usageKey, day, FREE_DAILY_CREDITS, FREE_DAILY_CREDITS * DAILY_BANK_DAYS);
    const monthly = await monthlyFor(who, env, premium, now);
    if (monthly > 0) granted += await store.claimMonthly(who.usageKey, day.slice(0, 7), monthly, monthly * MONTHLY_BANK_MONTHS);
    return granted;
  };
  /** The friend finished their first reading: both sides get credits, once. */
  const rewardReferral = async (who: { usageKey: string }, env: Env, now: number) => {
    if (!walletOn(env) || env.REFERRALS_ENABLED !== "true") return;
    const refs = deps.referrals(env);
    const iso = new Date(now).toISOString();
    const since = new Date(now - 365 * 86_400_000).toISOString();
    const won = await refs.claimReadingReward(who.usageKey, iso, since, REFERRAL_CREDIT_FRIENDS_PER_YEAR);
    if (!won) return;
    const store = deps.credits(env);
    await store.add(who.usageKey, REFERRAL_CREDITS, `ref-friend:${who.usageKey}`, "referral");
    if (won.rewardReferrer) await store.add(won.referrerKey, REFERRAL_CREDITS, `ref-referrer:${who.usageKey}`, "referral");
  };
  const charge = async (who: { appUserId: string; usageKey: string; accountId?: string | null }, env: Env, premium: boolean, usage: UsageStore, day: string, now: number): Promise<Charge> => {
    const used = await spentToday(usage, who.usageKey, day);
    if (!walletOn(env)) {
      const limit = premium ? DAILY_SPEND_GUARD : freeReadingsFor(env, who.accountId);
      return used < limit ? { ok: true, lot: null } : { ok: false, limit };
    }
    if (used >= DAILY_SPEND_GUARD) return { ok: false, limit: DAILY_SPEND_GUARD };
    await grantCredits(who, env, premium, day, now);
    const lot = await deps.credits(env).spend(who.usageKey);
    return lot === null ? { ok: false, limit: DAILY_SPEND_GUARD } : { ok: true, lot };
  };

  app.get("/health", (c) => c.json({ ok: true }));

  /** Who is asking: limits and Premium follow the account when this install
   * is signed in, else the install. */
  async function identity(env: Env, installId: string) {
    const installHash = await hashId(installId, env.HASH_SALT);
    const accountId = await deps.accounts(env).accountFor(installHash);
    const usageKey = accountId ? await hashId(`acct:${accountId}`, env.HASH_SALT) : installHash;
    return { installHash, accountId, usageKey, appUserId: accountId ?? installId };
  }

  async function installFrom(authHeader: string | undefined, env: Env, now: number): Promise<string | null> {
    const auth = authHeader ?? "";
    const token = auth.startsWith("Bearer ") ? auth.slice(7) : "";
    return token ? await verifyToken(token, env.JWT_SECRET, Math.floor(now / 1000)) : null;
  }

  // One-time challenge for App Attest (iOS device proof), valid 5 minutes.
  app.post("/v1/install/challenge", async (c) => {
    const ip = c.req.header("cf-connecting-ip") ?? "unknown";
    if (!(await allowWithinMinute(c.env.KV, `ip-install:${ip}`, 10, deps.now()))) {
      return c.json({ error: "rate_limited" }, 429);
    }
    if (!c.env.APPLE_APP_ID) return c.json({ error: "attestation_not_configured" }, 501);
    const challenge = bytesToB64(crypto.getRandomValues(new Uint8Array(32)));
    await c.env.KV.put(`att-ch:${challenge}`, "1", { expirationTtl: ATTEST_CHALLENGE_TTL });
    return c.json({ challenge });
  });

  // Anonymous install -> short-lived token.
  app.post("/v1/install", async (c) => {
    const ip = c.req.header("cf-connecting-ip") ?? "unknown";
    if (!(await allowWithinMinute(c.env.KV, `ip-install:${ip}`, 10, deps.now()))) {
      return c.json({ error: "rate_limited" }, 429);
    }
    const body = (await readJson(c.req.raw, MAX_INSTALL_BODY_BYTES)) as InstallBody | null;
    if (!body || !isUuid(body.installId)) {
      return c.json({ error: "invalid_request" }, 400);
    }
    const installId = body.installId;
    const keyName = `att:${await hashId(installId, c.env.HASH_SALT)}`;
    // App Attest (iOS): a valid attestation or assertion skips the unattested rules.
    const proof = c.env.APPLE_APP_ID ? await checkAppAttest(c.env, body, keyName, deps.now(), deps.appAttestRoot) : "none";
    if (proof === "failed") return c.json({ error: "attestation_failed" }, 403);
    if (proof === "none") {
      // An install that once attested must keep proving it with its key.
      if (c.env.APPLE_APP_ID && (await c.env.KV.get(keyName))) {
        return c.json({ error: "attestation_required" }, 403);
      }
      // TODO(owner): Play Integrity (Android). Until then unattested installs
      // are refused unless ALLOW_UNATTESTED_INSTALLS is set.
      if (c.env.ALLOW_UNATTESTED_INSTALLS !== "true") {
        return c.json({ error: "attestation_not_configured" }, 501);
      }
      // At most NEW_INSTALLS_PER_IP_PER_DAY new unattested install ids per IP
      // per UTC day. Known installs (token refresh) pass.
      if (!isQa(c.env, c.req.header("x-qa-token")) && !(await allowNewInstall(c.env, installId, ip, deps.now()))) {
        return c.json({ error: "rate_limited" }, 429);
      }
    }
    const token = await signToken(installId, c.env.JWT_SECRET, Math.floor(deps.now() / 1000));
    return c.json({ token });
  });

  // A photo of a whole spread: Claude names the cards. The image goes to the
  // model once and is never stored or logged; no reading credit is used.
  app.post("/v1/scan/spread", async (c) => {
    const now = deps.now();
    const installId = await installFrom(c.req.header("authorization"), c.env, now);
    if (!installId) return c.json({ error: "unauthorized" }, 401);
    const who = await identity(c.env, installId);
    if (!(await allowWithinMinute(c.env.KV, `burst:${who.installHash}`, BURST_PER_MINUTE, now))) {
      return c.json({ error: "rate_limited" }, 429);
    }
    const body = (await readJson(c.req.raw, MAX_SPREAD_IMAGE_B64 + 200)) as { image?: unknown; mediaType?: unknown } | null;
    const mediaType = body?.mediaType === "image/png" ? "image/png" : "image/jpeg";
    if (!body || !isImageB64(body.image)) return c.json({ error: "invalid_request" }, 400);
    const day = utcDay(now);
    const capKey = `spread:${who.usageKey}:${day}`;
    const done = Number((await c.env.KV.get(capKey)) ?? "0");
    if (done >= SPREAD_SCANS_PER_DAY) return c.json({ error: "daily_limit", limit: SPREAD_SCANS_PER_DAY }, 429);
    // VISION_MODEL picks the Anthropic model for photos (default: the reading model).
    const targets = serverTargets(c.env).map((t) =>
      t.provider === "anthropic" && c.env.VISION_MODEL ? { ...t, model: c.env.VISION_MODEL } : t);
    if (targets.length === 0) return c.json({ error: "service_busy" }, 503);
    const usage = deps.usage(c.env);
    const cap = Number(c.env.GLOBAL_DAILY_TOKEN_CAP ?? DEFAULT_GLOBAL_DAILY_TOKEN_CAP);
    if ((await usage.tokensToday(day)) >= cap) return c.json({ error: "service_busy" }, 503);
    await c.env.KV.put(capKey, String(done + 1), { expirationTtl: 2 * 86_400 });
    // Same provider order as readings, with one fallback.
    for (const target of targets.slice(0, 2)) {
      const slot = await usage.reserve(who.usageKey, day, "spread_scan", "single", target.model);
      try {
        const r = await (deps.vision ?? callVision)(body.image, mediaType, SPREAD_PROMPT, target);
        await usage.finalize(slot, r.inputTokens, r.outputTokens);
        const found = parseSpread(r.text);
        if (found.cards.length === 0) console.warn(`spread scan: no cards (${r.text.length} chars, ${r.outputTokens} out)`);
        return c.json(found);
      } catch (e) {
        console.warn(`spread scan failed (${target.provider}): ${(e as Error)?.message ?? e}`);
        await usage.release(slot);
      }
    }
    return c.json({ error: "service_busy" }, 503);
  });

  app.post("/v1/reading", async (c) => {
    const now = deps.now();
    const auth = c.req.header("authorization") ?? "";
    const token = auth.startsWith("Bearer ") ? auth.slice(7) : "";
    const installId = token ? await verifyToken(token, c.env.JWT_SECRET, Math.floor(now / 1000)) : null;
    if (!installId) return c.json({ error: "unauthorized" }, 401);

    const who = await identity(c.env, installId);
    const installHash = who.installHash;
    const ip = c.req.header("cf-connecting-ip") ?? "unknown";
    if (
      !isQa(c.env, c.req.header("x-qa-token")) &&
      (!(await allowWithinMinute(c.env.KV, `burst:${installHash}`, BURST_PER_MINUTE, now)) ||
        !(await allowWithinMinute(c.env.KV, `ip:${await hashId(ip, c.env.HASH_SALT)}`, IP_PER_MINUTE, now)))
    ) {
      return c.json({ error: "rate_limited" }, 429);
    }

    const user = userTarget(c.req.header("x-user-provider"), c.req.header("x-user-key"));
    if (!user.ok) return c.json({ error: "invalid_user_key" }, 400);
    const targets = user.target ? [user.target] : serverTargets(c.env);
    if (targets.length === 0) return c.json({ error: "service_busy" }, 503);

    const body = await readJson(c.req.raw);
    const parsed = parseReadingRequest(body);
    if (!parsed.ok) return c.json({ error: "invalid_request", detail: parsed.error }, 400);
    const req = parsed.value;

    // Fixed care reply, no model call, nothing logged or counted.
    if (detectCrisis(req.question, req.impression)) {
      return c.json({ crisis: true, message: CRISIS_MESSAGE });
    }
    // Plainly off-topic (about the AI, maths, code, injection): a fixed
    // redirect, no model call, nothing charged.
    if (detectOffTopic(req.question)) {
      return c.json({ off_topic: true, message: offTopicMessage(req.question, req.lang) });
    }

    const premium = await deps.premium(who.appUserId, c.env, now);
    const usage = deps.usage(c.env);
    // Longer spreads are Premium, with one free trial reading per install.
    if (!isFreeSpread(req.spread) && !premium) {
      if ((await usage.countTrial(who.usageKey)) > 0) {
        return c.json({ error: "premium_required" }, 402);
      }
    }
    const day = utcDay(now);
    const cap = Number(c.env.GLOBAL_DAILY_TOKEN_CAP ?? DEFAULT_GLOBAL_DAILY_TOKEN_CAP);
    if (!user.target) {
      const used = await usage.tokensToday(day);
      if (used >= cap) return c.json({ error: "service_busy" }, 503);
      await alertTokenUsage(c.env, used, cap, day, deps.alert);
    }

    // Own-key mode is a Premium feature (bought through the store): the user's
    // key pays the AI provider, so there is no daily reading cap, only the
    // per-minute brakes above. Everything else (crisis check, prompt rules,
    // output checks) is the same on both paths.
    if (user.target && !premium) return c.json({ error: "premium_required" }, 402);
    // One credit per reading: daily credits first, then bonus credits.
    let creditLot: number | null = null;
    // The owner's release test (scripts/quality-check.mjs) is not charged.
    if (!user.target && !isQa(c.env, c.req.header("x-qa-token"))) {
      const paid = await charge(who, c.env, premium, usage, day, now);
      if (!paid.ok) return c.json({ error: "daily_limit", premium, limit: paid.limit, guest: !premium && paid.limit === GUEST_READINGS_PER_DAY && !who.accountId }, 429);
      creditLot = paid.lot;
    }

    const slot = await usage.reserve(who.usageKey, day, "reading", req.spread, usageModel(targets[0]!));
    /** Not the user's fault: give back the reading and the credit. */
    const noCharge = async () => {
      await usage.release(slot);
      if (creditLot !== null) await deps.credits(c.env).refund(creditLot);
    };
    try {
      const params = { system: READING_SYSTEM_PROMPT, user: buildReadingMessage(req), maxTokens: readingMaxTokens(req.spread) };
      let inTok = 0;
      let outTok = 0;
      let structured: ReturnType<typeof parseModelReply> = null;
      let plain: string | null = null;
      let problem = "";
      // One retry when the reply fails a check (format, language, leaks).
      for (let attempt = 0; attempt < 2; attempt++) {
        const result = await callWithFallback(deps.llm, params, targets);
        inTok += result.inputTokens;
        outTok += result.outputTokens;
        if (result.refused) {
          await usage.finalize(slot, inTok, outTok);
          return c.json({ error: "declined" }, 422);
        }
        const redirect = parseOffTopic(result.text);
        if (redirect !== null || /"off_topic"\s*:\s*true/.test(result.text)) {
          console.log(JSON.stringify({ event: "off_topic", prompt: READING_PROMPT_VERSION, in: inTok, out: outTok }));
          // Tokens stay in the budget; the row stops counting as a reading.
          await usage.finalize(slot, inTok, outTok);
          await usage.relabel(slot, "off_topic");
          if (creditLot !== null) await deps.credits(c.env).refund(creditLot);
          return c.json({ off_topic: true, message: redirect ?? offTopicMessage(req.question, req.lang) });
        }
        structured = parseModelReply(result.text, req);
        if (structured?.crisis) {
          await usage.finalize(slot, inTok, outTok);
          return c.json({ crisis: true, message: CRISIS_MESSAGE });
        }
        if (structured) {
          const p = readingProblem(structured, req);
          if (p === null && !hitsBannedClaim(renderReading(structured))) break;
          problem = p ?? "banned_claim";
          structured = null;
        } else {
          // The model ignored the JSON format: a clean plain-text reply in the
          // right language is still acceptable.
          const out = checkOutput(result.text);
          if (out.ok && !hitsBannedClaim(out.text) && !leaksOrClaimsHuman(out.text) &&
              dominantScript(out.text) === replyLanguage(req.lang ?? "en", req.question).script) {
            plain = out.text;
            break;
          }
          problem = "format";
        }
        console.log(JSON.stringify({ event: "reading_check_failed", attempt, problem, prompt: READING_PROMPT_VERSION }));
      }
      if (!structured && plain === null) {
        // Both tries failed: a reading from stored card text, and no charge.
        await noCharge();
        await rewardReferral(who, c.env, now);
        return c.json({ reading: fallbackReading(req), structured: null, fallback: true, disclaimer: DISCLAIMER });
      }
      await usage.finalize(slot, inTok, outTok);
      await rewardReferral(who, c.env, now);
      return c.json({
        reading: structured ? renderReading(structured) : plain,
        structured,
        fallback: false,
        disclaimer: DISCLAIMER,
      });
    } catch (e) {
      await noCharge();
      if (user.target && isAuthError(e)) return c.json({ error: "user_key_rejected" }, 400);
      logUpstreamError(e);
      return c.json({ error: "upstream_failed" }, 502);
    }
  });

  // Follow-up question about an earlier reading. Premium only. The server does
  // not store readings, so the app sends the earlier text back as context,
  // which is treated as untrusted.
  app.post("/v1/followup", async (c) => {
    const now = deps.now();
    const auth = c.req.header("authorization") ?? "";
    const token = auth.startsWith("Bearer ") ? auth.slice(7) : "";
    const installId = token ? await verifyToken(token, c.env.JWT_SECRET, Math.floor(now / 1000)) : null;
    if (!installId) return c.json({ error: "unauthorized" }, 401);

    const who = await identity(c.env, installId);
    const installHash = who.installHash;
    const ip = c.req.header("cf-connecting-ip") ?? "unknown";
    if (
      !(await allowWithinMinute(c.env.KV, `burst:${installHash}`, BURST_PER_MINUTE, now)) ||
      !(await allowWithinMinute(c.env.KV, `ip:${await hashId(ip, c.env.HASH_SALT)}`, IP_PER_MINUTE, now))
    ) {
      return c.json({ error: "rate_limited" }, 429);
    }

    const user = userTarget(c.req.header("x-user-provider"), c.req.header("x-user-key"));
    if (!user.ok) return c.json({ error: "invalid_user_key" }, 400);
    const targets = user.target ? [user.target] : serverTargets(c.env);
    if (targets.length === 0) return c.json({ error: "service_busy" }, 503);

    const parsed = parseFollowupRequest(await readJson(c.req.raw, 16384));
    if (!parsed.ok) return c.json({ error: "invalid_request", detail: parsed.error }, 400);
    const req = parsed.value;

    if (detectCrisis(req.followup, req.question)) return c.json({ crisis: true, message: CRISIS_MESSAGE });

    let followupLot: number | null = null;
    const premium = await deps.premium(who.appUserId, c.env, now);
    if (user.target && !premium) return c.json({ error: "premium_required" }, 402);

    const usage = deps.usage(c.env);
    const day = utcDay(now);
    const cap = Number(c.env.GLOBAL_DAILY_TOKEN_CAP ?? DEFAULT_GLOBAL_DAILY_TOKEN_CAP);
    if (!user.target) {
      const used = await usage.tokensToday(day);
      if (used >= cap) return c.json({ error: "service_busy" }, 503);
      await alertTokenUsage(c.env, used, cap, day, deps.alert);
    }
    // One credit per follow-up, same as a reading: daily credits, then bonus credits.
    if (!user.target) {
      const paid = await charge(who, c.env, premium, usage, day, now);
      if (!paid.ok) {
        return premium
          ? c.json({ error: "daily_limit", premium: true, limit: paid.limit }, 429)
          : c.json({ error: "premium_required" }, 402);
      }
      followupLot = paid.lot;
    }

    const slot = await usage.reserve(who.usageKey, day, "followup", req.spread, usageModel(targets[0]!));
    const noCharge = async () => {
      await usage.release(slot);
      if (followupLot !== null) await deps.credits(c.env).refund(followupLot);
    };
    try {
      const want = replyLanguage(req.lang ?? "en", req.followup).script;
      let inTok = 0;
      let outTok = 0;
      for (let attempt = 0; attempt < 2; attempt++) {
        const result = await callWithFallback(
          deps.llm,
          { system: FOLLOWUP_SYSTEM_PROMPT, user: buildFollowupMessage(req), maxTokens: FOLLOWUP_MAX_TOKENS },
          targets,
        );
        inTok += result.inputTokens;
        outTok += result.outputTokens;
        if (result.refused) {
          await usage.finalize(slot, inTok, outTok);
          return c.json({ error: "declined" }, 422);
        }
        const checked = checkOutput(result.text);
        const script = checked.ok ? dominantScript(checked.text) : "none";
        const langOk = script === want || (want === "kana" && script === "cjk");
        if (checked.ok && langOk && !leaksOrClaimsHuman(checked.text) && !hitsBannedClaim(checked.text)) {
          await usage.finalize(slot, inTok, outTok);
          return c.json({ answer: checked.text, disclaimer: DISCLAIMER });
        }
        console.log(JSON.stringify({ event: "followup_check_failed", attempt, prompt: FOLLOWUP_PROMPT_VERSION }));
      }
      await noCharge();
      return c.json({ error: "bad_output" }, 502);
    } catch (e) {
      await noCharge();
      if (user.target && isAuthError(e)) return c.json({ error: "user_key_rejected" }, 400);
      logUpstreamError(e);
      return c.json({ error: "upstream_failed" }, 502);
    }
  });

  // Optional accounts. The app signs in with Google or Apple, sends the ID
  // token here, and this install is linked to our account id. No email or
  // name is stored.
  app.post("/v1/account/signin", async (c) => {
    const now = deps.now();
    const installId = await installFrom(c.req.header("authorization"), c.env, now);
    if (!installId) return c.json({ error: "unauthorized" }, 401);
    const ip = c.req.header("cf-connecting-ip") ?? "unknown";
    if (!(await allowWithinMinute(c.env.KV, `signin:${await hashId(ip, c.env.HASH_SALT)}`, 10, now))) {
      return c.json({ error: "rate_limited" }, 429);
    }
    const body = (await readJson(c.req.raw)) as { provider?: unknown; idToken?: unknown; authorizationCode?: unknown } | null;
    if (!body || !isAccountProvider(body.provider) || typeof body.idToken !== "string" || body.idToken.length > 4096) {
      return c.json({ error: "invalid_request" }, 400);
    }
    const provider = body.provider;
    const audiences = audiencesFrom(provider === "google" ? c.env.GOOGLE_CLIENT_IDS : c.env.APPLE_CLIENT_IDS);
    if (audiences.length === 0) return c.json({ error: "accounts_not_configured" }, 503);
    const subject = await deps.verifyIdToken(provider, body.idToken, audiences, c.env.KV, Math.floor(now / 1000));
    if (!subject) return c.json({ error: "invalid_token" }, 401);
    const store = deps.accounts(c.env);
    const accountId = await store.findOrCreate(provider, await hashId(`${provider}:${subject}`, c.env.HASH_SALT));
    const installHash = await hashId(installId, c.env.HASH_SALT);
    await store.link(installHash, accountId);
    // Keep an Apple refresh token so deleting the account can revoke it.
    if (provider === "apple" && siwaConfigured(c.env) && typeof body.authorizationCode === "string" && body.authorizationCode.length < 1024) {
      const rt = await exchangeCode(c.env, body.authorizationCode, Math.floor(now / 1000), deps.appleFetch);
      if (rt) await c.env.KV.put(appleTokenKey(accountId), rt);
    }
    // Signing in keeps the credits earned on this install.
    if (c.env.CREDITS_ENABLED === "true") {
      await deps.credits(c.env).move(installHash, await hashId(`acct:${accountId}`, c.env.HASH_SALT));
    }
    return c.json({ accountId, provider });
  });

  app.post("/v1/account/signout", async (c) => {
    const installId = await installFrom(c.req.header("authorization"), c.env, deps.now());
    if (!installId) return c.json({ error: "unauthorized" }, 401);
    await deps.accounts(c.env).unlink(await hashId(installId, c.env.HASH_SALT));
    return c.json({ ok: true });
  });

  // Deletes the signed-in account, all its device links and its usage rows.
  // A store subscription is not cancelled by this; the app tells the user.
  app.post("/v1/account/delete", async (c) => {
    const installId = await installFrom(c.req.header("authorization"), c.env, deps.now());
    if (!installId) return c.json({ error: "unauthorized" }, 401);
    const who = await identity(c.env, installId);
    if (!who.accountId) return c.json({ error: "not_signed_in" }, 400);
    // Everything held for the account and for every install signed in to it:
    // credits, referral records, creator posts and their screenshots, usage.
    const accounts = deps.accounts(c.env);
    const keys = [...new Set([who.usageKey, ...(await accounts.installsOf(who.accountId))])];
    const shots = deps.shots(c.env);
    for (const key of keys) {
      for (const shot of await deps.creator(c.env).deleteAllFor(key)) await shots?.delete(shot);
      await deps.credits(c.env).deleteAll(key);
      await deps.referrals(c.env).deleteAll(key);
    }
    await accounts.delete(who.accountId, who.usageKey);
    await c.env.KV.delete(`premium:${who.accountId}`);
    // Sign in with Apple: revoke the user's Apple tokens for this app.
    const appleToken = await c.env.KV.get(appleTokenKey(who.accountId));
    if (appleToken && siwaConfigured(c.env)) {
      await revokeToken(c.env, appleToken, Math.floor(deps.now() / 1000), deps.appleFetch);
    }
    await c.env.KV.delete(appleTokenKey(who.accountId));
    return c.json({ deleted: true });
  });

  app.post("/v1/credits/me", async (c) => {
    if (c.env.CREDITS_ENABLED !== "true") return c.json({ error: "credits_off" }, 404);
    const installId = await installFrom(c.req.header("authorization"), c.env, deps.now());
    if (!installId) return c.json({ error: "unauthorized" }, 401);
    const who = await identity(c.env, installId);
    const now = deps.now();
    const premium = await deps.premium(who.appUserId, c.env, now);
    const used = await spentToday(deps.usage(c.env), who.usageKey, utcDay(now));
    return c.json({
      balance: await deps.credits(c.env).balance(who.usageKey),
      daily: { amount: FREE_DAILY_CREDITS, monthlyAmount: await monthlyFor(who, c.env, premium, now), spendGuard: DAILY_SPEND_GUARD, spentToday: used, premium },
    });
  });

  // Today's daily credits (also granted automatically on the first reading).
  app.post("/v1/credits/daily", async (c) => {
    if (c.env.CREDITS_ENABLED !== "true") return c.json({ error: "credits_off" }, 404);
    const now = deps.now();
    const installId = await installFrom(c.req.header("authorization"), c.env, now);
    if (!installId) return c.json({ error: "unauthorized" }, 401);
    const who = await identity(c.env, installId);
    const premium = await deps.premium(who.appUserId, c.env, now);
    const granted = await grantCredits(who, c.env, premium, utcDay(now), now);
    return c.json({
      granted,
      balance: await deps.credits(c.env).balance(who.usageKey),
      dailyAmount: FREE_DAILY_CREDITS,
      monthlyAmount: await monthlyFor(who, c.env, premium, now),
    });
  });

  // ---- Creator program (off unless CREATOR_ENABLED=true and CREDITS_ENABLED=true) ----
  const creatorOn = (env: Env) => env.CREATOR_ENABLED === "true" && env.CREDITS_ENABLED === "true";

  app.post("/v1/creator/submit", async (c) => {
    if (!creatorOn(c.env)) return c.json({ error: "creator_off" }, 404);
    const now = deps.now();
    const installId = await installFrom(c.req.header("authorization"), c.env, now);
    if (!installId) return c.json({ error: "unauthorized" }, 401);
    const ip = c.req.header("cf-connecting-ip") ?? "unknown";
    if (!(await allowWithinMinute(c.env.KV, `creator:${await hashId(ip, c.env.HASH_SALT)}`, 10, now))) {
      return c.json({ error: "rate_limited" }, 429);
    }
    const shots = deps.shots(c.env);
    if (!shots) return c.json({ error: "creator_off" }, 503);
    const body = (await readJson(c.req.raw, SUBMIT_MAX_BODY_CHARS + 2000)) as { url?: unknown; screenshot?: unknown } | null;
    const link = parsePostUrl(body?.url);
    if (!link) return c.json({ error: "invalid_link" }, 400);
    const bytes = decodeBase64(body?.screenshot);
    const type = bytes ? sniffImage(bytes) : null;
    if (!bytes || !type || bytes.length > SCREENSHOT_MAX_BYTES) return c.json({ error: "invalid_screenshot" }, 400);

    const who = await identity(c.env, installId);
    const store = deps.creator(c.env);
    const iso = new Date(now).toISOString();
    const startOfDay = `${utcDay(now)}T00:00:00.000Z`;
    const startOfMonth = `${utcDay(now).slice(0, 7)}-01T00:00:00.000Z`;
    if ((await store.countSince(who.usageKey, startOfDay)) >= CREATOR_MAX_PER_DAY) return c.json({ error: "daily_limit" }, 429);
    if ((await store.countSince(who.usageKey, startOfMonth)) >= CREATOR_MAX_PER_MONTH) return c.json({ error: "monthly_limit" }, 429);

    const key = `shots/${crypto.randomUUID()}.${type.ext}`;
    await shots.put(key, bytes, type.mime);
    const id = await store.create({
      ownerKey: who.usageKey, appUser: who.appUserId, platform: link.platform, url: link.url,
      urlHash: await hashId(link.url, c.env.HASH_SALT), screenshotKey: key, createdAt: iso,
    });
    if (id === null) {
      await shots.delete(key);
      return c.json({ error: "duplicate_link" }, 409);
    }
    // Every attempt gets credits at once; the free month needs the owner's check.
    await deps.credits(c.env).add(who.usageKey, CREATOR_CREDITS, `creator:${id}`, "creator");
    return c.json({ id, credits: CREATOR_CREDITS, status: "pending" });
  });

  app.post("/v1/creator/mine", async (c) => {
    if (!creatorOn(c.env)) return c.json({ error: "creator_off" }, 404);
    const installId = await installFrom(c.req.header("authorization"), c.env, deps.now());
    if (!installId) return c.json({ error: "unauthorized" }, 401);
    const who = await identity(c.env, installId);
    const posts = (await deps.creator(c.env).mine(who.usageKey, 20)).map((p) => ({
      id: p.id, platform: p.platform, date: p.createdAt.slice(0, 10), status: p.status, likes: p.likes,
      monthGranted: p.monthGrantedAt !== null,
    }));
    return c.json({
      posts,
      rules: { creditsPerPost: CREATOR_CREDITS, likesForMonth: LIKES_FOR_MONTH, maxPerDay: CREATOR_MAX_PER_DAY, maxPerMonth: CREATOR_MAX_PER_MONTH },
    });
  });

  // Owner-only review: list pending posts, look at the screenshot, verify the likes.
  const adminOk = (c: { req: { header: (n: string) => string | undefined }; env: Env }) => {
    const token = c.env.ADMIN_TOKEN;
    if (!creatorOn(c.env) || !token || token.length < 24) return false;
    return safeEqual(c.req.header("authorization") ?? "", `Bearer ${token}`);
  };

  app.get("/v1/admin/creator/pending", async (c) => {
    if (!adminOk(c)) return c.json({ error: "unauthorized" }, 401);
    const posts = await deps.creator(c.env).pending(50);
    return c.json({ posts: posts.map((p) => ({ id: p.id, platform: p.platform, url: p.url, date: p.createdAt, hasScreenshot: p.screenshotKey !== null })) });
  });

  app.get("/v1/admin/creator/:id/screenshot", async (c) => {
    if (!adminOk(c)) return c.json({ error: "unauthorized" }, 401);
    const post = await deps.creator(c.env).get(Number(c.req.param("id")));
    const shots = deps.shots(c.env);
    const shot = post?.screenshotKey && shots ? await shots.get(post.screenshotKey) : null;
    if (!shot) return c.json({ error: "not_found" }, 404);
    return new Response(shot.bytes, { headers: { "content-type": shot.mime, "cache-control": "no-store" } });
  });

  app.post("/v1/admin/creator/:id/verify", async (c) => {
    if (!adminOk(c)) return c.json({ error: "unauthorized" }, 401);
    const now = deps.now();
    const body = (await readJson(c.req.raw)) as { likes?: unknown } | null;
    const likes = Number(body?.likes);
    if (!Number.isInteger(likes) || likes < 0) return c.json({ error: "invalid_request" }, 400);
    if (likes < LIKES_FOR_MONTH) return c.json({ error: "not_enough_likes", needed: LIKES_FOR_MONTH }, 400);
    const store = deps.creator(c.env);
    const post = await store.get(Number(c.req.param("id")));
    if (!post) return c.json({ error: "not_found" }, 404);
    if (post.status !== "pending") return c.json({ error: "already_reviewed" }, 409);
    const last = await store.lastMonthAt(post.ownerKey);
    if (last && now - Date.parse(last) < MONTH_COOLDOWN_DAYS * 86_400_000) return c.json({ error: "cooldown", since: last }, 409);
    if ((await store.monthsGrantedSince(post.ownerKey, new Date(now - 365 * 86_400_000).toISOString())) >= MONTHS_PER_YEAR) {
      return c.json({ error: "yearly_cap" }, 409);
    }
    if (!(await deps.grantMonth(post.appUser, c.env))) return c.json({ error: "grant_failed" }, 502);
    const iso = new Date(now).toISOString();
    await store.verify(post.id, likes, iso);
    await store.markMonthGranted(post.id, iso);
    return c.json({ id: post.id, status: "verified", monthGranted: true });
  });

  app.post("/v1/admin/creator/:id/reject", async (c) => {
    if (!adminOk(c)) return c.json({ error: "unauthorized" }, 401);
    const body = (await readJson(c.req.raw)) as { note?: unknown } | null;
    const note = typeof body?.note === "string" ? body.note.slice(0, 300) : "";
    const ok = await deps.creator(c.env).reject(Number(c.req.param("id")), note, new Date(deps.now()).toISOString());
    return ok ? c.json({ status: "rejected" }) : c.json({ error: "not_found_or_reviewed" }, 404);
  });

  // ---- Refer and earn (off unless REFERRALS_ENABLED=true) ----
  const referralsOn = (env: Env) => env.REFERRALS_ENABLED === "true";

  // My code (created on first ask) and how many friends paid / credits earned.
  app.post("/v1/referral/me", async (c) => {
    if (!referralsOn(c.env)) return c.json({ error: "referrals_off" }, 404);
    const installId = await installFrom(c.req.header("authorization"), c.env, deps.now());
    if (!installId) return c.json({ error: "unauthorized" }, 401);
    const who = await identity(c.env, installId);
    const store = deps.referrals(c.env);
    let code = await store.codeFor(who.usageKey);
    for (let i = 0; !code && i < 5; i++) {
      const candidate = newCode();
      if (!(await store.ownerOf(candidate))) {
        await store.createCode(who.usageKey, who.appUserId, candidate);
        code = candidate;
      }
    }
    if (!code) return c.json({ error: "try_again" }, 503);
    const s = await store.stats(who.usageKey);
    const friends = (await store.friendsOf(who.usageKey)).map((f) => ({
      joined: f.joinedAt.slice(0, 10),
      status: f.creditedAt ? "credited" : f.paidAt ? "pending" : "joined",
    }));
    return c.json({
      code, friendsJoined: s.redeemed, friendsPaid: s.paid, monthsEarned: s.credited,
      monthsPending: s.paid - s.credited, maxPerYear: MAX_CREDITS_PER_YEAR, friends,
      creditsEarned: (await store.rewardedFriends(who.usageKey)) * REFERRAL_CREDITS,
      creditsPerFriend: REFERRAL_CREDITS, maxFriendsPerYear: REFERRAL_CREDIT_FRIENDS_PER_YEAR,
    });
  });

  // A friend enters a code. Nothing is given for this alone: it only unlocks
  // the 50%-off first-year offer at the paywall (Apple 3.2.2).
  app.post("/v1/referral/redeem", async (c) => {
    if (!referralsOn(c.env)) return c.json({ error: "referrals_off" }, 404);
    const now = deps.now();
    const installId = await installFrom(c.req.header("authorization"), c.env, now);
    if (!installId) return c.json({ error: "unauthorized" }, 401);
    const ip = c.req.header("cf-connecting-ip") ?? "unknown";
    if (!(await allowWithinMinute(c.env.KV, `refcode:${await hashId(ip, c.env.HASH_SALT)}`, 5, now))) {
      return c.json({ error: "rate_limited" }, 429);
    }
    const body = (await readJson(c.req.raw)) as { code?: unknown; platform?: unknown } | null;
    const code = normaliseCode(body?.code);
    const platform = body?.platform === "ios" || body?.platform === "android" ? body.platform : null;
    if (!code || !platform) return c.json({ error: "invalid_request" }, 400);
    const who = await identity(c.env, installId);
    const store = deps.referrals(c.env);
    const referrerKey = await store.ownerOf(code);
    if (!referrerKey) return c.json({ error: "unknown_code" }, 404);
    if (referrerKey === who.usageKey) return c.json({ error: "own_code" }, 400);
    const iso = new Date(now).toISOString();
    const existing = await store.referralOf(who.usageKey);
    if (existing && existing.code !== code) return c.json({ error: "already_referred" }, 409);
    if (!existing) {
      await store.addReferral({ friendKey: who.usageKey, referrerKey, code, platform, redeemedAt: iso, paidTxn: null, paidAt: null, creditedAt: null });
    }
    if (platform === "android") return c.json({ offer: PLAY_REFERRAL_OFFER_TAG });
    const appleCode = await store.takeAppleCode(who.usageKey, iso);
    if (!appleCode) return c.json({ error: "no_codes_left" }, 503);
    return c.json({ appleOfferCode: appleCode });
  });

  // RevenueCat webhook: a referred friend's first paid purchase qualifies the
  // referral. Trials and promotional grants do not count.
  app.post("/v1/webhooks/revenuecat", async (c) => {
    const secret = c.env.REVENUECAT_WEBHOOK_AUTH;
    if (!secret || !safeEqual(c.req.header("authorization") ?? "", secret)) return c.json({ error: "unauthorized" }, 401);
    const body = (await readJson(c.req.raw, 65536)) as { event?: Record<string, unknown> } | null;
    const e = body?.event;
    if (!e) return c.json({ error: "invalid_request" }, 400);
    const type = String(e.type ?? "");
    const keyFor = async (appUser: string) => (await deps.accounts(c.env).isAccount(appUser))
      ? hashId(`acct:${appUser}`, c.env.HASH_SALT)
      : hashId(appUser, c.env.HASH_SALT);
    // A Premium user reinstalled and restored: RevenueCat moves the subscription
    // to the new app user id, and their credits follow it. Free users (no active
    // subscription on the new id) do not keep credits from a deleted install.
    if (type === "TRANSFER" && c.env.CREDITS_ENABLED === "true") {
      const ours = (v: unknown) => (Array.isArray(v) ? v.map(String).filter((id: string) => id !== "" && !id.startsWith("$RC")) : []);
      const from = ours(e.transferred_from);
      const to = ours(e.transferred_to);
      let moved = 0;
      for (const dest of to) {
        await c.env.KV.delete(`premium:${dest}`); // do not trust a cached "not premium" from before the restore
        if (!(await deps.premium(dest, c.env, deps.now()))) continue;
        for (const src of from) moved += await deps.credits(c.env).move(await keyFor(src), await keyFor(dest));
      }
      return c.json({ ok: true, moved });
    }
    // Credit packs (consumables).
    if (type === "NON_RENEWING_PURCHASE" && c.env.CREDITS_ENABLED === "true") {
      const amount = creditsInProduct(String(e.product_id ?? ""));
      const txn = String(e.transaction_id ?? "");
      const appUser = String(e.app_user_id ?? "");
      if (!amount || !txn || !appUser) return c.json({ ok: true, ignored: true });
      const added = await deps.credits(c.env).add(await keyFor(appUser), amount, txn);
      return c.json({ ok: true, credited: added ? amount : 0 });
    }
    // A refunded credit pack takes back its unused credits. RevenueCat sends a
    // refund of a non-renewing purchase as CANCELLATION (cancel_reason
    // CUSTOMER_SUPPORT). Subscription refunds end Premium through the store;
    // monthly credits already granted stay.
    if (type === "CANCELLATION" && c.env.CREDITS_ENABLED === "true" && creditsInProduct(String(e.product_id ?? ""))) {
      const txn = String(e.transaction_id ?? "");
      if (!txn) return c.json({ ok: true, ignored: true });
      return c.json({ ok: true, revoked: await deps.credits(c.env).revoke(txn) });
    }
    if (!referralsOn(c.env)) return c.json({ ok: true });
    const price = Number(e.price ?? 0);
    const txn = String(e.transaction_id ?? "");
    const appUser = String(e.app_user_id ?? "");
    const store = String(e.store ?? "");
    if (!["INITIAL_PURCHASE", "RENEWAL"].includes(type) || !(price > 0) || !txn || !appUser || store === "PROMOTIONAL") {
      return c.json({ ok: true, ignored: true });
    }
    const key = await keyFor(appUser);
    const paid = await deps.referrals(c.env).markPaid(key, txn, new Date(Number(e.event_timestamp_ms ?? deps.now())).toISOString());
    return c.json({ ok: true, qualified: paid });
  });

  return app;
}

/** Daily: give referrers their free month 14 days after the friend paid, at
 * most 6 a year. Referrers with an active store subscription are skipped
 * (credit stays banked) until it lapses; store extensions come later. */
export async function grantReferralCredits(env: Env, deps: Pick<Deps, "referrals"> & {
  now: () => number;
  grant?: (appUserId: string) => Promise<boolean>;
  subscribed?: (appUserId: string) => Promise<boolean>;
}): Promise<number> {
  if (env.REFERRALS_ENABLED !== "true" || !env.REVENUECAT_SECRET_KEY) return 0;
  const key = env.REVENUECAT_SECRET_KEY;
  const now = deps.now();
  const grant = deps.grant ?? ((u: string) => grantFreeMonth(u, key));
  const subscribed = deps.subscribed ?? ((u: string) => hasStoreSubscription(u, key, now));
  const store = deps.referrals(env);
  const due = await store.dueForCredit(new Date(now - CREDIT_DELAY_DAYS * 86_400_000).toISOString());
  const yearAgo = new Date(now - 365 * 86_400_000).toISOString();
  let granted = 0;
  for (const r of due) {
    if ((await store.creditsSince(r.referrerKey, yearAgo)) >= MAX_CREDITS_PER_YEAR) continue;
    const appUser = await store.appUserOf(r.referrerKey);
    if (!appUser || (await subscribed(appUser))) continue;
    if (await grant(appUser)) {
      await store.markCredited(r.friendKey, new Date(now).toISOString());
      granted++;
    }
  }
  return granted;
}

/** Tries each target once, in order; the first success wins. With our keys
 * that is the primary provider then at most one fallback; a user key has no
 * fallback. A rejected user key is not retried elsewhere. */
async function callWithFallback(llm: LlmFn, params: LlmParams, targets: LlmTarget[]): Promise<LlmResult> {
  let last: unknown = new Error("no provider");
  for (const t of targets) {
    try {
      return await llm(params, t);
    } catch (e) {
      last = e;
      if (t.byok) break;
      logUpstreamError(e);
    }
  }
  throw last;
}

/** Logs only the error class, HTTP status and the provider's error type: never
 * the request, the user's text or any key. */
function logUpstreamError(e: unknown): void {
  const err = e as { name?: string; status?: number; message?: string; error?: { error?: { type?: string } } };
  const msg = String(err?.message ?? "").replace(/sk-[A-Za-z0-9_-]+/g, "[key]").slice(0, 200);
  console.error("upstream_failed", err?.name ?? "unknown", err?.status ?? "-", err?.error?.error?.type ?? "-", msg);
}

async function readJson(req: Request, maxBytes = MAX_BODY_BYTES): Promise<unknown> {
  try {
    const text = await req.text();
    if (text.length > maxBytes) return null;
    return JSON.parse(text);
  } catch {
    return null;
  }
}

/** Deletes creator screenshots older than 30 days (the post link and status stay). */
export async function purgeScreenshots(env: Env, deps: Pick<Deps, "creator" | "shots"> & { now: () => number }): Promise<number> {
  const shots = deps.shots(env);
  if (!shots) return 0;
  const store = deps.creator(env);
  const stale = await store.staleScreenshots(new Date(deps.now() - SCREENSHOT_KEEP_DAYS * 86_400_000).toISOString(), 200);
  for (const s of stale) {
    await shots.delete(s.key);
    await store.clearScreenshot(s.id);
  }
  return stale.length;
}

const worker = createApp();
export default {
  fetch: worker.fetch,
  async scheduled(_event: ScheduledEvent, env: Env, ctx: ExecutionContext) {
    ctx.waitUntil(grantReferralCredits(env, { referrals: (e) => new D1ReferralStore(e.DB), now: () => Date.now() }));
    ctx.waitUntil(purgeScreenshots(env, defaultDeps));
  },
};
