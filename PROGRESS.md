# PROGRESS

Last updated: 2026-10-16. Update this file at the end of every phase.

| Phase | Scope | Status |
|---|---|---|
| Step 1 | Plan, research, costs (`docs/step1-plan.md`) | Done |
| A | Project setup, navigation, mock screens | Done (PR #1) |
| B | 78-card data, card list/search/detail | Done (PR #1); card art not yet added |
| C | Camera scan, on-device recognition, manual fallback | In progress (branch `phase-c-scan`) |
| D | Cloudflare Worker proxy + AI reading | Not started |
| E | RevenueCat subscriptions + real paywall | Not started |
| F | SQLite history/journal, notifications, accessibility, polish | Not started |
| G | Tests, store checklists, privacy and terms drafts | Not started |

## I need to do (owner)
- Run the tests and `flutter run` on the Mac and report problems (nothing has run on a real device yet).
- Card art: run `python3 app/tools/fetch_art.py --check`, then without `--check`; review every Commons file page (1909 printing, public domain). The file titles in the script are unverified guesses.
- Skim `app/assets/cards/cards.json` meanings (original wording) before release.
- Pick the final app name; check trademarks and store names (top pick: Veilscan).
- Create Anthropic API account with a monthly spend limit; Cloudflare and RevenueCat accounts; join Apple Small Business Program.
- Check the Google Play new-personal-account testing rule (testers/days) and the school's rules on commercial work.
- Buy 2-3 physical RWS-style decks and photograph them for training (see `ml/README.md`).
- Lawyer review: image licensing, trademark wording, privacy policy, terms.

## Known issues / not verified
- Nothing has been built or run on iOS or Android; only `flutter analyze` and widget tests (in the sandbox).
- No card art in the repo yet (placeholders shown).
- Store fees, prices and policies in the plan were checked on the web on 2026-10-16 and must be re-verified before launch.
