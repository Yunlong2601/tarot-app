# Website continuity verification — 22 October 2026

Fresh isolated worktree `shentarot-practice-continuity`, branch `feat/website-practice-continuity`, based on merged main `d354523`. Original checkout's uncommitted research/PROGRESS were preserved. PR #23 was confirmed merged and its published implementation was reused. This records pre-release tests; final merge/deployment/rollback IDs and live checks are in the follow-up PR release receipt.

## Requirement-to-evidence audit

| Requirement | Implementation / evidence |
|---|---|
| Measurable acquisition path | Existing small Star/Two/Eight/three-card teaching cluster reused; applied practice links added, not a new page family. Three original scripts and 1080×1350 PD-art PNGs prepared and publicly downloadable. Missing reports, stage definitions and no-tracking boundary documented in `website-competitor-observations-2026-10-22.md` and prior growth validation. No reporting connector/private data available; no invented metrics. |
| Optional personalised AI | Current Worker and backend validators/auth inspected. No browser session/preflight/route available. Exact existing payload, 300-character limits, follow-up constraints and proposed session/access/idempotency contract with integration gates are in `website-ai-contract-proposal-2026-10-22.md`. No backend edit, test bypass, submission button or false AI result. |
| Trust | Public methodology correction section gives URL/language/passage/rationale/source instructions and existing Support mailto. Review pack includes actual target pages, imagery, reversals, contested choices and consent/attribution process. Existing unconfirmed review disclosures retained. No experts contacted or credentials invented. |
| Return and learn | First-untried recommendation reuses the existing five-ID browser progress record, with useful all-tried review route and reset. Activity checkbox names include the activity. Save/Restore confirm changed-version replacement in an accessible modal, with Cancel/Escape. One-snapshot storage, recovery limits and lack of sync stay explicit. App Premium journal/look-back untouched. |
| Distinctive advantage | Same fictional question/spread/cards/orientations used as target. ShenTarot workflow exercised; FlipTarot public question/photo entry hit a sign-in status; Labyrinthos public reading hub and web app inspected. Matched competitor result quality/correction/export could not be exercised without new accounts; no superiority claim. Long native card lists and unclear next activity were addressed with filtering/recommendation. |
| Languages/quality/privacy | New `journey.json` in all eight languages; no runtime/development dependency added. Shared IDs/spread data retained. No new analytics/cookies/notifications/newsletter, no social posts/outreach/ad purchase. All app/backend/pricing/credit code untouched. |

## Automated checks

`npm test`, `npm run check:i18n`, `npm run check`, `npm run build`, `npm run check:reader-build`.

- Ten focused tests passed, covering input/orientation/reorder/duplicates, invalid stored records, Unicode persistence, denied/quota failures, example preservation/fixture isolation, progress recovery/reset, first-untried recommendation, overwrite comparisons and filtering that retains the selected card.
- Translation arrays/keys/placeholders match in eight locales. Native review remains needed.
- Astro: no errors, no warnings, two inherited birth-card hints.
- Build: 3,901 pages, unchanged page count. No repetitive SEO expansion.
- 136 production-page link/asset/canonical/hreflang/sitemap checks pass; homepage FAQ/schema and eight guide downloads pass; three demo PNGs validated as 1080×1350. PNGs were visually inspected.
- `git diff --check` passes; diff under app/backend is empty.

## Browser verification on production output (port 4331)

- Fixed example populated shared Situation/Challenge/Way-forward cards, including reversed Two of Pentacles. Name filtering reduced first picker to current Magician plus Queen of Cups; selecting, reversing, replacing with Star and moving later preserved notes and orientations. English alias “two coins” matched in Japanese. Duplicate selection remains disabled.
- Save baseline → edit → Restore → Cancel kept unsaved text. Confirm restored baseline. Save replacement → Escape kept previous snapshot; confirmed Save replaced it. Reopen tab → Restore recovered replacement text. Delete → reload → Restore found no valid snapshot. Modal focuses Cancel and supports Escape.
- A native confirmation initially stalled the browser-control tab during development; the new overwrite UI was replaced with an in-page dialog and both actions were retested. Stalled tab was closed; final browser checks used fresh tabs.
- Homepage reversed Queen search → one meaning result → correct reversed workspace seed. Keyboard Tab from question gave first impression a visible solid outline. Skip focused first picker.
- Copy returned readable question/spread/cards/orientations; text export downloaded; browser print pipeline produced synthetic `reflection-print.pdf`. Physical printing not tested.
- Progress: marking first activity changed the next recommendation to position practice and persisted after reload. All five marked showed the review/repeat message; reset worked. This tests state, not human comprehension or actual learning.
- French practice at 320px and Japanese filtered workspace at 320px had no document overflow. Japanese overwrite dialog at 390px was 358px wide, readable and cancellable. Screenshot captures committed. Temporary viewport overrides reset.
- Guide's English PNG download succeeded. Methodology correction instructions rendered; no email was sent.
- Existing daily draw/reveal and combinations tool produced valid card content. No final browser console errors were reported.

Artifacts: `docs/verification/website-continuity-2026-10-22/` contains desktop/mobile captures and a print PDF using fictional notes only. Existing guide/reference text remains server-rendered with a static no-JS download fallback; interactive workspace/progress still require JavaScript as disclosed.

## Remaining dependencies and honest limits

No new authenticated competitor accounts, AI requests, independent expert review, native-language review, consenting human sessions, physical phone, physical printing or screen-reader test occurred. Competitor end-to-end comparison is access-limited, so no speed/quality win or growth outcome is asserted. No actual Search Console/analytics reports were available. Newsletter delivery and secure browser AI still require the documented services/coordination; independent website work is complete without falsely enabling them. The owner-authorised release deploys only the website after passing CI; deployment proof follows in the PR release receipt.
