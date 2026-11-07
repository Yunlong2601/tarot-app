import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
import { parseHTML } from 'linkedom';
import { referenceHub, FAQ_TARGETS } from '../src/i18n/reference-hub.ts';
import { ritualCopy } from '../src/i18n/ritual.ts';
import { cardIds, slug } from '../src/lib/data.ts';
const locales = ['en', 'zh-hans', 'zh-hant', 'es', 'de', 'ja', 'fr', 'ru'];
const file = path => ['dist/' + path + '.html', 'dist/' + path + '/index.html'].find(existsSync);
const doc = path => parseHTML(readFileSync(file(path), 'utf8')).document;
const norm = s => s.replace(/\s+/g, ' ').trim();
for (const locale of locales) {
  const p = locale === 'en' ? '' : locale + '/';
  const d = doc(p + 'about'), h = referenceHub(locale);
  const schemas = [...d.querySelectorAll('script[type="application/ld+json"]')].flatMap(s => JSON.parse(s.textContent));
  const schema = schemas.find(s => Array.isArray(s['@type']) && s['@type'].includes('FAQPage'));
  assert.equal(schema.mainEntity.length, 12);
  assert.equal(schema.publisher.name, 'Shenetic');
  const growth = JSON.parse(readFileSync('src/i18n/' + locale + '/growth.json', 'utf8'));
  for (const k of ['methodTradition','methodProcess','methodReview']) assert(norm(d.querySelector('main').textContent).includes(growth[k]));
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
  const list = [...library.querySelectorAll('script[type="application/ld+json"]')].flatMap(s => JSON.parse(s.textContent)).find(s => s['@type'] === 'CollectionPage').mainEntity;
  assert.equal(list.numberOfItems, 78);
  assert.equal(list.itemListElement.length, cardIds.length);
  assert.equal(library.querySelectorAll('[data-search-card] h3').length, cardIds.length);
  cardIds.forEach((id, i) => {
    const card = library.querySelector('[data-search-card][data-href="/' + p + 'cards/' + slug(id) + '"]');
    assert(card);
    assert.equal(list.itemListElement[i].item.name, norm(card.querySelector('h3').textContent));
  });
  const markdown = readFileSync('dist/_agent-markdown/' + p + 'about.md', 'utf8');
  for (const f of h.faq) assert(markdown.includes(f.q) && markdown.includes(f.a), 'Markdown parity');
  const sitemap = readFileSync('dist/sitemap.xml', 'utf8');
  assert(sitemap.includes('https://shentarot.com/' + p + 'about'));
}
console.log('Reference hub: 8 locales, 96 FAQ answers, 624 card headings/schema entries, links and Markdown verified.');
