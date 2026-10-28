export const authMarkdown = `# ShenTarot auth.md

## 1. Audience and discovery

For agents requesting access to a user's existing ShenTarot reading account.
The user must explicitly approve in a build of the ShenTarot app that includes
Settings → Agent access. Public website content requires no authentication.

- Resource server: https://shentarot-api.shentech.workers.dev
- Protected Resource Metadata: https://shentarot-api.shentech.workers.dev/.well-known/oauth-protected-resource
- Authorization server issuer: https://shentarot.com
- Authorization Server Metadata: https://shentarot.com/.well-known/oauth-authorization-server
- Public signing keys: https://shentarot.com/oauth/jwks
- Core API reference: https://shentarot.com/api/openapi.json

Read the live metadata before proceeding. The PRM authorization_servers entry
must match the AS issuer. Supported scopes are reading:create and
followup:create; bearer credentials are sent only in the Authorization header.
This is OAuth authorization-code access with S256 PKCE. It is not OpenID Connect
and does not issue ID tokens or refresh tokens.

## 2. Register an anonymous public client

The supported Auth.md method is anonymous client registration followed by a
signed-in user's ownership claim/consent. Registration alone grants no reading
access, free credits, account creation or user identity. No ID-JAG or email-only
claim method is offered. Never POST registration during a passive scan.

POST https://shentarot.com/agent/auth with application/json:

\`\`\`json
{
  "type": "anonymous",
  "requested_credential_type": "access_token",
  "client_name": "Your agent name",
  "redirect_uris": ["https://your-agent.example/oauth/callback"],
  "token_endpoint_auth_method": "none",
  "grant_types": ["authorization_code"]
}
\`\`\`

Use your real registered HTTPS callback, without a fragment or embedded user
credentials. HTTP callbacks are accepted only on loopback for native clients.
HTTP 201 returns client_id, client_name, redirect_uris,
token_endpoint_auth_method: none, grant_types: [authorization_code], and
response_types: [code]. No client_secret or bearer access token is issued yet.
Client names are self-asserted and appear as unverified in the approval UI.

## 3. Request authorization and user approval

Generate a cryptographically random code_verifier of 43–128 unreserved ASCII
characters and code_challenge = BASE64URL(SHA256(code_verifier)), without padding.
Keep the verifier secret. Generate a fresh unpredictable state value (at least
16 characters) and bind it to your initiating user/session.

Open the authorization_endpoint in a browser with:

\`\`\`text
response_type=code
client_id=<registered client_id>
redirect_uri=<exact registered callback>
code_challenge=<S256 challenge>
code_challenge_method=S256
state=<random session-bound state>
scope=reading:create followup:create
resource=https://shentarot-api.shentech.workers.dev
\`\`\`

Request only needed scopes. The page displays a ten-minute user code, requested
permissions and your callback host. The user opens the ShenTarot app, signs in,
then enters the code under Settings → Agent access. They review the unverified
client name, callback host and credit-spending permissions, then approve or deny.
Do not ask for the user's Apple/Google tokens, app credentials or passwords.
If the installed app has no Agent access screen, the user needs an updated app
build before proceeding. Do not substitute a script that creates an install.

The claim_uri is https://shentarot.com/oauth/claim. It accepts POST JSON
{user_code, decision: approve|deny} only with an existing signed-in app-install
bearer credential. It is called by the app, not by the registering agent.
The app first POSTs {user_code} to /oauth/review to retrieve the exact consent
request. A decision is one-use and cannot be replaced after approval or denial.

Keep the browser page open. After approval it redirects to the registered callback
with code, state and iss. Verify state against your initiating session and verify
iss equals https://shentarot.com before exchanging. Denial returns access_denied.
Requests expire after ten minutes; start again if expired.

## 4. Exchange the one-use code

POST https://shentarot.com/oauth/token using application/x-www-form-urlencoded:

\`\`\`text
grant_type=authorization_code
client_id=<registered client_id>
redirect_uri=<same exact registered callback>
code=<callback code>
code_verifier=<original secret verifier>
\`\`\`

Success returns access_token, token_type: Bearer, expires_in: 3600, and scope.
The code is bound to the client, exact redirect URI and verifier and can be
exchanged only once. There is no password or client-credentials grant.

## 5. Use the credential

Send Authorization: Bearer <access_token> only over HTTPS to the resource server.
reading:create permits POST /v1/reading; followup:create permits POST /v1/followup.
Normal request bodies are described in the OpenAPI reference. Access does not
permit reading history, sharing, account deletion, account linking or administration.

Requests use the approving user's existing credits, Premium entitlements and
rate/daily limits. Do not spend credits without that user's request. Readings
are for entertainment and self-reflection only. Never put tokens in URLs or logs.
Tokens are signed with RS256; issuer, audience, expiry, grant status and the
original install-to-account binding are checked on every protected request.

## 6. Expiry, revocation and errors

Tokens expire after one hour. There is no automatic refresh: repeat authorization
and obtain fresh user approval when access expires. On 401 stop using the token.
Unlinking/changing/deleting the approving account also invalidates its install-bound
access. On 402 follow the app's credit/entitlement instructions. On 429 stop and
retry later; never create new clients, installations or accounts to bypass limits.

An agent can revoke its own access with POST https://shentarot.com/oauth/revoke,
application/x-www-form-urlencoded, token=<access_token>. The user can also revoke
from Settings → Agent access in the app. Revocation takes effect on the next API
request. Unsupported revocation-event delivery is not advertised.

Registration errors include invalid_client_metadata and slow_down. Authorization
errors include invalid_redirect_uri, invalid_request and expired_request. Code
exchange errors include invalid_grant and unsupported_grant_type. Discard an
invalid grant and restart from discovery; do not repeatedly replay an old code.
`;

export function authResponse(request) {
  if (new URL(request.url).pathname !== '/auth.md') return null;
  if (!['GET', 'HEAD'].includes(request.method)) return new Response('Method not allowed', {status:405,headers:{allow:'GET, HEAD'}});
  return new Response(request.method === 'HEAD' ? null : authMarkdown, {headers:{
    'content-type':'text/markdown; charset=utf-8', 'cache-control':'public, max-age=300',
    'content-signal':'ai-train=no, search=yes, ai-input=no', 'x-content-type-options':'nosniff',
  }});
}
