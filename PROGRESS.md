# PROGRESS

Last updated: 2026-10-16. Update this file at the end of every phase.

Primary working copy: the owner's local Mac folder. This repo is the backup and hand-off point.

| Phase | Scope | Status |
|---|---|---|
| Step 1 | Plan, research, costs (`docs/step1-plan.md`) | Done |
| A | Project setup, navigation, mock screens | Done (PR #1) |
| B | 78-card data, card list/search/detail | Done (PR #1); card art not yet added |
| C | Camera scan, on-device recognition, manual fallback | Code built on branch `phase-c-scan`; unit tests pass; NOT run on a device; no trained model yet |
| D | Cloudflare Worker proxy + AI reading | Not started |
| E | RevenueCat subscriptions + real paywall | Not started |
| F | SQLite history/journal, notifications, accessibility, polish | Not started |
| G | Tests, store checklists, privacy and terms drafts | Not started |

## Next step
Phase C is coded (`app/lib/features/scan/`: `recognition/scan_logic.dart`, `preprocess.dart`, `recognizer.dart`, `camera_scan_screen.dart`). Remaining for Phase C: write the `ml/` training pipeline, train and export `app/assets/models/tarot_classifier.tflite` (needs the owner's card photos), and test on real iPhone and Android. Without the model the scan screen falls back to the manual picker. Then Phase D after the owner says "continue".

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
