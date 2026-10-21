# Proposed browser AI contract — backend coordination required

Current-state inspection on 22 October: the website Worker forwards only `/s/*`; `backend/src/index.ts` reading/follow-up handlers require a verified Bearer install token. `/v1/install` remains guarded by `ALLOW_UNATTESTED_INSTALLS`, a testing flag, and is not browser authentication. No supported browser session/access preflight has appeared in current main. No backend file was edited or deployed; no credentials or reading payload were sent to production AI endpoints.

## Existing request contract

`backend/src/validate.ts` accepts:

```json
{
  "spread": "three_decision",
  "cards": [
    {"id":"major_01_magician","reversed":false},
    {"id":"pentacles_two","reversed":true},
    {"id":"pentacles_eight","reversed":false}
  ],
  "question":"How can I make room for a creative project?",
  "impression":"The coins seem busy."
}
```

Array order defines positions in the shared spread; do not invent arbitrary position names. Exact count and unique known IDs are required. Question and impression are cleaned and limited to 300 characters each. The reference workspace allows longer personal notes; an AI adapter must explain the limit and ask the user to shorten a copy, never silently truncate or delete the original.

Existing follow-up adds `reading` (required, maximum 4,000 cleaned characters), `followup` (required, maximum 300), and optional unique `clarifier`. It carries spread/cards/question again. Existing API trusts client-supplied reading context as untrusted content; a browser integration should bind server-side reading ownership and original draw rather than allow the client to switch it.

The backend already reserves usage and refunds a charged credit lot on handled model failure. That does not establish idempotent handling of a lost response or repeated HTTP request. Disabling a UI button alone cannot guarantee charging safety.

## Concrete proposal for the backend owner (not implemented)

1. Agree supported browser identity. Prefer same-origin secure HttpOnly session cookies, CSRF protection and an approved login flow tied to the existing credit identity. Do not mint app install tokens in browser JavaScript or store provider keys in HTML/local storage. Approve service routing and abuse/rate controls explicitly.
2. Provide a same-origin access preflight, e.g. `POST /api/reading-access` with spread and intent only. Return `allowed`, `signInRequired`, actual `creditCost`, available balance/allowance, limit/reset information and a short-lived server-bound access reference. Do not display guessed prices/credits from static configuration.
3. Provide `POST /api/readings` taking the validated existing request plus an opaque idempotency key and access reference. Bind the key to authenticated identity and a canonical request digest. Reserve/charge once, preserve a retrievable operation status, and return the same result on safe retry. Reject changed content under a reused key. Proposed response: operation/reading ID, status, reference to original draw, explanation text and actual charge outcome.
4. Provide operation status recovery after a lost response. A timeout must not automatically create a second charge. Review atomicity, expiry and refund/retry races with the existing wallet owner.
5. Provide follow-up by owned reading ID, new prompt and optional clarifier. Recover original confirmed cards/question on the server. Preflight each follow-up under existing Premium/credit rules. Do not grant new entitlements.
6. Keep validation, unauthorised, access/credit denial, rate limit, service unavailable and retriable failure distinguishable. UI retains all draft data, explains whether any charge occurred and offers the correct retry or sign-in action.
7. Evaluate explanations for card-in-position, at least one relationship, an alternative, no deterministic predictions and no unnecessary agreement with the user's assumption. Keep AI optional and label generated text.

Approval needed before changing `backend/`: owner of browser login/session, existing wallet identity mapping, routing, CSRF/CORS policy and idempotency persistence. This document is the concrete handoff, not permission to enable a test bypass. Current website stays reference-only until the supported flow passes the following gates.

## Required integration gates before enabling submission

- Unauthenticated/expired sessions and CSRF failures cannot request or charge a reading.
- Access preflight matches actual Premium/credit limits; changes between preflight and commit are handled without an unintended charge.
- Double click, two tabs, repeated request, lost response/status recovery and model failure cannot duplicate spending for one operation.
- Mismatched count, duplicate/unknown IDs, invalid orientations and oversized text are rejected while local input survives.
- Follow-ups cannot change the original draw or access another user's reading.
- Test success, refusal, 402/429/503, timeout and recovery with deterministic fixtures before a separately authorised live AI smoke test.
- No question, card IDs, photos, birth data or generated reading is added to analytics or client error telemetry.
