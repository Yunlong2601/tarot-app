import type { Draft } from './workspace';
/** Editorial fixture, deliberately shared by the example and manual workspace. */
export const EXAMPLE = { spread: 'three_decision' as const, cards: [
  { id: 'major_01_magician', reversed: false },
  { id: 'pentacles_two', reversed: true },
  { id: 'pentacles_eight', reversed: false },
] };
/** Replace only the confirmed cards; keep unrelated notes and independent save. */
export function applyExample(current: Draft, question: string): Draft {
  return { ...current, spread: EXAMPLE.spread, cards: EXAMPLE.cards.map(p => ({ ...p })), question: current.question || question };
}
