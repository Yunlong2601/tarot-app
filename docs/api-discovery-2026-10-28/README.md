# API discovery release — 2026-10-28

Published the existing ShenTarot app API via RFC 9727 Linkset at `https://shentarot.com/.well-known/api-catalog`, HTTP 200 and `application/linkset+json`. One API anchor: `https://shentarot-api.shentech.workers.dev`. Links resolve to an OpenAPI 3.1 core-operations reference (`/api/openapi.json`), human-readable docs (`/api/docs`) and the live API `/health` endpoint.

Homepage HTML and Markdown responses carry RFC 8288 Link relations `api-catalog`, `service-desc`, `service-doc`, `describedby`, with HTTPS absolute targets. Existing Link values are appended to rather than replaced. Discovery resources support GET/HEAD and reject writes. Docs also negotiate Markdown. No backend/authentication/access-permission changes, token issuance, reading creation, account mutation or credit spending were performed.

## Verification

- 38 site tests pass (conversion, routing, catalog, methods, homepage links and previous feature tests).
- Independent OpenAPI validator: `/tmp/shentarot-openapi.json is valid`.
- Real local Wrangler checks: catalog HTTP 200/content type, homepage Link header and Markdown docs.
- Live checks fetched every catalog relation; OpenAPI is valid JSON, docs return HTML and health returns `{"ok":true}`. Unauthenticated reading rejects with 401.
- Both homepage representations have all four relations. Six browser/static baseline bodies remain byte-identical.
- Supplied scanner POST returned pass for `checks.discovery.apiCatalog`, `checks.discoverability.linkHeaders` and `checks.contentAccessibility.markdownNegotiation`. Saved evidence in scanner-results.json.

## Deployment and limits

Worker `dbce59b9-87eb-4a72-8df3-e55e4cd95491` deployed at 100%. Prior version/rollback: `b261e456-30fd-4641-a306-8f56f1eb913a`. Cloudflare upload reported no modified static assets. Isolated release retained production revision `472d72f51717dc05b36d2e0333c0e993fd2f21eb`, Content Signals and all generated Markdown; unrelated local changes excluded.

The app API reference intentionally documents core health/install/reading/followup operations. Account, credits, sharing, webhooks and administrative operations are explicitly outside that reference. Health is liveness, not an upstream availability guarantee. Discovery does not provide delegated registration or authorization. Existing authenticated paid AI workflows were not called in validation.
