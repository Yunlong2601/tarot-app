// Build-time only: keep filesystem-backed shared data out of the browser bundle.
import { APP_SPREADS, cardIds, slug, spreadIds } from './data';
import { firstSentence, i18n, LEARN_SLUGS, type Locale } from '../i18n';
import { BASE } from '../config';
import type { SearchEntry } from './search';

const shortAliases: Record<string, string[]> = { cups_queen: ['qoc'], cups_king: ['koc'], major_20_judgement: ['judgment'] };

export function buildSearchIndex(locale: Locale): SearchEntry[] {
  const L = i18n(locale), english = i18n('en');
  return [
    ...cardIds.map(id => ({id, type:'cards' as const, title:L.cards[id]!.name,
      href:L.url(`cards/${slug(id)}`), description:firstSentence(L.cards[id]!.upright),
      keywords:[id, english.cards[id]!.name, ...L.cards[id]!.keywords, ...english.cards[id]!.keywords], aliases:[english.cards[id]!.name, ...(shortAliases[id] ?? [])], image:`${BASE}cards/art/${id}.jpg`})),
    ...spreadIds.map(id => ({id, type:'spreads' as const, title:L.content.spreads[id].name,
      href:L.url(`spreads/${slug(id)}`), description:L.content.spreads[id].blurb,
      keywords:[id, english.content.spreads[id].name, ...L.content.spreads[id].positions], aliases:[english.content.spreads[id].name], diagram:APP_SPREADS[id].layout})),
    ...LEARN_SLUGS.map(id => ({id, type:'learn' as const, title:L.learn.guides[id].title,
      href:L.url(`learn/${id}`), description:L.learn.guides[id].description,
      keywords:[id, english.learn.guides[id].title], aliases:[english.learn.guides[id].title]})),
    {id:'connected-reading',type:'learn' as const,title:L.growth.exampleTitle,href:L.url('learn/connected-reading'),description:L.growth.exampleLead,keywords:['connect cards',english.growth.exampleTitle]},
  ];
}
