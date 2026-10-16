import { CARDS } from "./cards";

export type Spread = "single" | "three" | "celtic";

export const SPREAD_SIZE: Record<Spread, number> = { single: 1, three: 3, celtic: 10 };

export const MAX_QUESTION_LENGTH = 300;

export interface ReadingRequest {
  spread: Spread;
  cards: { id: string; reversed: boolean }[];
  question: string | null;
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

export function parseReadingRequest(body: unknown): Parsed<ReadingRequest> {
  if (typeof body !== "object" || body === null) return fail("body must be a JSON object");
  const b = body as Record<string, unknown>;

  const spread = b.spread;
  if (spread !== "single" && spread !== "three" && spread !== "celtic") {
    return fail("spread must be single, three or celtic");
  }

  if (!Array.isArray(b.cards) || b.cards.length !== SPREAD_SIZE[spread]) {
    return fail(`spread ${spread} needs exactly ${SPREAD_SIZE[spread]} cards`);
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

  let question: string | null = null;
  if (b.question !== undefined && b.question !== null) {
    if (typeof b.question !== "string") return fail("question must be text");
    if (b.question.length > MAX_QUESTION_LENGTH * 2) return fail("question too long");
    const cleaned = cleanQuestion(b.question);
    if (cleaned.length > MAX_QUESTION_LENGTH) return fail("question too long");
    question = cleaned === "" ? null : cleaned;
  }

  return { ok: true, value: { spread, cards, question } };
}

function fail(error: string): { ok: false; error: string } {
  return { ok: false, error };
}

export function isUuid(v: unknown): v is string {
  return typeof v === "string" && /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(v);
}
