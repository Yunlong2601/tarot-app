import { test } from 'node:test';
import assert from 'node:assert/strict';
import { shuffleDeck, takeCard, randomInt } from '../src/lib/draw-deck.ts';

const cards = Array.from({ length: 78 }, (_, id) => ({ id }));
test('a shuffled deck preserves all 78 identities and leaves its source untouched', () => {
  const before = structuredClone(cards);
  const deck = shuffleDeck(cards, .25);
  assert.equal(deck.length, 78);
  assert.deepEqual(new Set(deck.map(d => d.card.id)), new Set(cards.map(c => c.id)));
  assert.deepEqual(cards, before);
  assert.ok(deck.every(d => !d.open && typeof d.reversed === 'boolean'));
});
test('choosing through the whole fixed deck cannot repeat a card or change orientations', () => {
  const deck = shuffleDeck(cards, .5);
  const fixed = new Map(deck.map(d => [d.card.id, d.reversed]));
  const chosen = [];
  while (deck.length) chosen.push(takeCard(deck, Math.floor(deck.length / 2))!);
  assert.equal(new Set(chosen.map(d => d.card.id)).size, 78);
  assert.ok(chosen.every(d => fixed.get(d.card.id) === d.reversed && !d.open));
});
test('invalid and stale choices leave the deck unchanged', () => {
  const deck = shuffleDeck(cards, 0), before = deck.slice();
  for (const index of [-1, 78, 1.5, NaN]) assert.equal(takeCard(deck, index), undefined);
  assert.deepEqual(deck, before);
});
test('orientation settings include all-upright and all-reversed decks', () => {
  assert.ok(shuffleDeck(cards, 0).every(d => !d.reversed));
  assert.ok(shuffleDeck(cards, 1).every(d => d.reversed));
  for (const chance of [-1, 2, NaN]) assert.throws(() => shuffleDeck(cards, chance), RangeError);
  assert.deepEqual(shuffleDeck([], .25), []);
});
test('crypto range validation and bounds', () => {
  for (const size of [0, -1, 1.5, Infinity]) assert.throws(() => randomInt(size), RangeError);
  for (const size of [1, 3, 78]) for (let i = 0; i < 40; i++) {
    const value = randomInt(size);
    assert.ok(Number.isInteger(value) && value >= 0 && value < size);
  }
});
