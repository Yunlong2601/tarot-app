import assert from 'node:assert/strict';
import {readFileSync,existsSync} from 'node:fs';
import {parseHTML} from 'linkedom';
import {createHash} from 'node:crypto';
import sharp from 'sharp';
import {IPHONE_BETA_EVIDENCE,BETA_SCREENSHOTS} from '../src/lib/beta.ts';
const locales=['en','zh-hans','zh-hant','es','de','ja','fr','ru'];
const sitemap=readFileSync('dist/sitemap.xml','utf8');
for(const lang of locales){
 const prefix=lang==='en'?'':`${lang}/`,route=`/${prefix}beta`;
 const html=readFileSync(`dist/${prefix}beta.html`,'utf8');
 const copy=JSON.parse(readFileSync(`src/i18n/${lang}/beta.json`,'utf8'));
 const {document:d}=parseHTML(html);
 assert.equal(d.querySelectorAll('h1').length,1);
 assert.equal(d.querySelector('h1').textContent,copy.title);
 assert.equal(d.querySelector('link[rel=canonical]').getAttribute('href'),`https://shentarot.com${route}`);
 for(const other of locales){const target=`https://shentarot.com/${other==='en'?'':other+'/'}beta`;assert.ok([...d.querySelectorAll('link[rel=alternate]')].some(l=>l.getAttribute('href')===target));}
 assert.ok(sitemap.includes(`<loc>https://shentarot.com${route}</loc>`));
 for(const p of ['android','iphone']){
  const section=d.getElementById(p);assert.ok(section&&!section.hasAttribute('hidden'));
  assert.equal(section.querySelectorAll('details[data-step][open]').length,3,'static/no-JS instructions must remain open');
  assert.equal(section.querySelectorAll('[data-confirm]').length,3);
  const url=`https://shentarot.com${route}#${p}`;
  assert.equal(section.querySelector('[data-copy-text]').getAttribute('data-copy-text'),url);
  assert.ok(section.querySelector('.beta-qr svg'),'QR must be local SVG');
  assert.equal(section.querySelector('[data-status]').textContent,copy.check);
 }
 assert.equal(d.querySelector('#iphone [data-iphone-costs]').textContent,copy.iphoneCosts.replace('{version}',IPHONE_BETA_EVIDENCE.version).replace('{build}',IPHONE_BETA_EVIDENCE.build).replace('{credits}',String(IPHONE_BETA_EVIDENCE.generalThreeCardCredits)));
 assert.ok(!d.querySelector('#android [data-iphone-costs]'),'iPhone credit evidence must not imply Android pricing');
 const links=[...d.querySelector('#android').querySelectorAll('.beta-step-body>a')].map(a=>a.getAttribute('href'));
 assert.deepEqual(links,['https://groups.google.com/g/shentarot-testers','https://play.google.com/apps/testing/com.shentech.shentarot','https://play.google.com/store/apps/details?id=com.shentech.shentarot']);
 assert.ok(!d.querySelector('main form'),'no website credential collection');
 const recovery=[...d.querySelectorAll('.beta-troubleshooting details')];
 assert.equal(recovery.length,5);
 recovery.forEach((entry,i)=>{
  assert.deepEqual([...entry.querySelectorAll('ol li')].map(li=>li.textContent),copy.troubleChecks[i]);
  assert.ok(entry.querySelector('a[href^="mailto:"]'),'each recovery needs email help');
 });
 assert.equal(recovery[2].querySelectorAll('a[href^="https://"]').length,1,'group recovery retries only Android');
 assert.equal(d.querySelectorAll('[data-beta-task]').length,4);
 assert.ok(d.querySelector('#beta-feedback-template').textContent.includes(copy.template.trim()));
 assert.ok(!html.includes('Not accepting new testers right now'));
 assert.ok(!d.querySelector('.beta-demo video'),'unverified video must not ship');
 assert.equal(BETA_SCREENSHOTS.length,3,'the product story requires three verified captures');
 const figures=[...d.querySelectorAll('.beta-product-story figure')];
 assert.equal(figures.length,3);
 for(const [i,capture] of BETA_SCREENSHOTS.entries()){
  assert.ok(capture.src.startsWith('/beta/'),'screenshots must be self-hosted');
  assert.ok(capture.build&&Number.isFinite(Date.parse(capture.verifiedAt)),'capture provenance required');
  const bytes=readFileSync('dist'+capture.src);
  assert.equal(createHash('sha256').update(bytes).digest('hex'),capture.sourceSha256,'capture bytes must match inspected source');
  const dimensions=await sharp(bytes).metadata();
  assert.equal(dimensions.width,1290);assert.equal(dimensions.height,2796);
  assert.equal(figures[i].querySelector('img').getAttribute('alt'),copy.screenshotAlts[i]);
  assert.equal(figures[i].querySelector('figcaption').textContent,copy.screenshotCaptions[i]);
  assert.equal(figures[i].querySelector('a').getAttribute('href'),capture.src);
 }
 assert.ok(html.indexOf('beta-product-story')<html.indexOf('beta-comparison')&&html.indexOf('beta-comparison')<html.indexOf('beta-before'),'show the product and comparison before installation');
 for(const path of ['index.html','cards/major-17-star.html']){
   const page=readFileSync(`dist/${prefix}${path}`,'utf8');assert.ok(page.includes(`href="${route}"`),`${lang} localized invitation missing`);
 }
 assert.ok(existsSync(`dist/${prefix}learn/beginner-reference.html`));
}
console.log('Beta journey: eight localized routes/alternates/sitemap, cautious availability, ordered platform steps, no-JS instructions, local QR artwork, feedback and contextual invitations passed. Physical installation and native-speaker review remain separate.');
