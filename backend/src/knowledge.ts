import { CARDS } from "./cards";
import type { Spread } from "./validate";

/** Position labels. The three-card spread uses the "path" framing for now. */
export const POSITIONS: Record<Spread, string[]> = {
  single: ["The card"],
  three: ["Where it began", "Where it stands", "Where it is heading"],
  celtic: [
    "The heart of it", "What crosses it", "Foundation", "Recent past", "Aim",
    "Near horizon", "You", "Surroundings", "Hopes and fears", "Direction",
  ],
};

const SUIT_LOGIC: Record<string, string> = {
  wands: "Wands (Fire): drive, creativity, will; asks what do I want and will I act",
  cups: "Cups (Water): feeling, relationships, imagination; asks what do I feel",
  swords: "Swords (Air): thought, speech, conflict, truth; asks what do I believe",
  pentacles: "Pentacles (Earth): body, work, money, home; asks what is real and sustainable",
};

const NUMBER_MEANING: Record<number, string> = {
  1: "a seed or opening", 2: "choice and balance", 3: "growth, first results", 4: "structure and rest",
  5: "friction, the rough middle", 6: "relief, exchange", 7: "a test, standing your ground",
  8: "movement, effort", 9: "near completion, resilience", 10: "completion and overload",
};

const COURT: Record<string, string> = {
  Page: "learner or messenger: curiosity, a first attempt",
  Knight: "in motion: pursuit; strength is drive, shadow is going too far or too fast",
  Queen: "inner mastery of the suit: receptive, embodied, sets boundaries",
  King: "outer mastery of the suit: leadership, responsibility; shadow is control",
};

const rankOf = (name: string): string => name.split(" ")[0]!;
const isCourt = (name: string): boolean => name in COURT || rankOf(name) in COURT;

export type DrawnLike = { id: string; reversed: boolean };

/** Facts computed in code so the model never has to count (or invent counts). */
export function spreadFacts(cards: DrawnLike[]): string {
  const n = cards.length;
  const infos = cards.map((c) => CARDS[c.id]!);
  const majors = infos.filter((i) => i.arcana === "major").length;
  const suits: Record<string, number> = {};
  let courts = 0;
  const byNumber = new Map<number, number[]>();
  const elements: Record<string, number> = {};
  infos.forEach((i, idx) => {
    if (i.arcana !== "minor") return;
    suits[i.suit!] = (suits[i.suit!] ?? 0) + 1;
    if (isCourt(i.name)) courts++;
    else if (i.number !== null) byNumber.set(i.number, [...(byNumber.get(i.number) ?? []), idx + 1]);
    if (i.element) elements[i.element] = (elements[i.element] ?? 0) + 1;
  });
  const suitText = Object.keys(suits).length
    ? Object.entries(suits).map(([s, c]) => `${s} ${c}`).join(", ")
    : "none";
  const rev = cards.map((c, i) => (c.reversed ? i + 1 : 0)).filter(Boolean);
  const repeats = [...byNumber.entries()].filter(([, p]) => p.length > 1)
    .map(([num, p]) => `two or more ${num}s (positions ${p.join(", ")})`);
  const topEl = Object.entries(elements).sort((a, b) => b[1] - a[1]);
  const dominant = topEl.length && topEl[0]![1] > 1 && (topEl.length === 1 || topEl[0]![1] > topEl[1]![1])
    ? topEl[0]![0] : "none";
  return [
    `majors: ${majors} of ${n}`,
    `suits (minors): ${suitText}; courts: ${courts}`,
    `reversed: ${rev.length} of ${n}${rev.length ? ` (positions ${rev.join(", ")})` : ""}`,
    `repeated numbers: ${repeats.length ? repeats.join("; ") : "none"}`,
    `dominant element: ${dominant}`,
  ].join("\n");
}

/** One card's block for the prompt, using only what applies to its orientation. */
export function cardBlock(c: DrawnLike, index: number, position: string): string {
  const info = CARDS[c.id]!;
  const orient = c.reversed ? "reversed" : "upright";
  const meta = info.arcana === "major"
    ? `Major${info.number !== null ? ` ${info.number}` : ""}${info.association ? `, ${info.association}` : ""}`
    : `${info.suit}${isCourt(info.name) ? " court" : ` ${info.number}`}, ${info.element}`;
  const lines: string[] = [`${index + 1}. ${position}: ${info.name}, ${orient} (${meta})`];
  if (info.k) {
    const k = info.k;
    lines.push(`   essence: ${k.essence}`);
    if (c.reversed) {
      lines.push(`   core (reversed): ${k.reversed.core}`);
      lines.push(`   modes: ${k.reversed.modes.join(" / ")}`);
    } else {
      lines.push(`   core: ${k.upright.core}`);
      lines.push(`   light: ${k.upright.light}; shadow: ${k.upright.shadow}`);
    }
    lines.push(`   image: ${k.imagery}`);
  } else {
    lines.push(`   meaning (${orient}): ${c.reversed ? info.reversed : info.upright}`);
    lines.push(`   keywords: ${info.keywords.join(", ")}`);
    if (info.suit) lines.push(`   suit: ${SUIT_LOGIC[info.suit]}`);
    if (info.number !== null && !isCourt(info.name)) lines.push(`   number ${info.number}: ${NUMBER_MEANING[info.number] ?? ""}`);
    if (isCourt(info.name)) lines.push(`   court: ${COURT[rankOf(info.name)]}`);
  }
  return lines.join("\n");
}

// ---- Safety pre-checks (run before any model call) ----

const normalise = (t: string): string =>
  t.normalize("NFKD").replace(/[̀-ͯ​-‏⁠﻿]/g, "").toLowerCase();

const CRISIS = [
  /\bkill (myself|me)\b/, /\bsuicid/, /\bend (my|it all|my own) (life|lives)?\b/, /\bwant to die\b/,
  /\bself[- ]?harm/, /\b(hurt|harm|cut|injure) myself\b/, /\bdon'?t want to (live|be here|be alive)\b/,
  /\bbetter off dead\b/, /\bno reason to live\b/, /\b(he|she|they|my (partner|husband|wife|parent|dad|mom)) (hits|beats|abuses) me\b/,
  /\bdomestic (violence|abuse)\b/, /\bbeing abused\b/,
];

export function detectCrisis(...texts: (string | null | undefined)[]): boolean {
  const t = normalise(texts.filter(Boolean).join(" \n "));
  return CRISIS.some((r) => r.test(t));
}

/** Fixed, human-written reply: no model call. Numbers and sites should be re-verified before launch. */
export const CRISIS_MESSAGE =
  "It sounds like you may be going through something really painful. A card reading cannot help with this, but people can. " +
  "If you might hurt yourself or someone is hurting you, please contact your local emergency number right now. " +
  "In the US you can call or text 988 (Suicide & Crisis Lifeline). Elsewhere, findahelpline.com lists free helplines by country. " +
  "If you can, reach out to someone you trust today. You deserve real support.";

const RESTRICTED: [string, RegExp][] = [
  ["medical", /\b(diagnos|cancer|tumou?r|medication|symptom|surgery|disease|therapy|treatment|illness|sick)\b/],
  ["legal", /\b(lawsuit|sue\b|court|lawyer|attorney|custody|divorce case|visa|immigration)\b/],
  ["financial", /\b(invest|stock|crypto|bitcoin|loan|mortgage|tax(es)?|lottery|should i buy|trading)\b/],
  ["death", /\b(when will i die|lifespan|how long (will|do) i live|will .* die)\b/],
  ["pregnancy", /\b(pregnan|conceive|fertility)\b/],
  ["gambling", /\b(gambl|casino|betting|lotto)\b/],
];

/** A hint for the model, never a reason to refuse by itself. */
export function restrictedTopic(...texts: (string | null | undefined)[]): string | null {
  const t = normalise(texts.filter(Boolean).join(" \n "));
  return RESTRICTED.find(([, r]) => r.test(t))?.[0] ?? null;
}
