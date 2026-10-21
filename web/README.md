# ShenTarot website

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
