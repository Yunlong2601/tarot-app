import { CARDS, cardIds } from "./data.ts";

/** Birth cards: the Major Arcana numbered 1 to 21. */
export const BIRTH = cardIds.filter((id) => CARDS[id].arcana === "major" && CARDS[id].number);
