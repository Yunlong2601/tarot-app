import { CARDS, cardIds } from "./data.ts";

/** Birth cards: the Major Arcana numbered 1 to 21, then the Fool, which
 * stands for a total of 22. */
export const BIRTH = [
  ...cardIds.filter((id) => CARDS[id].arcana === "major" && CARDS[id].number),
  ...cardIds.filter((id) => CARDS[id].arcana === "major" && !CARDS[id].number),
];

/** The number a birth card stands for (the Fool counts as 22). */
export const birthNumber = (id: (typeof cardIds)[number]) => CARDS[id].number || 22;
