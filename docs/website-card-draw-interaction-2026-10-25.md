# ShenTarot: shuffle, choose, turn

25 October 2026. Owner direction: expressive card-drawing motion, desktop primary, phone secondary. The owner clarified physical-keyboard input in the simulator; an on-screen-keyboard handoff does not block this phase.

## Research translated into the interaction

| Primary reference | Evidence and adaptation |
| --- | --- |
| [Codrops / Manoela Ilic — Card Stack Effects](https://tympanus.net/codrops/2015/10/28/effect-ideas-for-card-stacks/) and [demo](https://tympanus.net/Development/CardStackEffects/) | Read the original article and operated Yuda's Accept control in the browser. The top card displaces while the underlying stack remains recognizable. Adapt spatial continuity and deliberate selection. Historical 2015 study, not a current product-usability benchmark. |
| [Codrops — Swatch Book](https://tympanus.net/codrops/2012/07/02/swatch-book-with-css3-and-jquery/) | Article explains rotated neighbouring sheets and shared transform origins. Adapt the fan and raised inspected card. Demo not audited here; no legacy jQuery or artwork imported. |
| [Emil Kowalski — Practical Animation Tips](https://emilkowal.ski/ui/7-practical-animation-tips) | Author's guidance supports restrained, decelerating gestures. Exact timings below are design choices, not universal measured optima. |
| [Tarotap draw tool](https://tarotap.com/en/draw-cards) | Its published description separates a full-deck shuffle, face-down selection and reveal. Mechanical supporting reference only: complete live draw, randomness and mobile usability not audited. Its AI capabilities are not attributed to ShenTarot. |
| [MDN animate](https://developer.mozilla.org/en-US/docs/Web/API/Element/animate), [finished](https://developer.mozilla.org/en-US/docs/Web/API/Animation/finished), [Astro scripts](https://docs.astro.build/en/guides/client-side-scripts/) | Official API guidance; Astro checked through Context7. Implement native cancellable animation and initialize each component instance. |

Earlier portfolio research supplies the wider direction: Lusion's bounded stage, Studio Dumbar's consistent motion vocabulary and editorial paper/ink surfaces. Fresh code uses ShenTarot's original card-back SVG and existing card artwork. Reference assets and code were not copied.

## Resulting behavior

1. **Pause:** an idle deck stack. Homepage load no longer silently chooses a card. A saved daily card still restores directly.
2. **Shuffle:** explicit action fixes all 78 cards and orientations. Alternating stack layers move for about 620–692ms; the fan unfolds over about 700–828ms. Selection is immediately available; Skip cancels decoration.
3. **Browse:** nine backs in wide containers, five in compact containers/phone views. Previous/Next accesses the entire remaining deck. Range and selected count stay explicit.
4. **Choose:** hover/focus inspects; click/Enter commits the selected card without replacement. A 420ms decorative transfer reinforces the action. Animation never determines or changes the outcome.
5. **Turn:** explicit action reveals meaning immediately with a 420ms turn on the artwork link. Reversed rotation remains on its inner image. Only chosen artwork is warmed before reveal. Multi-card draws retain Turn all over.
6. **Continue:** existing meanings, summaries, sharing, copy and daily retention remain. Changing the generator's next count preserves the current reading until another shuffle is requested.

Arrow keys/Home/End move fan focus without selecting. Cards have stationary full-size button areas and roughly 44px exposed strips. Local/OS reduced motion, Skip, background-tab cancellation and missing-animation-API fallback preserve logical actions. OS reduction takes priority. No timer callback owns the draw.

## Source map

- `web/src/components/Reader.astro`: common UI and existing reading behavior.
- `web/src/lib/draw-deck.ts`: rejection-sampled cryptographic integers, Fisher–Yates shuffle, fixed orientations and selection without replacement.
- `web/src/lib/draw-motion.ts`: native animation lifecycle and cancellation.
- `web/src/styles/draw.css`: desktop table, compact fan and focus/hover treatment.
- `web/src/i18n/draw.ts`: explicit copy for eight locales.
- `web/src/pages/[...lang]/tools/random-card.astro`: shared reader with next-draw count 1–10.
- `web/tests/draw-deck.test.ts`: identity/orientation preservation, invalid choices and range boundaries.
- `web/scripts/check-ritual-build.mjs`: localized draw copy and emitted controls.

Shared across home, generator, daily/weekly draws, yes/no and spread pages. The physical-card workspace retains its own visual picker; it does not randomly replace a real draw. No package, WebGL, tracking, AI request, charge, backend/app change or draft-schema change was added. No merge/deploy/publication.

## Verification

- 23 tests pass, including five new deck-integrity tests. Astro: zero errors/warnings, two existing unrelated birth-card hints. Locale checks pass.
- Production: 3,909 pages; reader audit 160 pages; ritual audit 240 pages / 29,072 references; interaction audit 8 indexes / 808 destinations.
- Desktop browser: live shuffle/transfer/turn animations, immediate Skip, paging, focus-only arrows, deliberate Enter and pointer selection, correct reversed links and reveal focus.
- Ten rapid choices produce ten distinct cards; writing, summaries and next-count preservation hold. Existing yes/no weighted-middle-card logic and daily identity/orientation across reload verified.
- Local reduction cancels running effects. Reduced-motion pick/reveal creates no motion; OS reduction remains authoritative.
- A temporary local-page fixture removed the native animation method: shuffle, selection and reveal still completed. The method was restored in a finally block, then the page was navigated normally; no fixture remains in the preview.
- Fourteen responsive cases: desktop 1440, tablet 768, all eight locales at 390, and English/German/Russian/Japanese at 320. Checked button regions remain within the viewport and at least 44px wide. Phone-width click/pick/reveal also exercised. Pages remain vertically scrollable.
- Axe 4.14: zero detected A/AA-tagged violations in three draw states. Gradient contrast remains scanner-incomplete. Manual sRGB checks against the lightest stage color: checked labels at least 7.674:1; composited motion-state text 9.253:1; control borders 3.111:1. No conformance claim.
- Reader entry: 4,497 gzip bytes versus earlier baseline 2,323. Excludes shared chunks, CSS and markup; size evidence, not a fresh timing/CWV measurement.

Evidence under `docs/interaction-evidence-2026-10-23/`: `draw-interactions-2026-10-25.json`, `draw-accessibility-2026-10-25.json`, `draw-contrast-2026-10-25.json`, `draw-bundle-size-2026-10-25.json`, and `draw-desktop-fan`, `draw-desktop-reveal`, `draw-phone-fan` PNGs with the same date.

Viewport checks are not physical-phone evidence. Native touch, screen-reader behavior, consumer preference and field performance remain unverified. Hardware-keyboard simulator input is not presented as an on-screen-keyboard test. The latest owner priority is desktop first, phone second.
