# AGENTS.md: ShenTarot website (for Codex)

Codex works on the **website** in `web/`. Claude works on the Flutter app (`app/`), the backend (`backend/`) and `ml/`; its rules are in `CLAUDE.md`. Read this file, then `SHARED-FACTS.md` (names, links, prices, brand, API shape both sides must agree on), then `web/README.md` (how the site is built). Recent website history is in `PROGRESS.md` and the `docs/website-*.md` files.

## What the site is
The companion site for the ShenTarot: AI Lens app at https://shentarot.com: card meanings (78 cards, plus love, career, feelings and yes-or-no pages), 14 spreads, topics, zodiac and birth-card pages, a browser-local reading workspace (`/read`), Learn guides and practice, a card-of-the-day widget, `llms.txt`, and the privacy, terms and account-deletion pages the store listings link to. Eight languages (English at the root; `zh-hans`, `zh-hant`, `es`, `de`, `ja`, `fr`, `ru`). Static pages, no tracking, no cookies. The site is reference-only: no AI readings, scanning or account sync in the browser.

## Current state (2026-10-23)
- Astro 7 static build, served by the Cloudflare Worker `shentarot-site` (`web/wrangler.jsonc`) on the custom domain shentarot.com. Only `/s/*` (shared readings) runs `web/worker/index.js`, which forwards to the backend Worker `shentarot-api` through a service binding.
- Latest release: the "Quiet Ritual" editorial redesign (PR #27, merged to `main`); evidence and rollback reference in `docs/quiet-ritual-redesign-2026-10-22.md`.
- `APP_STORE_URL` and `PLAY_STORE_URL` in `web/src/config.ts` are empty, so download buttons say "Coming soon".
- `.well-known/apple-app-site-association` and `assetlinks.json` are in `web/public/` for links that open the app.

## Deploy
```bash
cd web
npm ci
npm run check:i18n && npm test && npm run check && npm run build && npm run check:reader-build && npm run check:ritual-build
npx wrangler login     # owner, once, on their Mac
npm run deploy         # build + wrangler deploy + IndexNow ping
```
Deploy only after the owner says so, from `main` once the PR is merged. The backend must be deployed before the site if `/s/*` changes. After a deploy check `https://shentarot.com/release.json`, `/privacy` and `/terms`. CI runs the same checks plus `npm audit --omit=dev`.

## Remaining to-dos
1. Privacy page: the Camera paragraph must describe the optional whole-spread photo, matching the GitHub Pages copy. Open PR #21 has the text but targets the stale `google-play-prep` branch; rebase onto `main` or redo it. Check the effective date matches the GitHub Pages copy.
2. Store links: fill `APP_STORE_URL` and `PLAY_STORE_URL` when the owner gives the live URLs (update `SHARED-FACTS.md` too).
3. Once shentarot.com/privacy and /terms are verified identical to the GitHub Pages copies, tell the owner so the store listings can switch to shentarot.com.
4. Browser AI stays off until the backend owner builds browser identity, access preflight and idempotent charging (`docs/website-ai-contract-proposal-2026-10-22.md`). Do not add a workaround.
5. Native-speaker check of the seven translations (machine-made); see `docs/website-review-pack-2026-10-22.md`.
6. Owner marketing steps from the growth work: resubmit the sitemap in Search Console and Bing after deploys, Pinterest bulk upload, outreach texts.
7. If the credit wallet, referrals or creator program are switched on, the privacy page needs those sections checked (wording for credits already exists).

## Rules
- **Secrets:** none in the repo or in the built site. No API keys, tokens, `.dev.vars`, Cloudflare credentials or install tokens in HTML, JavaScript or local storage. The IndexNow key file in `web/public/` is public by design. Never expose the app's testing install flow (`/v1/install`, `ALLOW_UNATTESTED_INSTALLS`) to browsers.
- **Scope:** edit only `web/` and website docs. Do not change `app/`, `backend/` or `ml/`; if the site needs a backend change, write the request in a doc or PR description for the owner. The site reads card and spread data from `backend/src/cards.ts`, `backend/src/spreads.ts`, `app/lib/data/spreads.dart` and `app/assets/cards/art`; treat them as read-only.
- **Facts:** names, prices, plans, links and brand come from `SHARED-FACTS.md`. Do not invent prices, store policy, features or reviews. Do not promise features that are off (credits, referrals, creator program) or not in the app.
- **Privacy:** no analytics, cookies, trackers or third-party scripts without the owner's approval. Keep fonts and assets self-hosted. Privacy, terms and deletion pages stay in English and must match the GitHub Pages copies.
- **Content:** keep the disclaimer (entertainment and self-reflection only, not professional advice) wherever reading text appears. Card art is the public-domain 1909 scans or original art; no other decks, no "Rider-Waite" in names or keywords.
- **i18n:** every new string goes into all eight locales; run `npm run check:i18n`.
- **Git:** a branch per change, PR to `main`, never push to `main` directly; small commits. Say what you did not verify (devices, browsers, live production) instead of assuming. Add a short dated note to `PROGRESS.md` for each website release.
- Anything that needs the owner (accounts, DNS, Search Console, legal review, translations) goes under "I need to do" in the PR or reply; never guess a missing value.

## Commands
```bash
cd web && npm ci && npm run dev    # http://localhost:4321
```
