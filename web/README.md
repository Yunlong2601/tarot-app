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

- `SITE_URL`: where the site lives. It is the old GitHub Pages address until the
  domain is set up; change it to the domain (e.g. `https://shentarot.com/`).
- `APP_STORE_URL`, `PLAY_STORE_URL`: fill in when the apps are live. Until then
  pages say "Coming soon".

## Publish on Cloudflare

1. Set `SITE_URL` in `src/config.ts` to the domain (links on the pages are
   built from it).
2. `npx wrangler login`, then `npm run deploy` (deploys `dist/` as the
   `shentarot-site` Worker, static files only).
3. In the Cloudflare dashboard add the domain to the `shentarot-site` Worker
   (Settings > Domains & Routes).
4. Keep the GitHub Pages copy of `privacy.html` and `terms.html` up, or redirect
   them, until the App Store and Google Play listings point at the new domain.

## Shared readings and opening links in the app

Shared reading pages (`/s/<link>`) are served by the backend Worker. To serve
them on the site's domain:

1. In `backend/wrangler.toml` add a route for `<domain>/s/*` to the
   `shentarot-api` Worker, and set `SHARE_BASE_URL = "https://<domain>"` so new
   links use the domain.
2. iOS: `public/.well-known/apple-app-site-association` already lists the app
   (team `SX4CW2L35K`, bundle `com.shentech.shentarot`) for `/s/*`. Add the
   Associated Domains capability with `applinks:<domain>` to the app.
3. Android: add `public/.well-known/assetlinks.json` with the app signing
   certificate's SHA-256 fingerprint (Play Console > Test and release > App
   integrity), and an `autoVerify` intent filter for `https://<domain>/s/` in
   `AndroidManifest.xml`.
