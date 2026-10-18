/** Questions that are not about the user's own life: about the AI or the app,
 * maths, code, prompt injection, or no words at all. They get a short
 * in-character redirect instead of a reading, and no credit is used. The
 * model flags the rest with "off_topic" (see READING_SYSTEM_PROMPT). */

const META: RegExp[] = [
  // About the AI, the model or the app.
  /\b(what|which) (ai |language |llm )?model (are|is|do|does|powers|runs) (you|this|it)\b/i,
  /\bwhat (ai|llm) (are|is) (you|this)\b/i,
  /\bare you (an? )?(ai|bot|robot|human|real person|real|chatgpt|gpt|claude|gemini|llm)\b/i,
  /\bwho (made|built|created|trained|programmed) you\b/i,
  // Prompt injection.
  /\b(ignore|forget|disregard) (all |any |the |your )?(previous|prior|above|earlier) (instructions|rules|prompts?)\b/i,
  /\b(system prompt|your instructions|your rules|developer mode|jailbreak)\b/i,
  // Chinese: what model / who are you / are you a person / ignore the above / system prompt.
  /(什么|哪个|哪一个|啥)(ai)?模型/i,
  /^(请问)?你(到底)?是(谁|什么|哪个|人|真人|机器人|ai|gpt|chatgpt|claude)/i,
  /谁(做|开发|训练|创造)了?你/,
  /(忽略|无视|忘记)(之前|以上|上面|前面)/,
  /(系统提示|提示词)/,
];

/** True when the question is plainly not a question about the user's life. */
export function detectOffTopic(question: string | null | undefined): boolean {
  const q = (question ?? "").trim();
  if (q === "") return false; // no question is a general reading
  if (META.some((r) => r.test(q))) return true;
  // Bare arithmetic ("2+2", "12 * 7 = ?").
  if (/^[\d\s+\-*/x×÷=().,?^%]+$/i.test(q) && /\d/.test(q) && /[+\-*/×÷^%=]/.test(q)) return true;
  // Code.
  if (/(\bfunction\s*\(|=>|\bdef \w+\(|#include|\bconsole\.log|\bSELECT .* FROM\b|<\/?\w+>)/i.test(q)) return true;
  // No letters in any script (emoji, digits or punctuation only).
  if (!/\p{L}/u.test(q)) return true;
  return false;
}

/** Chinese, Japanese or Korean characters. */
export const hasCjk = (s: string): boolean => /[぀-ヿ㐀-鿿가-힯]/.test(s);

const MESSAGES: Record<string, string> = {
  en: "I'm the world's best tarot AI reader, here to read the cards about your own life. What's on your mind?",
  zh: "我是世界上最好的塔罗 AI 解读师，只为你自己的生活解读牌面。你心里在想什么呢？",
};

/** The fixed redirect, in the question's script or else the phone's language. */
export function offTopicMessage(question: string | null | undefined, locale: string | null | undefined): string {
  const q = question ?? "";
  if (/[㐀-鿿]/.test(q) && !/[぀-ヿ가-힯]/.test(q)) return MESSAGES.zh!;
  if (!/\p{L}/u.test(q) && (locale ?? "").toLowerCase().startsWith("zh")) return MESSAGES.zh!;
  return MESSAGES.en!;
}
