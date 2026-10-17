# Security and abuse: how people may exploit ShenTarot, and what to do (draft, 2026-10-17)

Method: for each feature that gives away value (credits, free months, AI calls), ask who gains, how cheaply they can repeat it, and what it costs us. Checked against the code on branch `google-play-prep`. "Not built" means a gap, not a claim about stores or devices that were not tested.

## Where value leaks
| Free thing | Where it comes from |
|---|---|
| 10 welcome + 2 daily credits | every new owner key (a new install, or a new account) |
| 10 credits per referral (friend side) | every new install that redeems a code and reads once |
| 10 credits per creator post | every attempt, before anyone checks it |
| Free Premium month | creator post with 50 likes; referral payers |
| AI calls | every reading, follow-up and clarifier |

The main weakness behind most rows: **a new install is free and unlimited**. Installs are only identified by a random id the app makes, and `POST /v1/install` currently mints a token for any id when `ALLOW_UNATTESTED_INSTALLS=true` (the beta deploy script sets it). Without attestation, one script can create thousands of "users".

## Threats, impact and fixes
Priority: A = fix before launch, B = fix soon after, C = monitor.

| # | Exploit | Impact | Today | Mitigation | Priority |
|---|---|---|---|---|---|
| 1 | **Fake installs (sybil farming):** script creates installs to collect welcome + daily credits and spend them on AI | Free AI use; up to about US$0.036 per fake install in welcome credits (worst case), unlimited installs | 10 installs a minute per IP (KV, not atomic); no attestation | Build App Attest (iOS) and Play Integrity (Android) before launch and never ship `ALLOW_UNATTESTED_INSTALLS`; cap new installs per IP per day (D1, not KV); give the welcome gift only after the first reading, or after sign-in | A |
| 2 | **Referral farming:** one person redeems their own code from many installs | Friend side always gets 10 credits (plus welcome); referrer capped at 20 friends a year | Self-referral blocked by key only; cap on referrer | Needs fix 1; also: reward the friend and referrer only after the friend reads on a second day; block rewards when referrer and friend share an IP hash; cap referral redeems per IP per day | A |
| 3 | **Creator credit farming:** submit any public post (someone else's, or a random one) to get 10 credits | 10 credits (about US$0.03 worst case) per attempt, limited per owner, not per person | Link must be a known platform; daily/monthly limits per owner key; each link once | Check the post automatically where possible (TikTok, YouTube, X and Reddit publish oEmbed pages that show the caption and author: require #shentarot in the caption); require sign-in for the creator program; hold credits until the check passes or after 24 hours with spot checks | A |
| 4 | **Fake likes / deleted posts:** buy likes, or delete the post after the free month | One free month (about US$6.99 of value, cost to us is small) | Manual check of the live post, 60-day cooldown, 6 a year | Keep manual; open the live post yourself; re-check randomly after 7 days; ban repeat offenders by account | B |
| 5 | **Global token cap used as a weapon:** an attacker burns the daily cap so everyone gets "service busy" | Outage for all users, no direct loss | Cap protects the bill, not availability | Reserve a share of the cap for Premium and for installs older than 1 day; alert at 80%; per-IP daily token budget; Cloudflare rate limiting rules and Turnstile on `/v1/install` | A |
| 6 | **Use the AI as a free general chatbot (prompt injection):** put instructions in the question or notes | Cost, off-brand or unsafe output | Length limits, crisis check, JSON output, banned-claim check, restricted-topic handling | Keep; log refusal and fallback rates; add per-install limits on text length and on repeated declined topics | B |
| 7 | **Refund abuse:** buy a pack or subscribe, use the credits, then ask the store for a refund | Lost revenue (small per case) | Refund events are not handled | Handle RevenueCat `CANCELLATION` / refund events: remove the unused part of the grant, flag repeat refunders, stop giving them monthly credits | B |
| 8 | **Admin or webhook secrets leak:** `ADMIN_TOKEN`, `REVENUECAT_WEBHOOK_AUTH`, `JWT_SECRET`, RevenueCat secret key | Free months, credits, fake purchases, forged sessions | Secrets in Worker secrets; admin token compared in constant time; webhook secret compared with a plain `!==` | Constant-time webhook compare; rotate secrets on any leak; never paste them in chats or repo; separate keys for beta and production; remove `TESTER_INSTALL_IDS` from production | A |
| 9 | **Premium spoofing:** claim Premium from the app | Free Premium | Server-side RevenueCat check, fails closed; tester ids only from an env var | Leave `TESTER_INSTALL_IDS` empty in production; the app flag `TESTER_MODE` must never ship in store builds (add a release check) | A |
| 10 | **Calendar-month grant gaming:** subscribe on the 31st to get two months of credits | Up to 150 credits (about US$0.45 worst case) | Accepted | Anchor to the billing date later | C |
| 11 | **Reinstall to hide abuse / lose bans** | Weak enforcement | Per-install keys | Account sign-in plus attestation; ban by account and device attestation key | B |
| 12 | **Screenshots with personal data or bad images uploaded** | Privacy and legal exposure | 1 MB, JPEG/PNG only, 30-day deletion, private bucket, only the owner views | Keep the bucket private; add the clause to the Terms (done); do not auto-publish them; delete them when an account is deleted | A |
| 13 | **"Delete my data" leaves records:** account delete removes usage rows and the account, not credits, referral rows or creator posts and screenshots | Privacy promise broken | Not covered | Extend account delete to credits, lots, referrals, creator posts and screenshots; update the privacy text | A |
| 14 | **Credit double-spend by parallel requests** | A few free readings | Spend takes a specific lot with a guarded update; daily claim is guarded by a unique period marker | Keep; add a concurrency test on real D1 | C |
| 15 | **Guessing referral codes** | Friend discounts for strangers | 8-character code, 5 tries a minute per IP | Add a daily per-IP cap and slow responses after failures | B |
| 16 | **Account sign-in used to multiply gifts:** a throwaway Google or Apple account per gift | Same as fake installs, slower | Welcome per owner key; sign-in moves credits | Require a verified sign-in for the welcome gift and the creator program, plus attestation | B |

## Order of work before launch (A items)
1. Attestation (`POST /v1/install`), per-IP install limits in D1, no unattested installs in production.
2. Move welcome and referral rewards behind real use (first reading, second day), and block same-IP referral rewards.
3. Creator program: automatic caption check where an oEmbed page exists, sign-in required, credits held until the check passes.
4. Token cap reserve for Premium and old installs, an 80% alert, Cloudflare rate limiting and Turnstile.
5. Secrets hygiene: constant-time webhook compare, no tester ids, release check for `TESTER_MODE`, separate beta and production keys.
6. Extend account delete to credits, referrals, creator posts and screenshots.

## Costs to keep in mind
A fake install that spends the welcome gift costs under US$0.04 worst case. The danger is volume (thousands of installs) and the shared token cap, not any single account. Treat fix 1 as the foundation: most other rows become small once installs cost effort to create.
