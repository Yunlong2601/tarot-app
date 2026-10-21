# Website reference workspace: implementation and verification

Implemented on `feat/website-reader-workspace` in a separate worktree based on `origin/google-play-prep`. Original working copy and its uncommitted research were preserved. App, backend, prices, credit rules and entitlements were not edited.

## Delivered

- Website-led homepage with card search, spread selection and own-card workspace actions; existing artwork and tools retained.
- All-78-card name/keyword search, common English aliases, suit filters, reversed queries, clear empty-result recovery and short meanings. Card pages have an orientation switch and carry card/orientation into the workspace.
- Numbered spread diagrams sourced from the shared app layout coordinates and ordered position keys. Build validation checks every layout against its position count. Original worked examples for Past/Present/Future, Situation/Challenge/Way Forward and the centre pair of Celtic Cross. Mobile layouts were also checked for Celtic Cross at 390px and Horseshoe at 320px without horizontal overflow. The crossing pair is offset in the diagram for legibility; this is a reference layout, not a photo scanner.
- Browser-only `/read` workspace: all shared spread definitions, manual card assignment, duplicate prevention, orientation edits, move earlier/later, per-card reference links, optional first impression and reflective comparison prompts. It produces no generated reading.
- One explicitly labelled browser-local saved reflection; tab-scoped draft recovery; restore, deletion, copy, UTF-8 text export and print/PDF output. No account sync or premium journal entitlement is implied. The original app's journal is untouched.
- A short beginner practice path using the existing lessons and combinations tool.
- `/astrology` index and a recurring, undated practice on the existing zodiac pages. No live horoscope publishing system was invented. Symbolic astrology is distinguished from astronomy and personalised charts; NASA Science provides a factual sky-resource link. No calculated sky data is claimed.
- New interface/example copy in all eight existing locales, using the existing JSON loader and validation structure. Native-speaker review is still needed.
- Canonical/hreflang metadata retained and new localized routes added to the sitemap. No new analytics, remote fonts, cookies or API calls were added.

## AI integration handoff: intentionally unavailable on the website

The website Worker (`web/worker/index.js`) forwards only `/s/*` to its API binding. Everything else is static assets. `backend/src/index.ts` requires a verified Bearer install token for `/v1/reading` and `/v1/followup`. `/v1/install` currently rejects issuance unless the testing flag `ALLOW_UNATTESTED_INSTALLS` is enabled. That flag must not become a public browser-auth workaround. No browser login/access adapter or same-origin AI forwarding route is configured in this website snapshot.

A backend owner must supply a supported browser identity/session and abuse-control design, approved same-origin routing or CORS, and an access/credit preflight that shares the existing account rules. Then wire the shared card IDs, orientations, spread ID, question and optional impression into the existing request validator, retaining the original draw for follow-ups. Verify charging and safe retries before enabling any submission control. Do not put provider keys, install tokens or test credentials in static HTML or browser storage.

The UI therefore shows a plain availability note: AI is not connected here, inputs are not sent to an AI service, and this workspace consumes no credits. It has no fake submit button or synthetic AI result. Completing the authenticated API flow remains dependent on that separately coordinated backend work.

## Automated checks

Run from `web/`:

```sh
npm run check:i18n
npm test
npm run check
npm run build
npm run check:reader-build
```

- Five focused state/search/storage tests cover duplicates and reordering, invalid persisted data, Unicode save/restore, denied/quota storage failures, aliases and reversal queries.
- Translation structure and placeholders match across all eight locales.
- Astro check reports no errors or warnings; two existing hints remain in the unchanged birth-card pages (an unused import and an inline define:vars identifier).
- Production build generates 3,869 pages.
- Build verification checks 80 important pages across eight locales for working internal links/assets, canonical and alternate metadata, and new sitemap entries.

## Actual browser evidence

Production output served locally through Astro preview. Browser-controlled verification used synthetic questions and reflections only.

- Homepage “Queen of Cups reversed” search → one result → reversed meaning → seeded reversed card in workspace.
- Three-card entry, disabled duplicate options, orientation edits followed by card replacement, reordering and manual restore.
- Saved reflection recovered after refresh and after closing/reopening the tab; deletion followed by reload/restore correctly found no saved record.
- Clipboard contents and the downloaded text file included the spread, cards, orientation and reflection.
- Generated a PDF through the browser print pipeline; the print-only reading contained the question/cards/reflection. Physical printing was not tested.
- Keyboard Tab moved from question to first impression with a visible outline; Skip focused the first card picker.
- Narrow 390px layouts had no horizontal document overflow for the workspace and Celtic guide. Japanese workspace content was inspected; French workspace and Celtic Cross also passed at 320px without document overflow.
- Existing daily draw/reveal and birth-card calculation produced valid output without browser console errors.
- Search empty-result and reset restored all 78 cards; astrology navigation loaded the new index.

Browser preview was restarted after a development-server connection interruption; subsequent core checks ran on production output.

Browser quota fault injection was not supported by the available CDP method; denied/quota failures were checked through the injectable storage helper tests, not claimed as browser-simulated. No human comprehension study, physical phone, screen reader, production deployment, live AI request, cross-device sync or native translation review was performed.

## Review notes

The reference/library remains server-rendered without JavaScript; interactive search and the workspace require JavaScript and a noscript route links to meanings/spreads. Local browser storage is not a permanent backup. Export before clearing browser data or switching devices. No database migration is required.

Screenshots in `docs/verification/website-2026-10-21/` capture the built website with synthetic reading data. The research documents accompany the implementation for context; their market hypotheses remain unvalidated.
