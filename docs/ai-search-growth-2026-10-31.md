# AI discovery and attribution — 31 October 2026

## Change and authorization

The owner accepted the recommendation to permit real-time AI answers while reserving model-training rights. Public robots.txt and HTML/Markdown/discovery responses now declare `ai-train=no, search=yes, ai-input=yes`. Private shared readings and proxied OAuth responses retain backend handling; no authentication, security rules, credits, tracking or native code changed.

Generated page Markdown identifies ShenTarot, publisher ShenTech, Singapore, and the original page URL. This is source metadata, not an instruction that overrides the consuming assistant. Existing HTML canonicals and visible publisher information remain. No claim is made that a crawler honors the preference, fetches on every question, attributes an answer, ranks a page, or sends referral traffic.

Cloudflare defines ai-input as real-time model input/grounding and ai-train separately: https://contentsignals.org/ . Google says ordinary crawlability, helpful content and SEO fundamentals apply to its AI search experiences; special AI files are not required: https://developers.google.com/search/docs/appearance/ai-features . Existing llms/Markdown resources are discovery conveniences, not ranking guarantees.

## Observed baseline (Chrome, 31 October Singapore)

Google Search Console Web, selected last 28 days, chart with available data 17–28 October: 95 clicks, 15,175 impressions, CTR 0.6%, average position 28.8. Page table sorted by impressions includes:

| URL path | Clicks | Impressions |
|---|---:|---:|
| /zh-hans/cards | 0 | 440 |
| /zh-hans/learn/tarot-numbers | 0 | 317 |
| /de/tools | 1 | 307 |
| /zh-hans/learn/major-and-minor-arcana | 0 | 293 |
| /es/cards/pentacles-four | 0 | 257 |

The tarot-numbers page reports average position 5.8 but its query table says No data; do not invent query intent from suppressed/missing rows. Google's Generative AI features report shows 435 impressions across 203 page rows for the same available chart dates. Impressions are not referral visits or conversions.

Bing's selected 3-month overview (31 July–30 October) shows 2 clicks and 39 impressions. Its AI Performance report, Microsoft Copilots and Partners, selected 3 months, shows 0 citations and No data available for grounding queries. These are different platforms/windows and are not directly comparable. Zero reported citations does not prove a cause or all-provider absence.

## Validation and measurement

Run website tests, localization parity, Astro check, production build and all five website audits before merge. Verify live robots.txt, HTML/Markdown response headers, source metadata and merged revision after deployment. Do not represent local code as live before that check.

After a complete reporting window, compare clicks/impressions/CTR/position by page and locale and the available AI impressions/citations. Keep consent-free existing reports; add no new analytics. A change in traffic is an observation, not causal proof of this policy change. Next editorial priority is the high-impression tarot-numbers page after confirming its actual content and obtaining usable query evidence.
