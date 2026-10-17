import { Hono } from "hono";
import { hashId, signToken, verifyToken } from "./auth";
import type { Env } from "./env";
import { callProvider, isAuthError, type LlmFn, type LlmParams, type LlmResult, type LlmTarget } from "./llm";
import { serverTargets, usageModel, userTarget } from "./route";
import { CRISIS_MESSAGE, detectCrisis } from "./knowledge";
import {
  DISCLAIMER, FOLLOWUP_MAX_TOKENS, FOLLOWUP_SYSTEM_PROMPT, buildFollowupMessage, checkOutput,
} from "./prompts";
import {
  readingMaxTokens, READING_SYSTEM_PROMPT, buildReadingMessage, fallbackReading, hitsBannedClaim,
  parseModelReply, renderReading,
} from "./reading";
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
import { isFreeSpread } from "./spreads";
import { isUuid, parseFollowupRequest, parseReadingRequest } from "./validate";

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
  verifyIdToken: (provider: AccountProvider, token: string, audiences: string[], kv: KVNamespace, nowSeconds: number) => Promise<string | null>;
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
  verifyIdToken: (p, t, a, kv, n) => verifyIdToken(p, t, a, kv, n),
};

const MAX_BODY_BYTES = 4096;

/** Install or account ids treated as Premium for testing before store
 * products exist (TESTER_INSTALL_IDS, comma-separated). Remove for launch. */
export const testerIds = (env: Env): string[] =>
  (env.TESTER_INSTALL_IDS ?? "").split(",").map((s) => s.trim()).filter(Boolean);

export function createApp(deps: Deps = defaultDeps) {
  const app = new Hono<{ Bindings: Env }>();

  /** One credit buys a reading or a follow-up. Everyone receives 2 credits the
   * first time they use the app each UTC day; Premium also receives monthly
   * credits by plan (annual 150, 3 months 120, monthly 90) the first time in each
   * UTC month. Unused credits roll over and never expire, with a bank of 10
   * days' worth of daily and 2 months' worth of monthly credits. No one can spend
   * more than 50 credits a day. Before the wallet is switched on
   * (CREDITS_ENABLED), free gets 1 reading a day and Premium up to 50. */
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
  const charge = async (who: { appUserId: string; usageKey: string }, env: Env, premium: boolean, usage: UsageStore, day: string, now: number): Promise<Charge> => {
    const used = await spentToday(usage, who.usageKey, day);
    if (!walletOn(env)) {
      const limit = premium ? DAILY_SPEND_GUARD : FREE_READINGS_PER_DAY;
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

  // Anonymous install -> short-lived token.
  app.post("/v1/install", async (c) => {
    const ip = c.req.header("cf-connecting-ip") ?? "unknown";
    if (!(await allowWithinMinute(c.env.KV, `ip-install:${ip}`, 10, deps.now()))) {
      return c.json({ error: "rate_limited" }, 429);
    }
    const body = await readJson(c.req.raw);
    if (!body || !isUuid((body as { installId?: unknown }).installId)) {
      return c.json({ error: "invalid_request" }, 400);
    }
    // TODO(owner/Phase E): verify App Attest (iOS) / Play Integrity (Android) here.
    // Until that exists, installs are refused unless the local-testing flag is set.
    if (c.env.ALLOW_UNATTESTED_INSTALLS !== "true") {
      return c.json({ error: "attestation_not_configured" }, 501);
    }
    const installId = (body as { installId: string }).installId;
    const token = await signToken(installId, c.env.JWT_SECRET, Math.floor(deps.now() / 1000));
    return c.json({ token });
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
      !(await allowWithinMinute(c.env.KV, `burst:${installHash}`, BURST_PER_MINUTE, now)) ||
      !(await allowWithinMinute(c.env.KV, `ip:${await hashId(ip, c.env.HASH_SALT)}`, IP_PER_MINUTE, now))
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
    if (!user.target && (await usage.tokensToday(day)) >= cap) return c.json({ error: "service_busy" }, 503);

    // Own-key mode is a Premium feature (bought through the store): the user's
    // key pays the AI provider, so there is no daily reading cap, only the
    // per-minute brakes above. Everything else (crisis check, prompt rules,
    // output checks) is the same on both paths.
    if (user.target && !premium) return c.json({ error: "premium_required" }, 402);
    // One credit per reading: daily credits first, then bonus credits.
    let creditLot: number | null = null;
    if (!user.target) {
      const paid = await charge(who, c.env, premium, usage, day, now);
      if (!paid.ok) return c.json({ error: "daily_limit", premium, limit: paid.limit }, 429);
      creditLot = paid.lot;
    }

    const slot = await usage.reserve(who.usageKey, day, "reading", req.spread, usageModel(targets[0]!));
    try {
      const result = await callWithFallback(
        deps.llm,
        { system: READING_SYSTEM_PROMPT, user: buildReadingMessage(req), maxTokens: readingMaxTokens(req.spread) },
        targets,
      );
      await usage.finalize(slot, result.inputTokens, result.outputTokens);
      if (result.refused) return c.json({ error: "declined" }, 422);
      // Structured JSON is the normal case. If the model ignored the format,
      // accept a clean plain-text reply; anything else (or any banned claim)
      // falls back to a reading built from stored card text, never an error.
      const structured = parseModelReply(result.text, req);
      if (structured?.crisis) return c.json({ crisis: true, message: CRISIS_MESSAGE });
      let text: string | null = structured ? renderReading(structured) : null;
      if (text === null) {
        const plain = checkOutput(result.text);
        text = plain.ok ? plain.text : null;
      }
      let usedFallback = false;
      if (text === null || hitsBannedClaim(text)) {
        text = fallbackReading(req);
        usedFallback = true;
      }
      await rewardReferral(who, c.env, now);
      return c.json({
        reading: text,
        structured: usedFallback ? null : structured,
        fallback: usedFallback,
        disclaimer: DISCLAIMER,
      });
    } catch (e) {
      await usage.release(slot);
      if (creditLot !== null) await deps.credits(c.env).refund(creditLot);
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
    if (!user.target && (await usage.tokensToday(day)) >= cap) return c.json({ error: "service_busy" }, 503);
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
    try {
      const result = await callWithFallback(
        deps.llm,
        { system: FOLLOWUP_SYSTEM_PROMPT, user: buildFollowupMessage(req), maxTokens: FOLLOWUP_MAX_TOKENS },
        targets,
      );
      await usage.finalize(slot, result.inputTokens, result.outputTokens);
      if (result.refused) return c.json({ error: "declined" }, 422);
      const checked = checkOutput(result.text);
      if (!checked.ok) return c.json({ error: "bad_output" }, 502);
      return c.json({ answer: checked.text, disclaimer: DISCLAIMER });
    } catch (e) {
      await usage.release(slot);
      if (followupLot !== null) await deps.credits(c.env).refund(followupLot);
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
    const body = (await readJson(c.req.raw)) as { provider?: unknown; idToken?: unknown } | null;
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
    await deps.accounts(c.env).delete(who.accountId, who.usageKey);
    await c.env.KV.delete(`premium:${who.accountId}`);
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
    if (!secret || c.req.header("authorization") !== secret) return c.json({ error: "unauthorized" }, 401);
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
    // Starter Pack and other credit packs (consumables).
    if (type === "NON_RENEWING_PURCHASE" && c.env.CREDITS_ENABLED === "true") {
      const amount = creditsInProduct(String(e.product_id ?? ""));
      const txn = String(e.transaction_id ?? "");
      const appUser = String(e.app_user_id ?? "");
      if (!amount || !txn || !appUser) return c.json({ ok: true, ignored: true });
      const added = await deps.credits(c.env).add(await keyFor(appUser), amount, txn);
      return c.json({ ok: true, credited: added ? amount : 0 });
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

const worker = createApp();
export default {
  fetch: worker.fetch,
  async scheduled(_event: ScheduledEvent, env: Env, ctx: ExecutionContext) {
    ctx.waitUntil(grantReferralCredits(env, { referrals: (e) => new D1ReferralStore(e.DB), now: () => Date.now() }));
  },
};
