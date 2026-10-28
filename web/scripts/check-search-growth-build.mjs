import assert from 'node:assert/strict';
import { existsSync, readFileSync, readdirSync } from 'node:fs';
import { join } from 'node:path';
const origin = 'https://shentarot.com';
const targets = new Map([
  ['/zh-hans/cards', 'library'],
  ['/cards/pentacles-ace/love', 'love'],
  ['/tools/random-card', 'draw'],
  ['/zh-hans/learn/major-and-minor-arcana', 'arcana'],
  ['/cards/major-20-judgement', 'judgement'],
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
assert.equal(enriched, 5, 'Editorial additions must remain scoped to exactly five routes');
console.log('Search growth: five initial-HTML routes, canonicals, locale alternatives, sitemap, local links/artwork, anchors and FAQ parity passed. Does not prove indexing or traffic growth.');
