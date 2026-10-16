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

export type LlmFn = (params: LlmParams, model: string, apiKey: string) => Promise<LlmResult>;

/** Calls the model. Haiku 5.5 thinks by default and thinking tokens bill as
 * output, so effort is set to low. No temperature/top_p (400 on this model). */
export const callAnthropic: LlmFn = async (params, model, apiKey) => {
  const client = new Anthropic({ apiKey });
  const msg = await client.messages.create({
    model,
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
