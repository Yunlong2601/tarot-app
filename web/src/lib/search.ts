import { matches, normalise, queryParts } from './workspace.ts';

export interface SearchEntry {
  id: string;
  type: 'cards' | 'spreads' | 'learn';
  title: string;
  href: string;
  description: string;
  keywords: string[];
  aliases?: string[];
  image?: string;
  diagram?: [number, number][];
}

/** Validate the complete lazy-loaded index before rendering any of its entries. */
export function isSearchIndex(value: unknown): value is SearchEntry[] {
  const strings = (items: unknown): items is string[] => Array.isArray(items) && items.every(item => typeof item === 'string');
  const localPath = (path: unknown) => typeof path === 'string' && path.startsWith('/') && !path.startsWith('//') && !path.includes('\\');
  if (!Array.isArray(value)) return false;
  const keys = new Set<string>();
  return value.every(entry => {
    if (!entry || typeof entry !== 'object' || !['cards', 'spreads', 'learn'].includes(entry.type)
      || typeof entry.id !== 'string' || !entry.id || typeof entry.title !== 'string' || !entry.title
      || typeof entry.description !== 'string' || !localPath(entry.href) || !strings(entry.keywords)
      || (entry.aliases !== undefined && !strings(entry.aliases))
      || (entry.image !== undefined && !localPath(entry.image))
      || (entry.diagram !== undefined && (!Array.isArray(entry.diagram) || !entry.diagram.length
        || !entry.diagram.every((point: unknown) => Array.isArray(point) && point.length === 2 && point.every(Number.isFinite))))) return false;
    const key = `${entry.type}:${entry.id}`;
    if (keys.has(key)) return false;
    keys.add(key);
    return true;
  });
}

/** Pure, shared ranking. Filtering runs against public content; no persistent search history is created. */
export function searchEntries(entries: SearchEntry[], raw: string): SearchEntry[] {
  const { words, reversed } = queryParts(raw);
  const needle = words.join(' ');
  return entries.map(entry => {
    const title = normalise(entry.title);
    const aliases = (entry.aliases ?? []).map(alias => queryParts(alias).words.join(' '));
    const score = !words.length ? 4 : title === needle ? 0 : title.startsWith(needle) ? 1
      : aliases.some(alias => alias === needle) ? 2
      : matches([entry.title, ...entry.keywords, ...(entry.aliases ?? []), entry.description].join(' '), words) ? 3 : -1;
    return { entry, score };
  }).filter(result => result.score >= 0)
    .sort((a, b) => a.score - b.score || a.entry.title.localeCompare(b.entry.title, 'en')
      || a.entry.id.localeCompare(b.entry.id, 'en') || a.entry.type.localeCompare(b.entry.type, 'en'))
    .map(({entry}) => {
      if (entry.type !== 'cards' || !reversed) return {...entry};
      const url = new URL(entry.href, 'https://shentarot.invalid');
      url.searchParams.set('orientation', 'reversed');
      url.hash = 'card-meanings';
      return {...entry, href: `${url.pathname}${url.search}${url.hash}`};
    });
}

/** Remove only recognized orientation terms; retain the visitor's original card wording. */
export function withoutReversal(raw: string): string {
  return raw.replace(/reversed|reverse\b|逆位置|逆位|invertid[ao]|renvers[eé]e?|umgekehrt|перев[её]рнут\p{L}*/giu, '').replace(/\s+/g, ' ').trim();
}

/** Original-string ranges keep diacritics intact when displaying matched terms. */
export function matchRanges(title: string, raw: string): [number, number][] {
  let normalized = '', offset = 0;
  const starts: number[] = [], ends: number[] = [];
  for (const character of title) {
    const part = character.normalize('NFKD').replace(/[\u0300-\u036f]/g, '').toLowerCase().replace(/[-_]/g, ' ');
    for (let index = 0; index < part.length; index++) {starts.push(offset);ends.push(offset + character.length);}
    normalized += part;
    offset += character.length;
  }
  const ranges: [number, number][] = [];
  for (const word of queryParts(raw).words) {
    let start = normalized.indexOf(word);
    while (start >= 0) {ranges.push([starts[start]!, ends[start + word.length - 1]!]);start = normalized.indexOf(word, start + word.length);}
  }
  ranges.sort((a,b) => a[0]-b[0] || a[1]-b[1]);
  const merged: [number, number][] = [];
  for (const range of ranges) {
    const previous = merged.at(-1);
    if (previous && range[0] <= previous[1]) previous[1] = Math.max(previous[1],range[1]);
    else merged.push([...range]);
  }
  return merged;
}
