# PROGRESS

Last updated: 2026-10-16. Update this file at the end of every phase.

Primary working copy: the owner's local Mac folder. This repo is the backup and hand-off point.

| Phase | Scope | Status |
|---|---|---|
| Step 1 | Plan, research, costs (`docs/step1-plan.md`) | Done |
| A | Project setup, navigation, mock screens | Done (PR #1) |
| B | 78-card data, card list/search/detail | Done; card art added on branch `phase-g-card-art` |
| C | Camera scan, on-device recognition, manual fallback | Code built; a BASELINE model (public-domain art + synthetic augmentation only) is in `app/assets/models/`; NOT run on a device; not validated on real photos (see `ml/README.md`) |
| D | Cloudflare Worker proxy + AI reading | Code built on branch `phase-d-backend` (on top of `phase-c-scan`); backend + app tests pass; verified locally with wrangler dev (real local D1/KV, `backend/scripts/smoke.sh` passes); NOT deployed, never called the real API; device attestation not implemented: DECISION (owner, 2026-10-16): implement App Attest + Play Integrity before the public launch; waits for Apple Team ID and final bundle ID |
| E | RevenueCat subscriptions + real paywall | Code built on branch `phase-e-subscriptions`; fake-service tests pass; NOT run against RevenueCat or a store (`docs/phase-e-subscriptions-setup.md`) |
| F | SQLite history/journal, notifications, accessibility, polish | Code built on branch `phase-f-history`; 47 tests pass; iOS simulator build OK; notifications and SQLite NOT tried on a device; accessibility audit and follow-ups not done |
| G | Tests, store checklists, privacy and terms drafts | Docs written on branch `phase-g-release-docs` (checklists, test plan, data inventory, legal DRAFTS bundled in the app); lawyer review and device testing still to do |

## Launch readiness (Android first; shared code for iOS) — 2026-10-17

Every feature the paywall, store listing or README promises, checked on the signed release build against the live server where possible.

| Feature | Status | Notes |
|---|---|---|
| Camera scan, on-device recognition | Partly built | Works in code and on the emulator; model trained only on public-domain art, never tested on a real deck photo. Blocked on owner: deck photos for training, real-phone test |
| Manual card picker (with upright/reversed) | Built | Verified on emulator |
| Digital draw on screen | Built | Verified on emulator |
| 14 spreads, free one-time trial of a longer spread | Built | |
| AI reading (Claude Haiku, GPT-6 Luna backup) | Built, live | Verified on emulator with the live server |
| Look first note | Built | Verified live |
| Card-by-card layout, Why this card | Built | Verified live |
| Follow-up questions (Premium) | Built | Tested in code; live test needs Premium (blocked on RevenueCat) |
| Clarifier card (Premium) | Built | Same as above |
| Journal notes (Premium) | Built | Same as above |
| Look back a week later (Premium) | Built | In-app prompt only; no reminder notification yet |
| Reading history | Built | Verified on emulator |
| Card of the Day (free) | Built | |
| Daily reminder notification | Built | Not tried on a real phone |
| Card library (78 cards, upright/reversed) | Built | |
| Guide (how to use + 12 lessons + myths) | Built | |
| Report a reading (AI content) | Built | |
| Crisis wording → fixed care message | Built | Hotline numbers still to verify (owner) |
| Paywall, restore, manage subscription | Built | Shows "not available yet" until RevenueCat key exists (blocked on owner) |
| Own AI key | Built, hidden for launch | `OWN_KEY` flag |
| Accounts / sign-in | Built, off until set up | Google (Android) and Apple (iOS, behind `APPLE_SIGNIN`) sign-in, sign out, Delete account; server endpoints + migration `0002_accounts.sql` NOT deployed yet. Owner steps: `docs/accounts-setup.md`. Deletion page live: https://yunlong2601.github.io/shentarot-legal/delete-account.html |
| Play Integrity / App Attest | Not built | Blocked: app must exist in Play Console (Android) and Apple enrollment (iOS) |
| Topic chips on the question screen | Not built | Nice to have |

### (A) Can build now, no accounts needed (in order)
1. Reminder notification for the week-later look back (reuses the daily-reminder permission).
2. Clearer slow-server / offline / daily-limit states on the reading spinner (a message after ~10 s, retry button).
3. Topic chips (Love / Work / Self) on the question screen feeding the spread recommendation.
4. Accessibility pass on the new screens (reading panels, look back, Look first dialog) at 2x text.
5. Play Integrity code path behind a flag (server verification stays off until the owner links the app).

### (B) Blocked on the owner
1. RevenueCat + Play subscriptions (product ids in `docs/play-release-guide.md`), then the `goog_` key and `REVENUECAT_SECRET_KEY`.
2. Upload the AAB to a closed test, recruit testers (check the current tester/day rule).
3. Real-phone test, including a real card scan; deck photos for model training.
4. Verify crisis hotline numbers; decide on accounts (`docs/accounts-plan.md`).
5. Hero art and landing video (optional for v1).

## Next step
Backend live (test mode) at https://shentarot-api.shentech.workers.dev with Claude Haiku 5.5, GPT-6 Luna fallback and own-key support. Verified 2026-10-16 on the Android emulator: debug build with `--dart-define-from-file=config/live.json`, digital Career Path reading with a question and a Look-first note returned a real AI reading that used the note. Own-key mode is hidden in the app for launch (flag `OWN_KEY`). See `docs/own-key-and-providers.md`.

Readings are now laid out by section (`app/lib/features/reading/reading_sections.dart` parses the backend text; no backend change): a gold "In short" panel, one panel per card with its art, position and an expandable "Why this card", then "To reflect on" and "A small step". Old plain readings still show as text. Debug "Simulate scan" now produces a sample in the same layout. 93 app tests pass.

Clarifier card (Premium) is built: "Draw a clarifier card" under a reading draws one card on screen or takes one the user picked from their deck (never a card already in the reading) and sends it with `/v1/followup` as `clarifier` (counts against the 30 follow-ups a day). 90 app tests, 51 backend tests pass. Left from the knowledge plan: structured card-by-card rendering, intent chips, journal mood/tags.

Look back after a week (Premium) is built: 7 to 59 days after a reading, the Read tab shows "Look back at last week's reading" and the reading screen asks how it turned out (Save or Not now). Answers stay on the device (SQLite schema v2, `revisit` column, upgrade tested). No push notification for it yet (would reuse the daily reminder permission). 88 app tests pass.

"Look first" is built: before an AI reading a dialog asks what you notice in the cards (optional, Skip works, Cancel backs out); it is sent as `impression` (backend already handled it). Toggle in the You tab (default on). The privacy text mentions it. Still open from the plan: clarifier card, journal 7-day revisit, structured rendering. 85 app tests pass.

All 78 cards now have rich original knowledge (`app/tools/knowledge_courts.py`, `knowledge_pips.py`; run `make_knowledge.py` then `backend/scripts/gen-cards.mjs`). Owner should skim the pip/court wording; imagery notes were written from memory of the 1909 pictures and should be spot-checked against the scans. Backend 50 tests pass.

Google Play prep (branch `google-play-prep`): app id `com.shentech.shentarot`, upload key in `~/shentarot-keys` (back it up), signed release AAB, minimal permissions, report-a-reading button (Play AI content policy), data-safety answers, release guide, store assets in `store/play/`, release build verified on an Android emulator. See `docs/play-release-guide.md` for what only the owner can do.

(Earlier) New reading flow from the owner's second wireframe set (branch `spreads-and-flow`): Ask -> Select a Spread -> draw (digital slots / photo) -> reading; 14 spreads in two catalogs (app + backend), free trial reading for longer spreads, Library by category, layout view. See `docs/design-notes.md`. Deliberately changed/omitted wireframe items are listed there.

(Earlier) Tarot knowledge pass (branch `tarot-knowledge`, see `docs/tarot-knowledge-plan.md` for what is done and not done): reversed-card bug fixed (backend now sends orientation-specific data), new reading prompt with JSON output, crisis pre-check, stored-text fallback, 22 Majors written richly, Card of the Day, reversed setting, position labels, question nudge, 12-lesson Guide. Next content work: courts, then pips; then Look-first, clarifier, journal revisit.

(Earlier) UI redesign (branch `ui-redesign`, from the owner's wireframe): tabs Read / Guide / Library / You, landing with Photo-or-Digital reading button, digital card reading (tap to flip), Guide (how to use + tarot basics), Library (Spreads | Cards), You tab, and a DEMO sign-in page (no accounts; closable). Details and what is NOT built: `docs/design-notes.md`. Owner to supply: hero artwork (`app/assets/hero/hero.jpg`) and the landing video. Before release decide: build real sign-in or remove the demo "Sign in" button.

(Earlier) Store name chosen (ShenTarot: AI Scan & Read); onboarding text rewritten to the "hold the cards, we explain them" positioning; listing copy drafted in `docs/store-listing.md` (do not publish before real-device tests pass).

(Earlier) Android: toolchain installed and debug APK + release AAB build (see `docs/play-store-checklist.md`); not run on any device; release is debug-signed.

(Earlier) Phase G docs are done (see README for the list). The privacy policy and terms are filled in (provider ShenTech, contact shenyunlongbusiness@gmail.com, minimum age 13, usage records kept 90 days) and bundled in the app; NOT lawyer-reviewed (owner has no budget; use Apple's standard EULA on iOS). Static pages for the public URLs are in `site/`; published via GitHub Pages from the public repo Yunlong2601/shentarot-legal: https://yunlong2601.github.io/shentarot-legal/privacy.html and .../terms.html (edit `site/`, then copy to that repo and push). Owner now: Apple enrollment, then `docs/phase-e-subscriptions-setup.md`, deploy the backend (`backend/README.md`), build to a real iPhone and run `docs/test-plan.md`. Accessibility pass done in code (`app/test/accessibility_test.dart`: WCAG contrast of theme colours, tap-target and label guidelines, no overflow at 2x text on a small phone; fixed onboarding, Cards grid and paywall close button); still needs a real VoiceOver check on a device. App icon and dark launch screen are done (original art, rendered by `app/tool/make_icon_test.dart`; regenerate with `flutter test tool/make_icon_test.dart && dart run flutter_launcher_icons`). Engineering still open: App Attest / Play Integrity, real-photo training and evaluation of the card model (needs the owner's deck photos), Android build.

(Earlier) Phase F is coded: readings are saved in SQLite on the device (history list, swipe/delete, delete-all), Premium journal notes, daily reminder (local notification, permission asked only when switched on), onboarding flag and the daily free-reading count now persist. Decisions: history is visible to everyone; writing journal notes is Premium. Follow-up questions (Premium) are implemented on branch `phase-d-followups`: `POST /v1/followup` (30 a day), button on the reading screen, answers shown for the visit only (not saved). Privacy policy and data inventory updated (the earlier reading text is sent for context). Remaining before release: accessibility pass (VoiceOver, Dynamic Type), real-device test of notifications. Next: Phase G (tests, store checklists, privacy and terms drafts) after "continue".

(Earlier) Phase E is coded. Owner: follow `docs/phase-e-subscriptions-setup.md` (Apple + RevenueCat setup), then sandbox-test. Next build phase: F (history/notifications/polish) after "continue". iOS is the priority; Play Store work starts after.

(Earlier) Phase D is coded (`backend/`, `app/lib/core/`). Remaining: owner creates Anthropic/Cloudflare accounts and keys, deploys (`backend/README.md`), builds the app with `--dart-define=API_BASE_URL=...`, and tests a real reading; implement App Attest / Play Integrity in `POST /v1/install`. Then Phase E after "continue".

(Earlier note) Phase C is coded (`app/lib/features/scan/`: `recognition/scan_logic.dart`, `preprocess.dart`, `recognizer.dart`, `camera_scan_screen.dart`). Remaining for Phase C: write the `ml/` training pipeline, train and export `app/assets/models/tarot_classifier.tflite` (needs the owner's card photos), and test on real iPhone and Android. Without the model the scan screen falls back to the manual picker. Then Phase D after the owner says "continue".

## Local setup notes (Mac)
- Flutter 3.47.7 in `~/development/flutter`, GitHub CLI in `~/development/gh` (both on PATH via `~/.zshrc`).
- `flutter doctor`: CocoaPods missing (needed for iOS builds because `tflite_flutter` has no Swift Package Manager support; the macOS system Ruby 2.6 could not install it, so use Homebrew or a newer Ruby), and no Android SDK.

## I need to do (owner)
- Run the tests and `flutter run` on the Mac and report problems (nothing has run on a real device yet).
- Card art: open the Commons pages in `app/assets/cards/art/CREDITS.md` and confirm each is the original 1909/1910 Pamela Colman Smith scan, not a 1971+ recolour.
- Skim `app/assets/cards/cards.json` meanings (original wording) before release.
- Pick the final app name; check trademarks and store names (top pick: ShenTarot).
- Create Anthropic API account with a monthly spend limit; Cloudflare and RevenueCat accounts; join Apple Small Business Program.
- Check the Google Play new-personal-account testing rule (testers/days) and the school's rules on commercial work.
- Buy 2-3 physical RWS-style decks and photograph them for training (see the ML section of `docs/phase-c-design.md`).
- Lawyer review: image licensing, trademark wording, privacy policy, terms.

## Known issues / not verified
- Nothing has been built or run on iOS or Android; only `flutter analyze` and 17 tests (in a Linux sandbox, all passing).
- Card art: 78 Commons scans (all report licence "Public domain", dated 1910, 1909 Pamela Colman Smith deck) are in the repo; I spot-checked 3 by eye. Owner must still open the Commons file pages (listed in `app/assets/cards/art/CREDITS.md`) and confirm none is a 1971+ US Games recolour before release.
- Store fees, prices and policies in the plan were checked on the web on 2026-10-16 and must be re-verified before launch.
