import Anthropic from "@anthropic-ai/sdk";
import { MAX_TOKENS, SYSTEM_PROMPT, buildUserMessage } from "./prompts";
import type { ReadingRequest } from "./validate";

export interface LlmResult {
  text: string;
  inputTokens: number;
  outputTokens: number;
  refused: boolean;
}

export type LlmFn = (req: ReadingRequest, model: string, apiKey: string) => Promise<LlmResult>;

/** Calls the model. Haiku 5.5 thinks by default and thinking tokens bill as
 * output, so effort is set to low. No temperature/top_p (400 on this model). */
export const callAnthropic: LlmFn = async (req, model, apiKey) => {
  const client = new Anthropic({ apiKey });
  const msg = await client.messages.create({
    model,
    max_tokens: MAX_TOKENS[req.spread],
    system: SYSTEM_PROMPT,
    output_config: { effort: "low" },
    messages: [{ role: "user", content: buildUserMessage(req) }],
  });
  const text = msg.content.flatMap((b) => (b.type === "text" ? [b.text] : [])).join("\n");
  return {
    text,
    inputTokens: msg.usage.input_tokens,
    outputTokens: msg.usage.output_tokens,
    refused: msg.stop_reason === "refusal",
  };
};
