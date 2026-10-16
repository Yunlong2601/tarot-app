# PROGRESS

Last updated: 2026-10-16. Update this file at the end of every phase.

Primary working copy: the owner's local Mac folder. This repo is the backup and hand-off point.

| Phase | Scope | Status |
|---|---|---|
| Step 1 | Plan, research, costs (`docs/step1-plan.md`) | Done |
| A | Project setup, navigation, mock screens | Done (PR #1) |
| B | 78-card data, card list/search/detail | Done (PR #1); card art not yet added |
| C | Camera scan, on-device recognition, manual fallback | Code built on branch `phase-c-scan`; unit tests pass; NOT run on a device; no trained model yet |
| D | Cloudflare Worker proxy + AI reading | Code built on branch `phase-d-backend` (on top of `phase-c-scan`); backend + app tests pass; NOT deployed, never called the real API; device attestation not implemented |
| E | RevenueCat subscriptions + real paywall | Code built on branch `phase-e-subscriptions`; fake-service tests pass; NOT run against RevenueCat or a store (`docs/phase-e-subscriptions-setup.md`) |
| F | SQLite history/journal, notifications, accessibility, polish | Code built on branch `phase-f-history`; 47 tests pass; iOS simulator build OK; notifications and SQLite NOT tried on a device; accessibility audit and follow-ups not done |
| G | Tests, store checklists, privacy and terms drafts | Docs written on branch `phase-g-release-docs` (checklists, test plan, data inventory, legal DRAFTS bundled in the app); lawyer review and device testing still to do |

## Next step
Phase G docs are done (see README for the list). The privacy policy and terms are filled in (provider ShenTech, contact shenyunlongbusiness@gmail.com, minimum age 13, usage records kept 90 days) and bundled in the app; NOT lawyer-reviewed (owner has no budget; use Apple's standard EULA on iOS). Static pages for the public URLs are in `site/`; published via GitHub Pages from the public repo Yunlong2601/veilscan-legal: https://yunlong2601.github.io/veilscan-legal/privacy.html and .../terms.html (edit `site/`, then copy to that repo and push). Owner now: Apple enrollment, then `docs/phase-e-subscriptions-setup.md`, deploy the backend (`backend/README.md`), build to a real iPhone and run `docs/test-plan.md`. App icon and dark launch screen are done (original art, rendered by `app/tool/make_icon_test.dart`; regenerate with `flutter test tool/make_icon_test.dart && dart run flutter_launcher_icons`). Engineering still open: App Attest / Play Integrity, trained card model (`ml/` pipeline), card art, accessibility pass, follow-up questions, Android build.

(Earlier) Phase F is coded: readings are saved in SQLite on the device (history list, swipe/delete, delete-all), Premium journal notes, daily reminder (local notification, permission asked only when switched on), onboarding flag and the daily free-reading count now persist. Decisions: history is visible to everyone; writing journal notes is Premium. Follow-up questions are NOT implemented (removed from the paywall and reading screen until the backend supports them). Remaining before release: accessibility pass (VoiceOver, Dynamic Type), real-device test of notifications. Next: Phase G (tests, store checklists, privacy and terms drafts) after "continue".

(Earlier) Phase E is coded. Owner: follow `docs/phase-e-subscriptions-setup.md` (Apple + RevenueCat setup), then sandbox-test. Next build phase: F (history/notifications/polish) after "continue". iOS is the priority; Play Store work starts after.

(Earlier) Phase D is coded (`backend/`, `app/lib/core/`). Remaining: owner creates Anthropic/Cloudflare accounts and keys, deploys (`backend/README.md`), builds the app with `--dart-define=API_BASE_URL=...`, and tests a real reading; implement App Attest / Play Integrity in `POST /v1/install`. Then Phase E after "continue".

(Earlier note) Phase C is coded (`app/lib/features/scan/`: `recognition/scan_logic.dart`, `preprocess.dart`, `recognizer.dart`, `camera_scan_screen.dart`). Remaining for Phase C: write the `ml/` training pipeline, train and export `app/assets/models/tarot_classifier.tflite` (needs the owner's card photos), and test on real iPhone and Android. Without the model the scan screen falls back to the manual picker. Then Phase D after the owner says "continue".

## Local setup notes (Mac)
- Flutter 3.47.7 in `~/development/flutter`, GitHub CLI in `~/development/gh` (both on PATH via `~/.zshrc`).
- `flutter doctor`: CocoaPods missing (needed for iOS builds because `tflite_flutter` has no Swift Package Manager support; the macOS system Ruby 2.6 could not install it, so use Homebrew or a newer Ruby), and no Android SDK.

## I need to do (owner)
- Run the tests and `flutter run` on the Mac and report problems (nothing has run on a real device yet).
- Card art: run `python3 app/tools/fetch_art.py --check`, then without `--check`; review every Commons file page (1909 printing, public domain). The file titles in the script are unverified guesses.
- Skim `app/assets/cards/cards.json` meanings (original wording) before release.
- Pick the final app name; check trademarks and store names (top pick: Veilscan).
- Create Anthropic API account with a monthly spend limit; Cloudflare and RevenueCat accounts; join Apple Small Business Program.
- Check the Google Play new-personal-account testing rule (testers/days) and the school's rules on commercial work.
- Buy 2-3 physical RWS-style decks and photograph them for training (see the ML section of `docs/phase-c-design.md`).
- Lawyer review: image licensing, trademark wording, privacy policy, terms.

## Known issues / not verified
- Nothing has been built or run on iOS or Android; only `flutter analyze` and 17 tests (in a Linux sandbox, all passing).
- No card art in the repo yet (placeholders shown).
- Store fees, prices and policies in the plan were checked on the web on 2026-10-16 and must be re-verified before launch.
