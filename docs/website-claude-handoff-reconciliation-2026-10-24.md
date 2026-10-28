# Claude work review and website handoff reconciliation

Reviewed 23–24 October 2026 for the owner's request to reread Claude's ShenTarot files and understand its work. This is a record of inspected documents, source and history, not a fresh production or store audit.

## Current source map

| Source | Inspected state | How to use it |
| --- | --- | --- |
| GitHub `main` | `5b66e684e54f4bee0c8539fd22696a8841d5ceaa`, handoff PR #28 merged | Current agent boundaries and shared naming/brand instructions; some status paragraphs are already stale |
| Privacy PR #29 | Merged as `8a862151a724742db05a55feb7c9034d36666310` | Optional whole-spread photo wording and corresponding eight-locale site copy are in main; merging is not deployment evidence |
| Website worktree | `feat/ritual-interactions`, based on `5d63c7b`, with uncommitted interaction implementation | Current Codex work; preserve its changes when incorporating newer main |
| Original Mac checkout | `backup/mac-local-2026-10-21`, `69c4cbb` | Older development snapshot, not the latest app |
| Claude app worktree | `.claude/worktrees/zealous-bartik-6d72b9`, `d4fe4e4744efc810627656fb110584614a3cda73` | Newer app/backend source. This commit was also fetched successfully from GitHub, so it is not merely unpushed local work |
| Claude project library | Project “招财计划”, shared research, original source/design files and `codex/` handoff | Research and historical artifacts; dates and superseding decisions matter |
| Claude release conversation | Read-only inspection of current release updates | Claude-reported external actions; do not equate them with independent store-console verification |

The handoff assigns Codex to `web/` and website documentation, and Claude to `app/`, `backend/` and `ml/`. This review changed none of Claude's code or release state.

Primary repository references: [handoff PR #28](https://github.com/Yunlong2601/tarot-app/pull/28), [privacy PR #29](https://github.com/Yunlong2601/tarot-app/pull/29), [latest inspected app change](https://github.com/Yunlong2601/tarot-app/commit/d4fe4e4744efc810627656fb110584614a3cda73).

## What Claude built

### Product and architecture

ShenTarot: AI Lens serves people who want to understand cards drawn from a physical deck. Digital draws provide another route. The recurring product principles are explain, learn and reflect; keep the user's question, positions and orientations together; offer correction before interpretation; avoid deterministic predictions.

The app is Flutter with go_router and ChangeNotifier, bundled card knowledge and public-domain artwork, SQLite history, local notifications, a TFLite recognition path and manual fallback. The backend is a Cloudflare Worker with Hono, D1 and KV. RevenueCat handles subscriptions and consumable purchases. Provider keys remain server-side. Optional account identity is distinct from locally saved history; account code does not establish journal synchronization.

Claude created original knowledge for all 78 cards, including orientation-specific meaning, imagery, suit/number/court connections, questions, and position-aware reading prompts. Early reversed-card data mistakes were corrected. Recognition progressed from an early 78-class plan to 156 upright/reversed classes. Synthetic evaluation and a single successful photo example do not establish real-deck accuracy.

### App journey and retention

The work evolved from Read/Guide/Library/You to a five-destination shell described as Today, Draw, central Scan action, Learn and You. Source routes and the shell, rather than old README screenshots, determine the current navigation.

Implemented work includes question entry, sample questions, spread choice, digital drawing, manual card selection, orientation and reorder correction, an optional first impression, structured reading sections, clarifiers and follow-ups, local history and journal, Card of the Day, reminders, week-later reflection prompts, birth cards, learning content and translated UI/card text. Individual release availability still depends on the build, feature flags, entitlements and service configuration.

An opt-in share creates a public reading copy, with optional question inclusion, expiry and deletion. This is an exception to broad claims that reading text is never stored server-side.

### Photo recognition and security

October 20 commits add a whole-spread photograph flow: consent, upload for recognition, card confirmation/correction, then interpretation. The newer source includes a separate vision-provider path and an OpenAI fallback. This differs from the on-device single-card classifier. The privacy explanation must distinguish these paths and account for each actual provider.

iOS App Attest code is present in the newer app/backend branch: a challenge, attestation/assertion validation and a native bridge. The backend still contains a Play Integrity TODO in that inspected branch. Neither source presence nor a configuration file proves production enforcement. The older handoff's blanket “attestation still to build” statement is therefore too broad.

Other work includes input validation, untrusted prompt/context handling, fixed crisis/off-topic responses, usage limits, output validation/fallbacks, credit refunds, RevenueCat webhook handling, account deletion, test-mode release guards and share deletion controls. This read-through is not a security audit.

### Payments and growth systems

The accepted plan set in the shared facts is annual US$39.99 with a US$1.99 introductory month, quarterly US$14.99 and monthly US$6.99. The earlier weekly plan, seven-day free trial and US$99.99 annual proposal were superseded. Local store prices and active offers require store data. RevenueCat was restored after a short Qonversion experiment.

Claude built a credit ledger with grants, rollover, caps, purchases, refunds and identity transfer; optional referral and creator systems have separate flags and setup. Newer October 23 source/configuration enables credits and differentiates guest and signed-in daily grants. The merged handoff's “credits off for v1” snapshot is not a reliable statement about every subsequent build. This review does not assert the live server flags or store products are active.

Latest inspected change `d4fe4e4` adds paywall trust copy, an explicit reminder offer after purchase, a Yes/No spread, an original-art note, less flattering handling of difficult cards, translations and revised listing copy. The commit and files are verified; the reported 176 app/136 backend test results were not rerun here.

### Website foundations

Claude's October 18–19 work established the Astro/Cloudflare website, clean routes, app/share links, card/spread/topic pages, tools, question guides, combinations, elemental relationships, eight-locale content, social images, learning guides, context pages, zodiac/birth-card pages, the daily widget, crawler files and Pinterest/outreach materials.

Subsequent Codex changes added the own-card reading workspace, preservation/resume behavior, whole-spread practice and Quiet Ritual visual system. The current interaction work builds on these foundations. It should not be credited entirely to Claude or treated as already published.

## Corrections that matter for continuing the website

| Statement in older notes | Evidence from this review | Website consequence |
| --- | --- | --- |
| PR #28 is unmerged | GitHub reports merged | Use its scope rules; the local interaction checkout still needs safe integration with main |
| Privacy update is only on stale PR #21 | PR #29 merged the update into main | Preserve that change on integration; separately verify the deployed privacy page |
| Whole-spread code exists only on the Mac | Newer app commit is fetchable from GitHub; not part of inspected main | Coordinate with the app branch; do not overwrite it or assume it is in main |
| All photos stay on the device | Whole-spread recognition uploads a consented photo | Do not use blanket “photos never leave your phone” copy |
| No readings are stored on the server | Opt-in shared readings use server storage | Explain local reflections and public sharing separately |
| Credits are off | Newer app live config has `CREDITS: true`; Worker config has `CREDITS_ENABLED = "true"` | Do not promise allowances from stale documents; check the actual release before publishing commercial copy |
| App Attest and Play Integrity are both unbuilt | iOS App Attest exists; Android TODO remains in inspected source | Treat platform readiness separately; no browser token workaround |
| A reversals setting is missing | `readReversed` exists and persists in app state | Do not rebuild the same setting from the research backlog |
| Website is an 11-line landing page | That statement belongs to October 18 comparison | Preserve the current tools, guides, translations and working journeys |
| All catalogues contain exactly 14 spreads | Branches and documentation disagree; website baseline already contains 15 | Use current catalogue IDs and generated data, not a stale marketing count |
| App has 15 versus 16 languages | Commit updates 15 translation files; English is separate | Distinguish translations from total supported locales; website remains eight locales in this task |
| Free trial or “unlimited” is current | Later owner decision specifies paid introductory month and limits | Keep billing language tied to actual offers and limits |
| Website AI can use the app API directly | No supported browser identity/access/charging contract demonstrated | Keep the companion a clearly labelled deterministic interface concept |

## Research interpretation

Claude's research covers competitor naming/pricing, model costs/providers, annual-plan design, referrals, acquisition, customer pain points, personas, journeys and a Lean Canvas. It consistently recommends clearer value and billing, free meanings, correction of the physical draw, contextual explanations and repeat reflection.

These are desk-research hypotheses. The app-improvement report explicitly says interviews were not conducted. Frequency/intensity scores, synthetic personas, conversion targets, competitive superiority, acquisition costs and profitability projections are not ShenTarot measurements. Some reports contradict their own earlier observations—for example, whole-spread scanning is not unique, and a reversals toggle already exists. Model pricing, vendor terms and store rules were not revalidated for this document.

The old visibility plan emphasizes page volume and includes analytics suggestions. Current website instructions require useful journeys, eight-language consistency and no new tracking without authorization. Do not automatically implement the old analytics or mass-content suggestions. Outreach drafts and the 78-row Pinterest CSV are prepared materials, not evidence of publication, traffic or results.

## Additional website handoff files found on 24 October

Read these three newly present files in full. Their headers credit **WorkBuddy**, although the owner's request refers to Claude's project files:

- `docs/codex-web-design-brief-2026-10-24.md`: proposed craft contract, performance budget, tokens, motion, homepage narrative and validation gates.
- `docs/web-design-benchmark-2026-10-24.md`: award criteria, adjacent references and the reasoning behind that brief.
- `docs/website-audit-2026-10-24.md`: source/live audit that revises some of the earlier recommendations.

The later audit explicitly retracts the benchmark's dark-first recommendation and endorses the current paper/ink site with dark sections. That agrees with the owner's approved interaction plan. The earlier brief's scan/install-first homepage differs from the approved website-first Draw / Interpret / Search journey, and its copy remains marked OPEN. Reading these files does not silently replace the owner's agreed direction or make unavailable store links functional.

Fresh source checks confirm the practical asset findings: 78 public JPEGs total **6,492,787 bytes**, ranging **59,472–105,516 bytes**; `og.png` is **422,960 bytes**. `copy-art.mjs` currently copies source art, and `_headers` currently contains only the two well-known JSON rules. There is room to investigate smaller encodings, share-image weight and stylesheet cleanup. A 50–60% saving or indistinguishable quality remains a hypothesis until actual conversion, visual comparison and browser checks. Avoid enlarging 357px source art to manufacture a 600px rendition.

Corrections before adopting the new brief:

| Brief/audit claim | Reconciled interpretation |
| --- | --- |
| Astro 5 | Installed package and current checks use Astro **7.4.0**. |
| Every card is 95–105 KB | Measured range is approximately 59–106 KB; the total-heavy-asset finding still stands. |
| No cache headers means no asset caching | `_headers` lacks explicit asset rules, but Cloudflare static assets have default revalidation and ETag behavior. Inspect served headers before claiming assets always re-download. |
| One-year immutable for all art and OG paths | Current `/cards/art/<id>.jpg` and `/og/*` names are not content hashes. Fingerprint/version files first, or retain revalidation for names whose contents can change. Cloudflare's aggressive-cache example is explicitly for fingerprinted assets. |
| Lighthouse must report INP and a p75 CWV pass | A navigation-only Lighthouse run cannot measure INP; use its TBT diagnostically and measure actual interactions separately. Lab runs do not establish population p75 field performance. |
| `--preset=mobile` | Current Lighthouse CLI lists `perf`, `experimental`, and `desktop` presets; use the default mobile configuration or the documented form-factor options. |
| Two hints are in TarotSearch | The actual current Astro output identifies the two birth-card pages. |
| Delete the whole old `.site-header` rule | Some declarations (such as z-index and prefixed backdrop filtering) may still be inherited. Remove obsolete declarations/selectors after checking the cascade; do not assume an overridden background makes the entire rule unused. |
| All images must use `astro:assets`, versus later Sharp recommendation | The two documents propose different mechanisms. Preserve current IDs, dynamic picker/export paths and public-domain originals while choosing one verified derivative pipeline. No wholesale rewrite follows merely from the earlier mechanism preference. |
| Accessibility is award-level / only asset weight remains | Source patterns and automatic checks support particular findings, not a full conformance or user-study conclusion. Native keyboard and manual accessibility checks remain open. |

Primary documentation checked 24 October: [Google Web Vitals measurement guidance](https://web.dev/articles/vitals), [Lighthouse CLI options](https://github.com/GoogleChrome/lighthouse/blob/main/readme.md), and [Cloudflare static-asset headers and fingerprinted caching](https://developers.cloudflare.com/workers/static-assets/headers/). The broader award statistics and competitor superiority claims were not independently revalidated.

Practical follow-up order: measure and visually compare optimized artwork; use safe asset versioning/cache behavior; optimize the share image; add explicit UTF-8 text headers where needed; then remove proven obsolete CSS. Preserve the approved light/dark balance, eight locales, reduced-motion system, local reading journey and honest availability copy throughout.

## Files reviewed and coverage

Read the complete current remote `AGENTS.md`, `CLAUDE.md`, `SHARED-FACTS.md` and `PROGRESS.md` at the merged handoff, and local root/app/backend/ML/web READMEs. Reviewed original instructions and progress history as historical context.

The local documentation review covered:

- Product/design: `step1-plan.md`, `design-notes.md`, `tarot-knowledge-plan.md`, `phase-c-design.md`, `competitor-naming.md`, `store-listing.md`.
- Identity and commerce: `accounts-plan.md`, `accounts-setup.md`, `credits-setup.md`, `referral-setup.md`, `creator-setup.md`, `phase-e-subscriptions-setup.md`, `own-key-and-providers.md`, `unit-economics.md`, `growth-and-monetisation-framework.md`, `promotions-plan.md`.
- Privacy, safety and release: `data-inventory.md`, `security-and-abuse.md`, `privacy-policy-draft.md`, `terms-draft.md`, `referral-terms-draft.md`, `play-data-safety.md`, both store checklists, `play-release-guide.md`, `app-store-submission-guide.md`, `test-plan.md`.
- Newer app research: `app-improvement-report.md`, `tarot-pain-points.md`, `user-research-guide.md` and updated `store-listing.md` in Claude's active worktree.
- Website context: `website-consumer-research-2026-10-21.md`, `comet-market-analysis-2026-10-21.md`, `website-ai-contract-proposal-2026-10-22.md`, website README and existing implementation evidence consulted in this task.
- Listing/art provenance: `gemini-prompts.md` and the card-art credits/source inventory.
- New website analyst handoff: the complete design brief, design benchmark and strict website audit dated 24 October, reconciled above.

Additional Claude Library documents were downloaded through its UI and read from `~/Downloads/shentarot-claude-*`:

- `ai-api-cost-research.md`
- `ai-api-haiku-vs-luna.md`
- `pricing-research.md`
- `fliptarot-vs-shentarot.md`
- `annual-plan-monetisation.md`
- `growth-monetisation-consumer-review.md`
- `referral-program.md`
- `tarot-astrology-mingli-market-research.md`
- `visibility-plan.md`
- `outreach.md`
- `pinterest-pins.csv` (structure and sample entries inspected; not a fresh editorial review of every generated card caption).

The project library also contains source snapshots, generated translations, store assets and historical screenshots. Their inventory was inspected; this review does not claim that every binary image or every line of the entire app was audited. Current source was cross-checked where it could change website decisions. No secrets were copied into this document.

## Release evidence and limits

Claude's release chat subsequently reports build 10 in Google Play internal testing and a closed-test submission, after a build 9 signing rejection; it also reports Apple review/TestFlight activity. Those are chat reports, not independently rechecked store states. Old build artifacts can coexist with newer archives and must not be used as proof of the uploaded build. No approval date is guaranteed.

No app/backend code, store settings, paid products, secrets, deployments or external messages were changed during this review. Reading Claude's instructions does not authorize executing its remaining release actions.

## Application to the active interaction task

Continue the approved Tarot Index, writing surfaces, visual picker, connected-card stage and labelled companion design. Preserve card IDs, storage schemas, eight website locales and no-tracking behavior. Keep truthful local-save messages and explicit correction controls. Retain original/public-domain artwork and explain that the connected example is authored guidance.

Before a later release, integrate the merged handoff/privacy changes without replacing the interaction work, verify production privacy and commercial claims against the actual app release, and retain the documented native keyboard/accessibility and human-study limitations. The owner requested a study pack; participants have not been recruited.
