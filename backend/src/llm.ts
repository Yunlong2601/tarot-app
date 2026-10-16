import Anthropic from "@anthropic-ai/sdk";

export interface LlmParams {
  system: string;
  user: string;
  maxTokens: number;
}

export interface LlmResult {
  text: string;
  inputTokens: number;
  outputTokens: number;
  refused: boolean;
}

export type Provider = "anthropic" | "openai";

/** Which provider, model and key one call uses. `byok` = the user's own key:
 * never logged or stored, and not charged to our daily token budget. */
export interface LlmTarget {
  provider: Provider;
  model: string;
  apiKey: string;
  byok: boolean;
}

export type LlmFn = (params: LlmParams, target: LlmTarget) => Promise<LlmResult>;

export const DEFAULT_MODELS: Record<Provider, string> = {
  anthropic: "claude-haiku-5-5",
  openai: "gpt-6-luna",
};

/** An error from the provider that means the key itself was rejected. */
export function isAuthError(e: unknown): boolean {
  const s = (e as { status?: number })?.status;
  return s === 401 || s === 403;
}

/** Haiku 5.5 thinks by default and thinking tokens bill as output, so effort
 * is low. No temperature/top_p (400 on this model). One SDK retry, 30 s cap. */
export const callAnthropic: LlmFn = async (params, target) => {
  const client = new Anthropic({ apiKey: target.apiKey, maxRetries: 1, timeout: 30_000 });
  const msg = await client.messages.create({
    model: target.model,
    max_tokens: params.maxTokens,
    system: params.system,
    output_config: { effort: "low" },
    messages: [{ role: "user", content: params.user }],
  });
  const text = msg.content.flatMap((b) => (b.type === "text" ? [b.text] : [])).join("\n");
  return {
    text,
    inputTokens: msg.usage.input_tokens,
    outputTokens: msg.usage.output_tokens,
    refused: msg.stop_reason === "refusal",
  };
};

class ProviderError extends Error {
  constructor(public status: number, public error: unknown) {
    super(`openai ${status}`);
  }
}

/** OpenAI Responses API over fetch (no SDK). Reasoning off, nothing stored at
 * OpenAI (`store: false`), hard output cap, no retry here (the router does at
 * most one fallback). */
export const callOpenAI: LlmFn = async (params, target) => {
  const res = await fetch("https://api.openai.com/v1/responses", {
    method: "POST",
    headers: { authorization: `Bearer ${target.apiKey}`, "content-type": "application/json" },
    body: JSON.stringify({
      model: target.model,
      instructions: params.system,
      input: params.user,
      max_output_tokens: params.maxTokens,
      reasoning: { effort: "none" },
      store: false,
    }),
    signal: AbortSignal.timeout(30_000),
  });
  const json = (await res.json().catch(() => null)) as OpenAIResponse | null;
  if (!res.ok || !json) throw new ProviderError(res.status, json);
  return parseOpenAI(json);
};

interface OpenAIResponse {
  output?: { type?: string; content?: { type?: string; text?: string; refusal?: string }[] }[];
  usage?: { input_tokens?: number; output_tokens?: number };
}

export function parseOpenAI(json: OpenAIResponse): LlmResult {
  const parts = (json.output ?? []).filter((o) => o.type === "message").flatMap((o) => o.content ?? []);
  const text = parts.flatMap((p) => (p.type === "output_text" && p.text ? [p.text] : [])).join("\n");
  return {
    text,
    inputTokens: json.usage?.input_tokens ?? 0,
    outputTokens: json.usage?.output_tokens ?? 0,
    refused: text === "" && parts.some((p) => p.type === "refusal"),
  };
}

export const callProvider: LlmFn = (params, target) =>
  target.provider === "openai" ? callOpenAI(params, target) : callAnthropic(params, target);
