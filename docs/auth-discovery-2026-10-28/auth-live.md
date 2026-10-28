# ShenTarot auth.md

## 1. Audience and supported access

For agents helping a user understand ShenTarot or integrate its supported mobile
app. Public pages, Markdown representations, API documentation and service health
need no credential. API resource server:
https://shentarot-api.shentech.workers.dev

Independent agent registration and delegated account registration are not
supported. This document describes the existing app provisioning method; it does
not introduce an agent identity, claim ceremony, or permission to create an
installation for someone. Reading and follow-up requests may spend credits and
require the user's explicit instruction.

## 2. Discovery and method selection

- API catalog: https://shentarot.com/.well-known/api-catalog
- Core OpenAPI reference: https://shentarot.com/api/openapi.json
- Human documentation: https://shentarot.com/api/docs
- Supported credential method: short-lived app-install JWT, sent in the HTTP
  Authorization header with the Bearer scheme.
- Provisioning endpoint: POST https://shentarot-api.shentech.workers.dev/v1/install
  (mobile-app installation flow only, subject to deployment configuration).
- OAuth Protected Resource Metadata and Authorization Server Metadata are not
  published. There is no OAuth issuer, OAuth scope set or OAuth refresh token.
- Additional agent identity, ownership-claim and automated account-registration
  methods are unavailable. No structured agent-registration or revocation-event
  metadata is advertised.

If you are an independent agent seeking your own credential, stop here. Ask the
user to use the supported app rather than inventing an installation or collecting
Google/Apple tokens, passwords or email verification codes.

## 3. App provisioning method

Only the supported app installation flow should call this endpoint. Passive
scanners must not POST it: doing so can issue credentials and create install
activity. The request uses the app's existing install UUID; do not generate a new
identity just to bypass limits.

```http
POST /v1/install HTTP/1.1
Host: shentarot-api.shentech.workers.dev
Content-Type: application/json

{"installId":"<existing-app-install-uuid>"}
```

When provisioning is enabled and accepted, HTTP 200 returns:

```json
{"token":"<short-lived-install-JWT>"}
```

The token expires after 12 hours. Issuance depends on the deployed app-attestation
or beta configuration; a valid request can return HTTP 501 with
{"error":"attestation_not_configured"} when unattested installations are disabled.
HTTP 400 means invalid input; HTTP 429 means rate limited. Do not retry with new
install IDs or attempt to bypass an attestation restriction. Availability of
provisioning was not tested by creating a live credential.

## 4. Credential use

Use the token only against the ShenTarot API resource server over HTTPS:

```http
Authorization: Bearer <short-lived-install-JWT>
```

Never place credentials in query strings, public documents, logs, prompts or
requests to unrelated hosts. The documented protected operations are POST
/v1/reading and POST /v1/followup; their input shapes are in the OpenAPI reference.
A valid credential does not bypass credits, Premium rules or daily limits.

Optional account sign-in is performed inside the app using Google or Apple;
POST /v1/account/signin links that authenticated identity to an existing install.
It is not an agent registration method or a permission to acquire user tokens.

## 5. Expiry, failure and revocation

On HTTP 401, stop using the credential and let the supported app renew it through
its normal provisioning flow. There is no refresh-token or standalone revocation
endpoint for install JWTs. Discard locally held credentials when access is no
longer authorized; expiry is enforced server-side. App account sign-out is not a
claim that an install JWT has been revoked.

HTTP 402 indicates credit/entitlement restrictions; obtain user action in the app.
HTTP 429 indicates a limit; stop and retry later. HTTP 501 at provisioning means
that the current installation method is unavailable. Do not work around these
responses by creating new installations or accounts.
