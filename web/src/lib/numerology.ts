/** Birth-date numerology used by the free tools. Pure functions, so the
 * pages can run them in the browser and nothing is sent. */

const digitSum = (n: number) => String(n).split("").reduce((s, d) => s + +d, 0);

/** Birth cards: add month, day and year, then add the digits until the total
 * is 22 or less. 22 is The Fool (0), which pairs with The Emperor (4). A
 * two-digit total also gives the card for the sum of its digits. Returns
 * Major Arcana numbers, the main card first. */
export function birthCards(y: number, m: number, d: number): number[] {
  let n = y + m + d;
  while (n > 22) n = digitSum(n);
  if (n === 22) return [0, 4];
  const out = [n];
  while (n >= 10) {
    n = digitSum(n);
    out.push(n);
  }
  return out;
}

/** The year card: the same sum with the chosen year in place of the birth year. */
export const yearCard = (year: number, m: number, d: number) => birthCards(year, m, d)[0]!;

/** Life path number: add every digit of the birth date and reduce to one
 * digit, keeping the master numbers 11, 22 and 33. */
export function lifePath(y: number, m: number, d: number): number {
  let n = digitSum(y) + digitSum(m) + digitSum(d);
  while (n > 9 && n !== 11 && n !== 22 && n !== 33) n = digitSum(n);
  return n;
}

/** The Major Arcana card linked to a life path number: the card with that
 * number, with 22 as The Fool and 33 as its digit sum, 6 (The Lovers). */
export const lifePathCard = (n: number) => (n === 22 ? 0 : n === 33 ? 6 : n);

/** Parses an <input type="date"> value. */
export function parseDate(v: string): [number, number, number] | null {
  const m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(v);
  return m ? [+m[1]!, +m[2]!, +m[3]!] : null;
}

export const LIFE_PATH: Record<number, string> = {
  1: "Independence and new beginnings. You like to lead and to make your own way.",
  2: "Partnership and balance. You notice what others feel and help people meet in the middle.",
  3: "Expression and creativity. You think out loud, make things and bring people together.",
  4: "Steadiness and hard work. You build things that last, one careful step at a time.",
  5: "Freedom and change. You learn by trying, travelling and taking a chance.",
  6: "Care and responsibility. You look after people, homes and communities.",
  7: "Reflection and searching. You need time alone to think and find out what is true.",
  8: "Ambition and results. You are drawn to work, money and making a mark.",
  9: "Compassion and completion. You see the bigger picture and want to give back.",
  11: "A master number: intuition and inspiration. You sense things early and can light the way for others.",
  22: "A master number: the master builder. You can turn big ideas into something real.",
  33: "A master number: the master teacher. You lead through kindness and example.",
};
