import { validDraft, type Draft, type Spread, type StoragePort } from './workspace.ts';
import type { DrawnCard } from './draw-deck.ts';

/** One explicit, tab-local handoff. Questions never enter a URL or a server request. */
export const DRAW_TRANSFER_KEY = 'shentarot-draw-transfer-v1';
export const drawReturnKey = (path: string) => `${DRAW_TRANSFER_KEY}-return:${path}`;

export function freeDrawSpreads(name: string, position: string): Spread[] {
  return Array.from({ length: 10 }, (_, i) => ({
    id: `draw_${i + 1}`,
    name: name.replace('{n}', String(i + 1)),
    positions: Array.from({ length: i + 1 }, (_, j) => position.replace('{n}', String(j + 1))),
  }));
}

export function makeDrawTransfer(
  spread: Spread,
  cards: readonly DrawnCard<{ id: string }>[],
  question: string,
  ids: string[],
): Draft | null {
  if (!cards.length || cards.length > 10 || cards.some(card => !card.open)) return null;
  const draft: Draft = {
    version: 1, spread: spread.id,
    cards: cards.map(({ card, reversed }) => ({ id: card.id, reversed })),
    question, impression: '', reflection: '',
  };
  return validDraft(draft, [spread], ids) ? draft : null;
}

export function readDrawTransfer(storage: StoragePort, spreads: Spread[], ids: string[], key = DRAW_TRANSFER_KEY): Draft | null {
  try {
    const value: unknown = JSON.parse(storage.getItem(key) ?? 'null');
    return validDraft(value, spreads, ids) && value.cards.every(card => card.id !== '') ? value : null;
  } catch { return null; }
}
