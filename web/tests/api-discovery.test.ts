import test from 'node:test';
import assert from 'node:assert/strict';
import worker from '../worker/index.js';
import { catalog, openapi } from '../worker/api-discovery.js';
const env = { ASSETS: { async fetch(req: Request) { return new Response(new URL(req.url).pathname.startsWith('/_agent-markdown/') ? '# Home' : '<h1>Home</h1>', {headers:{'content-type':new URL(req.url).pathname.startsWith('/_agent-markdown/')?'text/markdown':'text/html'}}); } }, API:{async fetch(){return new Response('private');}} };
test('catalog identifies the deployed API and supplies resolvable docs, spec and health relations',async()=>{
 const r=await worker.fetch(new Request('https://shentarot.com/.well-known/api-catalog'),env);
 assert.equal(r.status,200);assert.match(r.headers.get('content-type')!,/^application\/linkset\+json/);assert.deepEqual(await r.json(),catalog);
 for(const entry of catalog.linkset){assert.equal(new URL(entry.anchor).protocol,'https:');for(const rel of ['service-desc','service-doc','status'] as const)assert.ok(entry[rel][0].href.startsWith('https://'));}
 for(const path of ['/api/openapi.json','/api/docs']){const r=await worker.fetch(new Request('https://shentarot.com'+path),env);assert.equal(r.status,200);}
 assert.equal(openapi.servers[0].url,catalog.linkset[0].anchor);assert.ok(openapi.paths['/health']);assert.ok(openapi.paths['/v1/reading'].post.security);
});
test('all discovery endpoints support HEAD and reject writes',async()=>{
 for(const path of ['/.well-known/api-catalog','/api/openapi.json','/api/docs']){
 const head=await worker.fetch(new Request('https://shentarot.com'+path,{method:'HEAD'}),env);assert.equal(head.status,200);assert.equal(await head.text(),'');
 const post=await worker.fetch(new Request('https://shentarot.com'+path,{method:'POST'}),env);assert.equal(post.status,405);assert.equal(post.headers.get('allow'),'GET, HEAD');}
});
test('homepage HTML and Markdown advertise all registered discovery relations',async()=>{
 for(const accept of ['text/html','text/markdown']){
 const r=await worker.fetch(new Request('https://shentarot.com/',{headers:{accept}}),env);const links=r.headers.get('link')!;
 for(const rel of ['api-catalog','service-desc','service-doc','describedby'])assert.ok(links.includes(`rel="${rel}"`));
 assert.match(r.headers.get('content-type')!,accept==='text/html'?/text\/html/:/text\/markdown/);}
 const docs=await worker.fetch(new Request('https://shentarot.com/api/docs',{headers:{accept:'text/markdown'}}),env);assert.match(docs.headers.get('content-type')!,/text\/markdown/);assert.match(await docs.text(),/# ShenTarot App API/);
});

test('public content permits grounding while reserving training rights',async()=>{
 for(const path of ['/', '/api/docs','/api/openapi.json','/.well-known/api-catalog','/auth.md']){
  const response=await worker.fetch(new Request('https://shentarot.com'+path),env);
  assert.equal(response.headers.get('content-signal'),'ai-train=no, search=yes, ai-input=yes',path);
 }
});
