import test from 'node:test';
import assert from 'node:assert/strict';
import worker, { wantsMarkdown } from '../worker/index.js';
import { toMarkdown } from '../scripts/agent-markdown.mjs';

test('Accept negotiation respects explicit types and quality values', () => {
  for (const value of ['', '*/*', 'text/html', 'text/markdown;q=0', 'text/markdown;q=0.2,text/html;q=0.9']) assert.equal(wantsMarkdown(value), false, value);
  for (const value of ['text/markdown', 'text/markdown, text/html', 'text/html;q=0.2, text/markdown;q=0.9', 'TEXT/MARKDOWN; charset=utf-8']) assert.equal(wantsMarkdown(value), true, value);
});
test('conversion keeps article meaning, links and structured data without UI or scripts', () => {
  const md = toMarkdown('<html><head><title>Card</title><meta name="description" content="Meaning"></head><body><nav>Menu</nav><main><h1>The Sun</h1><p>Clarity &amp; joy. <a href="/cards/sun">Learn</a></p><ul><li>Reflect</li></ul><button>Draw</button><script>secret()</script><div hidden>Hidden</div></main><script type="application/ld+json">{"@type":"Article"}</script></body></html>', 'https://shentarot.com/');
  assert.match(md, /# The Sun/); assert.match(md, /Clarity & joy/); assert.match(md, /https:\/\/shentarot.com\/cards\/sun/); assert.match(md, /-\s+Reflect/); assert.match(md, /```json/);
  assert.doesNotMatch(md, /Menu|secret|Hidden|<main>|Draw/);
});
const env = {
  ASSETS: { async fetch(req: Request) {
    const path = new URL(req.url).pathname;
    if (path === '/_agent-markdown/index.md' || path === '/_agent-markdown/zh-hans/cards/index.md') return new Response('# Meaning\n', {headers:{'content-type':'text/markdown'}});
    if (path.startsWith('/_agent-markdown/')) return new Response('missing', {status:404});
    if (path === '/robots.txt') return new Response('User-agent: *', {headers:{'content-type':'text/plain'}});
    if (path === '/missing') return new Response('Not found', {status:404});
    return new Response('<h1>Meaning</h1>', {headers:{'content-type':'text/html','etag':'html-only','vary':'Accept-Encoding','content-security-policy':"default-src 'self'"}});
  }},
  API: { async fetch() { return new Response('private', {headers:{'cache-control':'no-store'}}); } }
};
test('Worker serves Markdown, HTML default, nested indexes and HEAD with correct headers', async () => {
  for (const path of ['/', '/zh-hans/cards']) {
    const r = await worker.fetch(new Request('https://shentarot.com'+path, {headers:{accept:'text/markdown'}}), env);
    assert.match(r.headers.get('content-type')!, /text\/markdown/); assert.equal(await r.text(), '# Meaning\n'); assert.equal(r.headers.get('etag'), null); assert.equal(r.headers.get('vary'), 'Accept-Encoding, Accept'); assert.equal(r.headers.get('content-signal'), 'ai-train=no, search=yes, ai-input=no'); assert.ok(r.headers.has('content-security-policy'));
  }
  const html = await worker.fetch(new Request('https://shentarot.com/'), env); assert.match(html.headers.get('content-type')!, /text\/html/); assert.match(await html.text(), /<h1>/);
  const head = await worker.fetch(new Request('https://shentarot.com/', {method:'HEAD',headers:{accept:'text/markdown'}}), env); assert.match(head.headers.get('content-type')!, /text\/markdown/); assert.equal(await head.text(), '');
});
test('Worker preserves private shares, non-HTML, errors and HTML fallback', async () => {
  for (const [path, body, status] of [['/s/example','private',200],['/robots.txt','User-agent: *',200],['/missing','Not found',404],['/no-alternate','<h1>Meaning</h1>',200],['/_agent-markdown/index.md','Not found',404]] as const) {
    const r=await worker.fetch(new Request('https://shentarot.com'+path,{headers:{accept:'text/markdown'}}),env);assert.equal(r.status,status);assert.equal(await r.text(),body);
  }
});
