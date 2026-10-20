import { CARDS } from "./cards";
import { parseLang } from "./language";
import { isSpread, spreadSize, type Spread } from "./spreads";

export type { Spread };

export const MAX_QUESTION_LENGTH = 300;

export interface ReadingRequest {
  spread: Spread;
  cards: { id: string; reversed: boolean }[];
  question: string | null;
  /** What the user noticed in the cards before the reading (optional). */
  impression?: string | null;
  /** App language code (see language.ts); defaults to English. */
  lang?: string;
}

export type Parsed<T> = { ok: true; value: T } | { ok: false; error: string };

/** Plain text only: drops control characters and angle brackets (so the
 * question cannot close the tag it is wrapped in), collapses whitespace. */
export function cleanQuestion(raw: string): string {
  return raw
    .replace(/[\u0000-\u001f\u007f-\u009f\u2028\u2029]/g, " ")
    .replace(/[<>]/g, "")
    .replace(/\s+/g, " ")
    .trim();
}

function parseSpreadAndCards(b: Record<string, unknown>): Parsed<{ spread: Spread; cards: ReadingRequest["cards"] }> {
  const spread = b.spread;
  if (!isSpread(spread)) return fail("unknown spread");
  if (!Array.isArray(b.cards) || b.cards.length !== spreadSize(spread)) {
    return fail(`spread ${spread} needs exactly ${spreadSize(spread)} cards`);
  }
  const seen = new Set<string>();
  const cards: ReadingRequest["cards"] = [];
  for (const c of b.cards) {
    if (typeof c !== "object" || c === null) return fail("invalid card");
    const { id, reversed } = c as Record<string, unknown>;
    if (typeof id !== "string" || !Object.hasOwn(CARDS, id)) return fail("unknown card id");
    if (typeof reversed !== "boolean") return fail("reversed must be true or false");
    if (seen.has(id)) return fail("duplicate card");
    seen.add(id);
    cards.push({ id, reversed });
  }
  return { ok: true, value: { spread, cards } };
}

function parseText(raw: unknown, max: number, what: string): Parsed<string | null> {
  if (raw === undefined || raw === null) return { ok: true, value: null };
  if (typeof raw !== "string") return fail(`${what} must be text`);
  if (raw.length > max * 2) return fail(`${what} too long`);
  const cleaned = cleanQuestion(raw);
  if (cleaned.length > max) return fail(`${what} too long`);
  return { ok: true, value: cleaned === "" ? null : cleaned };
}

export function parseReadingRequest(body: unknown): Parsed<ReadingRequest> {
  if (typeof body !== "object" || body === null) return fail("body must be a JSON object");
  const b = body as Record<string, unknown>;
  const sc = parseSpreadAndCards(b);
  if (!sc.ok) return sc;
  const q = parseText(b.question, MAX_QUESTION_LENGTH, "question");
  if (!q.ok) return q;
  const imp = parseText(b.impression, MAX_QUESTION_LENGTH, "impression");
  if (!imp.ok) return imp;
  return { ok: true, value: { ...sc.value, question: q.value, impression: imp.value, lang: parseLang(b.lang) } };
}

export const MAX_FOLLOWUP_LENGTH = 300;
export const MAX_CONTEXT_READING_LENGTH = 4000;

export interface FollowupRequest extends ReadingRequest {
  /** The earlier reading text, sent back by the app as context. Untrusted. */
  reading: string;
  followup: string;
  /** One extra card drawn to clarify the reading (optional, not in the spread). */
  clarifier?: { id: string; reversed: boolean } | null;
}

export function parseFollowupRequest(body: unknown): Parsed<FollowupRequest> {
  if (typeof body !== "object" || body === null) return fail("body must be a JSON object");
  const b = body as Record<string, unknown>;
  const sc = parseSpreadAndCards(b);
  if (!sc.ok) return sc;
  const q = parseText(b.question, MAX_QUESTION_LENGTH, "question");
  if (!q.ok) return q;
  const f = parseText(b.followup, MAX_FOLLOWUP_LENGTH, "followup");
  if (!f.ok) return f;
  if (f.value === null) return fail("followup is required");
  const r = parseText(b.reading, MAX_CONTEXT_READING_LENGTH, "reading");
  if (!r.ok) return r;
  if (r.value === null) return fail("reading is required");
  let clarifier: FollowupRequest["clarifier"] = null;
  if (b.clarifier !== undefined && b.clarifier !== null) {
    if (typeof b.clarifier !== "object") return fail("invalid clarifier");
    const { id, reversed } = b.clarifier as Record<string, unknown>;
    if (typeof id !== "string" || !Object.hasOwn(CARDS, id)) return fail("unknown clarifier card id");
    if (typeof reversed !== "boolean") return fail("reversed must be true or false");
    if (sc.value.cards.some((c) => c.id === id)) return fail("clarifier is already in the spread");
    clarifier = { id, reversed };
  }
  return { ok: true, value: { ...sc.value, question: q.value, reading: r.value, followup: f.value, clarifier, lang: parseLang(b.lang) } };
}

function fail(error: string): { ok: false; error: string } {
  return { ok: false, error };
}

export function isUuid(v: unknown): v is string {
  return typeof v === "string" && /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(v);
}
