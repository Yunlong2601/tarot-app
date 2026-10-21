// Verify new user journeys resolve in the real production output, not just dev.
import { readFileSync, existsSync, statSync } from 'node:fs';
import { join } from 'node:path';
const locales = ['', 'zh-hans/', 'zh-hant/', 'es/', 'de/', 'ja/', 'fr/', 'ru/'];
const routes = ['', 'read', 'astrology', 'cards', 'cards/cups-queen', 'spreads/three', 'spreads/three-decision', 'spreads/celtic', 'learn', 'zodiac/aries', 'methodology', 'learn/connected-reading', 'learn/beginner-reference', 'learn/practice', 'cards/major-17-star', 'cards/pentacles-two', 'cards/pentacles-eight'];
function output(path) {
  const clean = decodeURIComponent(path).replace(/^\//,'');
  return [join('dist',clean || 'index.html'),join('dist',`${clean}.html`),join('dist',clean,'index.html')].find(p=>existsSync(p) && statSync(p).isFile());
}
let checked = 0;
for (const loc of locales) for (const route of routes) {
  const path = loc + route;
  const page = output('/'+path);
  if (!page) throw new Error(`Missing page ${path}`);
  const html = readFileSync(page,'utf8');
  if (!html.includes('rel="canonical"') || !html.includes('hreflang="x-default"')) throw new Error(`Missing locale metadata: ${path}`);
  for (const [,attribute,value] of html.matchAll(/\b(href|src)="([^"]+)"/g)) {
    const url = new URL(value.replaceAll('&amp;','&'),`https://shentarot.com/${path}`);
    if (url.origin !== 'https://shentarot.com' || !['http:','https:'].includes(url.protocol)) continue;
    if (!output(url.pathname)) throw new Error(`Broken ${attribute} in ${path}: ${url.pathname}`);
  }
  checked++;
}
const sitemap = readFileSync('dist/sitemap.xml','utf8');
for (const loc of locales) for (const route of ['read','astrology','methodology','learn/connected-reading','learn/beginner-reference','learn/practice']) if (!sitemap.includes(`https://shentarot.com/${loc}${route}</loc>`)) throw new Error(`Missing sitemap ${loc}${route}`);
console.log(`${checked} production pages: links, assets, locale metadata and new sitemap entries passed.`);
// Prevent marketing/schema from silently claiming an unavailable website AI flow.
for (const loc of locales) {
  const home = readFileSync(output('/'+loc),'utf8');
  const schemas = [...home.matchAll(/<script type="application\/ld\+json">(.*?)<\/script>/gs)].map(m=>JSON.parse(m[1]));
  if (schemas.some(s=>s['@type']==='MobileApplication')) throw new Error(`Upcoming app advertised as homepage application schema: ${loc}`);
  const faq = schemas.find(s=>s['@type']==='FAQPage');
  if (!faq || faq.mainEntity.length!==4) throw new Error(`Missing website-specific FAQ ${loc}`);
  for (const f of faq.mainEntity) if (!home.includes(f.name) || !home.includes(f.acceptedAnswer.text)) throw new Error(`FAQ/schema mismatch ${loc}`);
  const download=output('/'+loc+'learn/beginner-reference.txt');
  if(!download || readFileSync(download,'utf8').length<500) throw new Error(`Missing substantive reference download ${loc}`);
}
console.log('Homepage FAQ/schema consistency and eight static reference downloads passed.');
