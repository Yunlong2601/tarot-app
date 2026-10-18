import type { CardId } from "./data.ts";

/** Zodiac signs and their tarot cards, as the Golden Dawn tradition assigns
 * them: each sign's Major Arcana card, its traditional ruling planet's card,
 * and the three numbered cards of its decans (ten-degree thirds). */
export interface Sign {
  slug: string;
  name: string;
  dates: string;
  /** Last day of the sign as [month, day]; the sign starts the day after the previous one ends. */
  end: [number, number];
  element: "Fire" | "Earth" | "Air" | "Water";
  ruler: string;
  major: CardId;
  decans: [CardId, CardId, CardId];
}

const SUIT = { Fire: "wands", Water: "cups", Air: "swords", Earth: "pentacles" } as const;
const PIP = ["", "ace", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"];
const dec = (el: Sign["element"], first: number) =>
  [0, 1, 2].map((i) => `${SUIT[el]}_${PIP[first + i]}`) as [CardId, CardId, CardId];

export const PLANET_CARD: Record<string, CardId> = {
  Mars: "major_16_tower",
  Venus: "major_03_empress",
  Mercury: "major_01_magician",
  Moon: "major_02_high_priestess",
  Sun: "major_19_sun",
  Jupiter: "major_10_wheel_of_fortune",
  Saturn: "major_21_world",
};

export const SIGNS: Sign[] = [
  { slug: "aries", name: "Aries", dates: "21 March to 19 April", end: [4, 19], element: "Fire", ruler: "Mars", major: "major_04_emperor", decans: dec("Fire", 2) },
  { slug: "taurus", name: "Taurus", dates: "20 April to 20 May", end: [5, 20], element: "Earth", ruler: "Venus", major: "major_05_hierophant", decans: dec("Earth", 5) },
  { slug: "gemini", name: "Gemini", dates: "21 May to 20 June", end: [6, 20], element: "Air", ruler: "Mercury", major: "major_06_lovers", decans: dec("Air", 8) },
  { slug: "cancer", name: "Cancer", dates: "21 June to 22 July", end: [7, 22], element: "Water", ruler: "Moon", major: "major_07_chariot", decans: dec("Water", 2) },
  { slug: "leo", name: "Leo", dates: "23 July to 22 August", end: [8, 22], element: "Fire", ruler: "Sun", major: "major_08_strength", decans: dec("Fire", 5) },
  { slug: "virgo", name: "Virgo", dates: "23 August to 22 September", end: [9, 22], element: "Earth", ruler: "Mercury", major: "major_09_hermit", decans: dec("Earth", 8) },
  { slug: "libra", name: "Libra", dates: "23 September to 22 October", end: [10, 22], element: "Air", ruler: "Venus", major: "major_11_justice", decans: dec("Air", 2) },
  { slug: "scorpio", name: "Scorpio", dates: "23 October to 21 November", end: [11, 21], element: "Water", ruler: "Mars", major: "major_13_death", decans: dec("Water", 5) },
  { slug: "sagittarius", name: "Sagittarius", dates: "22 November to 21 December", end: [12, 21], element: "Fire", ruler: "Jupiter", major: "major_14_temperance", decans: dec("Fire", 8) },
  { slug: "capricorn", name: "Capricorn", dates: "22 December to 19 January", end: [1, 19], element: "Earth", ruler: "Saturn", major: "major_15_devil", decans: dec("Earth", 2) },
  { slug: "aquarius", name: "Aquarius", dates: "20 January to 18 February", end: [2, 18], element: "Air", ruler: "Saturn", major: "major_17_star", decans: dec("Air", 5) },
  { slug: "pisces", name: "Pisces", dates: "19 February to 20 March", end: [3, 20], element: "Water", ruler: "Jupiter", major: "major_18_moon", decans: dec("Water", 8) },
];

export const SUIT_OF = SUIT;

/** The sign for a month and day (dates vary by a day from year to year). */
export function signFor(m: number, d: number): Sign {
  const byEnd = [...SIGNS].sort((a, b) => a.end[0] * 100 + a.end[1] - (b.end[0] * 100 + b.end[1]));
  return byEnd.find((s) => m * 100 + d <= s.end[0] * 100 + s.end[1]) ?? byEnd[0]!;
}
