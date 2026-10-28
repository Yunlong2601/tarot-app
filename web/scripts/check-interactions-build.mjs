// Inspect real emitted locale indexes/routes, complementing pure ranking tests.
import assert from 'node:assert/strict';
import {readFileSync,existsSync,statSync} from 'node:fs';
import {join} from 'node:path';
import {isSearchIndex,searchEntries} from '../src/lib/search.ts';
const locales=['','zh-hans/','zh-hant/','es/','de/','ja/','fr/','ru/'];
const reversal=['reversed','逆位','逆位','invertida','umgekehrt','逆位置','renversée','перевёрнутая'];
function output(route){const p=decodeURIComponent(new URL(route,'https://shentarot.com').pathname).replace(/^\//,'');return [join('dist',p),join('dist',p+'.html'),join('dist',p,'index.html')].find(f=>existsSync(f)&&statSync(f).isFile());}
let count=0;
for(const [i,locale] of locales.entries()){
 const entries=JSON.parse(readFileSync(output('/'+locale+'search-index.json'),'utf8'));
 assert.ok(isSearchIndex(entries),`valid index ${locale}`);
 assert.equal(entries.filter(e=>e.type==='cards').length,78);
 assert.equal(entries.filter(e=>e.type==='spreads').length,15);
 for(const entry of entries){assert.ok(entry.title&&entry.description,`${locale} ${entry.id} copy`);assert.ok(entry.href.startsWith('/'+locale),`locale route ${entry.href}`);assert.ok(output(entry.href),entry.href);if(entry.image)assert.ok(output(entry.image),entry.image);count++;}
 const queen=entries.find(e=>e.id==='cups_queen');assert.ok(queen);
 for(const q of ['qoc',queen.title]) assert.equal(searchEntries(entries,q)[0].id,queen.id);
 const reversed=searchEntries(entries,queen.title+' '+reversal[i])[0];assert.ok(reversed.href.endsWith('?orientation=reversed#card-meanings'));
 assert.equal(searchEntries(entries,'coins').filter(e=>e.type==='cards').length,14);
 assert.deepEqual(searchEntries(entries,'zz_nonexistent_tarot_word_zz'),[]);
 const search=readFileSync(output('/'+locale+'search'),'utf8');assert.ok(search.includes('data-search-empty')&&search.includes('search-page-result'));
 const read=readFileSync(output('/'+locale+'read'),'utf8');for(const marker of ['data-workspace-loading','data-workspace-failed','id="card-picker"','data-draft-status','id="companion-concept"','data-desk-board','data-desk-spread-name','data-desk-connections','data-motion-toggle'])assert.ok(read.includes(marker),`${locale} missing ${marker}`);
}
console.log(`Interaction build audit passed: 8 localized indexes; ${count} real result routes and thumbnail files; aliases, translated reversals, card counts, and workspace recovery markup.`);
console.log('Does not replace keyboard, visual, native-device, screen-reader or consumer testing.');
