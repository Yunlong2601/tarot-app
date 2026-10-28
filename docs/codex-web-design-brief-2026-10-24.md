# Codex Web Design Brief — shentarot.com craft upgrade
**Date:** 2026-10-24 · **For:** Codex (web development agent) · **From:** WorkBuddy analyst
**Companion research:** `docs/web-design-benchmark-2026-10-24.md` (evidence, sources, and reasoning behind every decision here)
**Repo:** `shentarot-connected-practice` (branch `feat/ritual-interactions`), site root: `web/` (Astro + TS, i18n `[...lang]` routes, Cloudflare Workers via `wrangler.jsonc`)

---

## 0. The contract — how to use this document (read first)

This file is the **interface between research and implementation**. Rules:

1. **Only `DECIDED` items are instructions.** Items marked `DECIDED` are settled — implement them as written. Items marked `OPEN` require the owner's decision; if you hit one, **stop and ask**, do not guess.
2. **Acceptance criteria are the definition of done.** "Looks good" is not done. Each task lists a check that must pass, with the command or manual step.
3. **Do not add features that are not listed.** If you believe something is missing, add it to the `PROPOSED` section at the bottom and stop.
4. **Cite, don't paraphrase, the evidence.** If a decision seems wrong, open the cited source in the benchmark doc before changing it — then raise it rather than silently diverging.
5. **Preserve what is not in scope.** Specifically: i18n route structure, `worker/` deployment config, `wrangler.jsonc`, and the SEO page inventory (~3,900 generated pages) must not change as a side effect.
6. **Every task must leave the build green.** Run `npm run build` and `npm test` (in `web/`) before reporting done. If tests do not exist for what you touched, say so explicitly.
7. **Respect the existing `MotionControl.astro`.** Any new motion must be gated by the same mechanism the site already uses for reduced-motion.

**Status legend:** `DECIDED` (implement) · `OPEN` (ask owner) · `PROPOSED` (your suggestion, needs approval).

---

## 1. Performance budget — `DECIDED`

World-class bars, measured at the 75th percentile, mobile and desktop separately (web.dev Core Web Vitals, retrieved 2026-10-24):

| Metric | Budget | Where enforced |
|---|---|---|
| LCP | ≤ 2.5 s | Lighthouse CI or `npx lighthouse` on the built preview |
| INP | ≤ 200 ms | same |
| CLS | ≤ 0.1 | same |

Implementation requirements:
- All `<img>`/card art go through Astro's image pipeline (`astro:assets`) — no raw unoptimized bitmaps in `public/` for content images.
- Fonts: **self-hosted**, subset (latin + the locales we ship), `font-display: swap` **with size-adjust/metrics matched fallback** to avoid CLS, and `preload` only the one display face actually used above the fold.
- No blocking third-party scripts on first paint. Analytics/consent load deferred.
- JavaScript: ship per-page, not site-wide. If `Reader`/`CardSearch`/`TarotSearch` are currently bundled into every page, code-split them to the routes that use them.

**Acceptance:** Lighthouse mobile run on the built site reports LCP ≤ 2.5 s, CLS ≤ 0.1, INP ≤ 200 ms; report the actual numbers in your summary, not "passed".

---

## 2. Design tokens: type scale + palette — `DECIDED`

Create `web/src/styles/tokens.css` (or the project's existing token location) with:

- **Type scale:** one display face (headings), one text face (body), one mono (card names/labels if needed). Scale in `rem`, ratio ≤ 1.33 for body sizes; display sizes may go large (the category's winners use oversized display type — Co-Star's lesson is restraint in *assets*, not in *type*).
- **Palette, dark-first** (dark is the category's native habitat — three independent sources converge on this; see benchmark §2): background near-black but **not pure #000** (use e.g. #0B0B0F-class value so elevation shadows read), one warm off-white for body text, **one** accent. All text/background pairs must pass **WCAG 2.2 AA: 4.5:1 normal text, 3:1 large text** (W3C SC 1.4.3). Verify every pair with a contrast check before committing; paste the computed ratios in the PR/commit summary.
- **Spacing scale:** 4px base; 8px grid.
- Motion tokens: durations 150/250/400 ms, one easing curve, defined once in CSS custom properties.

**Acceptance:** a contrast table (foreground/background/ratio/pass) in the commit message; tokens referenced by at least the landing page; no hard-coded hex outside `tokens.css` in the files you touch.

---

## 3. Motion policy — `DECIDED`

- Motion must be **purposeful**: it explains the product (scan → identify → reflect) or guides attention. No ambient decoration loops on marketing pages.
- Scroll-linked animation only in the landing page's story sections, and only transform/opacity (never layout properties).
- Every animated element is gated by the existing reduced-motion mechanism (`MotionControl.astro` / `prefers-reduced-motion`).
- No autoplay audio, no scroll-jacking, no parallax on text.
- Card-reveal interaction (CSS 3D flip) is allowed **only** on the interactive reading components, and must respect reduced-motion by cross-fading instead of flipping.

**Acceptance:** with OS "reduce motion" on, no animation runs and nothing is hidden or unreachable; keyboard-only navigation reaches every interactive element; Lighthouse CLS ≤ 0.1.

---

## 4. Landing-page narrative order — `DECIDED` (structure), `OPEN` (final copy)

Section order (mirrors the app's real flow; copy itself is `OPEN` pending the store-listing audit decisions):
1. Hero: what ShenTarot is in one line + the scan value proposition + store buttons (`StoreButtons.astro`).
2. How it works: **scan your card → confirm the card → get a reflection** — three steps, illustrated with the actual UI, not abstract art.
3. The privacy/no-account differentiator (only the claims verified on-device — see benchmark doc and store-listing audit; **do not claim camera recognition accuracy**).
4. Proof/credibility section.
5. Install CTA.

**Acceptance:** the words "scan", "confirm", "reflect" (or agreed synonyms) appear in order in the DOM; store buttons present and functional; no capability claim that is not in the approved copy list.

---

## 5. Per-locale metadata quality — `DECIDED`

For every locale route: unique `<title>`, meta description, canonical, `hreflang` pairings, Open Graph + Twitter card image. **[FACT]** Semantics/SEO and Markup/Meta-data are two of the six axes of the Awwwards Developer Award — and they are pure SEO wins for us.

**Acceptance:** `astro check` clean; spot-check 3 locales (en + 2 others) for unique titles/descriptions; OG image renders (paste one screenshot).

---

## 6. Explicitly out of scope for now — `DECIDED`

- **No WebGL/Three.js on marketing pages.** The 2026 Awwwards field is 61% immersive-3D (single-source stat — direction corroborated, magnitude not), but those are brand experiences with bespoke budgets; our site must hit p75 CWV on mid-range phones. Revisit only after tasks 1–5 pass and only as an A/B test.
- No redesign of the ~3,900 SEO pages beyond token adoption (they inherit the new tokens automatically — that is the point).
- No changes to `worker/`, `wrangler.jsonc`, i18n route patterns, or deployment process.

---

## 7. Verification gates (run all, report results)

```
cd web
npm run build          # must pass
npm test               # must pass (report if no tests cover your change)
npx astro check        # must pass
npx lighthouse http://localhost:4321 --preset=mobile --only-categories=performance,accessibility,best-practices
```
Plus manual: reduced-motion on → no animation; keyboard tab-through → visible focus, logical order; 360px viewport → no horizontal scroll.

---

## 8. What Codex should push back on

If any instruction here conflicts with the codebase reality (e.g. a file named here doesn't exist, or the site uses a different token system), **stop and report the conflict** — do not improvise a new pattern. Likewise, if a performance target is unreachable on the current stack, report the measured numbers rather than deleting the requirement.

## PROPOSED (for owner review — not instructions)
_(Codex: append suggestions here, do not implement.)_
