import type { StoragePort } from './workspace';
export const PRACTICE_KEY = 'shentarot-practice-v1';
export const ACTIVITY_IDS = ['notice','position','reversal','connection','review'] as const;
export type ActivityId = typeof ACTIVITY_IDS[number];
export function validProgress(value: unknown): value is ActivityId[] {
  return Array.isArray(value) && value.every(id => ACTIVITY_IDS.includes(id)) && new Set(value).size === value.length;
}
export function readProgress(storage: StoragePort): ActivityId[] {
  const raw = storage.getItem(PRACTICE_KEY);
  if (raw === null) return [];
  const parsed: unknown = JSON.parse(raw);
  if (!validProgress(parsed)) throw new Error('Invalid practice progress');
  return parsed;
}
export function writeProgress(storage: StoragePort, ids: ActivityId[]): void {
  if (!validProgress(ids)) throw new Error('Invalid practice progress');
  storage.setItem(PRACTICE_KEY, JSON.stringify(ids));
}
