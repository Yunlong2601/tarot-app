import assert from 'node:assert/strict';
import {readFileSync,existsSync} from 'node:fs';
import {parseHTML} from 'linkedom';
import {LESSON_EVIDENCE,CARD_EVIDENCE} from '../src/lib/editorial.ts';
const locales=['en','zh-hans','zh-hant','es','de','ja','fr','ru'];
const lessons = {
 'how-to-read-tarot': {sources:2,cards:['cups-five','swords-two','pentacles-three']},
 'asking-questions': {sources:2,cards:['major-01-magician','pentacles-two','pentacles-eight']},
 'reversed-cards': {sources:2,cards:['wands-ace','major-09-hermit','major-08-strength','major-19-sun','major-16-tower','swords-ten','pentacles-eight']},
 'court-cards': {sources:2,cards:['pentacles-page','wands-knight','pentacles-knight','cups-queen','swords-king']},
 'tarot-suits': {sources:3,cards:['wands-four','cups-four','cups-two','swords-ace','pentacles-ten','wands-ace']},
 'tarot-numbers': {sources:2,cards:['cups-five','wands-eight','swords-eight','pentacles-eight']},
 'major-and-minor-arcana': {sources:3,cards:['major-00-fool','major-21-world','major-01-magician','pentacles-eight']},
};
for(const [slug, expected] of Object.entries(lessons)) {
 const evidence=LESSON_EVIDENCE[slug];
 const sourceURLs=evidence.sources.map(s=>s.url);
 assert.equal(sourceURLs.length,expected.sources,slug+': claim-specific sources');
for(const locale of locales){
 const prefix=locale==='en'?'':locale+'/';
 const path=prefix+'learn/'+slug;
 const file=['dist/'+path+'.html','dist/'+path+'/index.html'].find(existsSync);assert.ok(file,path);
 const html=readFileSync(file,'utf8');const {document}=parseHTML(html);
 const copy=JSON.parse(readFileSync(`src/i18n/${locale}/learn.json`,'utf8')).guides[slug];
 const article=document.querySelector('article');assert.ok(article);
 assert.ok(article.querySelector(`a[href="/${prefix}methodology#corrections"]`),locale+': localized correction route');
 assert.equal(copy.sections.length,7,locale+': source/example/check sections');
 for(const source of sourceURLs){
  assert.ok(article.querySelector(`a[href="${source}"]`),locale+': unmodified external source');
  assert.ok(!html.includes('/'+prefix+source),locale+': external source cannot be localized');
 }
 for(const n of [3,4,5,6])assert.ok(article.textContent.includes(copy.sections[n].h),locale+': visible section');
 for(const card of expected.cards)assert.ok(article.querySelector(`a[href="/${prefix}cards/${card}"]`),locale+': local card link');
 const schemas=[...document.querySelectorAll('script[type="application/ld+json"]')].map(s=>JSON.parse(s.textContent));
 const schema=schemas.find(s=>s['@type']==='Article');assert.equal(schema.dateModified,evidence.checkedAt);
 assert.deepEqual(schema.citation.map(s=>s.url),sourceURLs);
 for(const [i,source] of evidence.sources.entries()) {
  if('author' in source)assert.equal(schema.citation[i].author.name,source.author);
  else assert.ok(!('author' in schema.citation[i]),locale+': do not invent source authorship');
 }
 assert.ok(!('reviewedBy' in schema)&&!('lastReviewed' in schema),locale+': no fictitious human review');
 const markdown=['dist/_agent-markdown/'+path+'.md','dist/_agent-markdown/'+path+'/index.md'].find(existsSync);assert.ok(markdown);
 const md=readFileSync(markdown,'utf8');for(const source of sourceURLs)assert.ok(md.includes(source),locale+': Markdown citations');
}
assert.equal(evidence.independentExpertReview,false);
assert.equal(evidence.nativeLanguageReview,false);
}
console.log('Editorial evidence: fifty-six foundational article-locale routes include sources, original example, limited check record and exact citations; no independent-human-review claim. Does not validate other articles or translation quality.');

for(const [id,evidence] of Object.entries(CARD_EVIDENCE))for(const locale of locales){
 const prefix=locale==='en'?'':locale+'/';const path=prefix+'cards/'+id.replaceAll('_','-');
 const file=['dist/'+path+'.html','dist/'+path+'/index.html'].find(existsSync);assert.ok(file,path);
 const html=readFileSync(file,'utf8'),{document}=parseHTML(html);
 const card=JSON.parse(readFileSync(`src/i18n/${locale}/cards.json`,'utf8'))[id],copy=card.evidence;
 const section=document.querySelector('[data-card-evidence]');assert.ok(section,locale+': visible card evidence');
 assert.equal(section.querySelectorAll('h2[id]').length,4);
 for(const s of copy.sections){assert.ok(section.textContent.includes(s.h));}
 assert.ok(document.querySelector('.answer').textContent.includes(copy.answer));
 assert.ok(document.querySelector('a[data-use-card]'),locale+': preserve workspace action');
 assert.ok(document.querySelector('[data-card-orientation]'),locale+': preserve orientation');
 assert.ok(section.querySelector(`a[href="/${prefix}methodology#corrections"]`));
 const schema=[...document.querySelectorAll('script[type="application/ld+json"]')].map(s=>JSON.parse(s.textContent)).find(s=>s['@type']==='Article');
 assert.equal(schema.dateModified,evidence.checkedAt);
 assert.deepEqual(schema.citation.map(s=>s.url),evidence.sources.map(s=>s.url));
 for(const [i,source]of evidence.sources.entries()){assert.equal(schema.citation[i].author.name,source.author);assert.ok(section.querySelector(`a[href="${source.url}"]`));}
 assert.ok(!('reviewedBy'in schema)&&!('lastReviewed'in schema));
 const markdown=['dist/_agent-markdown/'+path+'.md','dist/_agent-markdown/'+path+'/index.md'].find(existsSync);assert.ok(markdown);
 const md=readFileSync(markdown,'utf8');for(const source of evidence.sources)assert.ok(md.includes(source.url));
 assert.equal(evidence.independentExpertReview,false);assert.equal(evidence.nativeLanguageReview,false);
 // Context pages must not inherit the base reference's source-comparison date.
 for(const ctx of ['love','career','feelings','yes-or-no']){
  const file=['dist/'+path+'/'+ctx+'.html','dist/'+path+'/'+ctx+'/index.html'].find(existsSync);assert.ok(file);
  assert.ok(!readFileSync(file,'utf8').includes('data-card-evidence'),locale+': context not marked checked');
 }
}
console.log('Forty checked base-card references: visible original example/check record, exact Article/Markdown citations and preserved reading controls; context pages are not marked checked.');
