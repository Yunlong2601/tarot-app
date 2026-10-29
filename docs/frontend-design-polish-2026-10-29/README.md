# ShenTarot frontend design refinement — 2026-10-29

Website-only refinement of the existing Quiet Ritual identity. No native app, backend, account, payment, or legal-copy changes. Production deployment is outside this change.

## Installed sources and how they were used

| Source | Local installation | Application in this pass |
| --- | --- | --- |
| [Official Flutter plugins](https://github.com/flutter/agent-plugins) | `~/.codex/skills/flutter-*` (10 published skills) | Responsive layout principles informed compact controls; Flutter code remains reserved for the native app. |
| [Impeccable](https://github.com/pbakaus/impeccable) | `~/.codex/skills/impeccable` | Preserve incumbent identity, audit function before decoration, improve control legibility and responsive composition. |
| [Taste Skill](https://github.com/Leonxlnx/taste-skill) | `~/.codex/skills/taste-skill` | Remove redundant homepage eyebrows and decorative chapter numbers; review the rendered layout and run the source lint. |
| [UI/UX Pro Max](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) | `~/.codex/skills/ui-ux-pro-max` | Queried UX database for touch targets/readability; increased prompt height and position-control spacing. |
| [Anthropic frontend-design](https://github.com/anthropics/skills/tree/main/skills/frontend-design) | `~/.codex/skills/frontend-design` | Keep cream/forest, bundled serif/sans, real deck imagery, and one clear primary action; simplify hierarchy. |
| [Awesome Design MD](https://github.com/VoltAgent/awesome-design-md) | `~/.codex/design-references/awesome-design-md` | Reference collection, not an executable skill. Apple analysis informed artwork-first presentation and restrained interface chrome; no brand assets or palette copied. |

New installations may require a fresh Codex session to appear in the skill catalog. Instructions were read directly for this pass. Impeccable context launcher initially lacked execute permission; used its documented fallback to read repository context, then repaired launcher execute permission for later sessions.

## Direction and real product inventory

- Cream `#f4f0e7`, forest `#243c35`, ink `#17171b`, text gold `#795d30`; keep bundled Cormorant Garamond and Inter.
- Real 78-card public-domain deck artwork leads the homepage and library.
- Two jobs: draw a card or interpret cards already held by the reader.
- Homepage includes a real draw engine, authored three-card example, practice path, topics, library, FAQs, beta destinations.
- Reading desk holds question, named positions, upright/reversed cards, full meanings, editable cards, connections, reflection, save/export.
- Three-card layouts retain their spatial spread; longer phone spreads retain the existing horizontal rail.
- Reference meanings remain distinct from unavailable browser AI. No invented popularity or revenue claims.
- Eight locales share layout; no new copy, translations, remote fonts, dependencies, tracking, or scripts.
- Headings balance naturally, controls stay readable, and quiet surrounding chrome lets the artwork lead.
- Preserve keyboard, reduced-motion, draft/restore, and export behavior; avoid adding animation solely for stylistic compliance.

## Concrete changes

Homepage headline reduced from an oversized three-line block to a balanced two-line composition at the reviewed desktop width. Removed redundant introductory labels and ornamental section numbering. Raised search, availability and library text sizes. The phone library uses two columns with larger card art and labels, and its search form can wrap naturally.

Reading desk labels and operational text now use at least 14px. Prompt controls have 44px minimum height; position controls use 44px minimum width and 8px gaps. The heading has a restrained scale, while the spatial card layout and margin annotation remain intact. Shared mobile menu uses an aria-hidden SVG rather than a font-dependent hamburger glyph.

## Verification

- 41 website tests pass; all eight locale dictionaries pass parity checks.
- Astro check: zero errors and warnings, two existing hints.
- Production build: 3,911 pages, 3,910 Markdown documents.
- Reader, ritual, interactions, search-growth and beta build audits pass.
- Taste source lint in app mode: no failures; warnings retained for established shared-label selectors, real step/position numbering, deck-art shadows, and genuine overlay shadows. Do not claim a complete stylistic-lint cleanup.
- Chrome review at 1,440px desktop, 768px tablet, 390px phone; English homepage and reading desk plus Simplified Chinese homepage. No document horizontal overflow at measured widths.
- Card picker opens and selecting The Star updates its position, full-meaning link, practice prompt and draft status.
- Physical devices, other browsers, native speaker translation review and complete accessibility conformance are not verified.

The local preview uses Astro's clean locale routes, for example `/zh-hans` without a trailing slash.
