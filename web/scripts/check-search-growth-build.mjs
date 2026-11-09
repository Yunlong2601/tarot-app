import assert from 'node:assert/strict';
import { existsSync, readFileSync, readdirSync } from 'node:fs';
import { join } from 'node:path';
import { parseHTML } from 'linkedom';
const origin = 'https://shentarot.com';
const localePrefixes = ['', '/zh-hans', '/zh-hant', '/es', '/de', '/ja', '/fr', '/ru'];
const targets = new Map([
  ['/zh-hans/cards', 'library'],
  ['/cards/pentacles-ace/love', 'love'],
  ...localePrefixes.map(prefix => [prefix + '/tools/random-card', 'draw']),
  ...localePrefixes.map(prefix => [prefix + '/tools/daily-card', 'daily']),
  ['/zh-hans/learn/major-and-minor-arcana', 'arcana'],
]);
const fileFor = path => ['dist' + path + '.html', 'dist' + path + '/index.html'].find(existsSync);
const attrs = tag => Object.fromEntries([...tag.matchAll(/([\w:-]+)="([^"]*)"/g)].map(m => [m[1], m[2]]));
const sitemap = readFileSync('dist/sitemap.xml', 'utf8');
for (const [path, kind] of targets) {
  const html = readFileSync(fileFor(path), 'utf8');
  assert.ok(html.includes(`data-growth-notes="${kind}"`), `${path}: missing initial HTML content`);
  assert.equal((html.match(/<h1\b/g) || []).length, 1, `${path}: one primary heading`);
  const links = [...html.matchAll(/<link\b[^>]*>/g)].map(m => attrs(m[0]));
  assert.equal(links.find(l => l.rel === 'canonical')?.href, origin + path);
  assert.equal(links.filter(l => l.hreflang).length, 9, `${path}: eight locales plus default`);
  const suffix = path.replace(/^\/(zh-hans|zh-hant|es|de|ja|fr|ru)(?=\/)/, '');
  for (const [tag, prefix] of [['en', ''], ['zh-Hans', '/zh-hans'], ['zh-Hant', '/zh-hant'], ['es', '/es'], ['de', '/de'], ['ja', '/ja'], ['fr', '/fr'], ['ru', '/ru'], ['x-default', '']]) {
    const expected = origin + prefix + suffix;
    assert.equal(links.find(l => l.hreflang === tag)?.href, expected, `${path}: ${tag} destination`);
    const translation = readFileSync(fileFor(prefix + suffix), 'utf8');
    const translatedLinks = [...translation.matchAll(/<link\b[^>]*>/g)].map(m => attrs(m[0]));
    assert.equal(translatedLinks.find(l => l.rel === 'canonical')?.href, expected);
    assert.ok(translatedLinks.some(l => l.hreflang && l.href === origin + path), `${path}: reciprocal alternative`);
  }
  assert.ok(sitemap.includes(`<loc>${origin + path}</loc>`));
  assert.ok(!/<meta[^>]+name="robots"[^>]+noindex/.test(html));
  // Check links and artwork inside the original editorial block, including anchors.
  const notes = html.split(`data-growth-notes="${kind}"`)[1].split('</footer>')[0];
  for (const [, raw] of notes.matchAll(/(?:href|src)="([^"]+)"/g)) {
    const url = new URL(raw.replaceAll('&amp;', '&'), origin + path);
    if (url.origin !== origin) continue;
    const target = url.pathname === path ? html : (fileFor(url.pathname) ? readFileSync(fileFor(url.pathname), 'utf8') : null);
    assert.ok(target !== null || existsSync('dist' + url.pathname), `${path}: missing ${raw}`);
    if (url.hash && target) assert.ok(target.includes(`id="${url.hash.slice(1)}"`), `${path}: missing anchor ${raw}`);
  }
  if (kind === 'draw' || kind === 'daily') {
    const locale = path === suffix ? 'en' : path.split('/')[1];
    const copy = JSON.parse(readFileSync(`src/i18n/${locale}/ui.json`, 'utf8'))[kind === 'draw' ? 'random' : 'daily'];
    const { document } = parseHTML(html);
    const guide = document.querySelector(`[data-growth-notes="${kind}"]`);
    assert.equal(guide?.querySelector('h2')?.textContent, copy.guideTitle, `${path}: localized guide`);
    assert.equal(guide.querySelectorAll('ol > li').length, 3, `${path}: choose, shuffle and reveal steps`);
    assert.deepEqual([...guide.querySelectorAll('h3')].map(h => h.textContent), [copy.rulesTitle, copy.continueTitle ?? copy.exampleTitle]);
    const markdown = readFileSync(`dist/_agent-markdown${path}.md`, 'utf8');
    assert.ok(markdown.includes(copy.guideTitle) && markdown.includes(copy.rules), `${path}: guide in Markdown`);
    if (kind === 'daily') {
      const prefix = path.slice(0, -suffix.length);
      assert.ok(guide.textContent.includes(copy.savedLimits) && markdown.includes(copy.savedLimits), `${path}: browser storage limits`);
      for (const destination of ['/cards/pentacles-two', '/topics/daily', '/tools/random-card']) {
        const href = prefix + destination;
        assert.ok(guide.querySelector(`a[href="${href}"]`) && markdown.includes(href), `${path}: ${destination} in HTML and Markdown`);
      }
    }
    const schema = [...document.querySelectorAll('script[type="application/ld+json"]')]
      .map(script => JSON.parse(script.textContent)).find(item => item['@type'] === 'WebApplication');
    assert.equal(schema?.url, origin + path, `${path}: tool schema uses canonical URL`);
    assert.equal(schema.isAccessibleForFree, true);
    assert.equal(schema.publisher.name, 'Shenetic');
  }
  for (const [, json] of html.matchAll(/<script[^>]+type="application\/ld\+json"[^>]*>(.*?)<\/script>/gs)) {
    const schema = JSON.parse(json);
    if (schema['@type'] === 'FAQPage') for (const q of schema.mainEntity) {
      const strip = s => s.replace(/<[^>]*>/g, '').replaceAll('&amp;', '&').replaceAll('&#39;', "'").replaceAll('&quot;', '"');
      assert.ok(strip(html).includes(q.name), `${path}: schema question absent from HTML`);
      assert.ok(strip(html).includes(q.acceptedAnswer.text), `${path}: schema answer absent from HTML`);
    }
  }
}
let enriched = 0;
function walk(dir) { for (const e of readdirSync(dir, { withFileTypes: true })) {
  const path = join(dir, e.name);
  if (e.isDirectory()) walk(path);
  else if (path.endsWith('.html') && readFileSync(path, 'utf8').includes('data-growth-notes=')) enriched++;
} }
walk('dist');
assert.equal(enriched, targets.size, 'Editorial additions must remain scoped to the audited routes');
console.log(`Search growth: ${targets.size} initial-HTML routes, canonicals, locale alternatives, sitemap, local links/artwork, anchors and FAQ parity passed. Does not prove indexing or traffic growth.`);
