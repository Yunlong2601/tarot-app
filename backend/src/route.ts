import type { Env } from "./env";
import { DEFAULT_MODELS, type LlmTarget, type Provider } from "./llm";

/** Our own keys: the primary provider (LLM_PROVIDER, default Anthropic), then
 * the other one as a single fallback if its key is set. At most two calls. */
export function serverTargets(env: Env): LlmTarget[] {
  const primary: Provider = env.LLM_PROVIDER === "openai" ? "openai" : "anthropic";
  const order: Provider[] = primary === "openai" ? ["openai", "anthropic"] : ["anthropic", "openai"];
  const out: LlmTarget[] = [];
  for (const p of order) {
    const apiKey = p === "openai" ? env.OPENAI_API_KEY : env.ANTHROPIC_API_KEY;
    if (!apiKey) continue;
    const model = p === "openai" ? (env.OPENAI_MODEL ?? DEFAULT_MODELS.openai) : (env.LLM_MODEL ?? DEFAULT_MODELS.anthropic);
    out.push({ provider: p, model, apiKey, byok: false });
  }
  return out;
}

const KEY_SHAPE: Record<Provider, RegExp> = {
  anthropic: /^sk-ant-[A-Za-z0-9_-]{20,250}$/,
  openai: /^sk-[A-Za-z0-9_-]{20,250}$/,
};

export type UserKey = { ok: true; target: LlmTarget | null } | { ok: false };

/** The user's own key, from the `x-user-provider` and `x-user-key` headers.
 * Only checked for shape here; never logged, stored or echoed back. No
 * fallback to our keys, so a user-key request never costs us tokens. */
export function userTarget(provider: string | undefined, key: string | undefined): UserKey {
  if (!provider && !key) return { ok: true, target: null };
  if ((provider !== "anthropic" && provider !== "openai") || !key || !KEY_SHAPE[provider].test(key)) {
    return { ok: false };
  }
  return { ok: true, target: { provider, model: DEFAULT_MODELS[provider], apiKey: key, byok: true } };
}

/** Stored in the usage table's model column so daily counts still work but the
 * global token budget ignores user-key calls. */
export const usageModel = (t: LlmTarget): string => (t.byok ? `byok:${t.model}` : t.model);
