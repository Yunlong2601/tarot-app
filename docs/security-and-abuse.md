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

## Owner decisions (2026-10-17) that change the plan
- **Shared networks and many devices are fine.** Friends and families share Wi-Fi, and someone with 20 devices may refer all 20: each is still a download. So there is no same-IP or same-device block on referral rewards; the yearly cap of 20 rewarded friends per referrer is the limit. (Devices signed in to the same account share one balance, so they cannot be a friend of that account.)
- **Creator farming is accepted.** A post earns 10 credits (about US$0.03 worst case), limited to 1 a day and 8 a month per person. Credits stay automatic; only the free month is checked by hand.
- **Built 2026-10-17:** items 8 (constant-time webhook compare, tester ids ignored outside beta, `scripts/release-check.sh` before production deploys), 9 (tester mode forced off in release builds), 12 and 13 (account deletion now removes credits, referral records, creator posts and screenshots for the account and its installs).

## Threats, impact and fixes
Priority: A = fix before launch, B = fix soon after, C = monitor.

| # | Exploit | Impact | Today | Mitigation | Priority |
|---|---|---|---|---|---|
| 1 | **Fake installs (sybil farming):** script creates installs to collect welcome + daily credits and spend them on AI | Free AI use; up to about US$0.036 per fake install in welcome credits (worst case), unlimited installs | 10 installs a minute per IP (KV, not atomic); no attestation | Build App Attest (iOS) and Play Integrity (Android) before launch and never ship `ALLOW_UNATTESTED_INSTALLS`; cap new installs per IP per day (D1, not KV); give the welcome gift only after the first reading, or after sign-in | A |
| 2 | **Referral farming:** one person redeems their own code from many installs | Friend side always gets 10 credits (plus welcome); referrer capped at 20 friends a year | Self-referral blocked by account key only; yearly cap on referrer | Accepted for shared IPs and many devices (owner decision). Fix 1 (attestation) is what limits fake installs; optionally reward only after the friend reads on a second day | B |
| 3 | **Creator credit farming:** submit any public post (someone else's, or a random one) to get 10 credits | 10 credits (about US$0.03 worst case) per attempt, limited per owner, not per person | Link must be a known platform; daily/monthly limits per owner key; each link once | Accepted (owner decision). Later option: automatic caption check through oEmbed pages where they exist | C |
| 4 | **Fake likes / deleted posts:** buy likes, or delete the post after the free month | One free month (about US$6.99 of value, cost to us is small) | Manual check of the live post, 60-day cooldown, 6 a year | Keep manual; open the live post yourself; re-check randomly after 7 days; ban repeat offenders by account | B |
| 5 | **Global token cap used as a weapon:** an attacker burns the daily cap so everyone gets "service busy" | Outage for all users, no direct loss | Cap protects the bill, not availability | Reserve a share of the cap for Premium and for installs older than 1 day; alert at 80%; per-IP daily token budget; Cloudflare rate limiting rules and Turnstile on `/v1/install` | A |
| 6 | **Use the AI as a free general chatbot (prompt injection):** put instructions in the question or notes | Cost, off-brand or unsafe output | Length limits, crisis check, JSON output, banned-claim check, restricted-topic handling | Keep; log refusal and fallback rates; add per-install limits on text length and on repeated declined topics | B |
| 7 | **Refund abuse:** buy a pack or subscribe, use the credits, then ask the store for a refund | Lost revenue (small per case) | Refund events are not handled | Handle RevenueCat `CANCELLATION` / refund events: remove the unused part of the grant, flag repeat refunders, stop giving them monthly credits | B |
| 8 | **(Built)** **Admin or webhook secrets leak:** `ADMIN_TOKEN`, `REVENUECAT_WEBHOOK_AUTH`, `JWT_SECRET`, RevenueCat secret key | Free months, credits, fake purchases, forged sessions | Secrets in Worker secrets; admin token compared in constant time; webhook secret compared with a plain `!==` | Constant-time webhook compare; rotate secrets on any leak; never paste them in chats or repo; separate keys for beta and production; remove `TESTER_INSTALL_IDS` from production | A |
| 9 | **(Built)** **Premium spoofing:** claim Premium from the app | Free Premium | Server-side RevenueCat check, fails closed; tester ids only from an env var | Leave `TESTER_INSTALL_IDS` empty in production; the app flag `TESTER_MODE` must never ship in store builds (add a release check) | A |
| 10 | **Calendar-month grant gaming:** subscribe on the 31st to get two months of credits | Up to 150 credits (about US$0.45 worst case) | Accepted | Anchor to the billing date later | C |
| 11 | **Reinstall to hide abuse / lose bans** | Weak enforcement | Per-install keys | Account sign-in plus attestation; ban by account and device attestation key | B |
| 12 | **(Built: deleted with the account)** **Screenshots with personal data or bad images uploaded** | Privacy and legal exposure | 1 MB, JPEG/PNG only, 30-day deletion, private bucket, only the owner views | Keep the bucket private; add the clause to the Terms (done); do not auto-publish them; delete them when an account is deleted | A |
| 13 | **(Built)** **"Delete my data" leaves records:** account delete removes usage rows and the account, not credits, referral rows or creator posts and screenshots | Privacy promise broken | Not covered | Extend account delete to credits, lots, referrals, creator posts and screenshots; update the privacy text | A |
| 14 | **Credit double-spend by parallel requests** | A few free readings | Spend takes a specific lot with a guarded update; daily claim is guarded by a unique period marker | Keep; add a concurrency test on real D1 | C |
| 15 | **Guessing referral codes** | Friend discounts for strangers | 8-character code, 5 tries a minute per IP | Add a daily per-IP cap and slow responses after failures | B |
| 16 | **Account sign-in used to multiply gifts:** a throwaway Google or Apple account per gift | Same as fake installs, slower | Welcome per owner key; sign-in moves credits | Require a verified sign-in for the welcome gift and the creator program, plus attestation | B |

## Order of work before launch (A items still open)
1. Attestation (`POST /v1/install`), per-IP install limits in D1, no unattested installs in production (the release check already refuses the beta switches in production config).
2. Token cap reserve for Premium and old installs, an 80% alert, Cloudflare rate limiting and Turnstile.
3. Separate beta and production keys and secrets (the release check cannot see Worker secrets; check `wrangler secret list` by hand).
4. Real-device test of delete, reinstall and restore.

Later: refund handling (7), guessing protection (15), account-based bans (11).

## Costs to keep in mind
A fake install that spends the welcome gift costs under US$0.04 worst case. The danger is volume (thousands of installs) and the shared token cap, not any single account. Treat fix 1 as the foundation: most other rows become small once installs cost effort to create.
