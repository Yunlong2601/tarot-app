/** Picks a spread from a question's wording, the same way the app does:
 * keep the English lists in step with `recommendSpread` in
 * app/lib/data/spreads.dart. A guess, never a rule. Each language has its own
 * word lists (ui.json "recommend"); the English ones are the defaults. */
import type { SpreadId } from "./data.ts";

export interface Keywords {
  reconnect: string[];
  ready: string[];
  love: string[];
  career: string[];
  decision: string[];
  growth: string[];
  /** Words a yes-or-no question starts with ("should", "will"). */
  yesNoStarts: string[];
  /** Endings that mark a yes-or-no question in some languages (Chinese 吗). */
  yesNoEnds: string[];
}

export const EN_KEYWORDS: Keywords = {
  reconnect: ["ex ", " ex", "reconcil", "get back together", "come back", "heal", "breakup", "broke up"],
  ready: ["single", "dating", "new love", "meet someone"],
  love: ["love", "relationship", "partner", "boyfriend", "girlfriend", "marriage", "crush"],
  career: ["job", "career", "work", "boss", "promotion", "study", "school"],
  decision: ["decide", "decision", "choose", "choice", "option", "whether"],
  growth: ["feel", "anxious", "stuck", "confus", "myself", "growth"],
  yesNoStarts: ["will", "should", "is", "am", "are", "do", "does", "can", "shall", "would"],
  yesNoEnds: [],
};

export function recommendSpread(question: string, kw: Keywords = EN_KEYWORDS): SpreadId {
  const q = question.toLowerCase();
  const any = (words: string[]) => words.some((w) => q.includes(w.toLowerCase()));
  if (any(kw.reconnect)) return "love_reconnect";
  if (any(kw.ready)) return "love_ready";
  if (any(kw.love)) return "love_connection";
  if (any(kw.career)) return "career_path";
  if (looksYesNo(q, kw)) return "yes_no";
  if (any(kw.decision)) return "three_decision";
  if (any(kw.growth)) return "three_hhh";
  return "three";
}

/** A question worded for a yes or no answer ("Should I...", "Will it..."). */
export function looksYesNo(question: string, kw: Keywords = EN_KEYWORDS) {
  // Spanish opens a question with ¿, which is not part of its first word.
  const q = question.trim().toLowerCase().replace(/^[¿¡"«“„]+/u, "");
  const bare = q.replace(/[?？!！。.\s]+$/u, "");
  const first = q.split(/[\s,]+/u)[0] ?? "";
  return (
    kw.yesNoStarts.some((w) => (/^[\p{L}]+$/u.test(w) && /^[a-zà-ÿа-яё]/u.test(w) ? first === w.toLowerCase() : q.startsWith(w.toLowerCase()))) ||
    kw.yesNoEnds.some((w) => bare.endsWith(w))
  );
}

/** Where the home page's question waits for the spread page's reader. Kept in
 * the tab's session storage, never in the address. */
export const ASK_KEY = "shentarot-ask";
