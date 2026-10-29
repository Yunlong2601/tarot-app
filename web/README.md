# ShenTarot website

Beta onboarding: `/beta` and all seven localized `/beta` routes provide explicit platform selection, ordered joining steps, user-confirmed local progress, QR handoff, troubleshooting and feedback. `src/lib/beta.ts` centralizes destinations and cautious availability metadata. The guide does not detect installation or enrolment. Verified native media remains gated; do not reuse concept previews or older store captures as current-build evidence. Run `npm run check:beta-build` after building. [Coverage, checks and remaining device/media verification](../docs/beta-conversion-2026-10-29/README.md).

Local creative prototypes: `/design-study` (English-only, `noindex, nofollow`). Field Guide, Observatory and Reading Room compare original layouts while sharing the real draw engine. The illustrated index loads on demand; the margin inspector and redraw guard are study-scoped. [Research, code, licence notes and verification](../docs/creative-code-study-2026-10-26/README.md). Not deployed.

Multi-card draws now use a spread-bound Mystical & Editorial table: orbital placeholders, real card placement, fine connecting paths and open paper reading rows. The generator supports all 15 named spreads as well as free draws. Compact layouts use an ordered horizontal rail. [Spread drawing report](../docs/website-spread-drawing-2026-10-26.md).

The shared card draw now includes an explicit shuffle, a paged face-down fan, selection and a turn reveal. Desktop is primary; compact layouts use five cards instead of nine. Skip and local/OS reduced motion preserve the action without effects. The generator, daily/weekly tools, yes/no and spread pages use the same reader. Implementation/research/evidence: [card-draw report](../docs/website-card-draw-interaction-2026-10-25.md).

The companion site for the iOS and Android apps: card meanings, spreads, topic
pages, a random card draw, a birth card calculator, and the privacy and terms
pages the store listings link to. Built with [Astro](https://astro.build) as
plain static pages (no tracking, no cookies) and hosted on Cloudflare at clean
addresses such as https://shentarot.com/privacy and
https://shentarot.com/cards/major-00-fool (old `.html` addresses redirect).

Card and spread content comes from the backend (`backend/src/cards.ts`,
`backend/src/spreads.ts`) and the app (`app/lib/data/spreads.dart` for each
spread's description and source; card art from `app/assets/cards/art`), so the
site, the app and the readings never disagree. Topic sample questions are in
`src/lib/topics.ts` and match the app's question screen.

## Work on it

```sh
cd web
npm install
npm run dev      # http://localhost:4321
npm run build    # writes dist/
npm run check    # type check
```

## Languages

The site is in English (at the root) and in Simplified Chinese, Traditional
Chinese, Spanish, German, Japanese, French and Russian, each under its own
prefix (`/zh-hans/`, `/zh-hant/`, `/es/`, `/de/`, `/ja/`, `/fr/`, `/ru/`).
Pages live in `src/pages/[...lang]/`; the privacy, terms and account deletion
pages stay in English only.

All text is in `src/i18n/<language>/`:

- `cards.json` and `content.json`: card meanings, spreads, topics, question
  guides, life path numbers and star signs. The English files are generated
  from the app's data with `npx tsx scripts/extract-i18n.ts`; re-run it when
  that data changes, then update the translations.
- `ui.json`: every other piece of page and tool text, written by hand.
- `learn.json`: the Learn tarot guides (`/learn`), written by hand. Links
  inside the text are `[words](path)`, with the English path, and each
  translation keeps the same paths.
- `interactions.json`: navigation, Tarot Index, writing controls, card picker,
  loading/recovery and motion controls. `companion.ts` contains the explicitly
  labelled future-companion fixtures for all eight locales.

`node scripts/check-i18n.mjs` checks that each translation has the same keys,
list lengths and `{placeholders}` as English. A missing string shows in
English. The translations were machine-made and are worth a native speaker's
check.

## Share images

The free tools, the reader and the card pages can save a result as a picture
(or share it from a phone), drawn in the browser from the card art. Card pages
also have link-preview images, made by `scripts/og-cards.mjs` before each build.

## Search engines and AI assistants

- `robots.txt` welcomes all crawlers and names the AI search crawlers (GPTBot,
  ClaudeBot, PerplexityBot and others) explicitly. If Cloudflare's "Block AI
  bots" setting is on for the domain, it overrides this; turn it off in the
  Cloudflare dashboard under Security > Bots.
- `/llms.txt` and `/llms-full.txt` give AI assistants the site in plain
  Markdown: every card, spread, topic, question guide and tool, and the full
  card meanings. They are built from the same English text as the pages.
- Card pages open with a one-line answer ("The Star means hope, renewal and
  calm.") and carry schema.org `DefinedTerm` and `FAQPage` data. The About page
  says who makes ShenTarot and where the meanings come from.
- `npm run deploy` ends with `scripts/indexnow.mjs`, which tells Bing and the
  other IndexNow search engines about every page. Its key is the public
  `public/<key>.txt` file. A failed ping is printed and never fails the deploy.

## Settings

`src/config.ts`:

- `SITE_URL`: where the site lives, `https://shentarot.com/`.
- `APP_STORE_URL`, `PLAY_STORE_URL`: fill in when the apps are live. Until then
  pages say "Coming soon".

## Publish on Cloudflare

shentarot.com is registered with Cloudflare, so its DNS is already there.

1. Deploy the backend first (`backend/README.md`): the site hands shared
   readings to it, and its `SHARE_BASE_URL` makes new share links use
   shentarot.com.
2. In `web/`: `npx wrangler login`, then `npm run deploy`. This deploys the
   `shentarot-site` Worker and attaches shentarot.com to it as a custom domain.
3. Check https://shentarot.com/privacy and /terms load, then switch
   the App Store, Google Play and Google sign-in links from the old GitHub
   Pages address to shentarot.com. Keep the GitHub Pages copy up until they
   are all switched.

## Shared readings and opening links in the app

`/s/<link>` pages are rendered by the backend Worker; `worker/index.js` passes
those requests to it through a service binding, and serves everything else
from `dist/`.

- iOS: `public/.well-known/apple-app-site-association` lists the app (team
  `SX4CW2L35K`, bundle `com.shentech.shentarot`) for `/s/*`, and the app has
  the matching Associated Domains entitlement (`applinks:shentarot.com`).
  Xcode's automatic signing adds the capability to the App ID on the next
  build.
- Android: the app has a verified intent filter for `https://shentarot.com/s/`,
  verified by `public/.well-known/assetlinks.json`. It holds the Play app
  signing certificate's SHA-256 fingerprint (Play Console > Test and release >
  App integrity > App signing); update it if that key ever changes.
- The app opens a shared link on its question screen, matching the page's
  "Ask your own question" button.

## Own-card reference workspace

`/read` (and each locale's `/read`) lets visitors enter a physical draw, inspect
reference meanings and keep one browser-local reflection. Drafts survive a tab
refresh in session storage; Save explicitly replaces the one local-storage
snapshot. No account sync, paid app entitlement or AI response is implied.
Visitors can copy, export text, print and delete it. Export is the portable backup.

`/astrology` collects existing zodiac/tarot correspondences with an undated
weekly practice. It does not publish forecasts or calculate live sky positions.

Run `npm run check:i18n`, `npm test`, `npm run check`, `npm run build`, then
`npm run check:reader-build`. State tests use Node's built-in TypeScript stripping
(Node 24 used for verification); no new runtime dependency was added.
See `../docs/website-enhancements-verification-2026-10-21.md` for browser evidence
and the required secure browser-authentication/API handoff before website AI
can be enabled. Do not expose the app's testing install flow to browser users.

## Teaching and repeat practice

`/learn/connected-reading` is an original editorial example; loading it asks
before replacing current cards and preserves personal notes and the saved snapshot.
`/methodology` discloses the source tradition, AI assistance and unconfirmed expert
and native-language review. `/learn/beginner-reference` has accessible HTML, a
static UTF-8 text download and browser print/PDF output. `/learn/practice` stores
five activity IDs locally, independently of the one saved reflection; it does
not create an account history or alter the app's Premium journal/look-back.
New copy is in each locale's `growth.json`. See
`../docs/website-growth-validation-2026-10-21.md` for measurement, distribution,
privacy/service dependencies and the unperformed human usability study.

## Practice continuity follow-up

Card position pickers now filter by local/English name, keyword and existing
English aliases, retaining the current selection. Save/Restore confirm before
replacing different content. The practice page recommends the first untried
activity from the same local progress record; it does not create a journal.
New interface text is in `journey.json` for all eight locales.

Three original English teaching PNGs are in `public/demos/`, downloadable from
the beginner reference. Rebuild them manually with `node scripts/demo-assets.mjs`
when editorial copy changes. They use the existing 1909 public-domain artwork
and the existing sharp development dependency. No content is posted automatically.

See `../docs/website-review-pack-2026-10-22.md` for the unperformed review and
`../docs/website-ai-contract-proposal-2026-10-22.md` for the concrete backend
handoff. Browser authentication/preflight/idempotency remain unsupported;
no AI submission or testing-token workaround was enabled.

## Quiet Ritual visual system

The premium/editorial system lives in `src/styles/ritual.css`, on top of the
shared reference-tool primitives in `site.css`. Cormorant Garamond and Inter
remain locally bundled under their existing SIL OFL licences; CJK uses native
system serif/sans fallbacks. `public/ritual-card-back.svg` is original SVG artwork.
New presentation copy is explicit for all eight locales in `src/i18n/ritual.ts`.
The homepage reuses `Reader.astro` rather than introducing new drawing rules or
storage. The connected example uses the same `EXAMPLE` fixture and translations
as the full lesson. No AI/auth/backend or existing storage schema changes.

`npm run check:ritual-build` audits 240 representative output pages, including
all tool templates and the eight redesigned homepages. It supplements (does not
replace) browser verification. `postbuild` writes `dist/release.json` with the
Git revision and build time for public deployment verification.

## Ritual interactions (local implementation; not published)

The Tarot Index searches cards, spreads and lessons. Each locale generates
`/search-index.json`; `/search?q=…` provides the full results page. Existing
`/cards?q=…` links still work. The header loads the search implementation and
index only when opened. Failed index requests can be retried; a failed search
module opens the full results page with the entered query when retried.
`src/lib/search.ts` owns validation, ranking and matched-text ranges, and reuses
the workspace's alias/orientation parser. Reversed results retain orientation
when opened and carried into a spread. Search creates no persistent history.

`src/lib/dialogs.ts` manages one modal at a time, Escape, focus containment and
focus restoration for search, mobile navigation, card selection and confirmation.
`src/lib/card-picker.ts` supplies thumbnail results, a desktop preview and
unavailable duplicate states. Orientation and Move earlier/later remain explicit
workspace controls. Existing draft version/storage keys remain unchanged; session
draft and saved-reflection messages appear only after the relevant write succeeds.

`src/styles/interactions.css` contains control/focus/motion tokens. The homepage's
explicit Fan/Positions/Connection steps use the existing authored example and
original SVG connectors (`thread-stage.css`). Native scrolling remains intact.
OS reduced motion overrides optional motion; the stage also has a visible control.
The future companion is a deterministic, labelled interface concept: no AI request,
identity, entitlement or payment integration is added.

Validate from `web/`:

```sh
npm test
npm run check:i18n
npm run check
npm run build
npm run check:reader-build
npm run check:ritual-build
npm run check:interactions-build
```

The interaction build audit checks eight indexes, result destinations, artwork,
query interpretation and recovery markup. It does not test native keyboards,
screen readers, translation quality or consumer comprehension. See
`../docs/website-interactions-verification-2026-10-24.md` for the requirement and
evidence matrix, performance comparison and outstanding validation. The owner
requested a recruitment/moderator pack instead of supplied participants:
`../docs/interaction-usability-study-2026-10-23.md`.

Before release, reconcile newer main changes using
`../docs/website-claude-handoff-reconciliation-2026-10-24.md`; do not overwrite
the merged photo-privacy update or infer live app features from historical notes.

## Search-growth follow-up (27 October 2026)

The five existing search-priority routes have scoped original editorial additions in initial HTML. See [audit, baseline and verification](../docs/search-growth-2026-10-26/README.md). Run `npm run check:search-growth-build` after building for canonical/locale/sitemap/link/artwork/FAQ parity and exact five-route scope. Changes remain local; the 28-day post-release comparison is pending and no new tracking/crawler permissions were added.

### Markdown content negotiation

The static postbuild step (`scripts/agent-markdown.mjs`) converts each built HTML
page into an internal Markdown asset using Turndown and LinkeDOM. Main content,
absolute links, title/description and JSON-LD are retained; navigation, scripts,
styles and interactive controls are removed. Regenerate with every build so the
alternate follows the same content release.

The Worker runs before static assets and serves these representations for GET or
HEAD requests that explicitly prefer `Accept: text/markdown`. Requests without
that preference keep HTML. HTML/Markdown responses vary on Accept, preserve
security headers, and declare `ai-train=no, search=yes, ai-input=no`. Markdown
responses discard HTML validators and encoding headers. No token-count header is
emitted because an exact tokenizer is not available. Non-HTML files, redirects,
errors and private `/s/*` backend responses retain their original handling.
Internal `/_agent-markdown/*` URLs are not public endpoints. A missing generated
alternate falls back to HTML. Cloudflare's paid zone conversion feature is not
required or enabled by this implementation.

Verify with `node --test tests/agent-markdown.test.ts`, a production build, and:

```sh
curl -i -H 'Accept: text/markdown' https://shentarot.com/
curl -I -H 'Accept: text/html' https://shentarot.com/
```

### API and agent discovery

`worker/api-discovery.js` publishes `/.well-known/api-catalog` as RFC 9727
`application/linkset+json`, `/api/openapi.json` as OpenAPI 3.1 JSON, and
`/api/docs` as human-readable HTML (Markdown by Accept negotiation). The catalog
identifies the existing deployed app API and links its real health endpoint.
The reference explicitly covers core health/install/reading/followup operations;
it does not claim to document account, credits, sharing, webhook or admin APIs.
Legacy app authentication is preserved. Scoped delegated OAuth is described in
`/auth.md` and the OpenAPI security scheme. Update this reference when core
backend contracts change.

The homepage advertises `api-catalog`, `service-desc`, `service-doc` and
`describedby` Link relations on HTML and Markdown responses. Discovery resources
support GET/HEAD, reject writes and contain no credentials. Verify with
`node --test tests/api-discovery.test.ts` and the external readiness scanner.

### Authentication discovery

The Worker serves `/auth.md` as Markdown and proxies the exact OAuth route
allowlist to the existing API service binding. Live PRM and AS metadata advertise
issuer `https://shentarot.com`, the real authorize/token/JWKS endpoints, S256 PKCE,
and the anonymous public-client registration method. Registration alone grants
no user access: a signed-in user must review and approve scopes in the app before
a one-use code can be exchanged for a one-hour token. Reading/followup access
remains subject to the existing credit/entitlement/rate checks. The native
approval screen is compiled locally but needs distribution in an app update.

See `../docs/oauth-reading-access-2026-10-28/README.md` for implementation sources,
release integrity, tests, limits and rollback. Validation is passive: do not POST
registration endpoints merely to scan them. Tests: `tests/auth-discovery.test.ts`.
