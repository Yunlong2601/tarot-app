# Website production release — 28 October 2026

- PR: https://github.com/Yunlong2601/tarot-app/pull/30
- Deployed source: `0a85e221fc3395846f3b8f4cad75d7c828a50d50` (main)
- Cloudflare website version: `c5ccb80d-1a15-4bc3-ad9b-f02f2f494cef`
- Previous website version: `a5bfe501-94de-416d-aab5-0a5f179bb7fa`

Merged current main privacy wording with multilingual search, drawing/reading continuity, practice content, beta onboarding and already-published website discovery handlers. Deployment affects only shentarot-site.

Validation: all six GitHub checks (push and PR app/backend/web) passed. Local 41 tests, Astro (zero errors/warnings; two existing hints), eight locales, 3,911-page build, reader/ritual/interaction/search/beta audits, dependency audit (zero production vulnerabilities), Wrangler dry-run. Chrome tested exact three-card/question/orientation transfer, saved reflection after reload, reversed search, Chinese library and 390px reading desk without horizontal overflow.

Production fresh `/release.json?v=0a85e22` matches source. Default browser release URL initially showed an older cached response. Live search returned Queen of Cups reversed with the correct destination. Chinese library has correct title/canonical. Privacy effective date is 28 October and terms load. IndexNow returned 200 for 3,894 submissions; this does not establish search-engine indexing or ranking improvements.

## Upstream issue retained

OAuth discovery returned 404 both at shentarot.com and directly at shentarot-api.shentech.workers.dev. Direct API health returned `{ok:true}`. Before/after website bindings match: API → shentarot-api, environment production; ASSETS unchanged. Backend deployment history shows versions a4cfca93 and 806446d8 at 11:47 UTC after the prior e12c121e OAuth deployment. This supports an upstream issue, but this release did not audit or repair backend source. No backend deployment or rollback was performed. Browser-native AI remains unavailable as advertised.

Physical devices, native screen readers, translation quality, consumer comprehension and paid conversion were not certified by this release. Yandex ownership was verified separately; sitemap UI remains read-only.
