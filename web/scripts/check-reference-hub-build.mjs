import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
import { parseHTML } from 'linkedom';
import { referenceHub, FAQ_TARGETS } from '../src/i18n/reference-hub.ts';
import { ritualCopy } from '../src/i18n/ritual.ts';
import { cardIds, slug, spreadIds } from '../src/lib/data.ts';
const locales = ['en', 'zh-hans', 'zh-hant', 'es', 'de', 'ja', 'fr', 'ru'];
const file = path => ['dist/' + path + '.html', 'dist/' + path + '/index.html'].find(existsSync);
const doc = path => parseHTML(readFileSync(file(path), 'utf8')).document;
const norm = s => s.replace(/\s+/g, ' ').trim();
const schemasFor = d => [...d.querySelectorAll('script[type="application/ld+json"]')].flatMap(s => JSON.parse(s.textContent));
const publisherId = 'https://shentarot.com/#shenetic';
const websiteId = 'https://shentarot.com/#website';
const checkPublisher = publisher => {
  assert.equal(publisher['@id'], publisherId);
  assert.equal(publisher.name, 'Shenetic');
};
for (const locale of locales) {
  const p = locale === 'en' ? '' : locale + '/';
  const d = doc(p + 'about'), h = referenceHub(locale);
  const schemas = schemasFor(d);
  const schema = schemas.find(s => Array.isArray(s['@type']) && s['@type'].includes('FAQPage'));
  assert.equal(schema.mainEntity.length, 12);
  checkPublisher(schema.publisher);
  assert.equal(schema.about['@id'], websiteId);
  const home = schemasFor(doc(p + 'index'));
  checkPublisher(home.find(s => s['@type'] === 'Organization'));
  const website = home.find(s => s['@type'] === 'WebSite');
  assert.equal(website['@id'], websiteId);
  assert.equal(website.publisher['@id'], publisherId);
  assert.equal(website.potentialAction.target.urlTemplate, 'https://shentarot.com/' + p + 'search?q={search_term_string}');
  const course = schemasFor(doc(p + 'learn')).find(s => s['@type'] === 'Course');
  checkPublisher(course.provider);
  const lesson = schemasFor(doc(p + 'learn/reversed-cards')).find(s => s['@type'] === 'Article');
  checkPublisher(lesson.author);
  checkPublisher(lesson.publisher);
  const growth = JSON.parse(readFileSync('src/i18n/' + locale + '/growth.json', 'utf8'));
  for (const k of ['methodTradition','methodProcess','methodReview']) assert(norm(d.querySelector('main').textContent).includes(growth[k]));
  const methodology = doc(p + 'methodology');
  const methodArticle = schemasFor(methodology).find(s => s['@type'] === 'Article');
  checkPublisher(methodArticle.publisher);
  assert.equal(methodArticle.mainEntityOfPage, 'https://shentarot.com/' + p + 'methodology');
  assert.deepEqual(methodArticle.citation.map(source => source.url), [...methodology.querySelectorAll('#deck-sources ~ ul a, #card-numbering ~ ul a')].map(a => a.href));
  const methodologyMarkdown = readFileSync('dist/_agent-markdown/' + p + 'methodology.md', 'utf8');
  for (const [fragment, key] of [['deck-sources', 'provenanceTitle'], ['card-numbering', 'numberingTitle']]) {
    assert.equal(norm(methodology.getElementById(fragment).textContent), norm(growth[key]));
    assert(norm(methodologyMarkdown).includes(norm(growth[key])), 'Methodology Markdown parity');
  }
  const arcana = doc(p + 'learn/major-and-minor-arcana');
  assert.ok(arcana.querySelector(`main a[href="/${p}methodology#card-numbering"]`));
  assert(!JSON.stringify(schemas).includes('reviewedBy'));
  const ids = [...d.querySelectorAll('[id]')].map(n => n.id);
  assert.equal(new Set(ids).size, ids.length, 'Duplicate fragment id');
  assert.equal(d.querySelector('link[rel="canonical"]').href, 'https://shentarot.com/' + p + 'about');
  assert.equal(d.querySelectorAll('link[rel="alternate"][hreflang]').length, 9);
  assert.equal(d.querySelectorAll('main [data-product-fact]').length, 4);
  assert.equal(d.querySelectorAll('main h2').length, 4);
  assert.match(d.querySelector('[data-product-fact="library"]').textContent, /78/);
  assert.match(d.querySelector('[data-product-fact="library"]').textContent, /8/);
  assert.equal(d.querySelector('#example ol').children.length, 3);
  const comparisonLink = '/' + p + 'learn/connected-reading#compare-layouts';
  assert.ok(d.querySelector(`#example a[href="${comparisonLink}"]`));
  const example = doc(p + 'learn/connected-reading');
  const comparison = example.getElementById('compare-layouts');
  assert.equal(norm(comparison.querySelector('h2').textContent), h.compareLayouts.title);
  for (const seed of ['creative', 'creative-timeline']) {
    assert.ok(comparison.querySelector(`a[href="/${p}read?example=${seed}"]`));
  }
  const exampleArticle = schemasFor(example).find(s => s['@type'] === 'Article');
  assert.ok(comparison.querySelector(`a[href="${exampleArticle.citation}"]`));
  for (const mention of exampleArticle.mentions) {
    const { pathname } = new URL(mention['@id']);
    assert.ok(example.querySelector(`a[href^="${pathname}"]`));
  }
  assert.match(d.querySelector('#app').textContent, /1\.0\.1/);
  assert.equal(d.querySelector('#app time').getAttribute('datetime'), '2026-10-30');
  assert(!norm(d.querySelector('main').textContent).includes('{cards}'));
  assert.equal(norm(d.querySelector('main .lead').textContent), ritualCopy(locale).heroLead);
  if (locale.startsWith('zh-')) assert([...ritualCopy(locale).heroLead].length <= 50, 'BLUF exceeds 50 characters');
  h.faq.forEach((f, i) => {
    const section = d.getElementById(FAQ_TARGETS[i][0]);
    assert.equal(norm(section.querySelector('h3').textContent), f.q);
    assert.equal(norm(section.querySelector('p').textContent), f.a);
    assert.equal(schema.mainEntity[i].acceptedAnswer.text, f.a);
    assert.equal(schema.mainEntity[i].name, f.q);
    assert.equal(schema.mainEntity[i]['@id'], schema.url + '#' + FAQ_TARGETS[i][0]);
    assert.equal(schema.mainEntity[i].acceptedAnswer.url, 'https://shentarot.com/' + p + FAQ_TARGETS[i][1]);
    if (locale.startsWith('zh-')) assert([...f.a].length <= 80, 'Chinese answer exceeds 80 characters');
  });
  for (const a of d.querySelectorAll('main a[href^="/"]')) {
    const target = new URL(a.getAttribute('href'), 'https://shentarot.com');
    assert(file(target.pathname.slice(1)), 'Missing guide ' + target.href);
  }
  const library = doc(p + 'cards');
  const collection = schemasFor(library).find(s => s['@type'] === 'CollectionPage');
  checkPublisher(collection.publisher);
  const list = collection.mainEntity;
  assert.equal(list.numberOfItems, 78);
  assert.equal(list.itemListElement.length, cardIds.length);
  assert.equal(library.querySelectorAll('[data-search-card] h3').length, cardIds.length);
  cardIds.forEach((id, i) => {
    const card = library.querySelector('[data-search-card][data-href="/' + p + 'cards/' + slug(id) + '"]');
    assert(card);
    assert.equal(list.itemListElement[i].item.name, norm(card.querySelector('h3').textContent));
    const detail = schemasFor(doc(p + 'cards/' + slug(id)));
    assert.equal(detail.find(s => s['@type'] === 'DefinedTerm')['@id'], list.itemListElement[i].item['@id']);
    const page = detail.find(s => s['@type'] === 'WebPage');
    checkPublisher(page.publisher);
    assert.equal(page.isPartOf['@id'], websiteId);
  });
  const spreads = doc(p + 'spreads');
  const spreadCatalog = schemasFor(spreads).find(s => s['@type'] === 'CollectionPage');
  checkPublisher(spreadCatalog.publisher);
  const spreadLinks = [...spreads.querySelectorAll('a.spread-card')];
  const spreadList = spreadCatalog.mainEntity;
  assert.equal(spreadLinks.length, spreadIds.length);
  assert.equal(spreadList.numberOfItems, spreadLinks.length);
  assert.equal(spreadList.itemListElement.length, spreadLinks.length);
  spreadLinks.forEach((link, i) => {
    const href = link.getAttribute('href');
    const { item, position } = spreadList.itemListElement[i];
    assert.equal(position, i + 1);
    assert.equal(item['@id'], 'https://shentarot.com' + href);
    assert.equal(item.name, norm(link.querySelector('h3').textContent));
    const page = schemasFor(doc(href.slice(1))).find(s => s['@type'] === 'FAQPage');
    assert.equal(page['@id'], item['@id']);
    assert.equal(page.name, item.name);
    checkPublisher(page.publisher);
    assert.equal(page.isPartOf['@id'], websiteId);
  });
  const markdown = readFileSync('dist/_agent-markdown/' + p + 'about.md', 'utf8');
  for (const f of h.faq) assert(markdown.includes(f.q) && markdown.includes(f.a), 'Markdown parity');
  const sitemap = readFileSync('dist/sitemap.xml', 'utf8');
  assert(sitemap.includes('https://shentarot.com/' + p + 'about'));
}
console.log('Reference hub: 8 locales, 96 FAQ answers, card and spread catalog links, publisher identities and Markdown verified.');
