# ShenTarot interaction implementation and verification

Prepared 24 October 2026. Local branch `feat/ritual-interactions`, based on `5d63c7b1169a6a511a82b4bc89734b9e20548ac3`, with uncommitted implementation changes. **Not merged, deployed or published.** This report does not declare the complete validation plan finished.

The implementation follows the approved parchment/ink direction: precise writing and discovery controls on light pages, with stronger spatial treatment reserved for the card stage. It retains Astro, the eight website locales, existing card/spread identifiers and draft schema. App/backend/ML code, paid access and production AI remain outside this change.

## Requirements and evidence

| Requirement | Implementation / authoritative evidence | Result and limit |
| --- | --- | --- |
| Editorial dropdowns | `web/src/layouts/Base.astro`, `scripts/shell.ts`, `styles/interactions.css`; desktop navigation screenshot | Grouped Draw & reflect / Compare & explore links with descriptions and original artwork preview; disclosures open by activation. Keyboard Enter/Escape observed. |
| Mobile navigation and search | Same shell plus shared dialogs; `browser-verification.json` | Brand, search and menu remain accessible; Draw a card is first in the mobile panel. 320/390/768 layouts checked. No essential hover-only destination. |
| Writing surfaces | `pages/[...lang]/read.astro`, `scripts/workspace.ts`, `styles/interactions.css` | Persistent labels, prompts, two-to-six-line autosizing, visible focus and near-limit counters. 5,000-character input preserved; overflowing prompt insertion reports an error. |
| Truthful storage | Workspace write handlers and existing `lib/workspace.ts`; storage-denial browser fixture | Session draft and local saved reflection are distinguished. Failed writes retain entered text and show failure; saved-state messages require successful storage. Existing keys and version remain unchanged. |
| Loading and recovery | Reader loading/failure markup and bootstrap timer; blocked-script browser check | Loading message is explicit; recovery appears when initialization fails. Reload after restoring the script returns the workspace. Static browsing links remain available. |
| Shared modal behavior | `lib/dialogs.ts`; keyboard browser observations | One open modal, Escape dismissal, Tab containment, focus restoration and inert background. Eight successive Tabs stayed in search. Native screen-reader behavior is not established by this check. |
| Locale search index and routes | `lib/search-index.ts`, localized `search-index.json.ts` / `search.astro` routes | Eight indexes, 101 entries each: cards, spreads and lessons. Existing `/cards?q=…` remains. Build audit checks 808 real result routes and referenced images. |
| Search ranking and queries | `lib/search.ts`, shared workspace parser, `tests/search.test.ts` | Exact title, prefix, alias, then keyword/description matching with deterministic ties. Tests include `qoc`, `coins`, reversed and translated queries, no matches, highlighting and invalid indexes. |
| Orientation and selection handoff | Search URL construction and existing card/workspace query handling; browser result journey | “Queen of Cups reversed” produces the reversed chip and orientation URL; use-in-spread preserves orientation. Removing the chip keeps card wording. |
| Search keyboard and recovery | `scripts/search-bootstrap.ts`, `search.ts`, `search-page.ts`; browser checks 23–24 October | Arrow/Enter, Escape with retained query, useful empty states, index retry and failed-module recovery. On 24 October, blocked search modules produced visible failure; retry retained `qoc reversed` on the full results page and returned the correct reversed card. Normal dialog search then worked. |
| Visual card picker | `lib/card-picker.ts`, workspace integration; desktop/mobile browser checks | Thumbnail results, desktop preview, explicit unavailable duplicate reasons and selection close/focus restoration. Orientation stays outside results. Correction, reorder and spread-loss guard remain. |
| Click / hover / focus | Shared interaction stylesheet and card placement state | Brief press/hover feedback, limited fine-pointer card tilt, persistent selected state and clear keyboard focus. Card placement uses separate translation so reversed rotation is preserved. |
| Signature stage | Homepage authored example, `thread-stage.css`, `shell.ts`; desktop/mobile screenshots | Explicit fan, positions and connection steps; adjacent-pair SVG connectors and matching explanation. Mobile uses numbered vertical relationships. No scroll hijacking, automatic draws or new AI claim. |
| Reading context and connections | Workspace summary and existing position-aware guidance | Selected cards/positions/orientations remain available and participate in guidance, including correction/reorder. Existing export/copy/print preparation is retained. Native PDF generation was not newly validated. |
| Motion | `MotionControl.astro`, shared styles and stage script; reduced-motion browser fixture | OS preference forces immediate changes and removes spatial transforms, even when the local control is toggled. Actions remain available without animation. |
| Future companion | `CompanionConcept.astro`, `i18n/companion.ts`; fixture browser checks | Explicit example label; confirmed context, response sections, card references, follow-up and separate context editing. Loading, stopping, retry, expired access, service failure and uncertain charge are fixed examples. No real requests or charges. |
| No tracking / preserved architecture | Scoped source diff and package review | No production endpoint, tracking, WebGL or new runtime dependency. Search does not persist history. Original SVG and existing public-domain card art are used. |
| Responsive layouts / zoom | `locale-mobile.json`, `browser-verification.json`, screenshots | 320/390/768 checks and eight-locale result pages passed without horizontal document overflow in checked states. 390×400 height simulation and 2× page magnification passed; neither substitutes for a native keyboard or full text-zoom audit. |
| Accessibility | Axe evidence plus keyboard checks | Final checked states have no detected AA-tagged violations after contrast/label fixes. Manual contrast items, native screen-reader behavior and complete WCAG 2.2 AA conformance remain unproven. |
| Performance | `mobile-lab.json`, three baseline/current pairs | Like-for-like local mobile lab comparison completed; interpretation below includes a DOM-ready regression. No field Core Web Vitals pass claimed. |
| Five learners | `interaction-usability-study-2026-10-23.md`, blank results CSV | Owner selected **Prepare the study pack**. Recruitment, consent, tasks, notes and analysis protocol are ready. No participant has been recruited or tested; no outreach was sent. |

Paths in the table are relative to `web/src/` unless a full `web/` or `docs/` prefix is shown. Browser evidence resides in `docs/interaction-evidence-2026-10-23/`; its directory retains the start date, with explicitly dated follow-up evidence below.

## Repository checks

The final check rerun on 24 October completed successfully:

- `npm test`: 18 tests passed.
- `npm run check:i18n`: all seven translations match English structure, list lengths and placeholders.
- `npm run check`: zero errors, zero warnings; two pre-existing hints in birth-card pages.
- Production build previously completed for the current source: 3,909 pages. Documentation-only follow-up edits do not change that output.
- `npm run check:reader-build`: 160 representative reader pages passed.
- `npm run check:ritual-build`: eight locales, 240 representative pages and 28,768 internal references passed.
- `npm run check:interactions-build`: eight indexes and 808 destination/artwork checks passed.
- `npm audit --omit=dev`: zero reported vulnerabilities.
- `git diff --check`: passed after the implementation report, README and progress-note updates; rerun when preparing the final commit.

These checks establish their particular assertions. They do not establish native translation quality, accessibility conformance, comprehension, store availability or production deployment.

## Performance comparison

Baseline: `5d63c7b`. Current: interaction working tree. Both used local gzip static serving, a 390×844 viewport, cache disabled and 4× CPU slowdown. Network throttling was unavailable, so these are local, unthrottled lab runs. Three runs per variant were alternated; values below are medians except constant transfer/request counts.

| Metric | Baseline | Current |
| --- | ---: | ---: |
| Largest Contentful Paint | 576 ms | 536 ms |
| Cumulative Layout Shift | 0.04517 | 0.04530 |
| DOM ready | 672.6 ms | 1,600.5 ms |
| Transferred bytes | 326,157 | 334,951 |
| Requests | 14 | 18 |

The initial transfer increase is 8,794 bytes (about 2.7%). The search implementation and locale index are absent from initial requests and load on demand. LCP and CLS are similar in this limited sample; DOM ready is slower and must not be described as a general performance improvement. Results are not field data, do not measure real mobile networks or INP, and do not prove a good Core Web Vitals assessment. Investigate the DOM-ready difference under representative production network conditions before making performance claims.

## Workspace regression follow-up, 24 October

**25 October update:** the Mac-lock follow-up below is historical. Access was restored, native Chrome 200%/400% zoom and the new reader motion control were checked, artwork deferral was observed, and paired mobile loading measurements were refreshed. See the [current completion audit](website-interactions-completion-audit-2026-10-24.md#resumed-runtime-evidence--25-october-2026). Native website keyboard and broader manual accessibility work remain open. `safari-keyboard-ready-2026-10-25.jpg` is a fresh ready-screen capture, not keyboard evidence.

The later [completion audit](website-interactions-completion-audit-2026-10-24.md) records two additional implementation gaps closed after this regression pass: the reader's own motion toggle and explicit lazy loading for offscreen workspace art. Their fresh runtime verification is pending because the Mac locked during a real Chrome zoom check. Only 110% was observed; do not record the interrupted 200% sequence as passed. Reset that test origin to 100% after unlock.

Three review findings were fixed in `web/src/scripts/workspace.ts` and checked against a fresh production build on isolated preview port 4357:

- Moving a card to the first or last position now restores keyboard focus to that card's picker when the same-direction move button becomes disabled. Enter-key checks reached `data-pick=0` and `data-pick=2`; the reordered Two of Pentacles retained its reversed orientation.
- Successful deletion clears the stale session-draft receipt. A disposable example was saved and deleted through the UI: the receipt became empty, the saved-delete status appeared, and cards/question/reflection were cleared. Reload retained an empty workspace, and Restore correctly reported no valid saved reflection.
- Initialization now ends after the first hydrated workspace, before waiting for seed/overwrite confirmation. A confirmation remained open for **37,468 ms**, with loading hidden and no failure message. Cancelling retained the prior question and reordered cards. Actual initialization exceptions still reveal recovery in the catch handler; this handler was reviewed but a post-hydration exception was not separately injected. The attempted CDP fixture method was unsupported and applied no override.

Evidence: `interaction-evidence-2026-10-23/workspace-regressions-2026-10-24.json`, `workspace-boundary-focus.png`, `workspace-confirmation-ready.png` and `workspace-deleted-feedback.png` in the same evidence folder. All saved/deleted content in this check was an agent-created disposable fixture on the isolated origin.

Reran 18 tests, Astro check (zero errors/warnings, two existing birth-card hints), all locale checks, the 3,909-page production build, and reader/ritual/interaction audits successfully. The performance comparison above predates this small workspace follow-up and remains historical evidence, rather than a new measurement of these exact bytes. Native keyboard and broader manual accessibility work remain open.

### Manual control-boundary contrast follow-up

Computed-style review found faint prompt-button and picker-trigger borders. Both now use `#75806c`. Prompt borders increased from 2.268:1 to **3.828:1** against their button surface and reach **3.527:1** against the surrounding writing panel. Picker borders increased from 2.126:1 to **3.649:1** against the button surface and reach **3.869:1** against the fieldset. Ratios use sRGB relative luminance. A fresh 3,909-page build and browser reload confirmed the actual computed colors. Evidence: `control-contrast-2026-10-24.json` and `workspace-controls-contrast.png` in the interaction evidence folder. This establishes these boundaries only, not complete conformance.

## Native keyboard follow-up, 24 October

Safari renders the local reader on the iPhone 17e / iOS 27 simulator. MobileBuildMCP returned a native 369×800 screenshot. Its runtime snapshot exposes Safari chrome and scroll areas, but no website input/button targets. A Tab key event did not expose a usable website field. Device Hub accessibility likewise exposes browser chrome; current window captures are small transformed previews that do not provide reliable page-control coordinates. Earlier capture attempts also returned ScreenCaptureKit error -3811.

This establishes rendering, **not an open website keyboard test**. The required native-keyboard check remains incomplete. A prior request to accept it as a documented manual item has not received an answer. Do not record silence as acceptance. The study pack provides the exact manual task: focus query/question/picker fields, enter text with the on-screen keyboard, reach results/close/submit, dismiss the keyboard, and verify text preservation.

Later on 24 October, the updated preview was moved from isolated port 4357 back to **4355**, and Safari on the dedicated **iPhone 17e / iOS 27** simulator was navigated to `/read` through Device Hub's actual URL editor. `safari-keyboard-check-ready.jpg` verifies the reader and visible blank question field. Safari's runtime snapshot still exposes only browser-chrome targets. The owner has been asked to tap the question field so the native keyboard can be inspected; that response is pending. No project/scheme or persistent simulator defaults were configured. The preview daemon is live at `http://127.0.0.1:4355`.

## Visual evidence

- `interaction-evidence-2026-10-23/navigation-desktop.png`
- `interaction-evidence-2026-10-23/thread-desktop.png`
- `interaction-evidence-2026-10-23/thread-mobile.png`
- `interaction-evidence-2026-10-23/search-mobile.png`
- `interaction-evidence-2026-10-23/companion-mobile.png`
- `interaction-evidence-2026-10-23/search-recovery-desktop.png` — captured 24 October after failed-module retry.
- `interaction-evidence-2026-10-23/safari-simulator-loaded.jpg` — rendering evidence only.

## Claude reconciliation and release boundary

Read `website-claude-handoff-reconciliation-2026-10-24.md` before integrating or releasing. Remote handoff PR #28 and privacy PR #29 are merged but have not been integrated into this branch. Preserve their optional-photo privacy changes. The newer app branch has source changes beyond the merged handoff, including credits and iOS attestation; neither source nor Claude's release chat proves current live flags or store approval. Browser AI remains a separately labelled concept.

The local implementation, study pack and automated/browser evidence are available for review. Remaining validation includes native on-screen keyboard, fuller zoom/accessibility checks and human review. Merge/deploy/publish has not occurred in this interaction task.

The additional 24 October design brief/benchmark/audit were also read in full and reconciled in that handoff document. The later audit supports the approved light direction. Its asset-optimization suggestions are recorded with measured file sizes and corrections to cache and Lighthouse assumptions; those suggestions have not yet been implemented by this verification pass.

Browser cleanup note: the recovered verification tab has network blocking cleared and normal caching restored. The original tab entered an internal connection-error page while its preview was unavailable; the browser URL policy then prevented reset or close. The original tab retains its temporary two-search-module block and disabled cache. Close that error tab and use the fresh local reader tab. These overrides are local to the old test tab and do not affect production or source files.
