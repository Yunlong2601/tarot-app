# Beta recruitment journey — 29 October 2026

Website-only implementation of the approved 20-point plan. All eight languages ship together. Existing cream/forest identity and free tools remain primary; no backend, native, subscription, new account, tracking or legal-page changes.

## Coverage of the 20 requirements

| # | Implementation / remaining evidence |
|---|---|
| 1 | Platform metadata has available/unavailable/check states, verification dates and official invitations. Both platforms retain cautious check wording because fresh public enrolment is unverified. An existing iPhone TestFlight installation and one reading were verified on the physical device. |
| 2 | Benefit-led localized headline and phone selection. |
| 3 | Three inspected physical-device captures show spread selection, a generated reading summary and an empty optional journal. Full-size links, eight-language alt/captions, English-interface disclosure and source hashes are implemented. No crop, AI editing or simulated screen is used. See device-verification.md. |
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
| 17 | Comparison identifies the verified iPhone 1.0.1 (19) build: physical-deck spread selection, photo/manual entry options and a general-reading path. Output quality, actual scan recognition and storage behavior remain unclaimed. See device-verification.md. |
| 18 | Before-you-join section explains eligibility, external language, no website registration and access/purchase help. The iPhone guide identifies the observed one-credit confirmation in build 1.0.1 (19); it does not imply Android pricing. Unknown OS/device conditions are omitted. |
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

Device Hub verified an installed iPhone beta and one owner-triggered reading using one existing credit. Fresh public enrolment, Android installation, physical QR scanning, actual screen-reader announcements, full accessibility conformance, native-speaker review and recruitment improvement remain unverified. An actual no-script sandbox frame and blocked-storage sandbox frame were exercised; no standalone browser-wide JavaScript-disabled session is claimed.

The screenshot publication gate is satisfied for the three inspected source files now configured in `BETA_SCREENSHOTS`. Replacement captures require the same inspection/provenance and eight-language captions. `BETA_VIDEO` remains null because no verified recording is available; enabling it requires the planned recording, poster, caption tracks and transcript.

No marketing email or tester feedback was sent. Future monitoring should use actual platform enrolment/installation evidence; page visits or clicked links are not proof of testers.

## 30 October follow-up: guide accessibility

- Installation progress now uses a complete localized sentence in all eight languages, with an atomic polite live region. Unchanged counts are not rewritten. This verifies announcement markup, not actual screen-reader speech.
- Mobile action bar hides when a focused control approaches its reserved bottom region; fragment destinations reserve bottom scroll space. Reopening the next step works even when its fragment is already current.
- Chinese headline scales down to fit 320px while preserving natural clauses. Chrome DOM overflow checks passed for all eight locales at 320, 390, 768 and 1440px. A Chinese 390px capture is `chinese-390-accessibility.jpg`.
- Chrome keyboard verification: reset → Android → Space on step-one checkbox focuses step-two summary, opens that step and shows the complete translated count. Closing step two and using the bottom action twice reopens it even with an unchanged fragment.
- Prior continuation also exercised an opaque-origin sandbox frame (actual denied localStorage) and a no-script sandbox frame. Storage denial left confirmation navigation usable; no-script HTML exposed all six platform steps and official links without confirmation checkboxes. Actual Chrome 200% zoom showed no horizontal overflow, then was restored to 100%.
- Current automated checks: 48 tests, localization parity, Astro check (zero errors/warnings; two pre-existing hints), production build and reader/ritual/interaction/search-growth/beta audits pass.
- Physical iPhone is connected in Device Hub. MobileBuildMCP discovery now sees YL, but its UI snapshot tool requires a simulator and cannot inspect this physical device. Device Hub can save full-resolution captures, while screen controls are not reliably actionable through the current connection. No newly captured private phone content is included in the repository or promotional media. TestFlight version confirmation, clean three-screen story, phone QR scans and actual screen-reader testing remain open.

### Accessibility release verification

PR #35 merged as `76d660f0e63d365abd905b7aa0345ecd7064358c`; all six CI checks passed. Cloudflare site version `7f9b26e7-7f44-45ac-9688-543a15c119cb` deployed from merged main. Live release.json matches, privacy/terms return HTTP 200, and the live Chinese beta DOM exposes complete translated progress sentences. IndexNow accepted 3,901 URLs; this does not establish indexing or recruitment.

## Ordered recovery follow-up

Five troubleshooting entries now contain two explicit ordered checks in every locale. The group-membership problem links only to the Android opt-in invitation; other platform problems retain the appropriate Android/iPhone invitations and email fallback. A separate explanation distinguishes unresponsive website controls from platform eligibility/installation errors. The build audit checks the authored ordered steps, five email fallbacks and Android-only retry.

Chrome opened all five recovery entries for eight locales at 390, 768 and 1440px (24 combinations): ten ordered items per route and no horizontal overflow. Chinese mobile evidence: `recovery-390.jpg`. Localization parity, Astro check, production build and the strengthened beta audit pass. No native app was modified.

## 30 October release and remaining verification

PR #36 merged as `88aae2869797244b74f9e3a4bb6783d53cfab57e`; six CI checks passed. Cloudflare site version `adc9786f-22f9-478d-a455-9df50d3186a7` deployed from merged main. Live release.json matches; privacy and terms return HTTP 200.

All 16 built QR SVGs (eight locales × two platforms) were rasterized at the actual 182px content width and independently decoded with macOS Core Image. Every result exactly matches its localized website guide and platform fragment. This is independent decoding evidence, not a physical phone scan. Temporary inputs/results are in `/tmp/shentarot-qr-audit`.

Actual VoiceOver verification was attempted through System Settings. Enabling VoiceOver caused the computer-use capture stream to fail (ScreenCaptureKit -3811), so spoken output was not verified. VoiceOver was switched back off and the off state was inspected in System Settings. The existing caption-panel preference was unchanged. Actual screen-reader announcements remain unverified.

Direct Device Hub input initially failed while the captured window was a tiny tilted thumbnail. After the owner brought it forward and the control session was rebound, a normal 644×822 window capture became available and coordinate taps worked. The agent opened Scan → general reading → three-card spread → manual selection, selected The Star, The Sun and Temperance, and explicitly chose upright for each. The app displays an optional pre-reading observation and Read · 1 credit. No reading is generated until the owner authorizes that one-credit use.

## 31 October: real-app story prepared for release

Three untouched 1290×2796 captures are self-hosted under `/beta/`. The clean summary excludes prior-card history and account details. The product comparison now follows the screenshot story, before installation; phone selection remains directly under the introduction. The iPhone guide explains the observed one-credit confirmation without promising universal or permanent pricing.

All 48 tests, localization parity, Astro checks, build and five audits pass. The beta audit now requires three real source hashes, dimensions, per-locale captions/alt, full-size links and product/comparison order. Chrome checked eight locales at 390/768/1440px (24 combinations): three figures, no horizontal overflow or broken visible images. Desktop figures align; phone figures stack. Evidence: `real-story-desktop.jpg`, `real-story-mobile.jpg`.

Only one existing credit was used by the owner. No more reading, follow-up or clarifier requests were made. Temporary keyboard capture is off; other-app visibility and the prior compact Device Hub mode were restored. Physical QR scans, actual screen-reader announcements and native-language review remain human/device validation items.
