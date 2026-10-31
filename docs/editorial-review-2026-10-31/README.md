# Site-wide reference evidence programme — 31 October 2026

The owner explicitly included all website reference content, beyond the initial seven lessons. `inventory.json` lists 487 logical public routes from the current sitemap, including reference indexes, cards and four contextual variants, lessons, spreads, questions, topics, zodiac/birth pages, tool explanations, reading/astrology references, homepage and publisher/methodology/widget claims. Eight locales have separate unverified language-review states. Noindex design prototypes, beta installation and legal text are outside this editorial-reference queue; their existing verification is not overwritten.

## Current progress

Six logical articles, `/learn/tarot-numbers`, `/learn/major-and-minor-arcana`, `/learn/tarot-suits`, `/learn/court-cards`, `/learn/reversed-cards` and `/learn/asking-questions`, have limited AI-assisted comparisons against specific primary-source passages and rewritten original worked examples in all eight locales. This does not mean their translations received human review, or that all 487 routes are source-verified. Every other record remains not started. The site-wide source/publisher component added earlier is not evidence that individual claims were checked.

Work in batches: remaining foundational lesson (how-to-read-tarot); major-card references; minor-card references; contextual interpretations; spreads/question/topic references; zodiac/birth/numerology and tool formulas; navigation and publisher consistency. A contextual interpretation needs its own reasoning, not a copied historical citation that never discussed that context. Reconcile newly added/removed routes before declaring the inventory complete.

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

`web/src/lib/editorial.ts` scopes structured citations and genuine content-modification dates to the checked articles only. No fake `lastReviewed` or `reviewedBy` is generated. The external-link fix in `Linked.astro` keeps HTTPS source URLs intact while local card/tool links still follow the selected language.

49 tests, locale parity, Astro check (zero errors/warnings; two existing hints), build and the five existing website audits pass. `npm --prefix web run check:editorial-build` additionally checks forty-eight complete questions/reversal/court/suits/numbers/arcana routes for their exact external sources, localized internal examples, source/check sections, Article citation parity and Markdown citations without invented human-review metadata. Chrome checked eight locales at 390/768/1440px: seven article sections, two source links and no horizontal overflow. These checks do not certify factual truth, expert review, native language quality, indexing or traffic growth.

## Arcana article: actual source-comparison record

Actor: Codex AI assistant; date: 31 October 2026 (Singapore). Read Waite Parts I–III directly, compared named passages with the article, and counted the site's actual shared deck labels (22 Major; 14 each Wands, Cups, Swords and Pentacles). No independent human expert or native-language review was performed.

| Claim or change | Evidence | Outcome / limit |
|---|---|---|
| 22 Major; four suits each with ten pips and four courts | [Part I §§2–3, permanent revision 15274505](https://en.wikisource.org/w/index.php?oldid=15274505&title=The_Pictorial_Key_to_the_Tarot/Part_1); site's current deck labels | 4 × 14 = 56, 22 + 56 = 78; explicitly scoped to this illustrated system, not every deck. |
| Fool 0 and World XXI; different printed placements of Fool | [Part II §§1–2, permanent revision 15274517](https://en.wikisource.org/w/index.php?oldid=15274517&title=The_Pictorial_Key_to_the_Tarot/Part_2), 0 and XXI; site's corresponding cards | Distinguish labels from ordering. Removed a compulsory life-journey narrative. |
| Magician's raised wand and four suit emblems on table | Part II §2, I | Verifiable visual observation; resource-inventory reading remains our original inference. |
| Working craftsperson in Eight of Pentacles | [Part III §2, permanent revision 15274510](https://en.wikisource.org/w/index.php?oldid=15274510&title=The_Pictorial_Key_to_the_Tarot/Part_3), Pentacles—Eight | Repeatable practice is an editorial application; not a source-backed promise of project success. |
| Major cards prove longer themes or greater importance; Minors change faster | No adequate evidence established in this check | Replaced categorical duration/importance claims with explicit teaching lenses; original question and position determine the proposed reflection. |
| More than half Major proves outside forces/turning point | No adequate evidence established in this check | Removed the inference in all eight locales. Counting describes the draw; it does not establish causation or a timescale. |
| Using only Majors is common among beginners | No usage research supplied | Removed the popularity claim. Offered it simply as an optional exercise with a changed draw pool. |
| Ten-minute tool practice, tool-collecting distraction and over-polishing alternatives | Newly authored teaching material | Clear question, positions, observation → inference → action, plus a plausible alternative. No actual client outcome, external prediction or endorsement asserted. |

Validation extends the existing evidence audit to sixteen article-locale routes and their exact citations, correction/local-card links and Markdown equivalents. The Chinese comparison illustration remains a clearly marked editorial example; its terminology now matches this lesson. All eight locale review states remain unverified.

Arcana browser verification: eight locales at 390/768/1440px (24 combinations), seven lesson sections and three exact source links per route, no horizontal overflow. Chinese evidence: `arcana-desktop.png` and `arcana-mobile.png`. Full build, editorial source audit and all five existing website audits passed after the final copy changes.

## Suits article: actual source-comparison record — 1 November 2026

Actor: Codex AI assistant. Directly read Waite Part I §3, the named Part III §2 entries and *Liber LXXVIII*, “The Titles of the Symbols”, items 1–4. Compared the shared 56 Minor-card records with the declared element map and read `elementOf` / the Pairing relationship model. This is a limited AI-assisted comparison, not independent expert or native-language review.

| Claim or change | Evidence | Outcome / limit |
|---|---|---|
| Four suits of fourteen, 56 Minor cards | [Waite, Part I §3](https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_1); current shared card records | Matches actual counts; does not support “half the meaning” or a universal deck definition. |
| Wands–Fire, Cups–Water, Swords–Air, Pentacles–Earth | [Liber LXXVIII, The Titles of the Symbols, items 1–4](https://sacred-texts.com/oto/lib78.htm); all fourteen cards per suit verified locally | Primary text explicitly names those Ace correspondences. Not claimed as physical law, universal tradition or identical card designs. Authorship of the particular online transcription was not established; no Person author is assigned to it in schema. |
| Four of Wands and Four of Cups scenes | [Waite, Part III §2](https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_3), Wands—Four and Cups—Four | Garland/flower-bearing figures versus seated figure and offered cup; comparison distinguishes scene observation from original gathering example. |
| Two of Cups, Ace of Swords, Ten/King of Pentacles | Same chapter, named entries | Checked image descriptions; King of Pentacles explicitly notes limits of treating the suit as exclusively money. Our suit questions remain teaching prompts rather than historical quotations or diagnostic claims. |
| Missing Cups proves suppressed feelings; many Swords forecasts conflict | No such inference established by the source comparison | Removed these assertions. Counts describe the draw, not another person's interior state or a clinical condition. |
| Pentacles guarantees lasting security or describes health | No empirical evidence supplied | Replaced with bounded questions about resources and support; no diagnosis, income forecast or financial recommendation. |
| Elemental support/opposition | Current `Pairing.astro` relationship function and `elementOf` | Described as a model's categories, not measured forces or success probabilities. Tool behavior unchanged. |
| Small-gathering scenario, capacity check, pressure-to-celebrate alternative | Newly authored teaching exercise | Observation → positions → inference → manageable action, with an alternative. Not a client story, friend mind-reading or promised outcome. |

Citation metadata now uses per-source authorship rather than assigning every historical reference to Waite. The five previously cited Waite sources retain their confirmed author; the newly consulted Liber transcription has no invented author. The evidence audit checks each visible source against its metadata and explicitly rejects invented authorship for sources without that field. The site-wide queue advances to 3/487 source-compared routes; all eight language-review states remain unverified.

Suits validation: 49 tests, parity, Astro check (zero errors/warnings; two existing hints), production build, source audit (24 article-locale routes) and all five website audits pass. Chrome measured all eight locales at 390/768/1440px: seven sections, three exact source links and no horizontal overflow. Screenshots are rendering evidence only; no actual screen-reader speech or native-language approval is claimed.

Suits capture limitation: desktop example/source capture `suits-desktop.png` was inspected. Phone capture returned downscaled/repeated-frame artifacts and is not retained as valid visual evidence; responsive phone checks above are DOM measurements, not a claim of physical-device or full visual acceptance. The source audit now checks the localized correction route and is included in `check:reader-build` so existing CI enforces it.


## Court article: actual source-comparison record — 1 November 2026

Actor: Codex AI assistant. Directly compared the named Waite passages with the article, counted four records per court rank (16 total) in the shared card data, and read the six-answer suit/rank matching logic of `which-card-are-you`. Limited AI-assisted checking; independent expert and native-language review remain unverified in every locale.

| Claim or change | Evidence | Outcome / limit |
|---|---|---|
| Four ranks in each of four suits | [Part I §3, revision 15274505](https://en.wikisource.org/w/index.php?oldid=15274505&title=The_Pictorial_Key_to_the_Tarot/Part_1); actual shared card records | 4 × 4 = 16 for this system; Knave/Page naming distinguished from universal deck rules. |
| All Knights rush toward a goal | [Part III §2, revision 15274510](https://en.wikisource.org/w/index.php?oldid=15274510&title=The_Pictorial_Key_to_the_Tarot/Part_3), Wands—Knight and Pentacles—Knight | Moving Wands horse contrasts with slow, enduring, heavy Pentacles horse. Removed universal speed; do not claim the text says stationary. |
| Queens only nurture inwardly | Part III §2, Cups—Queen | Source describes both seeing and acting. Four rank questions are expressly editorial options, not exhaustive gender/age/personality definitions. |
| Page observation, King judgment | Part III §2, Pentacles—Page and Swords—King | Looking intently at the pentacle and sitting in judgment support image descriptions; contemporary learning/boundary prompts are our inference. |
| Hardest cards for beginners; most readers agree | No usage or comprehension research supplied | Removed unsupported comparative/popularity claims in all eight languages. |
| Quiz reveals personality | Actual six-answer matching implementation | Described as playful matching, not validated psychometrics; no behavioral code changed. |
| Page/Pentacles Knight skill-learning example | Newly authored teaching material | Observation → question/position → repeatable practice, with over-preparation/rigidity alternatives; no client history, prediction or promised outcome. |
| Historical human descriptions | Consulted 1922 reprint, named court entries | Not evidence of contemporary people's gender, age, appearance, morality or motives. No expert/native endorsement invented. |

Verification results for this release are recorded after the final build below. Source audit now covers 32 article-locale routes. Queue progress is 4/487 limited source comparisons, not 4 completed human reviews.

Court release validation: 49 tests; eight-language parity; Astro check (0 errors, 0 warnings, 2 existing hints); production build; reader/editorial (32 article-locale routes), ritual, interactions, search-growth and beta audits passed. Chrome DOM checks at 390/768/1440px across eight locales found seven sections, two source links and no horizontal overflow. Desktop Chinese visual evidence: `court-desktop.png`. Mobile screenshot capture is unreliable in this browser setup, so no complete mobile visual or physical-device acceptance is claimed. Human accessibility and native-language review remain unverified.


## Reversals article: actual source-comparison record — 1 November 2026

Actor: Codex AI assistant. Direct reading of named Waite passages; comparison with the article and actual `workspace.ts` checkbox/matching meaning rendering, `card-picker.ts`, and Reader/draw-deck orientation behavior. No changes to drawing, saved readings or orientation logic. Independent expert and native-language review remain unverified.

| Claim or change | Evidence | Outcome / limit |
|---|---|---|
| A reversal always negates or softens a card | [Part III §3, revision 15274510](https://en.wikisource.org/w/index.php?oldid=15274510&title=The_Pictorial_Key_to_the_Tarot/Part_3), XIX Sun and XVI Tower | Sun keeps the upright sense to a lesser degree; Tower also includes oppression/confinement. Different historical entries refute a single automatic rule; not proof of future events. |
| Reversed Tower means a crisis was avoided | Same Tower entry | Removed that inference; reduced difficulty is not established avoidance. |
| Reversed Ten of Swords guarantees recovery | Part III §2, Swords—Ten | Text lists advantage/success with impermanence; no recovery promise retained. |
| Delayed means the promised event will come | No adequate support established | Replaced with a checkable practical-obstacle question; no guaranteed outcome/timing. |
| Blocked/inward/excess/delay are what reversals usually mean | No reader-use research or universal source established | Four optional original questions, not frequency claims or a universal historical taxonomy. |
| Original Sun/Eight of Pentacles hobby exercise | [Part II §2 XIX, revision 15274517](https://en.wikisource.org/w/index.php?oldid=15274517&title=The_Pictorial_Key_to_the_Tarot/Part_2); Part III §2 Pentacles—Eight | Child/white horse and working craftsperson are descriptions. Reduced enjoyment → small practice is our inference; alternative shorter practice/break avoids prescribing more work. No client narrative, emotional diagnosis or outcome guarantee. |
| Website practice instructions | `web/src/scripts/workspace.ts` reversed checkbox and display; `web/src/lib/card-picker.ts`; `Reader.astro`, `draw-deck.ts` | Orientation is recorded/displayed, not validated. No new orientation controls or manual-only behavior claimed for the random draw. |
| Edition | Consulted transcription of 1922 reprint | Historical description, divinatory list and editorial example distinguished. Independent expert/native review not performed. |

Source audit extended to 40 article-locale routes. Whole-site progress is 5/487 limited source comparisons; human review remains pending. Verification results follow after the final build.

Reversals release validation: 49 tests; locale parity; Astro check (0 errors/warnings, 2 existing hints); production build; reader/editorial (40 article-locale routes), ritual, interaction, search-growth and beta audits passed. Chrome DOM checks at 390/768/1440px in eight locales found seven sections, two source links and no horizontal overflow. Chinese desktop visual evidence: `reversals-desktop.png`. The known mobile screenshot capture issue remains; no physical-device, screen-reader or native-language acceptance is claimed.


## Questions article: actual source-comparison record — 1 November 2026

Actor: Codex AI assistant. Read named Waite passages and compared them with the guide; checked actual `three_decision` positions/purpose and website question/reflection fields. Limited source comparison, not independent expert or native-language review.

| Claim or change | Evidence | Outcome / limit |
|---|---|---|
| Cards answer exactly what is asked; fearful/vague questions cause poor readings | No adequate outcome evidence established | Removed certainty and blame; question is a focus for a reflection task. |
| Open questions are universally better or richer | [Part III §7, revision 15274510](https://en.wikisource.org/w/index.php?oldid=15274510&title=The_Pictorial_Key_to_the_Tarot/Part_3) includes definite yes/no legal examples | Open questions are our exercise choice, not an empirically superior or historically mandatory format. No legal/predictive validity implied. |
| Questions must never be repeated | Part III §7 permits repetition in specified circumstances | Pause/retain notes is an editorial suggestion, not a universal historical prohibition. New draw not treated as truth verification. |
| Decision spread reveals each option's future | Shared `three_decision` definition and localized website positions | Correctly named situation/challenge/way forward; no promised option outcomes. |
| Magician image and original resource prompt | [Part II §2 I, revision 15274517](https://en.wikisource.org/w/index.php?oldid=15274517&title=The_Pictorial_Key_to_the_Tarot/Part_2) | Four suit symbols on table verified; inventory application is editorial. |
| Two/Eight of Pentacles images | Part III §2, named entries | Dancing figure with two pentacles; working craftsperson. Competing tasks and small-sample action are our reasoning, not quotations. |
| Original two-hour hobby-project example | Newly authored exercise | Question rewrite → position/picture reasoning → small test; alternate tool-collecting reading and retaining disconfirming notes. No client story or guaranteed success. |
| Website reflection workflow | `web/src/scripts/workspace.ts`, `web/src/lib/workspace.ts` | Question/reflection fields exist; no behavioral change or claim of AI reading added. |

Consulted 1922 reprint transcription. Whole-site progress: 6/487 limited source comparisons; all independent expert/native review states remain unverified. Source audit extends to 48 article-locale routes. Verification results follow after the final build.

Questions release validation: 49 tests; locale parity; Astro check (0 errors/warnings, 2 existing hints); production build; reader/editorial (48 article-locale routes), ritual, interaction, search-growth and beta audits passed. Chrome DOM checks at 390/768/1440px in eight locales found seven sections, two source links and no horizontal overflow. Chinese desktop evidence: `questions-desktop.png`. Known mobile screenshot capture limitation remains; no physical-device, screen-reader or native-language acceptance is claimed.
