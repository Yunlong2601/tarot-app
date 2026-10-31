import { authResponse } from './auth-discovery.js';
import { DISCOVERY_LINKS, discoveryResponse } from './api-discovery.js';
// Shared readings retain their private backend response. Public static HTML has
// an alternate build-generated Markdown representation for requesting agents.
const POLICY = 'ai-train=no, search=yes, ai-input=yes';

export function wantsMarkdown(accept = '') {
  const ranges = accept.toLowerCase().split(',').map(part => {
    const [type, ...params] = part.trim().split(';');
    const qParam = params.map(p => p.trim()).find(p => p.startsWith('q='));
    const q = qParam ? Number(qParam.slice(2)) : 1;
    return { type, q: Number.isFinite(q) && q >= 0 && q <= 1 ? q : 0 };
  });
  const markdown = Math.max(0, ...ranges.filter(r => r.type === 'text/markdown').map(r => r.q));
  const html = Math.max(0, ...ranges.filter(r => r.type === 'text/html').map(r => r.q));
  return markdown > 0 && markdown >= html;
}

function varyAccept(headers) {
  const vary = headers.get('vary');
  if (vary !== '*' && !vary?.split(',').some(v => v.trim().toLowerCase() === 'accept')) headers.set('vary', vary ? `${vary}, Accept` : 'Accept');
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const oauthPaths = new Set(['/.well-known/oauth-protected-resource', '/.well-known/oauth-authorization-server', '/agent/auth', '/oauth/authorize', '/oauth/token', '/oauth/jwks', '/oauth/review', '/oauth/claim', '/oauth/grants', '/oauth/revoke', '/oauth/revoke-grant']);
    if (oauthPaths.has(url.pathname)) return env.API.fetch(request);
    const authenticationGuide = authResponse(request);
    if (authenticationGuide) return authenticationGuide;
    const discovery = discoveryResponse(request, wantsMarkdown(request.headers.get('accept') || ''));
    if (discovery) return discovery;
    if (url.pathname.startsWith('/s/')) return env.API.fetch(request);
    // Do not expose implementation-only alternate assets as public URLs.
    if (url.pathname.startsWith('/_agent-markdown/')) return new Response('Not found', { status: 404 });
    const preferMarkdown = wantsMarkdown(request.headers.get('accept') || '');
    const originRequest = new Request(request);
    if (preferMarkdown) for (const header of ['if-none-match', 'if-modified-since', 'range', 'if-range']) originRequest.headers.delete(header);
    const html = await env.ASSETS.fetch(originRequest);
    if (!['GET', 'HEAD'].includes(request.method) || html.status !== 200 || !html.headers.get('content-type')?.includes('text/html')) return html;
    const headers = new Headers(html.headers);
    varyAccept(headers);
    headers.set('content-signal', POLICY);
    if (url.pathname === '/') headers.append('link', DISCOVERY_LINKS);
    if (!preferMarkdown) return new Response(html.body, { status: html.status, headers });
    const path = url.pathname.replace(/\/$/, '') || '/index';
    const candidates = path.endsWith('.html') ? [path.replace(/\.html$/, '.md')] : [path + '.md', path + '/index.md'];
    for (const path of candidates) {
      const assetURL = new URL(url);
      assetURL.pathname = '/_agent-markdown' + path;
      const markdown = await env.ASSETS.fetch(new Request(assetURL, { method: 'GET', headers: { Accept: 'text/plain' } }));
      if (!markdown.ok || markdown.headers.get('content-type')?.includes('text/html')) continue;
      const text = await markdown.text();
      for (const name of ['content-length', 'content-encoding', 'etag', 'last-modified', 'content-range', 'transfer-encoding']) headers.delete(name);
      headers.set('content-type', 'text/markdown; charset=utf-8');
      return new Response(request.method === 'HEAD' ? null : text, { status: 200, headers });
    }
    // A stale/missing alternate must never break the public HTML page.
    return new Response(html.body, { status: html.status, headers });
  },
};
