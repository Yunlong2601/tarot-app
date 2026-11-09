import assert from 'node:assert/strict';
import {readFileSync,existsSync} from 'node:fs';
import {parseHTML} from 'linkedom';
import {LESSON_EVIDENCE,CARD_EVIDENCE,CONTEXT_EVIDENCE,QUESTION_EVIDENCE} from '../src/lib/editorial.ts';
const locales=['en','zh-hans','zh-hant','es','de','ja','fr','ru'];
const lessons = {
 'how-to-read-tarot': {sources:2,cards:['cups-five','swords-two','pentacles-three']},
 'asking-questions': {sources:2,cards:['major-01-magician','pentacles-two','pentacles-eight']},
 'reversed-cards': {sources:2,cards:['wands-ace','major-09-hermit','major-08-strength','major-19-sun','major-16-tower','swords-ten','pentacles-eight']},
 'court-cards': {sources:3,cards:['pentacles-page','wands-knight','pentacles-knight','cups-queen','swords-king']},
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
 if(slug==='court-cards'){
  const termSet=schemas.find(s=>s['@type']==='DefinedTermSet');
  assert.equal(termSet?.['@id'],`https://shentarot.com/${path}#court-ranks`);
  assert.equal(schema.hasPart['@id'],termSet['@id']);
  const ranks=['page','knight','queen','king'];
  assert.deepEqual(termSet.hasDefinedTerm.map(term=>term.termCode),ranks);
  for(const [i,rank] of ranks.entries()){
   const heading=article.querySelector(`#court-ranks h3#court-${rank}`);
   const term=termSet.hasDefinedTerm[i];
   assert.equal(heading?.textContent,term.name);
   assert.equal(term['@id'],`https://shentarot.com/${path}#court-${rank}`);
   assert.deepEqual([...heading.nextElementSibling.querySelectorAll('a')].map(a=>a.getAttribute('href')).sort(),
    ['cups','pentacles','swords','wands'].map(suit=>`/${prefix}cards/${suit}-${rank}`));
   for(const link of heading.nextElementSibling.querySelectorAll('a')) assert.ok(md.includes(link.getAttribute('href')));
  }
 }
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
 const schemas=[...document.querySelectorAll('script[type="application/ld+json"]')].map(s=>JSON.parse(s.textContent));
 const schema=schemas.find(s=>s['@type']==='Article');
 assert.equal(schema.dateModified,evidence.checkedAt);
 assert.deepEqual(schema.citation.map(s=>s.url),evidence.sources.map(s=>s.url));
 for(const [i,source]of evidence.sources.entries()){assert.equal(schema.citation[i].author.name,source.author);assert.ok(section.querySelector(`a[href="${source.url}"]`));}
 assert.ok(!('reviewedBy'in schema)&&!('lastReviewed'in schema));
 const markdown=['dist/_agent-markdown/'+path+'.md','dist/_agent-markdown/'+path+'/index.md'].find(existsSync);assert.ok(markdown);
 const md=readFileSync(markdown,'utf8');for(const source of evidence.sources)assert.ok(md.includes(source.url));
 if(['major_05_hierophant','major_09_hermit','major_19_sun','major_20_judgement','pentacles_four'].includes(id)){
  for(const orientation of ['upright','reversed']){
   const href=`/${path}?orientation=${orientation}#card-meanings`;
   assert.ok(section.querySelector(`a[href="${href}"]`),`${locale}: ${id} orientation example link`);
   assert.ok(md.includes(href),`${locale}: ${id} orientation link in Markdown`);
  }
 }
 if(id==='major_05_hierophant'){
  const aliases=['The Pope','Le Pape','Der Papst'];
  assert.deepEqual(schemas.find(s=>s['@type']==='DefinedTerm')?.alternateName,aliases);
  for(const alias of aliases) assert.ok(section.textContent.includes(alias) && md.includes(alias));
  assert.ok(section.querySelector('a[href^="https://www.piatnik.com/"][href$="#page=13"]'));
 }
 if(id==='pentacles_four'){
  assert.deepEqual(schemas.find(s=>s['@type']==='DefinedTerm')?.alternateName,['Four of Coins']);
  assert.ok(section.textContent.includes('Four of Coins') && md.includes('Four of Coins'));
 }
 assert.equal(evidence.independentExpertReview,false);assert.equal(evidence.nativeLanguageReview,false);
 // Context pages must not inherit the base reference's source-comparison date.
 for(const ctx of ['love','career','feelings','yes-or-no']){
  const file=['dist/'+path+'/'+ctx+'.html','dist/'+path+'/'+ctx+'/index.html'].find(existsSync);assert.ok(file);
  assert.ok(!readFileSync(file,'utf8').includes('data-card-evidence'),locale+': context not marked checked');
 }
}
console.log(`${Object.keys(CARD_EVIDENCE).length * locales.length} checked base-card references: visible examples and check records, Article and Markdown citations, and reading controls.`);

for (const [path, evidence] of Object.entries(CONTEXT_EVIDENCE)) for (const locale of locales) {
 const prefix = locale === 'en' ? '' : locale + '/';
 const route = prefix + path;
 const file = ['dist/' + route + '.html', 'dist/' + route + '/index.html'].find(existsSync);
 assert.ok(file, route);
 const {document} = parseHTML(readFileSync(file, 'utf8'));
 const localized = JSON.parse(readFileSync(`src/i18n/${locale}/contexts.json`, 'utf8'));
 const copy = localized.editorial[path];
 const section = document.querySelector('[data-context-evidence]');
 assert.ok(section && copy, route + ': scoped contextual evidence');
 assert.equal(document.querySelector('.answer').textContent, copy.answer);
 assert.equal(document.querySelector('h1').textContent, copy.headline);
 assert.equal(document.querySelector('title').textContent, copy.headline + ' · ShenTarot');
 assert.equal(document.querySelector(`main a[href="/${prefix}${evidence.continuePath}"]`).textContent, copy.continueLabel);
 assert.deepEqual([...section.querySelectorAll('h2')].map(h => [h.id, h.textContent]),
  copy.sections.map(item => [item.anchor, item.h]));
 assert.ok(section.querySelector(`a[href="/${prefix}methodology#corrections"]`));
 const schemas = [...document.querySelectorAll('script[type="application/ld+json"]')].map(s => JSON.parse(s.textContent));
 const article = schemas.find(schema => schema['@type'] === 'Article');
 const url = 'https://shentarot.com/' + route;
 assert.equal(article.url, url);
 assert.equal(article.about['@id'], url.slice(0, url.lastIndexOf('/')));
 assert.equal(article.dateModified, evidence.checkedAt);
 assert.equal(article.publisher.name, 'Shenetic');
 assert.ok(!('reviewedBy' in article) && !('lastReviewed' in article));
 assert.equal(evidence.independentExpertReview, false);
 assert.equal(evidence.nativeLanguageReview, false);
 assert.deepEqual(article.citation.map(source => source.url), evidence.sources.map(source => source.url));
 const markdownPath = ['dist/_agent-markdown/' + route + '.md', 'dist/_agent-markdown/' + route + '/index.md'].find(existsSync);
 assert.ok(markdownPath, route);
 const markdown = readFileSync(markdownPath, 'utf8');
 for (const source of evidence.sources) {
  assert.ok(section.querySelector(`a[href="${source.url}"]`) && markdown.includes(source.url));
 }
 for (const heading of section.querySelectorAll('h2')) assert.ok(markdown.includes('## ' + heading.textContent));
 const faq = schemas.find(schema => schema['@type'] === 'FAQPage').mainEntity;
 const answers = [...document.querySelectorAll('.faq details')].map(entry => [
  entry.querySelector('summary').textContent.trim(), entry.querySelector('p').textContent,
 ]);
 assert.deepEqual(faq.map(item => [item.name, item.acceptedAnswer.text]), answers);
 assert.deepEqual(answers.map(([question]) => question), copy.faqQuestions);
 assert.ok(answers.length === 3 && answers.every(([, answer]) => [...answer].length <= 80));

 const [, slug, ctx] = path.split('/');
 const cardPath = prefix + 'cards/' + slug;
 const cardFile = ['dist/' + cardPath + '.html', 'dist/' + cardPath + '/index.html'].find(existsSync);
 const cardDoc = parseHTML(readFileSync(cardFile, 'utf8')).document;
 const term = [...cardDoc.querySelectorAll('script[type="application/ld+json"]')]
  .map(script => JSON.parse(script.textContent)).find(schema => schema['@type'] === 'DefinedTerm');
 assert.equal(term['@id'], article.about['@id']);
 const id = slug.replaceAll('-', '_');
 for (const orientation of ['', '&orientation=reversed']) {
  assert.ok(document.querySelector(`a[href="/${prefix}read?card=${id}${orientation}"]`));
 }
 for (const other of ['love', 'career', 'feelings', 'yes-or-no'].filter(value => value !== ctx)) {
  const sibling = ['dist/' + cardPath + '/' + other + '.html', 'dist/' + cardPath + '/' + other + '/index.html'].find(existsSync);
  assert.ok(!readFileSync(sibling, 'utf8').includes('data-context-evidence'), locale + ': sibling scope');
 }
 if (slug === 'pentacles-ace') {
  assert.deepEqual(term.alternateName, ['Ace of Coins']);
  const index = JSON.parse(readFileSync(`dist/${prefix}search-index.json`, 'utf8'));
  assert.ok(index.find(item => item.id === id).aliases.includes('Ace of Coins'));
  assert.ok(section.textContent.includes('Ace of Coins') && markdown.includes('Ace of Coins'));
  if (locale === 'en') {
   const full = readFileSync('dist/llms-full.txt', 'utf8');
   assert.ok(full.includes(localized.cards[id].feelings.up) && full.includes(localized.cards[id].feelings.rev));
   assert.ok(!full.includes('This person feels a steady, real interest in you.'));
  }
 }
}
console.log(`${Object.keys(CONTEXT_EVIDENCE).length * locales.length} contextual references: sources, examples, limited check records, FAQ and card identity verified.`);

for (const [slug, evidence] of Object.entries(QUESTION_EVIDENCE)) for (const locale of locales) {
 const prefix = locale === 'en' ? '' : locale + '/';
 const path = prefix + 'questions/' + slug;
 const url = 'https://shentarot.com/' + path;
 const htmlPath = 'dist/' + path + '.html';
 const { document } = parseHTML(readFileSync(htmlPath, 'utf8'));
 const copy = JSON.parse(readFileSync(`src/i18n/${locale}/content.json`, 'utf8')).guides[slug];
 const editorial = document.querySelector('[data-question-evidence]');
 const markdown = readFileSync('dist/_agent-markdown/' + path + '.md', 'utf8');
 const practice = document.querySelector('[data-ask-guide]');
 assert.equal(document.querySelector('h1').textContent, copy.question);
 assert.equal(document.querySelector('.page-head .lead').textContent, copy.answer);
 assert.equal(practice.textContent, copy.editorial.practiceLabel);
 assert.equal(practice.getAttribute('data-ask-guide'), copy.better[0]);
 assert.notEqual(practice.getAttribute('data-ask-guide'), copy.question);
 assert.equal(document.querySelector('[data-guide-prompt]').textContent, copy.better[0]);
 assert.equal(practice.getAttribute('href'), '/' + prefix + 'spreads/love-connection#try');
 assert.ok(readFileSync('dist/' + prefix + 'spreads/love-connection.html', 'utf8').includes('id="try"'));
 assert.ok(markdown.includes('# ' + copy.question) && markdown.includes(copy.answer) && markdown.includes(copy.better[0]));
 assert.deepEqual([...editorial.querySelectorAll('h2')].map(h => [h.id, h.textContent]),
  copy.editorial.sections.map(section => [section.anchor, section.h]));
 for (const target of ['cards/major-06-lovers', 'cards/cups-two', 'cards/cups-four', 'spreads/love-connection', 'methodology#corrections']) {
  assert.ok(editorial.querySelector(`a[href="/${prefix}${target}"]`));
  assert.ok(markdown.includes('/' + prefix + target));
 }
 const schemas = [...document.querySelectorAll('script[type="application/ld+json"]')].map(s => JSON.parse(s.textContent));
 const article = schemas.find(s => s['@type'] === 'Article');
 const faq = schemas.find(s => s['@type'] === 'FAQPage');
 assert.equal(article.url, url);
 assert.equal(article.dateModified, evidence.checkedAt);
 assert.equal(article.publisher.name, 'Shenetic');
 assert.ok(!('reviewedBy' in article) && !('lastReviewed' in article));
 assert.equal(evidence.independentExpertReview, false);
 assert.equal(evidence.nativeLanguageReview, false);
 assert.deepEqual(article.citation.map(source => source.url), evidence.sources.map(source => source.url));
 for (const citation of article.citation) {
  assert.ok(editorial.querySelector(`a[href="${citation.url}"]`) && markdown.includes(citation.url));
 }
 for (const item of article.mentions) {
  assert.ok(document.querySelector(`main a[href="${new URL(item['@id']).pathname}"]`));
 }
 assert.equal(faq.mainEntity.length, 3);
 assert.deepEqual(faq.mainEntity.map(q => [q.name, q.acceptedAnswer.text]), copy.editorial.faq.map(q => [q.q, q.a]));
 assert.deepEqual(faq.mainEntity.map(q => [q.name, q.acceptedAnswer.text]),
  [...document.querySelectorAll('.faq details')].map(entry => [
   entry.querySelector('summary').textContent.trim(), entry.querySelector('p').textContent,
  ]));
 assert.ok(faq.mainEntity.every(q => [...q.acceptedAnswer.text].length <= 80));
 const next = parseHTML(readFileSync('dist/' + prefix + 'questions/will-my-ex-come-back.html', 'utf8')).document;
 assert.equal(next.querySelector('[data-ask-guide]').getAttribute('data-ask-guide'), next.querySelector('h1').textContent);
 assert.ok(!next.querySelector('[data-question-evidence]'));
}
console.log(`${Object.keys(QUESTION_EVIDENCE).length * locales.length} question guides: scoped citations, examples, prompt handoff, FAQ and Markdown verified.`);
