# ShenTarot: question hub, intent ownership and checkable information

Implementation checked: 2026-11-08 (Singapore). The research sample was collected November 6–7. These are separate dates.

## Decision and boundaries

The existing localized About route becomes the product-and-question hub. It owns “what ShenTarot provides, who publishes it, how the website differs from the observed beta, and where to start.” It is not a replacement for the individual card reference pages, working tools or full lessons.

The user supplied a five-step GEO workflow. MEN, ENT, CIT, FOQ, SOM, IGN and CGP are working labels here, not measured Google/OpenAI ranking factors. “No explicit citation” does not mean “cannot answer.” No claim is made that a rewrite will be cited tomorrow. No new analytics, external posting, marketplace listing or Wikipedia edit is included.

## 12 observed question intents

English questions are actual PAA labels or autocomplete predictions captured in the research evidence, with capitalization and punctuation normalized. Chinese and the other six localized versions are reader-oriented translations, not claims about observed Chinese query volume. Each Chinese answer is below 80 Unicode characters. English and other alphabetic languages use short answers below 80 words.

| Hub fragment | Observed English question | Evidence | Full answer or action owner |
| --- | --- | --- | --- |
| deck-count | How many cards are in a tarot deck? | Autocomplete, query 1 | /learn/major-and-minor-arcana |
| self-study | Can I teach myself to read tarot? | PAA, query 2 | /learn/how-to-read-tarot |
| four-suits | What do the four card suits symbolize? | PAA, query 4 | /learn/tarot-suits |
| court-cards | What are the 16 court cards? | PAA, query 6 | /learn/court-cards |
| shuffle | Is there a correct way to shuffle tarot? | PAA, query 11 | /learn/how-to-read-tarot |
| online-draw | Can I pull tarot cards online? | PAA, query 12 | /tools/random-card |
| daily-card | How to do a daily tarot card reading? | PAA, query 13 | /tools/daily-card |
| asking-questions | What not to ask in a tarot reading? | PAA, query 14 | /learn/asking-questions |
| reversals | Do you have to read tarot cards in reverse? | Autocomplete, query 19 | /learn/reversed-cards |
| feelings | Can tarot tell you how someone feels about you? | Autocomplete, query 22 | /questions/does-he-love-me |
| yes-no | How do I know if a tarot card is a yes or no? | PAA, query 5 | /tools/yes-no |
| future | Can tarot cards predict the future? | Autocomplete, query 8 | /methodology |

Raw Google PAA and prediction observations are retained in the local sampling files. The portable citation evidence has the original question, observed predictions and dated source observations. These are question candidates, not a global search-volume ranking.

## Semantic overlap review and consolidation

Inspected the actual source templates for homepage, About, methodology, Learn index, connected-reading example, beginner reference, card library, individual cards, spread library, daily-card, random-card, combinations, manual workspace and beta. The following ownership decisions apply to all eight language routes. Language variants are alternatives, not competing duplicate pages.

| Cluster / overlapping material | Main owner | Action / reason |
| --- | --- | --- |
| Product purpose, free scope, publisher | /about | Rebuilt this existing route as the hub. Homepage now states the short factual answer and links to the hub. No new competing product URL. |
| Twelve initial reading questions | /about#questions | One short-answer location with stable fragments. Each links to the relevant detailed resource. Learn and homepage provide discovery links. |
| Content tradition, AI assistance, review limitations | /methodology | Kept a concise disclosure on About and the methodology link. Exact disclosure repetition is useful context, not proof of search cannibalization. Detailed correction process remains on methodology. |
| “How to read” vs printable beginner reference | /learn/how-to-read-tarot for full lesson; /learn/beginner-reference for pocket guide | Retained distinct outcomes. No unsupported redirect or deletion. |
| Deck count, major/minor structure | /learn/major-and-minor-arcana | Hub gives only the direct answer, then links to the source-checked lesson. |
| Card names/78-card entity inventory | /cards | Five group H2s and 78 visible card H3s match the CollectionPage/ItemList. Detailed meaning stays on the card URL. |
| Three-card original example vs homepage example | /learn/connected-reading | About summarizes the same fixed editorial fixture and links to the full reasoning and a loadable example. It does not invent a new personal reading. |
| Daily draw vs random draw | /tools/daily-card vs /tools/random-card | Retained different tasks (daily reflection and another random draw). No false canonical merger. |
| Card pairs vs whole spread | /tools/combinations vs /read | Retained pair exploration versus entering a complete physical spread. |
| Mobile availability/installation | /beta | About has a small verified build observation and links to the full current installation guide. No duplicate install steps. |
| Love meanings vs another person’s feelings | /cards/*/love vs /questions/does-he-love-me | Contexts differ. No evidence from this sample establishes cannibalization. Reject mind-reading certainty. |

No query-by-page ranking time series was retrieved for this change, so “pages are competing and harming ranking” is not established. We consolidated the short-answer entry point and established clear internal destinations without removing useful pages merely because they mention similar terms.

## Information gaps and checkable product evidence

A model’s entire training corpus cannot be inspected. It is therefore not possible to prove that a datum has never appeared in any AI corpus. Existing ShenTarot facts must not be relabelled as newly discovered facts. The implementation instead exposes sourceable, product-specific information missing from the sampled generic category answers. See the CIT report for which answers were actually captured.

| Product H2 / fragment | Information provided | Authoritative evidence | Scope / limitation |
| --- | --- | --- | --- |
| using | Website has 78 upright/reversed references in eight languages, free and without browser AI charging | Actual card IDs + locale registry, all eight built libraries, no browser AI feature enabled | Counts are generated from actual data. This is the website, not a promise of free native AI. |
| example | Original fixed demonstration: upright Magician, reversed Two of Pentacles, upright Eight of Pentacles, situation/challenge/way-forward positions | web/src/lib/example.ts, localized growth copy, /learn/connected-reading, loadable /read?example=creative | Editorial example, not personal divination or independent experimental research. Existing original work, not claimed absent from all AI corpora. |
| app | Physical iPhone beta 1.0.1 (19), observed on 2026-10-30, general three-card reading requested 1 credit; spread/photo/manual-entry and general-reading options | web/src/lib/beta.ts IPHONE_BETA_EVIDENCE + released-capture metadata, existing verified beta copy and device evidence | Historical build observation only. Price in currency, Android charging and permanent free access not inferred. |
| questions | One saved reflection per browser/device, replaced on saving; explicit export before changing devices | web/src/lib/workspace.ts, web/src/scripts/workspace.ts, existing save/export tests | Browser-local storage, not account sync. No claim that the website detects app use. |

## BLUF

Homepage and About share one factual first paragraph in each locale.

Chinese: “ShenTarot 免费提供78张塔罗牌的正逆位牌义，方便你对照手上的牌，读懂自己的牌阵。”

This is 45 Unicode characters (validated by the build audit; use the actual count emitted from the file if wording changes). Price is free for the scoped website. Proposed native subscription prices were deliberately not converted into a fictitious currently available price range. The actual beta credit observation is separately attributed and dated.

## Entity placement

See entities.md and entities.csv for 108 ranked entities and four-platform status. Do not scatter all 108 labels into the About introduction. The 78 actual card entities are already a meaningful complete set for /cards: each receives a visible H3 and a matching DefinedTerm entry in a 78-item list. Five group H2s retain the deck hierarchy. The hub links into this library and uses the actual original example’s three named cards.

Shenetic is the publisher and ShenTarot the product. No Amazon/Wikipedia/Reddit sameAs relationship was asserted without identity evidence. No fake stars, reviews or independent reviewer credentials were added. FAQ schema describes visible questions; it is not a promise of a Google rich result or AI citation.

## Verification

- All eight locale JSON sets pass parity. Chinese lead <= 50 characters and all 24 Chinese FAQ answers <= 80 characters.
- New production audit checks eight About pages, 96 visible/schema-matched answers, 624 card headings/schema terms, fragment uniqueness, expected destinations, canonical/alternate count, sitemap presence, dated beta evidence and Markdown parity.
- Full website tests, Astro check, build, reader/editorial, ritual, interaction, search-growth and beta audits run after implementation.
- Real Chrome at 390px: all eight About pages had twelve questions and no document horizontal overflow. English, Simplified Chinese, German and Russian also checked at 768px and 1440px. Screenshots inspected for Chinese mobile and Russian desktop.
- Keyboard activation of the Chinese question link changed to #questions and landed at the visible section after smooth scrolling. No native screen-reader review or native-speaker signoff claimed.
- Independent agent review found and resolved a contextless “not yet” paragraph, missing provenance/review disclosures, an app heading with only price information, and a physical-shuffle link to the online tool. Audit also caught and fixed a duplicate #questions ID.
- Release/CI/live-production evidence to be added after the PR is merged and deployment checked.

## Outcome follow-up

Re-run the exact saved prompts in the same surface, language and requested location after indexing, keeping all original observations. Record whether ShenTarot is named, linked, and actually supports the cited claim separately. Compare inbound Search Console/Bing data when available. Do not attribute changes to this release without supporting evidence and do not count outbound links or visits as successful beta installations.
