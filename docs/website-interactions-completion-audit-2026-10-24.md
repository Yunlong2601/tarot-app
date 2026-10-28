# ShenTarot interaction completion audit — 24 October 2026

**Latest owner steering, 25 October:** the simulator uses a physical keyboard; prioritize desktop, with phone views secondary. The subsequent shuffle/choose/turn implementation and verification are in [the drawing report](website-card-draw-interaction-2026-10-25.md). The on-screen-keyboard limitation remains an evidence limit and does not block that phase. Earlier blocked-audit entries below are historical, not a renewed request to open a keyboard.

The previous goal turn made implementation progress: three workspace regressions were fixed and checked in the production browser, control boundaries were strengthened, and native Safari was prepared. This follow-up also makes implementation progress; it does not declare the goal complete.

## Scope and authority

The objective remains the full approved interaction plan in the goal attachment. The owner's later instruction replaces recruiting five learners with preparing the study pack. The subsequent portfolio request adds research, not authorization to implement every pattern in that catalogue. Production browser AI and release operations remain separate.

Current branch: `feat/ritual-interactions`. Audit sources are the current files, emitted build, test output and the evidence linked below. Earlier browser evidence is historical where a later change affects the same behavior. The detailed implementation map is in [the verification report](website-interactions-verification-2026-10-24.md).

## Required acceptance gates

| Gate | Explicit cases | Current evidence | Audit result |
| --- | --- | --- | --- |
| Search | Exact names; coins; qoc; reversed and translated names; no results; index failure; direct URLs | Search unit cases, eight real locale indexes, 808 generated destinations, browser query and failed-module recovery observations | Covered by automated and historical runtime evidence. |
| Workspace | Duplicate prevention; orientation; correction; reordering; spread changes; long notes; denied storage; reload/resume; old saved drafts | Workspace/practice tests, boundary/deletion/confirmation fixtures and 25 October image-request evidence | Covered for recorded cases, including newly deferred image loading. |
| Keyboard | Navigation, search, picking and dismissal without a pointer; predictable focus return | Recorded Enter/Arrow/Tab/Escape tests, boundary reorder fixture and 25 October motion/picker/search checks | Covered for recorded controls; new motion activation and 400% picker focus return verified. |
| Mobile | 320, 390 and 768 CSS pixels; zoom; open on-screen keyboard; no essential hover or horizontal overflow | Width/locale checks, 25 October real Chrome 200%/400% checks and native Safari reader screenshot | **Incomplete.** Native website keyboard remains unopened; zoom is covered for the recorded states. |
| Accessibility | Labels, contrast, announcements, visible/unobscured focus; WCAG 2.2 AA target; primary target-size preference | Axe evidence, semantic source, keyboard observations and measured prompt/picker boundary contrast | **Partial.** Current checked findings are documented; native-keyboard obstruction, stronger zoom evidence and broader manual review remain open. No conformance claim. |
| Motion | Complete journey with reduced motion and without animation enhancement; visible control near ritual stage | Historical journey/no-script checks plus 25 October reader keyboard/OS-priority/reversed-art fixture; eight-locale build markers | Covered for recorded cases. Latest reader control has fresh runtime evidence. |
| Performance | Establish baseline; lazy search data and offscreen artwork; like-for-like mobile lab comparison; honest CWV limits | Historical LCP/CLS comparison plus 25 October paired navigation/FCP/resource runs, lazy search bootstrap and deferred artwork requests | Recorded lab and lazy-loading requirements covered. No field CWV/INP pass or universal device-performance claim is established. |
| Repository checks | Existing tests, Astro, locales, production build, reader audit and ritual audit | Latest 18 tests pass; Astro 0 errors / 0 warnings / 2 existing inline-script/import hints; eight locales; 3,909 pages; reader 160 pages; ritual 240 pages / 28,768 references; interaction 808 destinations | Passed for the latest source/build. These checks do not replace UI or human validation. |
| Usability research | Owner-selected study pack replacing immediate participant recruitment | Study protocol and blank results template; no fabricated participants/results | Requested pack prepared. Real sessions remain future work. |
| AI concept | Labeled success, stopped response, retry, service failure and access fixtures; no real requests/charges | Current deterministic component, localized fixture copy and recorded browser fixture checks | Covered for recorded fixture states. Production AI remains excluded. |

## Source gaps resolved in this audit

1. The workspace's dark connection stage did not have a local motion control. It now renders the same localized `MotionControl` used on the homepage, handled by the existing shared shell script. The build audit checks its presence in every reader locale.
2. Workspace selection thumbnails and full meaning artwork were eager even below the viewport. They now opt into lazy loading before assigning image URLs. Existing stage and picker result images also set the loading mode before their source. Visible picker previews remain eager.

The new code uses existing components and browser features. It adds no package, storage key, tracking, production AI or change to draft version/card identifiers.

## Current computer-use blocker and cleanup requirement

During a dedicated Chrome zoom check on the local reader, **110% native browser zoom was observed**. The next sequence toward 200% was interrupted with: “The Mac is locked and automatic unlock could not unlock it.” Its final zoom level is unverified. Do not claim 200% or 400% passed. When the owner unlocks the Mac, restore that test origin to 100% before collecting new zoom/performance evidence.

The owner has been asked to unlock manually. An earlier request to tap the blank question field in Device Hub's iPhone 17e is also pending. No browser or native UI actions should be attempted to bypass the lock. No additional synthetic viewport is a substitute for the native keyboard gate.

The production preview was verified serving HTTP 200 at `http://127.0.0.1:4355/read` at the start of this audit. An HTTP response does not prove a live simulator keyboard or user input.

## Next verification, without changing scope

After unlock:

1. Reset the dedicated Chrome test origin to 100%; verify normal reader state.
2. Check the workspace motion button at a two-card or longer spread, including keyboard focus, OS reduced-motion priority and preservation of reversed artwork.
3. Inspect offscreen image/request behavior and refresh relevant lab evidence.
4. Complete and restore real browser zoom states, checking reading, search, picker and companion layout.
5. Inspect the native Safari keyboard after the owner opens the question field, then cover query/picker controls and preservation.
6. Reconcile these observations with this audit before deciding completion.

The goal remains active and completion remains unproven. This is the first follow-up with the newly observed Mac-lock condition; it is not grounds by itself to mark the goal blocked.

## Revalidation — 25 October 2026

The preceding research turn made progress on the owner's portfolio-research steering: the saved catalogue was refreshed against live sources. It was not a verified wait for user input and did not resolve the implementation's native UI gates.

Current authoritative checks confirm the preview daemon is running on port 4355 (PID 5841) and `git diff --check` succeeds. A fresh native Chrome accessibility observation again reports that the Mac is locked. No unlock was attempted, and no user reply has resolved the earlier request to open the website question field's native keyboard.

The same external-access dependency has persisted across successive goal turns: native website fields are unavailable to automation, the owner-assisted keyboard step remains unanswered, and the lock now prevents the pending native zoom work too. Source fixes and the study/research deliverables have been completed as far as their recorded evidence establishes; no further identified source edit substitutes for the remaining runtime requirements. The goal is therefore blocked pending an external-state change, not complete.

Resume after manual unlock: restore the dedicated test origin to 100% zoom, verify the latest workspace motion control and deferred image loading, collect real zoom evidence, and inspect the on-screen keyboard once the question field is focused. Keep the full acceptance scope above. No merge, deployment or publication has occurred.

## Resumed runtime evidence — 25 October 2026

Computer access was restored on the resumed turn. The existing preview daemon remained live (PID 5841), and a new dedicated Chrome tab was used; unrelated tabs and the iPhone 18 Pro app session were left unchanged. The previous turn confirmed the external blocker but completed no native UI gate. This resumed turn makes concrete verification progress.

- **Reader motion:** Enter toggles the latest local control; its focused outline computes to parchment, 2px. OS reduction remains effective through two local toggle activations. The reversed Two of Pentacles keeps its 180-degree artwork transform. Emulated OS preference was cleared afterward.
- **Native Chrome zoom:** browser chrome explicitly reported 200% and 400%, then 100% after cleanup. Reader document widths were 748/756 and 374/378 respectively (scroll width / viewport width). Search was exercised at both levels. At 400%, Close was reachable by keyboard; the picker chose The Moon and returned focus to its trigger within the viewport; the companion composer accepted example text within the viewport. Dialogs scroll vertically in the short 400% viewport. These observations cover the recorded states, not every page or every possible zoom/font configuration.
- **Artwork:** all 78 picker row images use lazy loading. The recorded open-picker observation had 32 loaded and 46 not yet loaded; the nearby eager preview remains available. Network evidence confirms deferred requests. Exact preload distance is browser-controlled; this is not a guarantee that every offscreen image stays unloaded.
- **Loading comparison:** three alternating baseline/current runs at 390×844, 4× CPU, disabled cache and equal local gzip servers. Median DOM ready: 226.9/174.6ms; load: 252.1/224.6ms; FCP: 128/144ms (baseline/current). Comparable page transfer: 345,362/356,817 bytes across 15/19 requests, excluding the favicon. Chrome fetched the same existing 452,991-byte favicon inconsistently in an exploratory pass; normalized runs retain its observations separately. Sampling at load can omit later asynchronous resources. Existing Chrome extensions and unthrottled local networking limit interpretation. The historical LCP/CLS comparison is not replaced with a new LCP/CLS/INP or field-CWV claim.
- **Native Safari:** selected only the dedicated iPhone 17e / iOS 27, bundle `com.apple.mobilesafari`, with nonpersistent session defaults and no project/scheme. Fresh MobileBuildMCP snapshot still reports 63 nodes and only five actionable browser-chrome targets. Device Hub screenshot remains too distorted for reliable field-coordinate input; raising the same window did not resolve it. No website keyboard was opened or claimed verified. The owner's earlier field-tap request remains pending.

Evidence: [zoom and motion JSON](interaction-evidence-2026-10-23/zoom-motion-2026-10-25.json), [artwork request JSON](interaction-evidence-2026-10-23/deferred-artwork-2026-10-25.json), [paired loading JSON](interaction-evidence-2026-10-23/mobile-lab-refresh-2026-10-25.json), and screenshots prefixed `reader-zoom`, `search-zoom`, `companion-zoom` and `workspace-motion-focus` with the 2026-10-25 date.

The fresh evidence closes the new workspace-motion and deferred-artwork follow-ups and strengthens zoom coverage. Native on-screen keyboard and broader manual accessibility gates remain open; completion is still unproven. No source edits required rerunning the already recorded production checks this turn.

## Resumed blocked audit — 25 October 2026

The native-field dependency recurred on three consecutive resumed turns: (1) fresh motion/zoom/performance work completed, but the Safari snapshot exposed only browser controls; (2) reopening the simulator frontend left the same five browser controls and no website field; (3) fresh session/default and runtime revalidation again returned 63 elements, five browser-chrome targets, screen hash `09idpay`, sequence 3, with no website keyboard targets. The preceding turn made no progress; the latest revalidation does not count as a verified wait for user input.

There is no identified unblocked source change that supplies the missing native-keyboard evidence. The earlier request for the owner to tap the visible blank question field remains unanswered. Do not repeat the same unsupported coordinate attempts, substitute an address-bar keyboard, or weaken the acceptance gate. Mark the goal blocked until the owner opens the question keyboard or supplies another usable native-control surface. Preserve the full objective and all remaining manual-review limits.

