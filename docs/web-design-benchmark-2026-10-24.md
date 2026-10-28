# Web Design Benchmark — shentarot.com vs. World-Class UI/UX
**Date:** 2026-10-24 · **Author:** WorkBuddy (analyst) · **Scope:** website (shentarot.com) only — app UI is out of scope for this doc
**Site audited:** `shentarot-connected-practice/web/` — Astro 5 + TypeScript, i18n routes (`[...lang]`), deployed to Cloudflare Workers; components include `Reader`, `CardSearch`, `TarotSearch`, `ResumeWorkspace`, `MotionControl` (reduced-motion control already exists).

## How to read this document (labelling convention — applies to every analyst doc)

Every claim carries one of three labels. This is the validity contract:

- **[FACT]** — sourced, dated, verifiable via the URL in References. If two sources disagree, both numbers appear.
- **[ANALYSIS]** — my inference from facts. Reasonable people could disagree; the reasoning is shown so it can be challenged.
- **[RECOMMENDATION]** — what to do. Never presented as fact.

**Research validity protocol** (how I keep this honest):
1. **Source hierarchy.** Platform rulebooks (Awwwards, Apple, W3C, web.dev) outrank vendor marketing, which outranks blogs. Blog/aggregator claims are used only for leads, then verified against the primary.
2. **Date-stamping.** Every fact carries the retrieval date (2026-10-24). Rankings and stats age fast.
3. **Triangulation.** A claim needs ≥2 independent sources or it is flagged SINGLE-SOURCE. Single-source numbers are leads, not foundations.
4. **Conflict disclosure.** Where sources disagree (they do — see stack-share numbers below), both values are reported; never averaged silently.
5. **No fabrication.** Missing data is written as "not found", never estimated and presented as measured.
6. **Separation of concerns.** Vendor "benchmark" percentages are always labelled estimates with their disagreement shown.

---

## 1. What the world's UI/UX rankings actually measure

### Awwwards (the reference ranking)
**[FACT]** Judging criteria and weights (awwwards.com/about-evaluation, retrieved 2026-10-24):
- Design **40%**, Usability **30%**, Creativity **20%**, Content **10%**
- Honorable Mention threshold: jury score **≥ 6.5**; Site of the Day requires top jury scores; Developer Award requires **> 7** from the developer jury
- Process: manual approval → minimum **18 jury members** vote, 3 outlier scores dropped → 5-day voting; Site of the Month = 8 highest-scoring sites per month; Site of the Year announced in **February** of the following year
- **[FACT]** The Developer Award is scored on six axes, observed live on a SOTD page (Into the Amazon, 7.4/10, SOTD 2025-04-21): **Semantics/SEO, Animations/Transitions, Accessibility, WPO (web performance optimization), Responsive Design, Markup/Meta-data**

**Reading for us:** the axes that carry weight are *craft* axes, not "impressiveness" axes. Accessibility and performance are jury-scored at the world's most-watched design award. **[ANALYSIS]** A marketing site can adopt the entire developer-axis checklist (semantics, a11y, WPO, responsive, metadata) without adopting the 3D showmanship — that is where award-level craft is free for us.

### CSS Design Awards
**[FACT]** Awards a Website of the Day; judges score **UI Design, UX Design, Innovation** each out of 10, averaged to a judge's score (observed example: Arc Marumo, WOTD 2026-10-22, 8.18). Also grants "Special Kudos" for categories such as Best UI/UX/Innovation (per project write-ups citing the platform).

### Other ranking/inspiration platforms
- **Land-book** (land-book.com): curated landing pages by category (Landing Page, Ecommerce, Portfolio, Template). Useful for *layout and conversion* patterns rather than awards.
- **Godly.website**: as of 2026-10-24 the domain now redirects to **recent.design** — a general design feed. **[FACT]** The old curated-godly list is no longer at that URL; do not brief Codex from stale bookmarks to it.
- **Dribbble / Behance / Mobbin**: screen-flow references (Mobbin specifically for real app screen flows of named products).

### What winners are actually built with (treat as snapshot, not law)
- **[FACT, SINGLE-SOURCE]** exhibita.design stack snapshot (August 2026, 31 winning sites): GSAP **16/31**, Animation 15, WebGL **13/31**, 3D 10, Scrolling 9, Transitions 8, Storytelling 7, UI design 7, Webflow 7. Notably **Three.js only 7** — more winners carry a WebGL tag than name Three.js, meaning much winning work is hand-written. The same page notes the long-run GSAP share is **17%** vs **52%** in the current snapshot — both numbers are correct for different windows. This is exactly why snapshot stats must be dated.
- **[FACT, SINGLE-SOURCE]** digitalstrategyforce.com analysis: immersive 3D was **61% of Q1 2026 SOTD winners**, up from 23% in Q1 2024; 29 of 47 Q1 2026 winners used Three.js. It is a single analysis site — the *direction* (motion-rich work dominating awards) is corroborated by the stack snapshot and the winner list; the exact percentages are not independently verified.
- **[FACT]** Site of the Year 2025: **landonorris.com** (OFF+BRAND), SOTD score 8.18 — corroborated by two independent write-ups (Awwwards annual page and a note.com analysis).

---

## 2. The niche reality: tarot/spiritual web design is a weak field

**[FACT]** Observed live sites in the tarot/astrology content category (retrieved 2026-10-24):
- **themystica.com** — online since 2001, free content, functional but dated information architecture
- **1001horoscopes.com** — 1.5M+ users since 2023 (their own claim), NASA JPL DE440 ephemerides, an exclusive animated tarot deck, 62K+ interpretations; modern-ish but content-site, not product-site
- **themysticdraw.com** — free daily draws, no signup; competent, template-grade visual identity
- **App-side aesthetic benchmarks** (secondary sources, consistent across three): **Co-Star** — deliberately monochrome black/white, one sans-serif, NASA data, ~30M registered users; **The Pattern** — typography-led, plain-language; **A(i)strology** (Wix Studio) — Awwwards Honorable Mention, dark immersive, mouse parallax, nebula scroll (SINGLE-SOURCE, practitioner article)

**[ANALYSIS]** Three conclusions:
1. **The category's visual bar is low.** No tarot/spiritual product site currently holds a sustained Awwwards presence. Craft alone would make shentarot.com visibly best-in-category.
2. **Dark UI is the category's native habitat** — three independent sources (practitioner build log, Co-Star's identity analysis, category reviews) converge on dark/cosmic as the mood that works; purple-and-gold clichés are what reviewers mock as "WordPress 2008".
3. **Restraint beats decoration in this niche.** Co-Star — the category's design icon — wins with almost no imagery. The differentiator available to us is typography, motion discipline, and performance, not a bigger WebGL budget.

### How to find references without drowning in templates
**[ANALYSIS, from a practitioner build log — method, not fact]** Searching "tarot website design" returns templates. Decompose the site's *essence* first (for ShenTarot: input = your physical card, dramatic reveal, personal interpretation), then search on three axes: **mood** ("dark mystical", "cosmic"), **interaction** ("card flip", "result reveal", "quiz onboarding"), **adjacent industry** ("personality test", "meditation", "wellness diagnostic"). Then filter platforms by tag, not category (Awwwards tag filters; Dribbble color filters; Mobbin by app name).

---

## 3. The measurable quality bars (these are the real "best in the world" tests)

These are checkable, tool-measured, and jury-scored at Awwwards. **[FACT]**

| Bar | Threshold | Source | Tool |
|---|---|---|---|
| LCP (loading) | ≤ **2.5 s** at 75th percentile, mobile measured separately | web.dev/articles/vitals (2026-10-24) | Lighthouse, CrUX |
| INP (interactivity) | ≤ **200 ms** at p75 | same | Lighthouse, CrUX |
| CLS (visual stability) | ≤ **0.1** at p75 | same | Lighthouse, CrUX |
| Text contrast | ≥ **4.5:1** normal text; ≥ **3:1** large text (≥18pt / 14pt bold ≈ 24px / 18.5px) | W3C WCAG 2.2 SC 1.4.3 | axe, Lighthouse |
| Reduced motion | honoured (site already ships `MotionControl.astro`) | WCAG | manual check |
| Semantics/metadata | valid HTML, descriptive titles/meta per locale | Awwwards developer axis | astro check, manual |

**[FACT]** INP replaced FID; FID was deprecated in 2024 when INP became a stable Core Web Vital. Any older brief referencing FID is stale.

**[ANALYSIS]** A page "passes" Core Web Vitals only if **all three** metrics pass at p75 — so a beautiful hero that shifts layout (CLS) or blocks interaction (INP) fails the whole assessment even with a fast LCP. This is why the motion policy below is strict.

---

## 4. Honest scoping: what "best in the world" should mean for shentarot.com

**[ANALYSIS]** Shentarot.com is not a portfolio. It is a multilingual product/marketing site with ~3,900 generated pages (SEO content) plus interactive reading components, deployed on Cloudflare Workers. Chasing SOTY-grade 3D on this surface would be actively harmful: 61%-immersive award sites are brand experiences with bespoke budgets; our site must load fast on mid-range phones, rank in search, and convert visitors into app installs.

**[RECOMMENDATION]** Target: **award-level craft, conversion-first priorities.** Concretely:
1. Adopt the full Awwwards developer-axis checklist (semantics, a11y, WPO, responsive, metadata) as *acceptance criteria* for every change.
2. Motion: restrained, purposeful, scroll-linked only where it explains the product (the card-scan flow *is* the story — animate that, not the background).
3. Typography-led identity, dark-first with a proper contrast-tested palette (the Co-Star lesson: fewer assets, stronger type).
4. Hard performance budget enforced in CI (below), because p75 CWV is the one "world-class" metric that is objectively measured and publicly reported via CrUX.
5. Do **not** ship WebGL/Three.js on marketing pages in v1. If a signature interactive moment is wanted later, gate it behind the existing reduced-motion control and a connection/device check, and A/B it — never on the critical rendering path.

---

## 5. Gap list for Codex (detail and acceptance criteria in the handoff brief)

**[ANALYSIS]** Ordered by impact ÷ effort:
1. **Performance budget in CI** — nothing else on this list survives contact with a heavy asset.
2. **Type scale + palette as design tokens** with contrast-tested values (removes the whole class of 4.5:1 failures).
3. **Motion policy** — durations, easing, scroll-trigger only above-the-fold story sections, all gated by `MotionControl`.
4. **Landing-page narrative order** — scan → reveal → reflect → install, mirroring the app's actual flow.
5. **Per-locale metadata quality** (titles, descriptions, OG/Twitter, canonical) — a jury axis *and* an SEO win.
6. **Signature moment candidate** (card-flip reveal as CSS 3D, not WebGL) — deferred until 1–5 pass.

**Companion file:** `docs/codex-web-design-brief-2026-10-24.md` — the implementation contract for Codex.

## References
- [Awwwards — Evaluation System](https://www.awwwards.com/about-evaluation)
- [Awwwards — Into the Amazon (SOTD page showing developer axes and jury scores)](https://www.awwwards.com/sites/into-the-amazon)
- [Awwwards — Annual Awards / Hall of Fame](https://www.awwwards.com/annual-awards/hall-of-fame/2024)
- [Awwwards — homepage nominees board](https://www.awwwards.com/)
- [CSS Design Awards — homepage (WOTD, UI/UX/Innovation scoring)](https://www.cssdesignawards.com/)
- [Land-book — design inspiration gallery](https://land-book.com/)
- [Core Web Vitals — web.dev](https://web.dev/articles/vitals)
- [WCAG 2.2 — Understanding Contrast (Minimum), SC 1.4.3](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html)
- [Exhibita — What They're Built With (stack snapshot, Aug 2026)](https://exhibita.design/stack.html)
- [Digital Strategy Force — Why immersive experiences dominate 2026 Awwwards](https://digitalstrategyforce.com/journal/why-are-immersive-experiences-dominating-the-2026-awwwards/)
- [Lando Norris SOTY 2025 analysis (note.com)](https://note.com/good_tern3684/n/n0924f148495a?hl=en-US)
- [Award-winning websites 2025–2030 reference (GitHub — aggregator, verify against Awwwards)](https://github.com/coroboros/research/blob/main/articles/award-winning-websites-2025-2030/award-winning-websites-2025-2030.md)
- [Why Googling 'Fortune Telling App Design' Almost Ruined My Product (dev.to — practitioner build log)](https://dev.to/ji_ai/why-googling-your-category-kills-your-design-and-how-i-built-a-cosmic-3d-background-with-threejs-32hk)
- [Co-Star app review 2026 (auraeastrology.com)](https://www.auraeastrology.com/blog/co-star-app-review-2026-an-astrologers-opinion)
- [Best astrology apps & sites 2026 (taroscoper.com)](https://www.taroscoper.com/guides/best-astrology-apps-and-sites-compared)
- [15 best astrology app UI/UX designs (makeanapplike.com)](http://makeanapplike.com/article/mobile-apps/best-astrology-app-ui-ux-designs)
- [The Mystica](https://themystica.com/astrology) · [1001 Horoscopes](https://www.1001horoscopes.com/) · [The Mystic Draw](https://themysticdraw.com/)
