# Delegated OAuth reading access — 2026-10-28

## Delivered

- Auth.md at https://shentarot.com/auth.md, H1 contains auth.md, Markdown response.
- OAuth AS metadata at https://shentarot.com/.well-known/oauth-authorization-server.
- PRM at https://shentarot-api.shentech.workers.dev/.well-known/oauth-protected-resource (mirrored on website).
- Consistent issuer https://shentarot.com; authorization, token and public JWKS endpoints; authorization_code grant, code response, S256 PKCE, no client secret, no refresh token.
- agent_auth skill/register_uri/claim_uri/revocation_uri and the supported anonymous public-client registration method. Client registration grants no user access. A signed-in app user must review and approve the client, redirect origin and scopes; then the client exchanges the one-use code.
- One-hour RS256 tokens limited to reading:create / followup:create, no account/history/admin access. Each API request verifies signature, issuer, audience, expiry, revocation and unchanged install-to-account ownership. Existing credit, entitlement, content safety and rate limits remain on the original handlers.
- App Settings → Agent access screen supports preview, explicit approve/deny, active grant list and revoke. It is in the compiled native update; NOT distributed to App Store/TestFlight/Play in this task. Existing store builds without that screen must update before user approval is possible. This limitation is also stated in auth.md.

## Verification

- Newer native/backend checkout: 152 backend tests pass, 200 Flutter tests pass, flutter analyze reports no issues.
- Website: 41 tests pass. Exact-production backend source: 8 additional targeted OAuth tests pass with real SQLite statements; these are the same scenarios included in the backend suite, not 8 different extra features.
- Local Worker/D1 HTTP flow passed registration → authorization page → authenticated user review/approval → PKCE exchange → reading authentication → revocation. Deliberately malformed reading bodies ensure no AI calls or credits spent. Missing scope and account deletion rejected; code replay rejected. All accounts/credentials in this test were local fixtures.
- Tests cover deny, expiry, changed ownership (including an account relink between validation and billing), duplicate exchange, wrong verifier/client/redirect, unsupported grants/scopes, grant revocation and existing API credit-limit behavior.
- iOS Simulator Debug build succeeded for Runner.xcworkspace / Runner on iPhone 18 Pro iOS 27 (72F735A0-6375-4EDC-A6F3-32554DB97A87), derived data /tmp/shentarot-oauth-deriveddata. Compile only; no physical-device/Apple-login/store-distribution claim. Existing third-party plugin warnings remain.
- Live passive checks pass for health, metadata, matching issuer/resource, public-only RSA JWKS and PRM WWW-Authenticate hint on a 401 reading request.
- External scanner passes Auth.md (anonymous only, no warnings), OAuth discovery, API catalog, Link headers, Markdown negotiation and Content Signals.
- Six browser/static body SHA-256 baselines remain identical to the earlier website release. No live agent registration POST, user token issuance, account creation, reading or credit spending was performed for validation.

## Release integrity

Backend deployed version e12c121e-5d88-4c64-93c1-7d3218ebfa6f. Previous backend rollback 67f71706-b3e9-4395-8cb5-fb4ab2c7f0e4. Website version a5bfe501-94de-416d-aab5-0a5f179bb7fa; previous website rollback c1e90a72-988a-478d-9c0e-1964ef51a061. Additive D1 migration 0010_oauth.sql creates only OAuth clients/requests/grants tables and indexes. No existing identity/credit tables were changed.

Release source was reconstructed from the exact active backend source map. OAuth was applied with only minimal index imports/mounting and reading/followup identity resolution edits. The newer native checkout matches that baseline except unrelated unreleased event/spread additions, which were excluded from deployment. A default-only Worker entry preserves runtime handlers without exporting test constants. All prior bindings, plain variables and secrets were compared for exact equality before activation. The new signing key is a secret_text binding; private signing keys and OAuth credential payloads are not in this report or repository. Install identifiers stored in grants are encrypted with AES-GCM using an HKDF key derived from the existing secret. Existing security settings were preserved.

## Source and next release

Native/backend changes are in tarot-app/.claude/worktrees/zealous-bartik-6d72b9. Website changes are in shentarot-connected-practice. The portable native-backend-oauth.patch includes only task-owned changes for review/handoff. Do not deploy the older website checkout's backend over production. Native distribution is a separate release step; the ready approval UI must ship for existing app users to authorize agents.

For signing-key rotation, use a new secret JWK and kid; existing OAuth tokens become invalid and users must reauthorize. Keep the original legacy app JWT_SECRET unchanged. Rollback the backend/website versions above if necessary; the additive tables can remain unused. No destructive rollback migration is needed. Do not store private JWKs in repository files.
