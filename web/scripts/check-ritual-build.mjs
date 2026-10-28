// Static production evidence only; browser, visual and performance checks remain separate.
import { readFileSync, existsSync, statSync, readdirSync } from 'node:fs';
import { join } from 'node:path';
import { ritualCopy } from '../src/i18n/ritual.ts';
import { drawCopy } from '../src/i18n/draw.ts';
import { spreadIds, slug } from '../src/lib/data.ts';
import { APP_STORE_URL, PLAY_STORE_URL } from '../src/config.ts';
const locales = ['en','zh-hans','zh-hant','es','de','ja','fr','ru'];
const origin = 'https://shentarot.com';
const fail = message => { throw new Error(message); };
function output(path) {
  const clean = decodeURIComponent(path).replace(/^\//,'');
  return [join('dist',clean || 'index.html'),join('dist',`${clean}.html`),join('dist',clean,'index.html')].find(f=>existsSync(f)&&statSync(f).isFile());
}
const decode = text => text.replace(/&#(x[\da-f]+|\d+);/gi,(_,n)=>String.fromCodePoint(n[0].toLowerCase()==='x'?parseInt(n.slice(1),16):Number(n))).replace(/&quot;/g,'"').replace(/&#39;|&apos;/g,"'").replace(/&lt;/g,'<').replace(/&gt;/g,'>').replace(/&amp;/g,'&');
const plain = html => decode(html.replace(/<[^>]*>/g,' ')).replace(/\s+/g,' ').trim();
const includesText = (html,text)=>plain(html).includes(text.replace(/\s+/g,' ').trim());
const tools = readdirSync('src/pages/[...lang]/tools').filter(f=>f.endsWith('.astro')).map(f=>`tools${f==='index.astro'?'':`/${f.slice(0,-6)}`}`);
const routes = [...new Set(['', 'read','cards','cards/major-17-star','cards/cups-queen/love','spreads','spreads/three','learn','learn/connected-reading','learn/practice','questions','topics/love','astrology','zodiac/aries','about','methodology',...tools,...spreadIds.map(id=>`spreads/${slug(id)}`)])];
let pages=0,references=0;
for(const locale of locales) {
  const prefix=locale==='en'?'':`${locale}/`;
  const homeFile=output(`/${prefix}`); if(!homeFile) fail(`Missing homepage ${locale}`);
  const home=readFileSync(homeFile,'utf8'), copy=ritualCopy(locale);
  const drawing=drawCopy(locale);
  if(!drawing || Object.values(drawing).some(value=>typeof value!=='string'||!value.trim())) fail(`Missing explicit draw copy ${locale}`);
  if(!includesText(home,drawing.title)||!home.includes('data-draw-fan')||!home.includes('data-draw-skip')) fail(`Missing localized drawing table ${locale}`);
  if(!copy) fail(`Missing explicit ritual copy ${locale}`);
  const headings=[...home.matchAll(/<h[12]\b[^>]*>([\s\S]*?)<\/h[12]>/gi)].map(m=>plain(m[1]));
  for(const key of ['heroTitle','dailyTitle','libraryTitle','trustTitle','finalTitle']) if(!headings.includes(copy[key])) fail(`Missing localized heading ${key}: ${locale}`);
  for(const key of ['heroLead','freeNote','appNote','comingSoon']) if(!includesText(home,copy[key])) fail(`Missing localized copy ${key}: ${locale}`);
  for(const id of ['ritual','card-library']) if(!home.includes(`id="${id}"`)||!home.includes(`href="#${id}"`)) fail(`Missing home anchor ${id}: ${locale}`);
  for(const route of ['read','cards','tools','tools/daily-card']) if(!home.includes(`href="/${prefix}${route}"`)) fail(`Missing home route ${route}: ${locale}`);
  if(!/<form\b[^>]*role="search"/.test(home)||!home.includes(`action="/${prefix}cards"`)||!home.includes('name="q"')) fail(`Missing search form ${locale}`);
  const schemas=[...home.matchAll(/<script\b[^>]*type="application\/ld\+json"[^>]*>([\s\S]*?)<\/script>/gi)].flatMap(m=>JSON.parse(m[1]));
  const faq=schemas.find(s=>s['@type']==='FAQPage');
  if(!faq?.mainEntity?.length||!schemas.some(s=>s['@type']==='WebSite')) fail(`Missing FAQ/WebSite schema ${locale}`);
  if(schemas.some(s=>s['@type']==='MobileApplication')) fail(`Upcoming app application schema ${locale}`);
  for(const q of faq.mainEntity) if(!includesText(home,q.name)||!includesText(home,q.acceptedAnswer.text)) fail(`FAQ content/schema mismatch ${locale}`);
  for(const route of routes) {
    const path=`/${prefix}${route}`,file=output(path);if(!file) fail(`Missing representative route ${path}`);
    const html=readFileSync(file,'utf8');
    if(html.includes('data-reader')) for(const marker of ['data-draw-deck','data-draw-fan','data-draw-previous','data-draw-next','data-draw-progress','data-draw-skip']) if(!html.includes(marker)) fail(`Missing draw control ${marker}: ${path}`);
    if(route.startsWith('spreads/')) {
      const configs=[...html.matchAll(/<script\b[^>]*type="application\/json"[^>]*data-config[^>]*>([\s\S]*?)<\/script>/g)].map(m=>JSON.parse(m[1]));
      const reader=configs.find(c=>Array.isArray(c.deck));
      const id=route.slice('spreads/'.length).replaceAll('-','_');
      if(!reader?.spread||reader.spread.id!==id||reader.spread.layout.length!==reader.positions.length||!html.includes('data-spread-board'))fail(`Draw/layout binding missing: ${path}`);
    }
    if(!/<nav\b[^>]*aria-label=/.test(html)||!/<main\b[^>]*id="main"/.test(html)||!/<footer\b/.test(html)) fail(`Missing semantic shell ${path}`);
    if(!html.includes('rel="canonical"')||!html.includes('hreflang="x-default"')) fail(`Missing locale metadata ${path}`);
    for(const [,attribute,raw] of html.matchAll(/\b(href|src|poster)="([^"]+)"/g)) {
      const value=decode(raw);
      if(!APP_STORE_URL&&/^https?:\/\/(?:apps|itunes)\.apple\.com\//i.test(value)) fail(`Unavailable App Store link ${path}`);
      if(!PLAY_STORE_URL&&/^https?:\/\/play\.google\.com\/store/i.test(value)) fail(`Unavailable Play Store link ${path}`);
      const url=new URL(value,`${origin}${path}`);
      if(url.origin!==origin||!['http:','https:'].includes(url.protocol)) continue;
      if(!output(url.pathname)) fail(`Broken ${attribute} on ${path}: ${url.pathname}`);
      references++;
    }
    pages++;
  }
}
console.log(`Ritual static audit passed: ${locales.length} locales; ${pages} representative pages including every tool template; ${references} internal href/src/poster references.`);
console.log('Verified localized home headings/copy, search/CTA destinations, semantic shell, FAQ/schema consistency and absent unavailable store links. Does not verify browser interaction, translation quality, visual layout, accessibility conformance or performance.');
