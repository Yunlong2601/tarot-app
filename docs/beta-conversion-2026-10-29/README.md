# Beta recruitment journey — 29 October 2026

Website-only implementation of the approved 20-point plan. All eight languages ship together. Existing cream/forest identity and free tools remain primary; no backend, native, subscription, new account, tracking or legal-page changes.

## Coverage of the 20 requirements

| # | Implementation / remaining evidence |
|---|---|
| 1 | Platform metadata has available/unavailable/check states, verification dates and official invitations. Both platforms use cautious check wording until physical installation is verified. |
| 2 | Benefit-led localized headline and phone selection. |
| 3 | Three-screenshot story renderer and required localized alt/captions/provenance fields implemented. **Media not published:** existing store captures could not be compared with the currently distributed build. No simulated/concept app screenshot is substituted. |
| 4 | Optional self-hosted video renderer, explicit controls, preload none, poster, per-locale captions and transcript. **Omitted per plan:** no verified recording is available. |
| 5 | Homepage hero text invitation; beta-page header and mobile navigation point to phone selection. |
| 6 | Home, shared invitation bands and FAQ distinguish testing from public-store release. Unavailable production badges removed from these recruitment panels. |
| 7 | Explicit platform selection and fragment navigation. No automatic device selection; both guides exist in initial HTML. |
| 8 | Android sequence retains group → opt-in → install, with user-confirmed steps and Show all steps. Opening external links does not mark completion. |
| 9 | Existing-group shortcut opens step two without marking group membership. |
| 10 | Versioned local progress contains only platform, six installation flags and four task flags; reset, invalid-data and denied/quota storage recovery. |
| 11 | Build-time local SVG QR codes link to each localized guide/platform fragment, with text and copy fallback. **Physical phone scanning not verified.** |
| 12 | Same-account warning appears at the Android introduction and beside group/opt-in actions. Store profile check explained at installation. |
| 13 | Five problem-specific expandable recovery paths, official retry invitations and localized help email subjects. |
| 14 | Eight complete static routes, canonical/alternate metadata, sitemap, nav, captions/messages and feedback templates; no EN-only labels. **Native-speaker review remains required before broad promotion.** |
| 15 | Beta-only next-step mobile bar appears after selector leaves view, reserves safe-area/body space, hides during dialogs/editing/keyboard viewport contraction or zoom. |
| 16 | Contextual localized invitations on card pages and after all cards in a draw have been revealed. No readings/questions are passed into invitations. |
| 17 | Honest website/app comparison; specific distributed-build capabilities remain deliberately unclaimed pending verification. |
| 18 | Before-you-join section explains platform eligibility, external language, no website registration, build-specific access/purchases and help. Unverified OS/device/pricing claims omitted. |
| 19 | Optional first-reading mission, four locally remembered checklist items and localized beginner-guide link; no detected-installation claim. |
| 20 | Localized mailto feedback template, copy fallback, privacy reminder and dated website release note. No fabricated native release notes, reviews or tester counts. |

## Verification

- 48 website tests pass, including new invalid/obsolete progress, locale-independent persistence, field stripping, denied/quota storage, next-step and fragment tests.
- Eight-language dictionary parity passes.
- Astro: zero errors/warnings, two existing unrelated hints.
- Production build: 3,918 pages and 3,917 Markdown documents.
- Reader, ritual, interactions, search-growth and revised beta production audits pass.
- Taste source review of beta page/CSS: zero failures or warnings. Browser review uses the supported CUA browser API, not the skill's separate browser inspector.
- Browser: platform selection, confirmation, reload persistence and reset checked. All eight locales measured at phone width without document overflow. English desktop at 1,440px and German tablet at 768px reviewed; desktop and Chinese mobile screenshots are saved alongside this report.
- Static audit verifies no-JavaScript initial HTML exposes both complete guides, official destinations, local SVG QR, feedback template and fallback links. No claim of a full browser no-JavaScript session.
- QR generation runs at build time with `qrcode`; no QR service or runtime script. Dependency audit fixes also update Wrangler within its existing supported range; API binding and Worker routes are unchanged. `npm audit` and `npm audit --omit=dev`: zero vulnerabilities.

## Explicit limits and media publication gate

iPhone Mirroring was inspected and reported Connection Interrupted. No compatible physical Android/iPhone installation, physical QR scan, actual screen-reader session, complete accessibility conformance, native-speaker review or recruitment improvement has been verified. A raw-CDP no-JavaScript attempt was unavailable; static no-JS structure remains verified. Do not describe these as passed.

Before enabling `BETA_SCREENSHOTS`, compare three clean captures with a distributed beta, record build/date and original evidence, provide real alt/captions in all eight locales and self-host them. Before enabling `BETA_VIDEO`, provide a verified 20–30 second recording, poster, eight caption tracks and transcripts. Keep both configurations empty/null until then. The decorative card back is website art, not an app screenshot.

No marketing email or tester feedback was sent. Future monitoring should use actual platform enrolment/installation evidence; page visits or clicked links are not proof of testers.
