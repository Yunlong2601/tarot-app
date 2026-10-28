# OAuth discovery: integration decision pending

Current verified state: website and backend protected-resource metadata return 404; backend authorization-server metadata returns 404. Backend uses 12-hour HS256 install JWTs and optional Google/Apple ID-token verification to link an existing installation. These are not OAuth access tokens issued for delegated agent scopes. No live registration or token issuance was probed.

The user expanded the objective to working OAuth/OIDC discovery. A truthful issuer must identify an actual authorization server with functional authorize/token/JWKS endpoints. Do not publish dummy endpoints, empty signing keys, relabel an app install endpoint as OAuth, or proxy a third-party issuer as though its access tokens already authorize the reading API.

Pending user choice: (1) add actual delegated OAuth access to the existing reading API, or (2) document a provider the user already uses. Asked asynchronously in chat; no answer yet.

If adding delegated access, implementation needs a user-approved registration/consent flow tied to the existing account, narrowly scoped access to readings/followups, issuer/audience validation in the backend, expiry/revocation, registered redirect URI validation and PKCE, one-use authorization codes, signing keys/JWKS and secret rotation. Existing credits/entitlements/rate limits must remain tied to the original user. Publish PRM and AS metadata only once those flows are configured and validated. Do not expose unsupported registration methods or spend real user credits in passive validation.

If documenting an existing provider, verify its issuer and all discovery endpoints and confirm the resource server accepts its tokens for the advertised operations. The Google/Apple app-signin implementation alone does not prove that integration.

The Auth.md self-contained fallback is independent and describes current supported app provisioning, with independent agent registration explicitly unavailable. OAuth discovery remains incomplete; do not mark the full expanded goal complete.

## Read-only follow-up audit

Rechecked the active backend deployment (version `67f71706-b3e9-4395-8cb5-fb4ab2c7f0e4`) via Wrangler version metadata. The only matching configured identity-provider binding is `APPLE_CLIENT_IDS` (plain-text configuration); no OAUTH/OIDC/ISSUER/AUTH0/WORKOS/ACCESS_AUD binding was found. No values or secrets were printed. Source search likewise found Apple/Google ID-token account linking, not a configured authorization server. The website OAuth discovery endpoint still returns 404 and the published auth.md remains available.

This narrows the integration decision: there is no discovered existing agent OAuth provider to document. Recommended path, if the user wants agents to operate the reading API, is a new delegated OAuth integration tied to existing app accounts, with explicit user consent and existing credit limits. The pending question still requires an answer before dependent account/authentication changes; no credential issuance or access expansion performed.

## Blocked audit

The same missing OAuth integration choice persisted across three consecutive goal turns: the expanded-objective turn requested it, the first continuation verified only Apple sign-in is configured in the active backend, and this continuation rechecked live auth.md (200), website AS metadata (404), and backend PRM (404). No user selection or provider configuration was supplied. The self-contained guide, tests, release and evidence are finished; remaining work changes account authentication and credential issuance and depends on choosing an actual issuer/integration. Goal marked blocked, not complete, pending that input. Resume without redoing completed discovery work.
