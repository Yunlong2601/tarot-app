# ShenTarot: five-page search-growth implementation

Audit captured 26 October 2026 (Singapore); local implementation verified 27 October. **No deployment, indexing submission, tracking addition, security-rule edit or crawler-permission change.** Existing interaction work on this branch is preserved; app/backend untouched.

## What changed

| Existing URL | Original content and discovery improvement |
|---|---|
| `/zh-hans/cards` | Clearer title/description and introduction; static reference guide with suit anchors and contextual links, including reversed-card learning. The 78 real card links remain in initial HTML. |
| `/cards/pentacles-ace/love` | Single/relationship/outcome distinctions, reversed cautions and an original three-card worked example; explicit link to the separate feelings page and own-card workspace. |
| `/tools/random-card` | Clear generator title and instructions for free/named spread draws, shuffle/pick/reveal, crypto randomness, fixed orientation probability, keyboard/Skip/motion alternatives and reference-only availability. |
| `/zh-hans/learn/major-and-minor-arcana` | Standardised terminology within this lesson, comparison table, public-domain card illustration and position-based original example. Replaced deterministic claims about ratios with interpretation conventions. FAQ changes flow into existing schema from the same source. |
| `/cards/major-20-judgement` | Card number 20 in the title and visible answer, upright/reversed summary, symbolism reasoning and original position/connected-card examples outside the enhanced tabs. |

The shared `SearchGrowthNotes` component renders only at these five route/locale combinations. It adds no client JavaScript. Existing routes, canonicals, language alternatives and honest AI labels stay intact. A real anchor issue found during validation was corrected: spread `#try` targets now have an ID in the initial HTML, not only after tab enhancement.

## Actual baseline and its limits

Source: authenticated Search Console UI, three-month selection; chart activity **17–24 October 2026**, eight days. [Full captured baseline](./search-baseline.json) includes the disclosed query, country/device and AI tables, plus source URLs. No modelled search volume is substituted for observed data.

| Page | Clicks | Impressions | CTR | Avg. position | Google AI report |
|---|---:|---:|---:|---:|---|
| Chinese card library | 0 | 155 | 0% | 7.6 | Not listed in 96 rows |
| Ace of Pentacles love | 0 | 128 | 0% | 10.7 | Not listed |
| Random generator | 2 | 116 | 1.7% | 26.7 | Not listed |
| Chinese Arcana lesson | 0 | 70 | 0% | 7.5 | Not listed |
| Judgement | 0 | 42 | 0% | 20.5 | 12 impressions |

Sitewide Google: 25 clicks, 4.93k impressions, 0.5% CTR, position 33.5; Google AI: 141 impressions across 96 listed URLs. Bing's selected three-month report: 8 impressions, no clicks; Microsoft Copilot/partners AI report: no citations. These report-specific measures are not visits or completed readings.

**Dimension tables do not reconcile to headline totals.** For example, the library discloses six query/device impressions against 155 headline impressions; the Arcana lesson discloses no rows against 70 headline impressions. Preserve both observations. Do not describe the displayed countries/devices as the complete audience mix, assign suppressed queries, or infer zero demand from an empty table. Unlisted AI URLs are not proof of zero AI exposure. Random-generator disclosed queries include `tarot card shuffle` (19 impressions) and `tarot shuffle` (11); Judgement includes `20 tarot card` (10). Those observations informed useful copy, not repetitive keyword insertion.

## Indexing exclusions reviewed

Google report updated 23 October: 3,379 indexed; 1,850 excluded. [Ten report examples per category](./exclusion-samples.json) and [four live target inspections](./production-samples.json) are retained.

| Category | Report count | Representative inspection and action |
|---|---:|---|
| Proper canonical alternative | 720 | `cards/cups-two?orientation=reversed` keeps the selected reversed view and declares the clean card URL canonical. Valid consolidation retained. |
| Redirect | 428 | HTTP Russian workspace card URL reaches the HTTPS workspace and shows the selected Eight of Swords. The client then removes consumed card parameters (`workspace.ts`), so the final address alone does not prove query loss or a server redirect chain. No redirect rewritten. |
| Discovered, not indexed | 521 | Queen of Cups feelings is loadable, self-canonical and has no robots exclusion in the inspected DOM. No technical blocker established; no forced-indexing or mass-content change. Strengthened relevant Chinese library links to feelings/reversed learning without changing URLs. |
| Crawled, not indexed | 181 | Chinese Eight of Swords is loadable, self-canonical and has no robots exclusion in the inspected DOM. Existing library links expose it in static HTML. This sample does not establish why Google omitted it. |

These are representative checks, not a complete 702-URL diagnosis. The prior fresh Google live test of Ace of Pentacles love succeeded; the indexed inspection reported successful Googlebot smartphone fetch and matching canonical. Do not equate a local eligibility pass with guaranteed indexing. No evidence justified overriding a canonical or removing a redirect.

## Cloudflare: search access remains separate from training

After owner sign-in, inspected AI Crawl Control metrics/security and Security Analytics Events read-only. [All-crawler metrics](./cloudflare-all-crawlers.txt), [OAI search metrics](./cloudflare-oai-searchbot.txt), and [verified AI-search event result](./cloudflare-verified-ai-search-events.txt).

- Selected last seven days: OAI-SearchBot 979 requests; 967 HTTP 200, 11 HTTP 404, one HTTP 405. Its Block Crawler switch was off. These are Cloudflare-classified crawler observations, not trust in a manually supplied user-agent string.
- All-crawler metrics displayed roughly 23k allowed requests and 64 unsuccessful responses, including two 403s. The OAI-filtered view contained no 403. Do not attribute those two aggregate 403s to OAI.
- Last-24-hour Events filtered to **Verified Bot Category = AI Search** returned no matching firewall events. Sampling/window limits apply; this does not establish absence of older events or all search-engine categories.
- Unfiltered sampled events included browser-integrity blocks at the time of the earlier command-line check. Timing alone is not a verified attribution of those requests. No raw visitor IPs were saved to this report.
- Search access and training permissions were not changed. In particular, successful OAI-SearchBot retrieval does not require enabling GPTBot training. No blanket security bypass was warranted.

## Validation

- 26 existing tests pass. Astro check: 119 files, zero errors/warnings and two existing birth-card hints. Eight-locale validation passes.
- Production build: 3,910 pages. Reader audit: 160 pages; ritual audit: 352 pages; interaction audit: eight indexes / 808 result routes.
- `npm run check:search-growth-build` verifies exactly five enriched initial-HTML routes, canonical and exact reciprocal locale alternatives, sitemap membership, local links/artwork/anchors and FAQ text/schema parity. It deliberately does not claim search-engine indexing or rich-result eligibility.
- [Runtime checks](./runtime.json): five pages at desktop 1280px and compact 390px; expected editorial blocks and canonicals, no document horizontal overflow, no broken loaded images. No physical-phone or full accessibility-conformance claim.
- [English editorial screenshot](./love-desktop.png) and [Chinese illustrated lesson](./arcana-desktop.png) were visually inspected.

## Measurement follow-up — pending, not a traffic-lift claim

The local implementation and baseline capture are complete; the **future 28-day comparison is not**. There has been no release of these changes and no 28-day post-change observation. See [measurement procedure](./measurement.md). Completed-reading conversions and ChatGPT/Perplexity referrals remain unverified. No tracking was introduced to fill those gaps.

### Requirement completion audit

| Requirement | Current evidence / status |
|---|---|
| Representative exclusions; preserve valid consolidations | Four category samples and live inspections recorded above; no established canonical/robots defect in these samples. Kept valid alternatives and existing redirects; strengthened relevant static links. Does not assert all excluded pages are fixed. |
| Read Cloudflare evidence before any rule change | AI metrics/security and verified-AI-search event window inspected; no permissions or rules changed. Other verified-bot categories/older windows remain outside that sample. |
| Improve the five URLs; static answers/links; truthful AI | Five route-scoped original blocks, checked in generated HTML and runtime; existing unavailability labels retained. |
| Editorial attribution and consistent structured data | Visible original-example attribution and methodology links; generated FAQ question/answer parity audit passes. |
| Dated metrics/query/country/device/AI baseline | Captured JSON contains all five pages, disclosed dimension tables and AI rows; missing/suppressed data explicitly distinguished from zero. |
| Metadata, eligibility, rendering, locales/build | Five-route audit, runtime JSON, locale checks, Astro/build/tests and existing audits pass. Production Google eligibility was sampled separately; local changes are not indexed yet. |
| Next complete 28-day comparison | **Pending future separately authorised release and elapsed reporting window.** Procedure supplied; no fabricated results or traffic-lift claim. |
| No release/submissions/tracking/crawler changes | None performed. Browser inspection filters changed only the report views. |

The full ongoing goal remains incomplete solely for the future observation/comparison. Implementation should be reviewed locally before any separately authorised release; there is no automatic deployment or scheduled follow-up.
