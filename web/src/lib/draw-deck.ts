/** A shuffle fixes every card and orientation before the visitor chooses. */
export type DrawnCard<T> = { card: T; reversed: boolean; open: boolean };

export function randomInt(size: number): number {
  if (!Number.isInteger(size) || size < 1 || size > 0x100000000) throw new RangeError('Invalid random range');
  const value = new Uint32Array(1);
  const limit = 0x100000000 - (0x100000000 % size);
  do { crypto.getRandomValues(value); } while (value[0]! >= limit);
  return value[0]! % size;
}

export function shuffleDeck<T>(cards: readonly T[], reversals: number, random = randomInt): DrawnCard<T>[] {
  if (!Number.isFinite(reversals) || reversals < 0 || reversals > 1) throw new RangeError('Invalid reversal probability');
  const deck = cards.slice();
  for (let i = deck.length - 1; i > 0; i--) {
    const j = random(i + 1);
    [deck[i], deck[j]] = [deck[j]!, deck[i]!];
  }
  return deck.map(card => ({ card, reversed: random(1000) < reversals * 1000, open: false }));
}

/** Remove the chosen card, retaining the fixed order/orientations of the others. */
export function takeCard<T>(deck: DrawnCard<T>[], index: number): DrawnCard<T> | undefined {
  if (!Number.isInteger(index) || index < 0 || index >= deck.length) return undefined;
  return deck.splice(index, 1)[0];
}
