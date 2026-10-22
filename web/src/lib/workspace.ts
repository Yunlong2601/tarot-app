/** Browser-only workspace state. Never contains credentials or sends a reading. */
export interface Pick { id: string; reversed: boolean }
export interface Draft { version: 1; spread: string; cards: Pick[]; question: string; impression: string; reflection: string }
export interface Spread { id: string; name: string; positions: string[] }
export const STORAGE_KEY = 'shentarot-reference-v1';
export const blank = (spread: Spread): Draft => ({ version: 1, spread: spread.id, cards: spread.positions.map(() => ({ id: '', reversed: false })), question: '', impression: '', reflection: '' });
export function validDraft(value: unknown, spreads: Spread[], ids: string[]): value is Draft {
  if (!value || typeof value !== 'object') return false;
  const d = value as Draft;
  const spread = spreads.find(s => s.id === d.spread);
  if (d.version !== 1 || !spread || !Array.isArray(d.cards) || d.cards.length !== spread.positions.length) return false;
  if (![d.question, d.impression, d.reflection].every(x => typeof x === 'string' && x.length <= 5000)) return false;
  const selected: string[] = [];
  for (const p of d.cards) {
    if (!p || typeof p.id !== 'string' || (p.id !== '' && !ids.includes(p.id)) || typeof p.reversed !== 'boolean') return false;
    if (p.id) selected.push(p.id);
  }
  return new Set(selected).size === selected.length;
}
export function setPick(d: Draft, index: number, id: string, reversed: boolean): boolean {
  if (index < 0 || index >= d.cards.length || (id && d.cards.some((p, i) => i !== index && p.id === id))) return false;
  d.cards[index] = { id, reversed };
  return true;
}
export function movePick(d: Draft, index: number, delta: number): void {
  const next = index + delta;
  if (index < 0 || next < 0 || index >= d.cards.length || next >= d.cards.length) return;
  [d.cards[index], d.cards[next]] = [d.cards[next]!, d.cards[index]!];
}
export const normalise = (s: string) => s.normalize('NFKD').replace(/[\u0300-\u036f]/g, '').toLowerCase().replace(/[-_]/g, ' ').replace(/\s+/g, ' ').trim();
export function queryParts(raw: string) {
  const reversed = /reversed|reverse\b|逆位|逆位置|invertid[ao]|renvers[eé]e?|umgekehrt|перев[её]рнут/iu.test(raw);
  const query = raw.replace(/reversed|reverse\b|逆位置|逆位|invertid[ao]|renvers[eé]e?|umgekehrt|перев[её]рнут\p{L}*/giu, ' ').trim();
  const aliases: Record<string, string> = { qoc: 'queen cups', koc: 'king cups', judgment: 'judgement' };
  const normal = normalise(query);
  const words = (aliases[normal] ?? normal).replace(/\bcoins?\b/g, 'pentacles').replace(/\bdis[ck]s?\b/g, 'pentacles').replace(/\bstaves\b|\brods\b/g, 'wands').split(' ').filter(Boolean);
  return { reversed, words };
}
export function matches(text: string, words: string[]) { const hay = normalise(text); return words.every(w => hay.includes(w)); }

export interface StoragePort { getItem(key: string): string | null; setItem(key: string, value: string): void; removeItem(key: string): void }
/** Catch denied storage and corrupt data; callers must display a recoverable error. */
export function loadDraft(storage: StoragePort, key: string, spreads: Spread[], ids: string[]): Draft | null {
  try { const value: unknown = JSON.parse(storage.getItem(key) ?? 'null'); return validDraft(value, spreads, ids) ? value : null; }
  catch { return null; }
}
export function saveDraft(storage: StoragePort, key: string, draft: Draft): boolean {
  try { storage.setItem(key, JSON.stringify(draft)); return true; } catch { return false; }
}

/** Detect a real overwrite, excluding property order or transient UI state. */
export function sameDraft(a: Draft, b: Draft): boolean {
  return a.spread===b.spread && a.question===b.question && a.impression===b.impression && a.reflection===b.reflection && a.cards.length===b.cards.length && a.cards.every((p,i)=>p.id===b.cards[i]!.id && p.reversed===b.cards[i]!.reversed);
}
export function hasWork(d: Draft): boolean { return d.cards.some(p=>p.id!=='') || [d.question,d.impression,d.reflection].some(v=>v.trim()!==''); }
export function filterDeck<T extends {id:string;name:string;englishName:string;keywords:string[]}>(deck:T[],query:string,selected:string):T[] {
  const {words}=queryParts(query);
  return deck.filter(c=>c.id===selected || matches([c.id,c.name,c.englishName,...c.keywords].join(' '),words));
}

/** Preserve the physical draw by position; callers confirm any selected tail loss. */
export function losesCards(d: Draft, spread: Spread): boolean { return d.cards.slice(spread.positions.length).some(p=>!!p.id); }
export function changeSpread(d: Draft, spread: Spread): Draft {
  return { ...d, spread: spread.id, cards: spread.positions.map((_,i)=>({...(d.cards[i] ?? {id:'',reversed:false})})) };
}

/** Pair selected positions in reading order, preserving gaps and the whole draw. */
export function connectionPairs(d: Draft): [number, number][] {
  const positions=d.cards.flatMap((p,i)=>p.id ? [i] : []);
  return positions.slice(1).map((position,i)=>[positions[i]!,position]);
}
