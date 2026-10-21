// The site's content comes from the same data as the app and the readings, so
// they never disagree.
import { readFileSync } from "node:fs";
import { join } from "node:path";
import { CARDS } from "../../../backend/src/cards.ts";
import { SPREADS } from "../../../backend/src/spreads.ts";
import type { I18n } from "../i18n/index.ts";

export { CARDS, SPREADS };
export type CardId = keyof typeof CARDS;
export type SpreadId = keyof typeof SPREADS;

export const cardIds = Object.keys(CARDS) as CardId[];
export const spreadIds = Object.keys(SPREADS) as SpreadId[];

/** major_00_fool -> major-00-fool, used in page addresses. */
export const slug = (id: string) => id.replace(/_/g, "-");
export const suitTitle = (s?: string | null) => (s ? s[0]!.toUpperCase() + s.slice(1) : "Major Arcana");
export const titleCase = (s: string) => s[0]!.toUpperCase() + s.slice(1);
/** What each group of cards is about, shown on the card pages. */
export const GROUP_ABOUT: Record<string, string> = {
  major: "Life's big themes and turning points",
  wands: "Energy, drive and creativity",
  cups: "Feelings, love and relationships",
  swords: "Thought, conflict and truth",
  pentacles: "Work, money and the body",
};
export const plural = (n: number, word: string) => `${n} ${word}${n === 1 ? "" : "s"}`;

/** What each spread is for and where it comes from, as the app shows them
 * (app/lib/data/spreads.dart). The backend's `purpose` text is written for the
 * reading model, not for people, so the site never shows it. Read at build
 * time; builds run from this folder. */
function readAppSpreads(): Record<string, { blurb: string; source: string; layout: [number, number][] }> {
  const dart = readFileSync(join(process.cwd(), "../app/lib/data/spreads.dart"), "utf8");
  const consts = Object.fromEntries([...dart.matchAll(/^const (_\w+) = '([^']*)';/gm)].map((m) => [m[1], m[2]]));
  const text = (src: string) =>
    src.startsWith("_") ? consts[src]! : [...src.matchAll(/'([^']*)'/g)].map((m) => m[1]).join("");
  const layouts = Object.fromEntries([...dart.matchAll(/const (_\w+) = \[([\s\S]*?)\];/g)].map(m => [m[1], m[2]]));
  const out: Record<string, { blurb: string; source: string; layout: [number, number][] }> = {};
  for (const block of dart.split("SpreadDef(").slice(1)) {
    const wire = block.match(/wire: '([a-z_]+)'/)?.[1];
    const blurb = block.match(/blurb:\s*((?:'[^']*'\s*)+)/)?.[1];
    const source = block.match(/source:\s*((?:'[^']*'\s*)+|_\w+)/)?.[1];
    if (!wire || !blurb || !source) continue;
    const layoutSrc = block.match(/layout:\s*(_\w+|\[[\s\S]*?\]),/)?.[1];
    const layoutText = layoutSrc?.startsWith('_') ? layouts[layoutSrc] : layoutSrc;
    const layout = [...(layoutText ?? '').matchAll(/Offset\(([\d.]+),\s*([\d.]+)\)/g)].map(m => [Number(m[1]), Number(m[2])] as [number, number]);
    if (layout.length !== SPREADS[wire as keyof typeof SPREADS].positions.length) throw new Error(`Missing layout for ${wire}`);
    out[wire] = { blurb: text(blurb), source: text(source), layout };
  }
  for (const id of Object.keys(SPREADS)) {
    if (!out[id]) throw new Error(`No blurb or source for spread ${id} in spreads.dart`);
  }
  return out;
}
export const APP_SPREADS = readAppSpreads();

/** The deck as the browser tools need it, in one language. */
export const deckForTools = (L: I18n) =>
  cardIds.map((id) => ({
    id,
    slug: slug(id),
    name: L.cards[id]!.name,
    major: CARDS[id].arcana === "major",
    n: CARDS[id].number,
  }));

const SIGN_ELEMENT: Record<string, string> = {
  Aries: "Fire", Leo: "Fire", Sagittarius: "Fire",
  Taurus: "Earth", Virgo: "Earth", Capricorn: "Earth",
  Gemini: "Air", Libra: "Air", Aquarius: "Air",
  Cancer: "Water", Scorpio: "Water", Pisces: "Water",
};
/** A card's element: its suit's, or for a Major Arcana card the element of its
 * zodiac sign or element attribution. Cards attributed to a planet get null. */
export function elementOf(id: CardId): string | null {
  const c = CARDS[id];
  if (c.element) return c.element;
  const a = c.association ?? "";
  return ["Fire", "Water", "Air", "Earth"].includes(a) ? a : (SIGN_ELEMENT[a] ?? null);
}

/** The deck with the short meanings the reading tools show, in one language. */
export const readerDeck = (L: I18n) =>
  cardIds.map((id) => {
    const c = CARDS[id];
    const tr = L.cards[id]!;
    return {
      id,
      slug: slug(id),
      name: tr.name,
      suit: c.suit as string | null,
      n: c.number as number | null,
      keywords: tr.keywords,
      up: tr.upright,
      rev: tr.reversed,
      upQ: tr.k?.upright.question ?? "",
      revQ: tr.k?.reversed.question ?? "",
      el: elementOf(id),
    };
  });
export type ReaderCard = ReturnType<typeof readerDeck>[number];

/** Card meanings for the birthday, zodiac and quiz tools, in one language. */
export const meaningDeck = (L: I18n) =>
  cardIds.map((id) => {
    const c = CARDS[id];
    const tr = L.cards[id]!;
    return {
      id,
      slug: slug(id),
      name: tr.name,
      suit: c.suit as string | null,
      n: c.number as number | null,
      keywords: tr.keywords,
      core: tr.k?.upright.core ?? tr.upright,
      love: tr.k?.upright.love ?? "",
      question: tr.k?.upright.question ?? "",
      el: elementOf(id),
    };
  });
export type MeaningCard = ReturnType<typeof meaningDeck>[number];
