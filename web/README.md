# ShenTarot website

The companion site for the iOS and Android apps: card meanings, spreads, topic
pages, a random card draw, a birth card calculator, and the privacy and terms
pages the store listings link to. Built with [Astro](https://astro.build) as
plain static pages (no tracking, no cookies) and hosted on Cloudflare.

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
3. Check https://shentarot.com/privacy.html and /terms.html load, then switch
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
- Android: the app has a verified intent filter for `https://shentarot.com/s/`.
  Verification also needs `public/.well-known/assetlinks.json` with the app
  signing certificate's SHA-256 fingerprint (Play Console > Test and release >
  App integrity). Until it exists, Android opens these links in the browser.
- The app opens a shared link on its question screen, matching the page's
  "Ask your own question" button.
