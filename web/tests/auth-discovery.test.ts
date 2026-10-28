import test from 'node:test';
import assert from 'node:assert/strict';
import worker from '../worker/index.js';
const env={ASSETS:{async fetch(){throw Error('Auth discovery must not hit app or assets');}},API:{async fetch(){throw Error('Must not provision credentials');}}};
test('auth.md documents actual OAuth registration, consent, PKCE and credential use',async()=>{
 const r=await worker.fetch(new Request('https://shentarot.com/auth.md'),env);assert.equal(r.status,200);assert.match(r.headers.get('content-type')!,/^text\/markdown/);
 const text=await r.text();assert.match(text,/^# .*auth\.md/m);assert.match(text,/anonymous public client/);assert.match(text,/https:\/\/shentarot.com\/agent\/auth/);assert.match(text,/Authorization: Bearer/);assert.match(text,/code_verifier/);assert.match(text,/user must explicitly approve/i);assert.match(text,/expires_in: 3600/);assert.match(text,/oauth\/revoke/);
});
test('auth.md HEAD and write rejection are passive and issue no credentials',async()=>{
 const head=await worker.fetch(new Request('https://shentarot.com/auth.md',{method:'HEAD'}),env);assert.equal(head.status,200);assert.equal(await head.text(),'');assert.match(head.headers.get('content-type')!,/text\/markdown/);
 const post=await worker.fetch(new Request('https://shentarot.com/auth.md',{method:'POST'}),env);assert.equal(post.status,405);assert.equal(post.headers.get('allow'),'GET, HEAD');
});
test('OAuth discovery and authenticated approval requests reach the real backend unchanged',async()=>{
 const seen: {path: string; auth: string | null; body: string | null}[]=[];
 const proxyEnv={ASSETS:{async fetch(){throw Error('Must not serve static HTML for OAuth');}},API:{async fetch(req: Request){seen.push({path:new URL(req.url).pathname,auth:req.headers.get('authorization'),body:req.method==='POST'?await req.text():null});return new Response('{"proxied":true}',{headers:{'content-type':'application/json'}});}}};
 for(const path of ['/.well-known/oauth-protected-resource','/.well-known/oauth-authorization-server','/oauth/jwks']){
 const r=await worker.fetch(new Request('https://shentarot.com'+path),proxyEnv);assert.equal(r.status,200);assert.deepEqual(await r.json(),{proxied:true});}
 await worker.fetch(new Request('https://shentarot.com/oauth/claim',{method:'POST',headers:{authorization:'Bearer test-placeholder','content-type':'application/json'},body:'{"user_code":"fixture","decision":"deny"}'}),proxyEnv);
 assert.equal(seen.at(-1)!.auth,'Bearer test-placeholder');assert.match(seen.at(-1)!.body!,/"decision":"deny"/);
});
