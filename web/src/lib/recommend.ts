import type { SpreadId } from "./data.ts";

/** Picks a spread from a question's wording, the same way the app does:
 * keep in step with `recommendSpread` in app/lib/data/spreads.dart. A guess,
 * never a rule. */
export function recommendSpread(question: string): SpreadId {
  const q = question.toLowerCase();
  const any = (words: string[]) => words.some((w) => q.includes(w));
  if (any(["ex ", " ex", "reconcil", "get back together", "come back", "heal", "breakup", "broke up"])) return "love_reconnect";
  if (any(["single", "dating", "new love", "meet someone"])) return "love_ready";
  if (any(["love", "relationship", "partner", "boyfriend", "girlfriend", "marriage", "crush"])) return "love_connection";
  if (any(["job", "career", "work", "boss", "promotion", "study", "school"])) return "career_path";
  if (looksYesNo(q)) return "yes_no";
  if (any(["decide", "decision", "choose", "choice", "option", "whether"])) return "three_decision";
  if (any(["feel", "anxious", "stuck", "confus", "myself", "growth"])) return "three_hhh";
  return "three";
}

/** A question worded for a yes or no answer ("Should I...", "Will it..."). */
export const looksYesNo = (question: string) =>
  /^(will|should|is|am|are|do|does|can|shall|would)\b/.test(question.trim().toLowerCase());

/** Where the home page's question waits for the spread page's reader. Kept in
 * the tab's session storage, never in the address. */
export const ASK_KEY = "shentarot-ask";
