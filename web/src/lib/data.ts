// The site's content comes from the same data as the app and the readings, so
// they never disagree.
import { readFileSync } from "node:fs";
import { join } from "node:path";
import { CARDS } from "../../../backend/src/cards.ts";
import { SPREADS } from "../../../backend/src/spreads.ts";

export { CARDS, SPREADS };
export type CardId = keyof typeof CARDS;
export type SpreadId = keyof typeof SPREADS;

export const cardIds = Object.keys(CARDS) as CardId[];
export const spreadIds = Object.keys(SPREADS) as SpreadId[];

/** major_00_fool -> major-00-fool, used in page addresses. */
export const slug = (id: string) => id.replace(/_/g, "-");
export const suitTitle = (s?: string | null) => (s ? s[0]!.toUpperCase() + s.slice(1) : "Major Arcana");
export const titleCase = (s: string) => s[0]!.toUpperCase() + s.slice(1);
export const plural = (n: number, word: string) => `${n} ${word}${n === 1 ? "" : "s"}`;

/** What each spread is for and where it comes from, as the app shows them
 * (app/lib/data/spreads.dart). The backend's `purpose` text is written for the
 * reading model, not for people, so the site never shows it. Read at build
 * time; builds run from this folder. */
function readAppSpreads(): Record<string, { blurb: string; source: string }> {
  const dart = readFileSync(join(process.cwd(), "../app/lib/data/spreads.dart"), "utf8");
  const consts = Object.fromEntries([...dart.matchAll(/^const (_\w+) = '([^']*)';/gm)].map((m) => [m[1], m[2]]));
  const text = (src: string) =>
    src.startsWith("_") ? consts[src]! : [...src.matchAll(/'([^']*)'/g)].map((m) => m[1]).join("");
  const out: Record<string, { blurb: string; source: string }> = {};
  for (const block of dart.split("SpreadDef(").slice(1)) {
    const wire = block.match(/wire: '([a-z_]+)'/)?.[1];
    const blurb = block.match(/blurb:\s*((?:'[^']*'\s*)+)/)?.[1];
    const source = block.match(/source:\s*((?:'[^']*'\s*)+|_\w+)/)?.[1];
    if (!wire || !blurb || !source) continue;
    out[wire] = { blurb: text(blurb), source: text(source) };
  }
  for (const id of Object.keys(SPREADS)) {
    if (!out[id]) throw new Error(`No blurb or source for spread ${id} in spreads.dart`);
  }
  return out;
}
export const APP_SPREADS = readAppSpreads();

/** The deck as the browser tools need it. */
export const deckForTools = cardIds.map((id) => ({
  id,
  slug: slug(id),
  name: CARDS[id].name,
  major: CARDS[id].arcana === "major",
  n: CARDS[id].number,
}));
