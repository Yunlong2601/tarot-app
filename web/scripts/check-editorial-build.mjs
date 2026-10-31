import assert from 'node:assert/strict';
import {readFileSync,existsSync} from 'node:fs';
import {parseHTML} from 'linkedom';
import {LESSON_EVIDENCE} from '../src/lib/editorial.ts';
const locales=['en','zh-hans','zh-hant','es','de','ja','fr','ru'];
const sourceURLs=LESSON_EVIDENCE['tarot-numbers'].sources.map(s=>s.url);
for(const locale of locales){
 const prefix=locale==='en'?'':locale+'/';
 const path=prefix+'learn/tarot-numbers';
 const file=['dist/'+path+'.html','dist/'+path+'/index.html'].find(existsSync);assert.ok(file,path);
 const html=readFileSync(file,'utf8');const {document}=parseHTML(html);
 const copy=JSON.parse(readFileSync(`src/i18n/${locale}/learn.json`,'utf8')).guides['tarot-numbers'];
 const article=document.querySelector('article');assert.ok(article);
 assert.equal(copy.sections.length,7,locale+': source/example/check sections');
 for(const source of sourceURLs){
  assert.ok(article.querySelector(`a[href="${source}"]`),locale+': unmodified external source');
  assert.ok(!html.includes('/'+prefix+source),locale+': external source cannot be localized');
 }
 for(const n of [3,4,5,6])assert.ok(article.textContent.includes(copy.sections[n].h),locale+': visible section');
 for(const card of ['cups-five','wands-eight','swords-eight','pentacles-eight'])assert.ok(article.querySelector(`a[href="/${prefix}cards/${card}"]`),locale+': local card link');
 const schemas=[...document.querySelectorAll('script[type="application/ld+json"]')].map(s=>JSON.parse(s.textContent));
 const schema=schemas.find(s=>s['@type']==='Article');assert.equal(schema.dateModified,'2026-10-31');
 assert.deepEqual(schema.citation.map(s=>s.url),sourceURLs);
 assert.ok(!('reviewedBy' in schema)&&!('lastReviewed' in schema),locale+': no fictitious human review');
 const markdown=['dist/_agent-markdown/'+path+'.md','dist/_agent-markdown/'+path+'/index.md'].find(existsSync);assert.ok(markdown);
 const md=readFileSync(markdown,'utf8');for(const source of sourceURLs)assert.ok(md.includes(source),locale+': Markdown citations');
}
assert.equal(LESSON_EVIDENCE['tarot-numbers'].independentExpertReview,false);
assert.equal(LESSON_EVIDENCE['tarot-numbers'].nativeLanguageReview,false);
console.log('Editorial evidence: eight numbers lessons include sources, original example, limited check record and exact citations; no independent-human-review claim. Does not validate other articles or translation quality.');
