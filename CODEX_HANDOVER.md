# Codex handover — ShenTarot website

Branch: `feat/website-enhance-20261102` (based on `origin/main`, 2026-11-02).
Scope: Tier 0 internal-linking and disclosure work on `web/`. No data, backend or app changes.

Read `AGENTS.md` and `web/README.md` first. Nothing here overrides them.

---

## 1. Read this before you start: a headline finding was wrong

An audit earlier on 2026-11-02 concluded that `/read` ignores `?card=`, `?spread=` and
`?orientation=`, and specified a handler as the top engineering ticket (~714 links).

**That is false. The handler already ships and works.** Verified by loading the live site
in a browser, four cases, fresh context each time:

| Loaded | Slot 1 shows |
|---|---|
| `/read` (control) | nothing placed — `0 / 3 cards entered` |
| `/read?card=major_00_fool` | **The Fool (Upright)** |
| `/read?card=major_00_fool&orientation=reversed` | **The Fool (Reversed)** |
| `/read?spread=three_decision&card=major_08_strength` | spread switched **and** Strength placed upright |

The URL is cleaned with `history.replaceState`. `?example=` is handled as well.

**Do not build a param handler. Do not "fix" these links.**

Why it was misdiagnosed: the conclusion came from MD5 byte-identity of server HTML and from
JS bundle inspection. Both are evidence about *code*, not *behaviour* — and byte-identical
HTML is exactly what a client-side handler produces. The behavioural test takes ninety
seconds and was never run.

**Working rule for this repo:** a finding that justifies a large engineering ticket is not
written up until the behaviour has been observed in a browser.

---

## 2. What changed on this branch

Seven changes across two rounds. Every user-facing string is either reused from an existing
translated key or written in all eight locales, so **all eight locales ship together** —
nothing here is English-only.

Round one (§2.1–2.4) was internal linking: 7 files, +31 lines, no new strings.
Round two (§2.5–2.7) was on-page SEO: the `/read` title, the `/topics` hub and the sitelinks
`SearchAction`.

### 2.1 `/tools/reading-sheet` now honours `?spread=<id>`
`web/src/pages/[...lang]/tools/reading-sheet.astro`

Read client-side (the site is static, so query params are not available at build time),
validated against the select's own options, then the existing `show()` runs. Unknown or
missing values are ignored and the page keeps its default sheet — a bad parameter can
never leave the page blank.

Verified: `?spread=celtic` → "Celtic Cross"; `?spread=yes_no` → "Yes or No";
`?spread=bogus` → default "Past, Present, Future".

### 2.2 All 15 spread pages link to their own printable sheet
`web/src/pages/[...lang]/spreads/[slug].astro`

Adds `tools/reading-sheet?spread={id}` alongside the existing "Interpret my cards" and
"Draw the cards" actions. Label and blurb reuse `ui.json`
`tools.list['reading-sheet'].title` / `.text` and `tools.open`.

### 2.3 All 5 topic pages hand off to a matching tool
`web/src/lib/topics.ts`, `web/src/pages/[...lang]/topics/[slug].astro`

New required `tool` field on the `Topic` interface. Mapping:

| Topic | Tool |
|---|---|
| `love` | `tools/love-compatibility` |
| `career` | `tools/reading-sheet` |
| `daily` | `tools/daily-card` |
| `choices` | `tools/yes-no` |
| `growth` | `tools/life-path` |

All `TOPICS` consumers only read the array, so the new required field breaks nothing.

### 2.4 The three "tell me about me" tools now state their limits
`web/src/pages/[...lang]/tools/{year-card,life-path,which-card-are-you}.astro`

These assign an identity from a birth date or a quiz and previously had no refusal line at
all — the most fortune-telling-adjacent surface on the site.

- `year-card`, `life-path` → reuse `ui.notFate` — *"Themes you may grow into, not a fixed fate."*
- `which-card-are-you` → reuse `workspace.disclaimer` — *"For entertainment and self-reflection only. Interpretations are possibilities, not predictions or professional advice."*

Both were already translated in all eight locales. `birth-card` already had `notFate`.

### 2.5 `/read` finally has a title tag worth ranking
`web/src/i18n/*/workspace.json`, `web/src/pages/[...lang]/read.astro`

The title tag was **"Interpret my cards"** — 18 characters, no keyword, no brand — on the
page most new visitors land on.

`workspace.title` is *also* the nav label and the CTA link text on 312 card-context pages,
so it could not be changed in place. Added a separate `seoTitle` key and used it for the
title tag only:

> Read your tarot cards: choose a spread and explore the meanings · ShenTarot

Written per locale (75/77/81/87/37/72/30/30 chars for en/de/es/fr/ja/ru/zh-hans/zh-hant).

**Still not fixed:** the H1 is still *"A story, laid open."* — see §6 item 3. That is a
brand-voice decision, not a code change; it needs the owner.

### 2.6 The `/topics` hub now exists
`web/src/pages/[...lang]/topics/index.astro` (new), `sitemap.xml.ts`, `layouts/Base.astro`,
`topics/[slug].astro`, `i18n/*/ui.json`

`/topics` was one of three sections whose children existed but whose index page 404'd. The
five topic pages were reachable only from the footer, with no parent.

- Hub ships in all eight locales (new `topics` block in `ui.json`, matching the existing
  `spreads` / `cards` / `questions` index blocks: title, description, crumb, eyebrow, h1, lead).
- `CollectionPage` + `ItemList` schema.
- Added to `sitemap.xml.ts` paths.
- Footer "Readings" column links it.
- Topic pages now get a real breadcrumb: Home › Topics › Love tarot reading.

**Deliberately not built: `/zodiac` and `/birth-cards`** — `/tools/zodiac-tarot` and
`/tools/birth-card` already link to every child and already hold the head term. A new hub
at `/zodiac` or `/birth-cards` would compete with them. If you disagree, that is a
cannibalisation call, not a missing-page call — check which URL currently ranks first.

### 2.7 Homepage `WebSite` schema gains a `SearchAction`
`web/src/pages/[...lang]/index.astro`

`Organization` (Shenetic) and `WebSite` (ShenTarot) were already on the homepage. `WebSite`
had no `potentialAction`, which is the only thing that makes a sitelinks search box
possible. Added `SearchAction` → `{site}search?q={search_term_string}`, so it localises
(`/de/search?q=`, `/ja/search?q=`, …). No new strings.

---

## 3. Tried and rejected — do not re-attempt without a new idea

**Spread-specific CTA on the 9 question guides.** The audit wanted "Ask this in a reading"
replaced with something like "Draw cards in the Celtic Cross spread". A string
`guide.askThisSpread` was written and translated into all eight locales, then **removed**
before commit.

Reason: four of the fifteen spread names are themselves questions —
`love_reconnect` is **"Will My Ex Come Back?"**, `love_ready` is **"When Will I Find Love?"**,
`love_bring` is **"Is This Relationship Right for Me?"**, `love_connection` is
**"Where Do We Stand?"**. On the guide for that exact question the button rendered as
"Draw the cards in the Will My Ex Come Back? spread" — clumsy, and it duplicated the page's
own H1. Because most guides route to the `love_*` spreads, most of the nine would have read
badly.

To revisit this you need wording that survives a question-shaped name, or a separate
short label for the `love_*` spreads. Not a copy tweak.

---

## 4. Verify before you push

```sh
cd web
npm install
npm run build
npm run check          # astro/tsc: expect 0 errors, 0 warnings
npm run check:i18n     # all 7 non-English locales must print ok
npm test
npm run check:reader-build && npm run check:editorial-build && npm run check:ritual-build \
  && npm run check:interactions-build && npm run check:search-growth-build && npm run check:beta-build
```

All of these passed on this branch. 3,918 pages build.

CI is strict about attribution (`scripts/check-editorial-build.mjs` asserts exact source
URLs, citation order and `dateModified`). **Do not touch `src/lib/editorial.ts`, the
`learn/` guides or the card evidence blocks** unless you are doing source work — those
checks will fail and should fail.

---

## 5. House rules that bit during this work

- **New strings cost eight.** A new `ui.json` key must be added to all eight locale files or
  `check:i18n` fails. **Prefer reusing an existing translated key over writing a sharper
  new one** — reuse ships 8/8 immediately, authoring ships 1/8. Section 2 reuses
  `tools.list.*`, `notFate` and `workspace.disclaimer` for exactly this reason.
- **This is a static build.** `Astro.url.searchParams` does not work. Read query params in
  a client `<script>` with `URLSearchParams`, like `/read` does.
- **Never guess a card or spread slug.** `/search-index.json` is authoritative and its
  `id` values are underscored (`major_00_fool`), while URLs are hyphenated
  (`major-00-fool`). Cards and spreads key on `id`; `learn` keys on hyphenated `slug`.
- **One branch per change, PR to `main`.** Never push to `main` directly.
- Keep `PROGRESS.md` updated at the end of each phase.

---

## 6. Still open, in priority order

From the 2026-11-02 audit (`roadmap-shentarot-2026-11-02.md`). Re-checked against this
branch on 2026-11-02; these are still true.

1. **Two section hubs still do not exist** — `/zodiac` and `/birth-cards`. `/topics` is done
   (§2.6). **Do not build the other two without deciding cannibalisation first**: the tools
   `/tools/zodiac-tarot` and `/tools/birth-card` already link to every child and already
   hold the head term. Check which URL ranks before adding a competitor.
2. **Regression tests for the `/read` handler**, reversed case first. It works today; a
   `?card=`-only change would silently leave the reversal broken, and nobody reports that.
   Note tests run against one locale — English passing does not cover `/de/read` etc.
3. **`/read` still cannot rank, but half of it is fixed.** The 18-character title is gone
   (§2.5). What remains: H1 is still *"A story, laid open."* and the page has under 100
   words of indexable prose, while being the primary landing page for "what do my tarot
   cards mean". The H1 is brand voice — owner decision. The prose is a content job.
4. **GSC-gated:** pull impressions for `/cards/.*/(love|career|feelings|yes-or-no)`. Whether
   the 312 card-context pages earn their crawl decides keep / consolidate / prune. Blocked
   on sitemap segmentation shipping first.
5. **`<lastmod>` on all sitemap URLs** — currently zero of 3,899; sitemap is one
   unsegmented 3.9MB file.
6. **Verify Core Web Vitals field data** before the INP weighting change.

**Not open:** the `/read` param handler (§1), 171/189/716 link counts (superseded — the
handler exists), the `_`→`-` "key-format" normalisation (the shipped links already match
`search-index.json` 1:1), and the `/ja` "thin content" flag (a whitespace-token artefact;
CJK has no spaces — 780 URLs must not be pruned).

---

## 7. Deployment record — this is live

**Merged:** PR #58, squash-merged to `main` as `4ee5832` (2026-11-02 12:28 UTC).

**Deployed:** `npm run deploy` in `web/` — `wrangler deploy` to worker `shentarot-site`,
custom domain `shentarot.com`.

- Wrangler version ID: **`43686dac-cb23-4a50-ac0b-b1a3d5ad9044`**
- 4,104 files uploaded
- `scripts/indexnow.mjs` pinged **3,909 URLs** to Bing (HTTP 200)

**Verified against the live site after deploy** (not against `dist/`):

| Check | Result |
|---|---|
| `/topics` (was 404) | 200, in all 8 locales |
| `/read` title | 75 chars, correct in en/de/ja |
| `/topics` schema | `CollectionPage` + `ItemList` in all 8 locales |
| `/topics/love` breadcrumb | `ShenTarot > Topics > Love tarot reading` |
| Homepage `SearchAction` | present, `https://shentarot.com/search?q={search_term_string}` |
| `sitemap.xml` | 3,907 `<loc>` entries, 35,136 `xhtml:link`, includes `/topics` and all locales |
| `/spreads/celtic` → reading-sheet | `/tools/reading-sheet?spread=celtic` |
| `/topics/career` → tool | links `tools/reading-sheet` |
| `year-card` / `life-path` / quiz limits lines | all present |
| 404 behaviour | `/this-page-does-not-exist` still 404 |

**Behavioural test in a real browser against production:**

| URL | Result |
|---|---|
| `/tools/reading-sheet` | select = `three`, shows only `three` |
| `?spread=celtic` | select = `celtic` |
| `?spread=yes_no` | select = `yes_no` |
| `?spread=bogus` | falls back to `three` |
| `/read` | `0 / 3 cards entered`, no card |
| `?card=major_00_fool` | `1 / 3`, The Fool, **Upright** |
| `?card=…&orientation=reversed` | `1 / 3`, The Fool, **Reversed** |
| `?spread=three_decision&card=major_08_strength` | spread switched to *Situation, Challenge, Way Forward*, Strength placed |

**Deploy gotcha worth knowing:** `npm ci` failed with `npm error File exists:
~/.npm/_cacache/content-v2/sha512/1a/c7` — the shared npm cache has a corrupted entry on this
machine. Do not delete the user's cache; pass a throwaway one instead:
`npm ci --cache /tmp/npm-cache-fresh`. Setup completed on a clean checkout after that.

**Note:** deploying does not need a merge — `web/package.json` `deploy` builds from the
working tree, so an unmerged branch can be pushed live by accident. Deploy from `main`.
