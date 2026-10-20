# Creator program: how it works and owner setup

Built 2026-10-17, **switched off** (server `CREATOR_ENABLED`, which also needs `CREDITS_ENABLED`; app flag `CREATOR`). Migration `0007_creator.sql` is NOT applied to the live database yet. Rules are constants in `backend/src/creator.ts`.

## What users do
Anyone can be a creator. In the app: You > Creator program. They post about ShenTarot with **#shentarot** (and **#ad** or **#gifted**, because a free subscription counts as payment) on TikTok, Instagram, YouTube, Xiaohongshu, Reddit, X, Facebook or Threads, then send the post link and a screenshot.

- **Every attempt gets 10 credits at once.** Limits: 1 a day, 8 a month, each post once (links are normalised, so tracking tags do not make a post new).
- **50 likes earns 1 free month of Premium.** The owner checks the screenshot and the post, then verifies it. One free month per creator every 60 days, at most 6 a year. The month is a RevenueCat promotional entitlement (the same call the referral program uses).
- Screenshots (PNG or JPEG, up to 1 MB) go to a private R2 bucket and are deleted after 30 days by the daily cron; the link and result stay.

## Owner setup (in order)
1. Create a private R2 bucket: `npx wrangler r2 bucket create shentarot-shots`, then uncomment the `[[r2_buckets]]` block in `backend/wrangler.toml`.
2. Set the admin secret (at least 24 random characters): `npx wrangler secret put ADMIN_TOKEN`. Keep it out of chats and the repo. Rotate it if it leaks.
3. Apply the migration: `npx wrangler d1 migrations apply shentarot --remote` (also applies 0005 and 0006 if they are pending).
4. Tell me to switch on: set `CREATOR_ENABLED=true` and `CREDITS_ENABLED=true`, deploy, and build the app with `--dart-define=CREATOR=true --dart-define=CREDITS=true`.
5. Have the program wording reviewed (it is in the Terms and in `docs/referral-terms-draft.md` style); check Apple and Google rules on rewarding social posts before launch.

## Reviewing posts (owner)
Replace `$API` with the Worker URL and `$TOKEN` with the admin secret:
```bash
curl -s -H "Authorization: Bearer $TOKEN" $API/v1/admin/creator/pending
curl -s -H "Authorization: Bearer $TOKEN" $API/v1/admin/creator/12/screenshot -o shot.jpg
curl -s -X POST -H "Authorization: Bearer $TOKEN" -d '{"likes": 57}' $API/v1/admin/creator/12/verify
curl -s -X POST -H "Authorization: Bearer $TOKEN" -d '{"note": "likes not real"}' $API/v1/admin/creator/12/reject
```
Open the post link yourself and count the likes on the live post; the screenshot is only supporting evidence. `verify` needs at least 50 likes, refuses inside the 60-day cooldown or after 6 months in a year, and does nothing if RevenueCat does not confirm the grant.

## Known limits (see also docs/security-and-abuse.md)
- Credits are paid before anyone checks the post, so a fake post still earns 10 credits (about US$0.03 worst case). The owner accepts this (2026-10-17). The daily and monthly limits cap one install at 80 credits a month, but fresh installs get fresh limits until App Attest / Play Integrity exists.
- Review is manual (curl). A small review page can come later.
