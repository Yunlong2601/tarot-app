# Shared facts (app + website)

One place for facts that both the Flutter app (worked on with Claude, see `CLAUDE.md`) and the website (worked on with Codex, see `AGENTS.md`) must agree on. If you change one of these, change it here in the same PR and say so in the PR description. If a fact is not known, it says **unknown**: do not fill it in by guessing.

Last checked: 2026-10-23, from the repo, `docs/` and the project notes.

## Product
| Fact | Value | Source |
|---|---|---|
| Store name | ShenTarot: AI Lens | App Store Connect record, 2026-10-17 |
| Home-screen name | ShenTarot | `docs/store-listing.md` |
| Publisher | Shenetic, Singapore | Owner correction, 1 November 2026; website attribution updated |
| Contact / support email | shenyunlongbusiness@gmail.com | `web/src/config.ts` |
| Bundle id / Android app id | `com.shentech.shentarot` (final) | `AGENTS.md` decisions |
| Apple app | Apple ID 6823779463, SKU `shentarot`, team `SX4CW2L35K` | `docs/app-store-submission-guide.md` |
| Positioning | For people who own a physical deck and don't know how to read what they drew. "Hold the cards. We explain them." | `docs/store-listing.md` |
| Deck | Rider-Waite-Smith only; art is the public-domain 1909/1910 Pamela Colman Smith scans or original art. Never 1971+ US Games art. Do not use "Rider-Waite" in the name, icon or keywords. | `AGENTS.md` decisions |
| Disclaimer | Entertainment and self-reflection only; readings are written by AI, are not predictions, and are not medical, legal, financial or other professional advice. Every screen or page that shows a reading carries it. | store listing, backend |
| Age rating | 13+ (App Store); minimum age 13 in the privacy policy | PROGRESS.md |

## Store links
| Store | URL |
|---|---|
| App Store | **unknown**: not public yet. Leave `APP_STORE_URL` in `web/src/config.ts` empty; the site shows "Coming soon". |
| Google Play | **unknown**: not public yet. Leave `PLAY_STORE_URL` empty. |

When the owner gives the live URLs, update this table and `web/src/config.ts` together.

## Web addresses
| Page | Address | Status |
|---|---|---|
| Website | https://shentarot.com | Live (Cloudflare Worker `shentarot-site`, deployed from `web/`) |
| Privacy | https://shentarot.com/privacy | Live, but its Camera paragraph does not yet cover the optional whole-spread photo (open PR #21, based on the old `google-play-prep` branch) |
| Terms | https://shentarot.com/terms | Live. iOS uses Apple's standard EULA. |
| Account deletion | https://shentarot.com/delete-account | Live |
| Legal copies the store listings link to today | https://yunlong2601.github.io/shentarot-legal/privacy.html, `.../terms.html`, `.../delete-account.html`; support URL https://yunlong2601.github.io/shentarot-legal/ | The privacy copy here was updated for the whole-spread photo on 2026-10-20. Keep both copies identical until the stores are switched to shentarot.com. |
| Shared readings | `https://shentarot.com/s/<token>`, rendered by the backend through the site Worker | Universal/App Links set up in `web/public/.well-known/` |
| Backend API | https://shentarot-api.shentech.workers.dev | Live in test mode (`app/config/live.json`) |

## Plans and prices (owner decision 2026-10-17)
The project instructions' original plan (weekly plan, free trial on annual) was replaced by the owner on 2026-10-17: **no weekly plan and no free trial.**

| Plan | Product id (both stores) | Price (USD) | Notes |
|---|---|---|---|
| Annual | `shentarot_annual` | US$39.99 / year | Intro offer US$1.99 for the first month (Play offer id `first-month`), new subscribers only |
| 3 months | `shentarot_quarterly` | US$14.99 / 3 months | |
| Monthly | `shentarot_monthly` | US$6.99 / month | |
| Credit packs | (see `docs/credits-setup.md`) | 10 / 25 / 40 credits for US$1.99 / 3.99 / 5.99 | Only with the credit wallet on |

- RevenueCat entitlement: `premium`. Apple subscription group "Premium" (levels 1 to 3 as above).
- Local prices (SGD and others) are set per storefront by the stores; check the consoles, not this table.
- Free: 2 AI readings a day, 1 to 3-card spreads, one free try of a longer spread; scanning, Card of the Day, library and lessons are free.
- Premium: all 14 spreads, follow-ups, clarifier card, journal notes, look back, up to 50 readings a day.
- The credit wallet, referrals and creator program are built but **off** for v1 (`CREDITS_ENABLED`, `REFERRALS_ENABLED`, `CREATOR_ENABLED` on the server; `CREDITS`, `REFERRALS`, `CREATOR` in the app). The website must not promise them while they are off.
- Unit economics: `docs/unit-economics.md` (about US$0.0003 AI cost per reading; break-even about 5 annual subscribers).

## Brand
| Where | Colours | Fonts |
|---|---|---|
| App (dark, black and gold; `app/lib/app/theme.dart`) | background `#0B0B0B`, surface `#151515`, surface high `#1F1D19`, gold `#EBD48C`, gold light `#F6E8B8`, gold deep `#C9A24D`, gold tint `#2B261B`, on-gold `#17130A`, muted text `#A9A59B` | Platform default |
| Website "Quiet Ritual" (`web/src/styles/site.css`, `ritual.css`) | paper `#F4F0E7`, ink `#17171B`, forest `#243C35`, accent `#B69A60`, text gold `#795D30`, violet `#55435D` | Cormorant Garamond + Inter (bundled, SIL OFL) |

The app and the site use different palettes on purpose (dark app, light editorial site). Icon: `play-upload/icon-512.png`, original art.

## Backend API (Cloudflare Worker in `backend/`, TypeScript + Hono)
Full detail: `backend/README.md`. Auth is an anonymous install token: `POST /v1/install` returns a 12 h Bearer token. There is **no browser identity yet**, so the website must not call the AI endpoints (see `docs/website-ai-contract-proposal-2026-10-22.md`).

| Method and path | Auth | Purpose |
|---|---|---|
| `GET /health` | none | `{ok: true}` |
| `POST /v1/install` | none (attestation still to build) | `{installId}` -> `{token}` |
| `POST /v1/reading` | Bearer | `{spread, cards: [{id, reversed}], question?, impression?}` -> `{reading, structured, fallback, disclaimer}`, or `{crisis: true, message}` |
| `POST /v1/followup` | Bearer, Premium | adds `reading`, `followup`, optional `clarifier` -> `{answer, disclaimer}` |
| `POST /v1/share`, `POST /v1/share/:token/delete`, `GET /s/:token` | Bearer / none | Shared readings |
| `POST /v1/account/signin`, `/signout`, `/delete` | Bearer | Optional sign-in (off until set up) |
| `POST /v1/credits/me`, `/v1/credits/daily`, `/v1/referral/*`, `/v1/creator/*` | Bearer | Wallet, referral, creator (flags off) |
| `GET/POST /v1/admin/creator/*` | `ADMIN_TOKEN` | Owner review |
| `POST /v1/webhooks/revenuecat` | webhook secret | Subscription events |

Input rules: question and impression up to 300 characters each, cleaned; card ids from `backend/src/cards.ts`; spread ids from `backend/src/spreads.ts` (14 spreads). Free spreads must match in `backend/src/spreads.ts` (`isFreeSpread`) and `app/lib/data/spreads.dart` (`SpreadInfo.isFree`). The website reads card and spread content from these same files.

**Gap:** the optional whole-spread photo feature (photo sent once to the server and Anthropic, then deleted) is live on the server and in TestFlight build 7 (2026-10-20), but its code is **not in `main`** on GitHub. It is on the owner's Mac.

## Not known yet (owner to supply)
- Live App Store and Google Play URLs.
- Whether the stores will switch their privacy/support links from GitHub Pages to shentarot.com, and when.
- Lawyer review of privacy and terms (none yet).
