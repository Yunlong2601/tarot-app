# Spread-bound drawing — Mystical & Editorial

Implemented locally on 26 October 2026. Desktop is primary; phone is secondary. The owner's “follow C” is interpreted as the previously proposed Mystical & Editorial direction. This phase is not merged, deployed or published.

## Experience

- An open parchment reading table replaces the surrounding deck panel on multi-card draws. Forest card backs, orbital empty positions, fine connecting paths, serif headings, circular browsing controls and underlined secondary actions share one visual language.
- The real spread geometry comes from the existing shared app spread catalogue, including the two crossing Celtic positions. These paths show placement order, not newly inferred meanings or AI analysis.
- Shuffle fixes the deck and orientations. Each pointer/keyboard choice travels to its numbered position; the next position becomes prominent. Cards stay face down until individually turned or Turn all over is selected. The reading below retains real card names, positions, orientations and meaning links.
- The generator can select any of the 15 named spreads, or a free draw of 1–10 cards. Changing its pending spread preserves the existing draw and question until an explicit new shuffle. A named spread owns its card count and yes/no behavior.
- Compact layouts use an ordered native horizontal rail. Selecting a card scrolls its position into view without scrolling the whole document. Card meanings remain a vertical reading. Celtic's crossing card becomes upright in the rail; reversed orientation stays independent.
- Existing Skip, local motion control and operating-system reduced-motion support remain available. No required dragging, hover-only instructions, new production AI endpoint, tracking, app/backend changes or workspace draft migration.

## Implementation

- `web/src/components/Reader.astro`: shared bound-spread registry, placement, reveal, focus and pending generator selection.
- `web/src/lib/spread-stage.ts`: validated shared geometry and bounded free-draw positions.
- `web/src/styles/spread-stage.css`: open desktop table, compact rail and editorial reading surfaces.
- `web/src/styles/draw.css`: stationary 44px fan hit areas prevent overlapping art from stealing adjacent numbered choices.
- `web/src/lib/draw-motion.ts`: Skip restores focus without an unwanted page jump.
- `web/scripts/check-ritual-build.mjs`: every named spread in every supported locale now receives a binding/layout audit.

## Verification

- 26 unit tests pass, including geometry mismatch rejection, coincident Celtic positions, free counts, no-repeat drawing and preserved orientation.
- Astro checks: 115 files, zero errors/warnings, two existing birth-card hints. All locale checks pass.
- Production build: 3,909 pages. Reader audit: 160 pages; ritual audit: eight locales, 352 pages, 41,888 references; search audit: eight indexes and 808 result routes. All pass. `git diff --check` passes.
- Actual local production browser: all 15 named spreads completed shuffle → choose → reveal, with exact counts, unique card IDs and ordered position assignment. The all-spread sweep used reduced motion; a separate seven-card Horseshoe journey used normal motion and pointer/keyboard choices, preserving earlier identities and orientations.
- Generator browser test: one Horseshoe pick survives a pending Celtic selection; Shuffle applies ten empty Celtic positions and keeps the question. Switching back to free count one restores a normal single-card reveal.
- Phone layout checks at 320, 390 and 768 CSS pixels found no document horizontal overflow. A fourth card was selected and revealed in the compact rail; all previous picks remained available. These are browser viewport checks, not physical-phone research.
- Desktop Horseshoe and Celtic compositions were visually inspected. Staff number pins sit beside the Celtic stack; compact pins return above individual cards. The Celtic key uses one set of ordered-list numbers and offers 44px-high alternative reveal/meaning controls. Selecting its second reveal control opened only position two and restored focus to that card's meaning anchor.
- Final axe audit of the revealed Celtic reader: desktop zero violations and zero incomplete checks; compact zero violations with contrast checks requiring manual review around pseudo-elements/clipped rail captions. Computed text-to-paper ratios for caption, ordinal and key are 10.42:1, 5.16:1 and 5.81:1 respectively. The compact screenshot confirms visible caption text is on paper. Offscreen rail items remain scrollable.
- Evidence: `interaction-evidence-2026-10-26/spread-validation.json`, desktop and phone PNGs. Automated accessibility findings are limited to the audited states and do not establish full WCAG conformance or screen-reader usability.

## Remaining validation limits

No consumer sessions, physical-phone study or native screen-reader audit was performed in this phase. The earlier consenting-participant study pack remains available. Production AI companion integration remains separate. No conversion or performance improvement is claimed from visual changes alone.

Recommended review: start at `/spreads/horseshoe#try`, shuffle, choose three cards, reveal them, then finish the remaining positions. Compare `/spreads/celtic#try` and the generator's named-spread selector.
