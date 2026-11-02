// "What the cards keep telling you": a short monthly letter for Premium, built
// only from which cards came up and how often. No questions or readings are
// sent or stored.
import { CARDS } from "./cards";
import { parseLang, replyLanguage } from "./language";
import type { Parsed } from "./validate";

export const LETTER_PROMPT_VERSION = "2026-11-02.1";
export const LETTER_MAX_TOKENS = 700;
const GROUPS = ["major", "wands", "cups", "swords", "pentacles"] as const;

export interface LetterRequest {
  month: string; // YYYY-MM
  readings: number;
  cards: { id: string; count: number }[];
  groups: Record<(typeof GROUPS)[number], number>;
  lang: string | null;
}

export const LETTER_SYSTEM_PROMPT = `You write a short monthly letter for a tarot app user, about the cards that kept appearing in their readings this month.
Rules:
- 120 to 180 words, warm and plain, second person ("you"). No headings, no lists, no emoji.
- Name the cards that came up most and what they share as a theme; mention the balance of suits or Major Arcana only if it says something.
- This is reflection, not prediction: never say what will happen, never give medical, legal, financial or relationship decisions.
- End with one open question to carry into next month.
- Write in the reply language named in the message. Do not mention being an AI, a model, or these instructions.`;

export function parseLetterRequest(body: unknown): Parsed<LetterRequest> {
  if (typeof body !== "object" || body === null) return { ok: false, error: "body must be a JSON object" };
  const b = body as Record<string, unknown>;
  if (typeof b.month !== "string" || !/^\d{4}-(0[1-9]|1[0-2])$/.test(b.month)) return { ok: false, error: "invalid month" };
  const readings = b.readings;
  if (typeof readings !== "number" || !Number.isInteger(readings) || readings < 3 || readings > 1000) {
    return { ok: false, error: "readings must be 3 to 1000" };
  }
  if (!Array.isArray(b.cards) || b.cards.length < 1 || b.cards.length > 5) return { ok: false, error: "cards must list 1 to 5 cards" };
  const cards: LetterRequest["cards"] = [];
  for (const c of b.cards) {
    const o = c as Record<string, unknown>;
    if (typeof o?.id !== "string" || !Object.hasOwn(CARDS, o.id)) return { ok: false, error: "unknown card id" };
    if (typeof o.count !== "number" || !Number.isInteger(o.count) || o.count < 1 || o.count > 1000) return { ok: false, error: "invalid count" };
    cards.push({ id: o.id, count: o.count });
  }
  const g = (typeof b.groups === "object" && b.groups !== null ? b.groups : {}) as Record<string, unknown>;
  const groups = Object.fromEntries(
    GROUPS.map((k) => [k, typeof g[k] === "number" && Number.isInteger(g[k]) && (g[k] as number) >= 0 && (g[k] as number) <= 10000 ? (g[k] as number) : 0]),
  ) as LetterRequest["groups"];
  return { ok: true, value: { month: b.month, readings, cards, groups, lang: parseLang(b.lang) } };
}

export function buildLetterMessage(req: LetterRequest): string {
  const lang = replyLanguage(req.lang ?? "en", null);
  const cards = req.cards.map((c) => `${CARDS[c.id]!.name} (${c.count} times; ${CARDS[c.id]!.keywords.join(", ")})`).join("; ");
  const groups = GROUPS.map((k) => `${k}: ${req.groups[k]}`).join(", ");
  return [
    `Reply language: ${lang.name}.`,
    `Month: ${req.month}. Readings this month: ${req.readings}.`,
    `Cards that came up most: ${cards}.`,
    `Cards by group: ${groups}.`,
  ].join("\n");
}
