# Site-wide reference evidence programme — 31 October 2026

The owner explicitly included all website reference content, beyond the initial seven lessons. `inventory.json` lists 487 logical public routes from the current sitemap, including reference indexes, cards and four contextual variants, lessons, spreads, questions, topics, zodiac/birth pages, tool explanations, reading/astrology references, homepage and publisher/methodology/widget claims. Eight locales have separate unverified language-review states. Noindex design prototypes, beta installation and legal text are outside this editorial-reference queue; their existing verification is not overwritten.

## Current progress

One logical article, `/learn/tarot-numbers`, has a limited AI-assisted comparison against specific primary-source passages and a rewritten original worked example in all eight locales. This does not mean its eight translations received human review, or that all 487 routes are source-verified. Every other record remains not started. The site-wide source/publisher component added earlier is not evidence that individual claims were checked.

Work in batches: remaining six foundational lessons; major-card references; minor-card references; contextual interpretations; spreads/question/topic references; zodiac/birth/numerology and tool formulas; navigation and publisher consistency. A contextual interpretation needs its own reasoning, not a copied historical citation that never discussed that context. Reconcile newly added/removed routes before declaring the inventory complete.

## Per-article acceptance

- Identify factual/historical, visual, conventional and original interpretive claims separately. Replace claims that exceed the evidence rather than adding decorative links.
- Record exact author, title, consulted edition/revision, passage location and which statement the source supports. A historical occult claim is evidence of a tradition, not empirical prediction or medical advice.
- Show an original example with observation, suit/position reasoning, a plausible alternative and a bounded reflection/action. Do not use fabricated client stories, outcomes or testimonials.
- Log actual checking actor/method/date/scope. AI comparison and automated HTML audits are not independent expert approval. Do not invent a person, credentials, review date or `reviewedBy` schema.
- Keep all eight published locales aligned; mark independent language review separately and pending until an actual reviewer supplies results.
- Check source links, local examples, visible/schema parity, Markdown representation, keyboard/no-JS behavior and mobile layouts. Preserve saved readings, disclaimer and export flows.

## Numbers article: actual source-comparison record

Actor: Codex AI assistant; date: 31 October 2026 (Singapore). Method: direct reading of the source edition page and Part III, then comparison with the website wording and the local birth/year calculation implementation. This is limited editorial checking, not a human tarot expert review.

| Claim or change | Checked evidence | Result / limit |
|---|---|---|
| Consulted edition and attribution | [Title/edition, permanent revision 15985439](https://en.wikisource.org/w/index.php?oldid=15985439&title=The_Pictorial_Key_to_the_Tarot) | Arthur Edward Waite; designs Pamela Colman Smith; consulted 1922 reprint, first publication listed 1910. Not labelled as first-edition scan. |
| Numbers cannot replace pictures | [Part III, permanent revision 15274510](https://en.wikisource.org/w/index.php?oldid=15274510&title=The_Pictorial_Key_to_the_Tarot/Part_3), §1 | Waite rejects relying on numerical powers/bare words alone. The site's Ace-to-Ten table is explicitly its own mnemonic, not attributed wholesale to Waite. |
| Same eight, different pictures | Part III §2, Wands—Eight; Swords—Eight; Pentacles—Eight | Moving wands, bound/blindfolded figure, working craftsperson; counterexample to a fixed universal numeric meaning. |
| Five of Cups image | Part III §2, Cups—Five | Three fallen cups, two standing; loss with something remaining. Verified description is separated from our project-resumption example. |
| Five of Wands comparison | Part III §2, Wands—Five | Competition/mimic conflict differs from Cups—Five; removes “every Five” as a universal factual rule. |
| Original inference and alternative | Newly authored teaching material | Remaining-resource inventory vs pausing to acknowledge loss; neither is a quotation, prediction or account of a real client. |
| Birth/year arithmetic | `web/src/lib/numerology.ts`, `web/src/lib/birth.ts`, corresponding tool pages | Separate digit-sum conventions, including Fool mapping; the lesson no longer implies one universal zero-to-21 calculation or predictive validation. |
| Court cards | Part III §2 court-card entry headings and site's actual images | Rank titles distinguished from Ace-to-Ten; unsupported universal 11–14 assignment removed. |
| Independent expertise / translation | No such review supplied | Explicitly not confirmed. All locale review states remain unverified. |

Rejected candidate: Project Gutenberg eBook 43548 is catalogued as L. W. De Laurence's *The Illustrated Key to the Tarot*, not Waite's original title/attribution. It was not cited as Waite's book. The title check prevented a plausible but incorrect attribution.

## Implementation and verification

`web/src/lib/editorial.ts` scopes structured citations and a genuine content-modification date to this article only. No fake `lastReviewed` or `reviewedBy` is generated. The external-link fix in `Linked.astro` keeps HTTPS source URLs intact while local card/tool links still follow the selected language.

49 tests, locale parity, Astro check (zero errors/warnings; two existing hints), build and the five existing website audits pass. `npm --prefix web run check:editorial-build` additionally checks eight complete numbers routes for two exact external sources, localized internal examples, source/check sections, Article citation parity and Markdown citations without invented human-review metadata. Chrome checked eight locales at 390/768/1440px: seven article sections, two source links and no horizontal overflow. These checks do not certify factual truth, expert review, native language quality, indexing or traffic growth.
