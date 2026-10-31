// Discovery documents describe the existing app API; they grant no new access.
const SITE = 'https://shentarot.com';
const API = 'https://shentarot-api.shentech.workers.dev';
export const DISCOVERY_LINKS = [
  `<${SITE}/auth.md>; rel="describedby"; type="text/markdown"`,
  `<${SITE}/.well-known/api-catalog>; rel="api-catalog"; type="application/linkset+json"`,
  `<${SITE}/api/openapi.json>; rel="service-desc"; type="application/vnd.oai.openapi+json"`,
  `<${SITE}/api/docs>; rel="service-doc"; type="text/html"`,
  `<${SITE}/llms.txt>; rel="describedby"; type="text/plain"`,
].join(', ');
export const catalog = { linkset: [{
  anchor: API,
  'service-desc': [{ href: `${SITE}/api/openapi.json`, type: 'application/vnd.oai.openapi+json' }],
  'service-doc': [{ href: `${SITE}/api/docs`, type: 'text/html' }],
  status: [{ href: `${API}/health`, type: 'application/json' }],
}] };
const ref = name => ({ $ref: `#/components/schemas/${name}` });
const jsonContent = schema => ({ 'application/json': { schema } });
const response = (description, schema = ref('Error')) => ({ description, content: jsonContent(schema) });
const errors = { '400': response('Invalid input'), '401': response('Missing or expired install token'), '402': response('Premium or credits required'), '429': response('Rate or daily limit reached'), '503': response('Service temporarily unavailable'), '502': response('Upstream failure'), '422': response('Request declined') };
const readingProperties = {
  spread: { type: 'string', description: 'A supported spread id, for example single, three or celtic. Card count must match that spread.' },
  cards: { type: 'array', minItems: 1, maxItems: 10, items: ref('Card'), description: 'Known, unique card ids in spread-position order.' },
  question: { type: ['string', 'null'], maxLength: 300 },
  impression: { type: ['string', 'null'], maxLength: 300 },
};
export const openapi = {
  openapi: '3.1.0',
  info: { title: 'ShenTarot App API — core operations', version: '1.0.0', description: 'Discovery of the existing mobile-app API. This specification covers health, installation, readings and follow-ups; it is not an exhaustive inventory of account, credit, sharing, webhook or administrative operations. Requires the normal app install token and applicable entitlements. Delegated OAuth reading/followup access is available with explicit user approval; see /auth.md. Entertainment and self-reflection only.' },
  servers: [{ url: API }],
  externalDocs: { url: `${SITE}/api/docs` },
  paths: {
    '/health': { get: { operationId: 'health', summary: 'Service liveness', responses: { '200': response('Worker is responding; does not attest upstream AI availability', {type:'object',required:['ok'],properties:{ok:{type:'boolean',const:true}}}) } } },
    '/v1/install': { post: { operationId: 'install', summary: 'Obtain a short-lived app-install token', description: 'For the mobile app. Issuance is controlled by deployment attestation/beta configuration; discovery is not permission to create installations. Returns 501 when attestation is not configured and un-attested installs are disabled.', requestBody: {required:true,content:jsonContent({type:'object',required:['installId'],properties:{installId:{type:'string',format:'uuid'}}})}, responses: {'200':response('Install token',{type:'object',required:['token'],properties:{token:{type:'string'}}}),'400':errors['400'],'429':errors['429'],'501':response('Attestation not configured')} } },
    '/v1/reading': { post: { operationId: 'reading', summary: 'Request a reading for selected cards', security: [{installBearer:[]},{agentOAuth:['reading:create']}], requestBody:{required:true,content:jsonContent(ref('ReadingRequest'))},responses:{...errors,'200':response('Reading or fixed care response',{oneOf:[ref('ReadingResponse'),ref('CareResponse')]})} } },
    '/v1/followup': { post: { operationId:'followup',summary:'Ask a follow-up about an earlier reading',description:'Requires an install token and applicable credits/entitlements. Earlier reading text is supplied by the client.',security:[{installBearer:[]},{agentOAuth:['followup:create']}],requestBody:{required:true,content:jsonContent(ref('FollowupRequest'))},responses:{...errors,'200':response('Answer or fixed care response',{oneOf:[{type:'object',required:['answer','disclaimer'],properties:{answer:{type:'string'},disclaimer:{type:'string'}}},ref('CareResponse')]})} } },
  },
  components:{securitySchemes:{agentOAuth:{type:'oauth2',flows:{authorizationCode:{authorizationUrl:'https://shentarot.com/oauth/authorize',tokenUrl:'https://shentarot.com/oauth/token',scopes:{'reading:create':'Create readings with user credits','followup:create':'Ask followups with user credits'}}}},installBearer:{type:'http',scheme:'bearer',bearerFormat:'JWT',description:'Short-lived app-install token issued by the existing app flow.'}},schemas:{
    Card:{type:'object',required:['id','reversed'],properties:{id:{type:'string',description:'Existing ShenTarot card id, such as major_19_sun.'},reversed:{type:'boolean'}}},
    ReadingRequest:{type:'object',required:['spread','cards'],properties:readingProperties},
    FollowupRequest:{type:'object',required:['spread','cards','reading','followup'],properties:{...readingProperties,reading:{type:'string',minLength:1,maxLength:4000},followup:{type:'string',minLength:1,maxLength:300},clarifier:{anyOf:[ref('Card'),{type:'null'}],description:'Optional additional card, distinct from the spread.'}}},
    ReadingResponse:{type:'object',required:['reading','disclaimer'],properties:{reading:{type:'string'},disclaimer:{type:'string'},fallback:{type:'boolean'},structured:{type:['object','null'],additionalProperties:true}}},
    CareResponse:{type:'object',required:['crisis','message'],properties:{crisis:{type:'boolean',const:true},message:{type:'string'}}},
    Error:{type:'object',required:['error'],properties:{error:{type:'string'},detail:{type:'string'}},additionalProperties:true},
  }},
};
export const docsMarkdown = `# ShenTarot App API

Base URL: ${API}

This is the existing mobile-app API. Delegated OAuth access to reading and
follow-up operations requires explicit approval from a signed-in app user.
See https://shentarot.com/auth.md for registration, PKCE, scopes and revocation.
The catalog describes one API. The OpenAPI document covers its core operations;
account, credit, sharing, webhook and administrative operations are outside this
public reference. Discovery does not grant access or change authentication.

- [API catalog](${SITE}/.well-known/api-catalog)
- [OpenAPI specification](${SITE}/api/openapi.json)
- [Service health](${API}/health)

## Core operations

- GET /health — returns {"ok":true} when the Worker responds. This is liveness,
  not a guarantee that the AI provider or all dependencies are available.
- POST /v1/install — app installation flow; JSON contains an installId UUID.
  Token issuance depends on deployment attestation/beta configuration. A disabled
  unattested-install flow returns 501. Agents must not mint installations on a
  user's behalf; no delegated registration flow is provided.
- POST /v1/reading — bearer install token, spread id and cards (id, reversed),
  optional question/impression. The card count must match the spread and card
  ids must be unique and known. May consume the user's reading credits.
- POST /v1/followup — bearer install token, spread/cards, earlier reading and
  followup text; optional question and clarifier. Applicable credits and
  entitlements are enforced by the existing backend.

## Access and usage

Use the supported app flow for app authentication, or the delegated OAuth flow
in https://shentarot.com/auth.md for scoped agent access. Questions and followups are
limited to 300 characters; earlier-reading context is limited to 4,000.
Readings are for entertainment and self-reflection only. Do not send payment,
account secrets or sensitive personal information. Errors include invalid input
(400), unauthorized (401), entitlement/credit restrictions (402), rate limits
(429) and temporary upstream/service failures (502/503). Treat 429 as a stop and
retry later; do not bypass limits. Care responses may replace model-generated
readings. Do not create readings or spend credits without the user's request.

## Website representations

Public website pages support Accept: text/markdown. Browsers receive HTML by
default. Private shared readings are not converted. Existing content usage
preferences are ai-train=no, search=yes, ai-input=yes.
`;
const escapeHTML = text => text.replaceAll('&','&amp;').replaceAll('<','&lt;').replaceAll('>','&gt;');
const docsHTML = `<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width"><title>ShenTarot API documentation</title></head><body><main><h1>ShenTarot API documentation</h1><p><a href="/api/openapi.json">OpenAPI specification</a> · <a href="/.well-known/api-catalog">API catalog</a></p><pre style="white-space:pre-wrap;overflow-wrap:anywhere">${escapeHTML(docsMarkdown)}</pre></main></body></html>`;

export function discoveryResponse(request, preferMarkdown) {
  const path = new URL(request.url).pathname;
  const resource = path === '/.well-known/api-catalog' ? [JSON.stringify(catalog), 'application/linkset+json']
    : path === '/api/openapi.json' ? [JSON.stringify(openapi), 'application/vnd.oai.openapi+json']
    : path === '/api/docs' ? [preferMarkdown ? docsMarkdown : docsHTML, preferMarkdown ? 'text/markdown' : 'text/html'] : null;
  if (!resource) return null;
  const headers = {'content-type':resource[1]+'; charset=utf-8','cache-control':'public, max-age=300','content-signal':'ai-train=no, search=yes, ai-input=yes','x-content-type-options':'nosniff'};
  if (!['GET','HEAD'].includes(request.method)) return new Response('Method not allowed',{status:405,headers:{allow:'GET, HEAD'}});
  if (path === '/api/docs') headers.vary = 'Accept';
  return new Response(request.method === 'HEAD' ? null : resource[0],{headers});
}
