# ShenTarot: question hub, intent ownership and checkable information

Implementation checked: 2026-11-08 (Singapore). The research sample was collected November 6–7. These are separate dates.

## Decision and boundaries

The existing localized About route becomes the product-and-question hub. It owns “what ShenTarot provides, who publishes it, how the website differs from the observed beta, and where to start.” It is not a replacement for the individual card reference pages, working tools or full lessons.

The user supplied a five-step GEO workflow. MEN, ENT, CIT, FOQ, SOM, IGN and CGP are working labels here, not measured Google/OpenAI ranking factors. “No explicit citation” does not mean “cannot answer.” No claim is made that a rewrite will be cited tomorrow. No new analytics, external posting, marketplace listing or Wikipedia edit is included.

## 12 observed question intents

English questions use the PAA labels or autocomplete predictions captured in the research evidence, with capitalization and punctuation normalized. The other seven versions translate those questions for their readers. From November 9, all 96 answers use a limit of 80 Unicode code points, including spaces and punctuation. Each links to the lesson or tool for the full explanation.

| Hub fragment | Observed English question | Evidence | Full answer or action owner |
| --- | --- | --- | --- |
| deck-count | How many cards are in a tarot deck? | Autocomplete, query 1 | /learn/major-and-minor-arcana |
| self-study | Can I teach myself to read tarot? | PAA, query 2 | /learn/how-to-read-tarot |
| four-suits | What do the four card suits symbolize? | PAA, query 4 | /learn/tarot-suits |
| court-cards | What are the 16 court cards? | PAA, query 6 | /learn/court-cards |
| shuffle | Is there a correct way to shuffle tarot? | PAA, query 11 | /learn/how-to-read-tarot#s2 |
| online-draw | Can I pull tarot cards online? | PAA, query 12 | /tools/random-card |
| daily-card | How to do a daily tarot card reading? | PAA, query 13 | /tools/daily-card |
| asking-questions | What not to ask in a tarot reading? | PAA, query 14 | /learn/asking-questions |
| reversals | Do you have to read tarot cards in reverse? | Autocomplete, query 19 | /learn/reversed-cards |
| feelings | Can tarot tell you how someone feels about you? | Autocomplete, query 22 | /questions/does-he-love-me |
| yes-no | How do I know if a tarot card is a yes or no? | PAA, query 5 | /tools/yes-no |
| future | Can tarot cards predict the future? | Autocomplete, query 8 | /methodology |

The portable citation evidence records the actual Google PAA labels, observed predictions, original questions and dated source observations. These are question candidates, not a global search-volume ranking.

## Semantic overlap review and consolidation

Inspected the actual source templates for homepage, About, methodology, Learn index, connected-reading example, beginner reference, card library, individual cards, spread library, daily-card, random-card, combinations, manual workspace and beta. The following ownership decisions apply to all eight language routes. Language variants are alternatives, not competing duplicate pages.

| Cluster / overlapping material | Main owner | Action / reason |
| --- | --- | --- |
| Product purpose, free scope, publisher | /about | Rebuilt this existing route as the hub. Homepage now states the short factual answer and links to the hub. No new competing product URL. |
| Twelve initial reading questions | /about#questions | One short-answer location with stable fragments. Each links to the relevant detailed resource. Learn and homepage provide discovery links. |
| Content tradition, AI assistance, review limitations | /methodology | Kept a concise disclosure on About and the methodology link. Exact disclosure repetition is useful context, not proof of search cannibalization. Detailed correction process remains on methodology. |
| “How to read” vs printable beginner reference | /learn/how-to-read-tarot for full lesson; /learn/beginner-reference for pocket guide | Retained distinct outcomes. No unsupported redirect or deletion. |
| Deck count, major/minor structure | /learn/major-and-minor-arcana | Hub gives only the direct answer, then links to the source-checked lesson. |
| Card names/78-card entity inventory | /cards | Two group H2s cover Major and Minor Arcana. Four H3s within Minor Arcana contain the suits. All 78 card names, links and memberships match the CollectionPage and its lists. The linked lesson explains the distinction, while each card URL owns its detailed meaning. |
| Three-card original example vs homepage example | /learn/connected-reading | About summarizes the same fixed editorial fixture and links to the full reasoning and a loadable example. It does not invent a new personal reading. |
| Daily draw vs random draw | /tools/daily-card vs /tools/random-card | Retained different tasks (daily reflection and another random draw). No false canonical merger. |
| Card pairs vs whole spread | /tools/combinations vs /read | Retained pair exploration versus entering a complete physical spread. |
| Mobile availability/installation | /beta | About has a small verified build observation and links to the full current installation guide. No duplicate install steps. |
| Love meanings vs another person’s feelings | /cards/*/love vs /questions/does-he-love-me | Contexts differ. No evidence from this sample establishes cannibalization. Reject mind-reading certainty. |

We consolidated the short-answer entry point and gave the complete tutorials and working tools distinct destinations. The Search Console follow-up below checks where selected queries actually landed before launch.

### Search Console follow-up, November 8

The [ShenTarot Performance report](https://search.google.com/search-console/performance/search-analytics?resource_id=sc-domain%3Ashentarot.com) was checked on November 8, 2026, Singapore time. Each row used Web search, the 28-day view, an exact-query filter and the Pages tab, with no country or device filter. The chart showed available data for October 17–November 5. This gives a pre-release snapshot by query and page. The page counts below refer to rows the report displayed.

| Exact query | Clicks | Impressions | Page shown |
| --- | ---: | ---: | --- |
| `tarot card shuffle` | 0 | 34 | `/tools/random-card` |
| `tarot shuffle` | 0 | 32 | `/tools/random-card` |
| `random tarot card` | 0 | 8 | `/tools/random-card` |
| `daily tarot reading` | 0 | 1 | `/topics/daily` |
| `how many cards are in a tarot deck` | 0 | 0 shown | No data |
| `yes or no tarot` | 0 | 0 shown | No data |
| `shentarot` | 0 | 0 shown | No data |

The three draw queries produced 74 reported impressions, all on the generator. The one reported impression for the daily query went to the daily topic guide. This supports separate destinations for drawing a card and researching daily reading. Three queries returned no rows, so their search landing pages remain unverified. The small sample and pre-release date range leave the new hub’s impact open.

The [URL Inspection report](https://search.google.com/search-console?resource_id=sc-domain%3Ashentarot.com) listed all three inspected URLs as indexed. Both hub pages reported the inspected URL as Google’s selected canonical. The draw tool declared its own URL as canonical. Crawl times below are transcribed as displayed.

| Inspected URL | Last crawl shown | Fetch | Indexing allowed |
| --- | --- | --- | --- |
| `https://shentarot.com/about` | 2026-10-22 05:53:23 | Successful | Yes |
| `https://shentarot.com/zh-hans/about` | 2026-10-27 06:00:16 | Successful | Yes |
| `https://shentarot.com/tools/random-card` | 2026-11-03 23:38:54 | Successful | Yes |

The [production manifest](https://shentarot.com/release.json) served revision `37435f964a1d21dcfe122a4522df3f35401c42fd`, built November 7 at 17:16:45 UTC. The live English Markdown hub served the new four H2 sections and twelve questions. The recorded crawls all precede that build. Use a crawl at or after the deployment and a complete reporting window to separate an indexed URL from verified coverage of the new hub content.

### Google Search generative AI baseline, November 9

On November 9 in Singapore, the domain property showed **Include** selected under Search generative AI. Its separate Generative AI features report was available. The report used the default three-month selector and **Web (text)**. It displayed October 17 through November 6, 2026. Summing all 21 dates yields **1,067 property impressions**, consistent with the rounded 1.07k on the chart. The Pages tab showed **382 URL rows**. Google counts property and page impressions differently when a result includes several links from one site. The dates in the report use Pacific Time. [Site control](https://search.google.com/search-console/settings/search-gen-ai?resource_id=sc-domain%3Ashentarot.com) · [Site report](https://search.google.com/search-console/performance/search-analytics/ai?resource_id=sc-domain%3Ashentarot.com) · [Report definitions](https://support.google.com/webmasters/answer/16984139?hl=en)

| Visible page or group | Page rows | Page impressions |
| --- | ---: | ---: |
| Card reference URLs across languages, including contexts | 303 | 910 |
| English Judgement reference | 1 | 53 |
| German Hierophant reference | 1 | 53 |
| Spanish Four of Pentacles reference | 1 | 40 |
| English random draw | 1 | 14 |
| Russian random draw | 1 | 3 |
| Simplified Chinese random draw | 1 | 1 |

The card group includes the three individual cards in the table. There was no row for an About hub, the birth card calculator or the Sun base reference in the displayed report. The observed impressions combine AI Overviews and AI Mode, so the report cannot assign a specific prompt or feature to a page. It establishes that links to the site appeared during this period. The individual English queries sampled in the citation audit can still omit the site.

The random draw owns the online draw intent. Its eight pages now document one-card selection, the 78-card shuffle, the 1-in-4 reversal setting and the transfer of the same cards, positions, orientations and optional question into the workspace. The About hub keeps its short answer and points to the tool. The daily card tool remains the destination for a daily draw. [English tool](https://shentarot.com/tools/random-card#how-to-draw) · [Simplified Chinese tool](https://shentarot.com/zh-hans/tools/random-card#how-to-draw)

A Chrome preview check on the Simplified Chinese random draw selected one card, shuffled, used the optional pick action and revealed an upright Page of Wands. Continuing into the workspace retained the card, upright orientation and a synthetic practice question in the tab. The question did not appear in the workspace URL. This run covered the one-card path.

### Daily draw and daily practice

The daily tool owns the actual one-card draw and explains its date and storage behavior in all eight locales. It writes the card ID, orientation and local date after reveal. Reopening the tool looks up the current local date and restores the result from that browser profile when available. A Chrome preview retained reversed Justice after refresh and after switching from Simplified Chinese to English. The topic page owns broader daily questions and spread suggestions. The random tool remains the destination for a fresh shuffle on demand. [Daily tool guide](https://shentarot.com/zh-hans/tools/daily-card#daily-guide) · [Daily topic](https://shentarot.com/zh-hans/topics/daily) · [CIT sample 13](citation-audit.md)

### Report refresh through November 7

The same domain report was checked again on November 9 in Singapore. The 22 daily rows from October 17 through November 7 sum to **1,162 property impressions**. November 7 accounts for 95, and the Pages tab shows 411 URL rows. A table filter for `/tools/daily-card` returned one German URL with one impression. A filter for `/about` returned zero rows. These are counts across Google’s generative search features. [Generative AI report](https://search.google.com/search-console/performance/search-analytics/ai?resource_id=sc-domain%3Ashentarot.com)

The English About inspection still reports the URL as indexed and selected as canonical. The last crawl displayed is October 22, 05:53:23. This crawl predates the hub rewrite. The refreshed report provides a baseline for the daily guide before its release. [URL Inspection](https://search.google.com/search-console?resource_id=sc-domain%3Ashentarot.com)

## Information gaps and checkable product evidence

A model’s entire training corpus cannot be inspected. It is therefore not possible to prove that a datum has never appeared in any AI corpus. Existing ShenTarot facts must not be relabelled as newly discovered facts. The implementation instead exposes sourceable, product-specific information missing from the sampled generic category answers. See the CIT report for which answers were actually captured.

| Product H2 / fragment | Information provided | Authoritative evidence | Scope / limitation |
| --- | --- | --- | --- |
| using | Website has 78 upright/reversed references in eight languages, free and without browser AI charging | Actual card IDs + locale registry, all eight built libraries, no browser AI feature enabled | Counts are generated from actual data. This is the website, not a promise of free native AI. |
| example | Original fixed demonstration: upright Magician, reversed Two of Pentacles, upright Eight of Pentacles, situation/challenge/way-forward positions | web/src/lib/example.ts, localized growth copy, /learn/connected-reading, loadable /read?example=creative | Editorial example, not personal divination or independent experimental research. Existing original work, not claimed absent from all AI corpora. |
| app | Physical iPhone beta 1.0.1 (19), observed on 2026-10-30, general three-card reading requested 1 credit; spread/photo/manual-entry and general-reading options | web/src/lib/beta.ts IPHONE_BETA_EVIDENCE + released-capture metadata, existing verified beta copy and device evidence | Historical build observation only. Price in currency, Android charging and permanent free access not inferred. |
| questions | One saved reflection per browser/device, replaced on saving; explicit export before changing devices | web/src/lib/workspace.ts, web/src/scripts/workspace.ts, existing save/export tests | Browser-local storage, not account sync. No claim that the website detects app use. |

The comparison is with actual answers, not a guess about what the models know. ChatGPT's beginner and self-reading samples (2, 9) already explain the deck and suggest journaling. They do not give ShenTarot's language coverage, physical-card entry flow or one-record retention behavior. The three-card and combination samples (15, 17) already explain positions and give examples. They do not provide ShenTarot's specific loadable three-card exercise. The online-draw sample (12) names and links other free tools, so free/no-account drawing is a shared feature; the handoff from an existing physical draw to the workspace is a different task. Generic questions did not ask about native beta credits. The dated one-credit observation answers a product-specific question that the category sample leaves outside its scope.

### Branded product-answer check, November 8

One fresh ChatGPT temporary chat in the default interface mode was given the following English prompt. This separate observation used a brand name and explicitly requested web search and sources. The earlier category baseline used unbranded questions.

> Search the web for ShenTarot. What can I do with my own tarot cards on the website, is there a worked spread I can try, what does the app add, and how are saved reflections handled? Cite the pages that support each answer.

| H2 | Fact present in the finished answer | Hub detail absent from this answer |
| --- | --- | --- |
| `using` | Manual entry of physical cards, both orientations, all 78 cards and no account | Coverage in eight languages |
| `example` | The exact three example cards, their orientations and positions, the creative-project question and the exercise's connecting interpretation | A direct link that preloads the example in the workspace. The answer directed readers to the homepage for the example. |
| `app` | Beta access and the distinction between browser guidance and mobile AI interpretation | The October 30 observation for iPhone beta 1.0.1 (19) and the confirmation for one credit |
| `questions` | One saved reflection in browser local storage, replacement on save and downloadable export | Which state the export uses and whether the file includes all three positions and orientations in the example |

The completed answer had direct links to the [homepage](https://shentarot.com/), [tools index](https://shentarot.com/tools) and [privacy policy](https://shentarot.com/privacy). The two opened citation chips identified the homepage and tools index for the web workflow, and the homepage for the worked example. The hub was not the direct destination in those checked citations. This confirms that at least some published product facts are retrievable in a branded search answer. The comparison applies to this captured answer and leaves the providers' training datasets unverified.

The branded answer mentioned a downloadable copy without specifying which workspace state it used or the card details in the file. A November 8 Chrome check on a local production build opened the three-card example, saved synthetic reflection A, changed the draft to synthetic reflection B and downloaded the text. The downloaded file contained B plus all three card positions and orientations. Restoring the saved reflection recovered A. The workspace writes the current draft to a text file through its existing export control. The eight About pages now explain which state is exported and link directly to the workspace reflection controls. [Reproduce with the three-card example](https://shentarot.com/read?example=creative)

## BLUF

Homepage and About share one factual first paragraph in each locale.

Chinese: “ShenTarot 免费提供78张塔罗牌的正逆位牌义，方便你对照手上的牌，读懂自己的牌阵。”

This is 45 Unicode characters. The build audit enforces the 50-character limit. Price is free for the scoped website. Proposed native subscription prices were deliberately not converted into a fictitious currently available price range. The actual beta credit observation is separately attributed and dated.

## Entity placement

See entities.md and entities.csv for 109 ranked entities and four-platform status. The 78 entries on /cards each have a visible heading and a matching DefinedTerm in a 78-item list. Major and Minor Arcana have separate H2s and fragment links. Each of the four suits has an H3 under Minor Arcana. The section lists point to the same card identifiers as the full list. The hub links to this library and names the three cards in its worked example.

The directory and detail pages now use the same localized identifier for each card and spread. The spread catalogue derives its item list from the same groups and order as the visible headings. Home, About, card references, spread references and learning pages use the canonical Shenetic publisher ID. The website entity has its own ID and refers to Shenetic as publisher. Each homepage’s search action points to its actual localized search URL. The schema describes first-party relationships. The cross-platform observations remain in the entity register. [W3C node identifiers](https://www.w3.org/TR/json-ld11/#node-identifiers) · [Google organization markup](https://developers.google.com/search/docs/appearance/structured-data/organization)

The follow-up samples for questions 15 and 17 describe reading positions and combinations in general. The product page now points to a controlled comparison using ShenTarot's actual workspace. Both links preload the upright Magician, reversed Two of Pentacles and upright Eight of Pentacles in the same order. The third position changes from possible direction to a step the reader can try. The existing connected-reading guide owns the comparison, and each spread page owns its own instructions and practice tool. [Comparison](https://shentarot.com/learn/connected-reading#compare-layouts) · [Timeline exercise](https://shentarot.com/read?example=creative-timeline) · [Decision exercise](https://shentarot.com/read?example=creative)

The ChatGPT follow-up for question 19 used the Sun to illustrate joy and possible setbacks. The Sun reference now locates the historical orientation claim in Waite Part III §3, compares it with the publisher booklet and gives a repeatable drawing exercise absent from that recorded answer. The About FAQ still points to the general reversals lesson. The Sun page owns this card's source comparison and orientation controls. [Reversals lesson](https://shentarot.com/learn/reversed-cards) · [Sun example](https://shentarot.com/cards/major-19-sun#reference-evidence-2)

Shenetic is the publisher and ShenTarot the product. No Amazon/Wikipedia/Reddit sameAs relationship was asserted without identity evidence. No fake stars, reviews or independent reviewer credentials were added. FAQ schema describes visible questions; it is not a promise of a Google rich result or AI citation.

## Verification

- All eight locale JSON sets pass parity. Both Chinese leads use at most 50 characters. All 96 FAQ answers use at most 80 code points. The build audit verifies their visible and structured text, and confirms the shuffle link opens an existing section in each language.
- New production audit checks eight About pages, 96 visible/schema-matched answers, 624 card headings/schema terms, fragment uniqueness, expected destinations, canonical/alternate count, sitemap presence, dated beta evidence and Markdown parity.
- Full website tests, Astro check, build, reader/editorial, ritual, interaction, search-growth and beta audits run after implementation.
- Real Chrome at 390px: all eight About pages had twelve questions and no document horizontal overflow. English, Simplified Chinese, German and Russian also checked at 768px and 1440px. Screenshots inspected for Chinese mobile and Russian desktop.
- Keyboard activation of the Chinese question link changed to #questions and landed at the visible section after smooth scrolling. No native screen-reader review or native-speaker signoff claimed.
- Independent agent review found and resolved a contextless “not yet” paragraph, missing provenance/review disclosures, an app heading with only price information, and a physical-shuffle link to the online tool. Audit also caught and fixed a duplicate #questions ID.
- [PR #60](https://github.com/Yunlong2601/tarot-app/pull/60): all six GitHub checks passed for the submitted revision; squash merged to main as `37435f964a1d21dcfe122a4522df3f35401c42fd`.
- Cloudflare deployed from that merged revision. IndexNow accepted the sitemap submission (HTTP 200); this does not show indexing.
- [Production verification](production-verification.json) checked the exact deployed revision, all eight About and card-library routes, Markdown responses, privacy and terms at 01:17 SGT on November 8.

## Outcome follow-up

Re-run the exact saved prompts in the same surface, language and requested location after indexing, keeping all original observations. Record whether ShenTarot is named, linked, and actually supports the cited claim separately. Compare inbound Search Console/Bing data when available. Do not attribute changes to this release without supporting evidence and do not count outbound links or visits as successful beta installations.

### Celtic Cross layout intent and editorial check, November 8

The query behind the new layout FAQ comes from a reader asking why Celtic Cross readings use a different order. The layout comparison and the answer belong on `/spreads/celtic#layout-source` and the page’s existing FAQ. The About hub keeps its twelve initial questions. [Observed reader question](https://www.reddit.com/r/tarot/comments/1mr6xdx/the_best_spread_the_celtic_cross_goes_into/)

On November 8 Codex compared Waite’s Part III §7, the publisher manual’s diagram and written positions, and ShenTarot’s production labels. Waite’s roles at 3–5 map to positions 5, 3 and 4 here. His setup chooses a separate significator before ten cards are drawn. ShenTarot’s workspace takes the ten drawn cards. The upright Eight of Pentacles example uses the same card and changes the position’s role to show why the numbering matters. This is a documented editorial comparison. Independent practitioner and native-speaker reviews are pending. [Waite’s text](https://en.wikisource.org/wiki/The_Pictorial_Key_to_the_Tarot/Part_3) · [U.S. Games diagram](https://m.media-amazon.com/images/I/910OvOHFBVL.pdf#page=30) · [U.S. Games position instructions](https://m.media-amazon.com/images/I/910OvOHFBVL.pdf#page=32)

### Birthday calculation intent, November 9

Question 29 surfaced The Tarot School’s calculator in Google. ChatGPT explained that methods vary and gave no explicit text source in the captured answer. The recorded evidence does not include a complete answer transcript. The birth card tool owns the calculation query, individual birth card pages own interpretations, and the year card tool owns calculations for a chosen calendar year. This adds a comparison to the existing calculation page.

For the sample date January 4, 1988, ShenTarot adds the full year to reach 1993, then sums its digits to reach 22. The tool shows The Fool (0) and The Emperor (4). Applying The Tarot School’s published rules to the same date gives 112, then 13 and 4, which correspond to Death and The Emperor. Greer’s own writing supports the 22-to-4 convention. The comparison covers these named methods. [The Tarot School’s rules](https://tarotschool.com/BirthCards2.html) · [Greer on The Fool and The Emperor](https://marykgreer.com/2021/01/05/emperor-death-fool-birth-cards-and-daechwita/)

On November 9 the local production build displayed 0 and 4 for 1988-01-04, 19, 10 and 1 for 1987-01-02, and only 4 for 2000-01-01 in Chrome. For January 4 the 2026 result was The Lovers (6). Future and empty dates produced no result cards. The eight language routes expose the comparison in initial HTML and Markdown, and their structured citations point to the same two public references.

A fresh English Google sample with the original Singapore query on November 9 called the four-part formula standard and also described 22 as The Fool in those same steps. Its worked date reached 18 and did not test that conflict. The Tarot School’s method instead pairs positive card numbers and explicitly excludes The Fool. The expanded related results showed The Tarot School, Labyrinthos, Tarot.com and SolsTarot among the sources inspected. No ShenTarot mention or link was visible in the summary or its expanded sources. This observation predates the updated calculator. Search Console listed the English calculator as indexed and showed its last crawl as October 24 at 09:50:24. [Original query](https://www.google.com/search?q=How+do+I+calculate+my+tarot+birth+card%3F&hl=en&gl=sg&pws=0) · [The Tarot School’s rule for The Fool](https://tarotschool.com/BirthCards2.html)

In a separate Search Console observation on November 9, the English Sun reference was indexed and its last crawl was November 4 at 00:31:05 as displayed. That predates the November 8 change to its source and example. [Sun reference](https://shentarot.com/cards/major-19-sun) · [Search Console](https://search.google.com/search-console?resource_id=sc-domain%3Ashentarot.com)
