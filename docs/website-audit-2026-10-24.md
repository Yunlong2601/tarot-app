# Strict Website Audit — shentarot.com (code + live site)
**Date:** 2026-10-24 · **Auditor:** WorkBuddy (analyst) · **Method:** source review (`shentarot-connected-practice/web/`), live-site fetch, `npm test` (18/18 pass), `astro check` (0 errors, 0 warnings, 2 hints)
**Bars used:** the benchmark in `web-design-benchmark-2026-10-24.md` — CWV LCP ≤2.5s / INP ≤200ms / CLS ≤0.1 at p75 mobile; WCAG 2.2 AA 4.5:1; Awwwards developer axes (semantics, a11y, WPO, responsive, metadata).

**Label convention:** [FACT] sourced/measured · [ANALYSIS] my inference · [RECOMMENDATION] what to do · [UNMEASURED] could not verify here.

---

## Verdict

**[ANALYSIS]** This is a genuinely well-engineered site — materially better than the benchmark expected. The content strategy is honest (the live homepage explicitly states "These are reference meanings and practice prompts, not an AI reading" and "The companion app is upcoming"), the accessibility and metadata work is at award-developer-axis level, and the motion system is exemplary. **The one real weakness is asset weight** — the image pipeline is the only place where the site is clearly below a world-class bar. Everything else is polish.

Scorecard:

| Bar | Status | Evidence |
|---|---|---|
| Semantics / metadata | **Exemplary** | [FACT] canonical, per-locale hreflang + x-default, OG/Twitter, JSON-LD BreadcrumbList, skip link, `<html lang>` per locale (`src/layouts/Base.astro:79-98`) |
| Accessibility | **Strong** | [FACT] skip link, focus-visible outlines, 44px min tap targets, `prefers-reduced-motion` kill-switch, `aria-current`, dialog labelling (`Base.astro:102-132`, `ritual.css:12-13,238,277`) |
| Motion discipline | **Exemplary** | [FACT] scroll-linked reveal gated behind `@supports (animation-timeline:view())` + full reduced-motion override; no scroll-jacking (`ritual.css:270-277`) |
| Responsive | **Strong** | [FACT] fluid `clamp()` type, 900px/650px breakpoints, mobile dialog nav (`ritual.css:179-247`) |
| Type / palette system | **Strong** | [FACT] single token set, Cormorant Garamond + Inter Variable self-hosted with latin+cyrillic subsets, local token inversion for dark sections (`site.css:1-13`, `ritual.css:51-54`) |
| **WPO (performance)** | **Below bar** | [FACT] see Finding 1 — ~100 KB per card image, no modern formats, no asset cache headers |
| CWV (live) | **[UNMEASURED]** | No Lighthouse run available in this environment. Command provided in Finding 1. |
| Test/type discipline | **Strong** | [FACT] 18/18 tests pass; `astro check` clean |

---

## Findings (ordered by severity)

### 1. P1 — Card art is ~3× heavier than it needs to be
**[FACT]** `public/cards/art/` holds 78 JPGs totalling **6.3 MB**; individual files are **95–105 KB** at only **357×600 px** (measured: `major_00_fool.jpg` 357×600/95 KB-class). A 357×600 JPEG at quality 80 should be roughly 30–45 KB. Homepage hero loads two of these (`src/pages/[...lang]/index.astro:40-41`, one with `fetchpriority="high"` — correctly prioritised), and every card page loads one.
**[FACT]** `sharp@0.35.5` is already a devDependency **and already proven in this repo** — `scripts/og-cards.mjs` uses it to generate 1200×630 OG images. The art pipeline (`scripts/copy-art.mjs`) does a raw `copyFileSync` with no transcoding.
**[FACT]** No `<picture>`/WebP/AVIF anywhere; `<img>` tags carry fixed `width="300" height="514"` (good for CLS) but no `srcset`/`sizes` (30 `<img>` in src, lazy-loading present on galleries — good).
**[ANALYSIS]** A WebP pass at quality ~78 on the same 357×600 art typically lands 35–50 KB — a **50–60% byte cut with no visible difference at display size** (max display is 300 px wide). On the card pages this directly targets LCP; across 78 pages × the homepage it is the single largest performance lever available. Dimension over-serving is *not* the issue (357 px source for a 300 px slot is nearly correct) — **encoding weight is**.
**[RECOMMENDATION]** Extend the existing prebuild pipeline (not a new tool): in `copy-art.mjs`, after copying, run each JPG through sharp → resize to 2× max display (600×1014 cap) → emit `.webp` (q78) alongside, and switch `<img>` to `<picture>` with the JPG as fallback. Estimated saving: ~3–4 MB off the deployed asset set, ~50% off every card-page image.

### 2. P1 — No cache headers for static assets
**[FACT]** `public/_headers` contains rules only for `/.well-known/*` files. No `Cache-Control` for `/cards/art/*`, `/og/*`, fonts, or `_astro/*`.
**[ANALYSIS]** Cloudflare's defaults help, but card art and fonts are immutable-by-content — they should be `public, max-age=31536000, immutable`. Repeat visitors (the daily-card ritual is designed for return traffic) re-validate or re-fetch art that will never change.
**[RECOMMENDATION]** Add to `_headers`: `  Cache-Control: public, max-age=31536000, immutable` for `/cards/art/*`, `/og/*`, `/_astro/*`.

### 3. P2 — Two competing design systems; dead CSS is a live risk
**[FACT]** `site.css:57` defines a **dark translucent header** (`rgba(9,8,15,.72)`) with `.site-nav` rules; the actual markup uses `.desktop-nav` (`Base.astro:106`), and `ritual.css:22` overrides the header to light cream (`rgba(244,240,231,.97)`). The dark-header rules and `.site-nav` block are **dead code** — currently harmless because ritual.css wins the cascade, but they are a trap: the next person to edit header styling may edit the dead rule and see nothing change, or remove ritual.css and ship an invisible near-black brand on a dark header (`--fg:#17171b` on `rgba(9,8,15,.72)` would fail contrast catastrophically).
**[FACT]** Token vocabulary is duplicated: `site.css` (`--bg/--fg/--gold…`) and `ritual.css` (`--forest/--ink/--paper/--accent…`) describe the same palette with different names.
**[RECOMMENDATION]** Delete the dead `.site-header` dark rule and `.site-nav` block from site.css; merge ritual's four tokens into the site.css token set (aliases kept during migration). This is hygiene, not urgency — but it is the kind of thing that causes a future contrast regression.

### 4. P2 — `og.png` is 423 KB
**[FACT]** `public/og.png` = 422,960 bytes, the default share image for every page that doesn't override it.
**[ANALYSIS]** A 423 KB PNG preview image is heavy for WhatsApp/X/link-unfurler budgets; a quality-85 JPEG re-encode is typically ~80–120 KB. OG scrapers broadly support JPEG.
**[RECOMMENDATION]** Re-encode via the same sharp pipeline (or add an og.png step to og-cards.mjs). Low effort, keeps sharing fast.

### 4b. P2 — `llms.txt` / `llms-full.txt` served without charset (verified 2026-10-24)
**[FACT]** Live `https://shentarot.com/llms.txt` responds `content-type: text/plain` with **no charset parameter**. The file itself is correct — `dist/llms.txt` is valid UTF-8 (`file` reports "Unicode text, UTF-8") and contains `简体中文` correctly. But a consumer that decodes text/plain as Latin-1 (Python `requests` defaults to ISO-8859-1 for text/* without charset — and many AI ingestion pipelines are Python-based) renders the locale names as mojibake: observed live as `ç®€ä½ä¸­æ–¶` instead of `简体中文`.
**[ANALYSIS]** This is a direct hit on the file's entire purpose: llms.txt exists so AI engines read your site accurately. A mangled entity/header block is exactly the part an LLM would quote back.
**[RECOMMENDATION]** Add to `public/_headers`:
```
/llms.txt
  Content-Type: text/plain; charset=utf-8
/llms-full.txt
  Content-Type: text/plain; charset=utf-8
```
One-line fix, zero risk. Verify with `curl -sI https://shentarot.com/llms.txt`.

### 5. P3 — Minor
- **[FACT]** `astro check` reports 2 hints (a template-string type nit at `TarotSearch.astro:56`-ish). Cosmetic; fix in passing.
- **[ANALYSIS]** The `.hero-divider` uses `font-size:.54rem` at the smallest breakpoint (`ritual.css:211`) — ~8.7px effective. Not a WCAG failure (no minimum size in AA) but below comfort; worth raising to .6rem.
- **[UNMEASURED]** Live CWV. Run: `npx lighthouse https://shentarot.com --preset=mobile` (and again post-Fix-1). CrUX data via PageSpeed Insights once the site has traffic.

---

## Where the site contradicts my own benchmark — and the site is right

**[ANALYSIS]** My benchmark recommended **dark-first** (the category's "native habitat"). The site ships a **light editorial** system: paper `#f4f0e7`, ink `#17171b`, forest `#243c35`, gold `#b69a60`, Cormorant Garamond display. I am revising the recommendation: every competitor in this niche runs dark-cosmic (the dev.to build log confirms the cliché: "red backgrounds with gold text… layouts that haven't been updated since 2008"). A **paper-and-ink editorial** tarot site is *rarer* than a dark one, matches the "quiet ritual / reference meanings, not fortune-telling" positioning already in the copy, and the dark sections (`.ink-section`, footer, cta-band) provide contrast rhythm without committing the whole page to dark. **Keep the light direction.** My earlier recommendation was pattern-matching to the category, not to this product.

---

## What to hand Codex (in priority order)

1. Sharp WebP/AVIF art pipeline in `copy-art.mjs` + `<picture>` swap (Finding 1) — biggest lever.
2. `_headers` immutable caching (Finding 2) — one-line fix.
3. `og.png` re-encode (Finding 4).
4. Dead-CSS/token cleanup (Finding 3) — after 1–3, so it doesn't churn.
5. Lighthouse before/after numbers reported in the commit (my benchmark's acceptance-criteria convention).

**Explicitly not problems:** the honest "no AI on the website" copy, the hreflang/i18n implementation, the reduced-motion architecture, the test suite. Do not let a redesign brief touch those.

## References
- Audit targets: `web/src/layouts/Base.astro`, `web/src/styles/site.css`, `web/src/styles/ritual.css`, `web/src/pages/[...lang]/index.astro`, `web/scripts/copy-art.mjs`, `web/scripts/og-cards.mjs`, `web/public/_headers`, `web/public/cards/art/*` (measured 2026-10-24)
- [Core Web Vitals thresholds — web.dev](https://web.dev/articles/vitals)
- [WCAG 2.2 SC 1.4.3 Contrast (Minimum) — W3C](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html)
- [Awwwards — Evaluation System](https://www.awwwards.com/about-evaluation)
- [Live site — shentarot.com](https://shentarot.com)
