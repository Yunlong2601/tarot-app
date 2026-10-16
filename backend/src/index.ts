import { Hono } from "hono";
import { hashId, signToken, verifyToken } from "./auth";
import type { Env } from "./env";
import { callAnthropic, type LlmFn } from "./llm";
import { CRISIS_MESSAGE, detectCrisis } from "./knowledge";
import {
  DISCLAIMER, FOLLOWUP_MAX_TOKENS, FOLLOWUP_SYSTEM_PROMPT, buildFollowupMessage, checkOutput,
} from "./prompts";
import {
  readingMaxTokens, READING_SYSTEM_PROMPT, buildReadingMessage, fallbackReading, hitsBannedClaim,
  parseModelReply, renderReading,
} from "./reading";
import { isPremium } from "./revenuecat";
import {
  BURST_PER_MINUTE, D1UsageStore, DEFAULT_GLOBAL_DAILY_TOKEN_CAP, FREE_READINGS_PER_DAY,
  IP_PER_MINUTE, PREMIUM_FOLLOWUPS_PER_DAY, PREMIUM_READINGS_PER_DAY, allowWithinMinute, utcDay, type UsageStore,
} from "./usage";
import { isFreeSpread } from "./spreads";
import { isUuid, parseFollowupRequest, parseReadingRequest } from "./validate";

export interface Deps {
  llm: LlmFn;
  usage: (env: Env) => UsageStore;
  premium: (installId: string, env: Env, nowMs: number) => Promise<boolean>;
  now: () => number;
}

const defaultDeps: Deps = {
  llm: callAnthropic,
  usage: (env) => new D1UsageStore(env.DB),
  premium: (id, env, now) => isPremium(id, env.REVENUECAT_SECRET_KEY, env.KV, now),
  now: () => Date.now(),
};

const MAX_BODY_BYTES = 4096;

export function createApp(deps: Deps = defaultDeps) {
  const app = new Hono<{ Bindings: Env }>();

  app.get("/health", (c) => c.json({ ok: true }));

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

    const installHash = await hashId(installId, c.env.HASH_SALT);
    const ip = c.req.header("cf-connecting-ip") ?? "unknown";
    if (
      !(await allowWithinMinute(c.env.KV, `burst:${installHash}`, BURST_PER_MINUTE, now)) ||
      !(await allowWithinMinute(c.env.KV, `ip:${await hashId(ip, c.env.HASH_SALT)}`, IP_PER_MINUTE, now))
    ) {
      return c.json({ error: "rate_limited" }, 429);
    }

    const body = await readJson(c.req.raw);
    const parsed = parseReadingRequest(body);
    if (!parsed.ok) return c.json({ error: "invalid_request", detail: parsed.error }, 400);
    const req = parsed.value;

    // Fixed care reply, no model call, nothing logged or counted.
    if (detectCrisis(req.question, req.impression)) {
      return c.json({ crisis: true, message: CRISIS_MESSAGE });
    }

    const premium = await deps.premium(installId, c.env, now);
    const usage = deps.usage(c.env);
    // Longer spreads are Premium, with one free trial reading per install.
    if (!isFreeSpread(req.spread) && !premium) {
      if ((await usage.countTrial(await hashId(installId, c.env.HASH_SALT))) > 0) {
        return c.json({ error: "premium_required" }, 402);
      }
    }
    const day = utcDay(now);
    const cap = Number(c.env.GLOBAL_DAILY_TOKEN_CAP ?? DEFAULT_GLOBAL_DAILY_TOKEN_CAP);
    if ((await usage.tokensToday(day)) >= cap) return c.json({ error: "service_busy" }, 503);

    const limit = premium ? PREMIUM_READINGS_PER_DAY : FREE_READINGS_PER_DAY;
    if ((await usage.count(installHash, day, "reading")) >= limit) {
      return c.json({ error: "daily_limit", premium }, 429);
    }

    const model = c.env.LLM_MODEL ?? "claude-haiku-5-5";
    const slot = await usage.reserve(installHash, day, "reading", req.spread, model);
    try {
      const result = await deps.llm(
        { system: READING_SYSTEM_PROMPT, user: buildReadingMessage(req), maxTokens: readingMaxTokens(req.spread) },
        model, c.env.ANTHROPIC_API_KEY,
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
      return c.json({
        reading: text,
        structured: usedFallback ? null : structured,
        fallback: usedFallback,
        disclaimer: DISCLAIMER,
      });
    } catch (e) {
      await usage.release(slot);
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

    const installHash = await hashId(installId, c.env.HASH_SALT);
    const ip = c.req.header("cf-connecting-ip") ?? "unknown";
    if (
      !(await allowWithinMinute(c.env.KV, `burst:${installHash}`, BURST_PER_MINUTE, now)) ||
      !(await allowWithinMinute(c.env.KV, `ip:${await hashId(ip, c.env.HASH_SALT)}`, IP_PER_MINUTE, now))
    ) {
      return c.json({ error: "rate_limited" }, 429);
    }

    const parsed = parseFollowupRequest(await readJson(c.req.raw, 16384));
    if (!parsed.ok) return c.json({ error: "invalid_request", detail: parsed.error }, 400);
    const req = parsed.value;

    if (detectCrisis(req.followup, req.question)) return c.json({ crisis: true, message: CRISIS_MESSAGE });

    if (!(await deps.premium(installId, c.env, now))) return c.json({ error: "premium_required" }, 402);

    const usage = deps.usage(c.env);
    const day = utcDay(now);
    const cap = Number(c.env.GLOBAL_DAILY_TOKEN_CAP ?? DEFAULT_GLOBAL_DAILY_TOKEN_CAP);
    if ((await usage.tokensToday(day)) >= cap) return c.json({ error: "service_busy" }, 503);
    if ((await usage.count(installHash, day, "followup")) >= PREMIUM_FOLLOWUPS_PER_DAY) {
      return c.json({ error: "daily_limit", premium: true }, 429);
    }

    const model = c.env.LLM_MODEL ?? "claude-haiku-5-5";
    const slot = await usage.reserve(installHash, day, "followup", req.spread, model);
    try {
      const result = await deps.llm(
        { system: FOLLOWUP_SYSTEM_PROMPT, user: buildFollowupMessage(req), maxTokens: FOLLOWUP_MAX_TOKENS },
        model, c.env.ANTHROPIC_API_KEY,
      );
      await usage.finalize(slot, result.inputTokens, result.outputTokens);
      if (result.refused) return c.json({ error: "declined" }, 422);
      const checked = checkOutput(result.text);
      if (!checked.ok) return c.json({ error: "bad_output" }, 502);
      return c.json({ answer: checked.text, disclaimer: DISCLAIMER });
    } catch (e) {
      await usage.release(slot);
      logUpstreamError(e);
      return c.json({ error: "upstream_failed" }, 502);
    }
  });

  return app;
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

export default createApp();
