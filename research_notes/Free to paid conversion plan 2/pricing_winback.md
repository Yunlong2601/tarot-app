# Pricing/packaging experiments and win-back tactics for hybrid (subscription + credits) apps, iOS-first: ShenTarot

ShenTarot's current setup, for reference: annual $39.99 with a $1.99 pay-up-front first month; quarterly $14.99; monthly $6.99. Credit packs are 10 for $1.99, 25 for $3.99 and 40 for $5.99. Free users get 1 credit a day (2 when signed in) plus 10 welcome credits. Billing runs through RevenueCat.

Research date: 2026-10-27. Sources are 2025-2026 unless flagged. Vendor case studies (Adapty, Superwall, RevenueCat blog) are self-reported marketing and are flagged as such.

## Q1. Benchmarks: free trials vs paid intro offers, weekly plans, annual share, price-tier tests

### Takeaway
ShenTarot's prices sit close to the 2026 medians: the median yearly plan is about $34.80 overall and $39.99 in North America, and the median monthly is about $10 (Health & Fitness $9.99). That makes the $6.99 monthly look cheap and the $39.99 annual look about right. About 44% of Social & Lifestyle apps run no trial, so a paid intro offer instead of a free trial is a common, defensible choice. I found no clean head-to-head benchmark comparing a free trial with a paid intro offer. The best evidence is one RevenueCat case study, which showed a large rise in conversion but a large fall in LTV.

### Cited Findings
- **Trial mix by category (SOSA 2026):** "no trial" ranges from 18% to 44% across categories. Social & Lifestyle is highest at 43.6%, the only category where no-trial beats mixed-trial. Health & Fitness has the highest "mixed" share at 59%. — [RevenueCat State of Subscription Apps 2026](https://www.revenuecat.com/state-of-subscription-apps/)
- **Trial-to-paid by trial length (median / top quartile):** 17–32 days: 42.5% / 59.4%. 5–9 days: 37.4% / 52.8%. 4 days or less: 25.5% / 38.5%. — [RevenueCat SOSA 2026](https://www.revenuecat.com/state-of-subscription-apps/)
- **Day-0 trial cancellations:** 55.4% for 3-day trials, 39.8% for 7-day, 31.1% for 30-day. 84% of 3-day trial cancellations happen between Day 0 and Day 1. — [RevenueCat SOSA 2026](https://www.revenuecat.com/state-of-subscription-apps/)
- **Hard vs freemium paywall:** median D35 conversion is 10.7% for hard paywalls vs 2.1% for freemium (the figures come via a secondary summary and a RevenueCat engineering post citing the report). — [RevenueCat blog](https://www-docs.revenuecat.com/blog/engineering/android-paywall-gap/); [RocketShip HQ summary](https://www.rocketshiphq.com/?p=5478)
- **Health & Fitness benchmarks (the closest wellness proxy; there is no separate spiritual category):** D35 download-to-paid median 2.9% (top quartile 6.2%); trial-to-paid 37.7%; D14 RPI $0.48; monthly realized LTV $24.23. — [RevenueCat SOSA 2026](https://www.revenuecat.com/state-of-subscription-apps/)
- **Plan mix:** about 42% of subscriptions sold are monthly and about 34% yearly. Weekly share runs from 4% (Health & Fitness) to 47% (Social). Annual plans bring in 59% of Health & Fitness revenue, though the report also says 68% elsewhere and contradicts itself. In North America the split is 36% monthly and 40% yearly. — [RevenueCat SOSA 2026](https://www.revenuecat.com/state-of-subscription-apps/)
- **Median prices (2026):**
  - Weekly: about $5.99 (North America $6.99).
  - Monthly: about $10 (Health & Fitness $9.99; North America $9.99). The report also says the monthly median rose from $7 to $8, so the figure is internally inconsistent.
  - Yearly: rose from $31.60 to $34.80 (North America $39.99; Health & Fitness about $39.94).
  - Most common price points: $5 weekly, $10 monthly, $30 yearly. — [RevenueCat SOSA 2026](https://www.revenuecat.com/state-of-subscription-apps/)
- **Download-to-trial by price tier:** high-priced apps 8.9%, mid 5.4%, low 4.4%. Higher prices did not depress trial starts. — [RevenueCat SOSA 2026](https://www.revenuecat.com/state-of-subscription-apps/)
- **Renewal:** the first annual renewal median is 23%–40%. Annual plans account for 35% of annual cancellations in month 1. — [9to5Mac on SOSA 2026](https://9to5mac.com/2026/05/27/new-report-shows-annual-app-subscribers-rarely-return-after-they-cancel/). The same article also gives "yearly plans renew at 83.4%", which conflicts with the 23–40% median. This may be a different metric, such as an auto-renew-on rate, so verify before using it.
- **Paid intro offer case study (vendor blog, July 2025, a single app):**
  - The app dropped its 3-day trial and moved to weekly at 85% off, monthly at 75% off, and a yearly "discount" made by raising the list price 66% and striking it through.
  - Install-to-paid rose from about 3% to a peak of about 14% (+433%). CPA (SKAN) fell from $105 to $13.
  - LTV-30 fell about 81%, from about $55 to about $10. Only about 40% paid full price at first renewal, compared with more than 50% under the trial.
  - The author attributes part of the result to a TikTok trend. — [RevenueCat blog, David Vargas](https://www.revenuecat.com/blog/growth/introductory-offers-apps)
- **Weekly price test (Adapty playbook, vendor-reported, no sample sizes):** raising weekly from $7.99 to $9.99 "typically" cut conversion 5–8% and raised ARPU 18–22%. — [Adapty paywall experiments playbook](https://adapty.io/blog/markdown/paywall-experiments-playbook.md)
- **Decoy test (Adapty, Glam AI, roughly 24.5k users per arm):** adding a $119.99 yearly plan above the $59.99 yearly plan raised yearly conversion from 0.43% to 0.55% and net revenue per user from $0.261 to $0.292. Weekly conversion was flat. — [Adapty Glam AI paywall tests](https://adapty.io/blog/markdown/glam-ai-paywall-tests.md)
- **AI apps:** about 41% more revenue per payer, but they churn about 30% faster (secondary coverage also reports 36%, so the figure is unconfirmed). — [RevenueCat SOSA 2026](https://www.revenuecat.com/state-of-subscription-apps/); [ecosistemastartup coverage](https://ecosistemastartup.com/?p=66753)

### Inferences
- **Monthly price:** $6.99 is below the 2026 median monthly price ($9.99 in North America and Health & Fitness). A monthly test at $9.99 is low-risk and also makes the annual's per-month saving look bigger: $39.99 a year is about $3.33 a month, which is 67% off $9.99 versus 52% off $6.99.
- **Annual intro offer:** the $1.99 first month on the annual plan is a paid intro, in line with the no-trial Social & Lifestyle norm. The Vargas case suggests deep paid intros raise conversion sharply but attract price-driven users. Judge any intro test on D30/D60 revenue per install and first-renewal rate, not on conversion alone.
- **Quarterly plan:** $14.99 a quarter is about $5 a month, roughly the same per month as monthly, so it gives users little reason to pick it. Test either removing it (a simpler 2-plan paywall) or using it as a decoy.
- **Weekly plan:** a weekly plan (about $4.99–$5.99) is the common norm for impulse-driven Social/Lifestyle and AI apps. But Health & Fitness, the closest wellness analog, has only a 4% weekly share. Treat weekly as a test arm, not a default.

### Gaps
- No RevenueCat, Adapty or Superwall benchmark specific to spirituality, astrology or tarot. Health & Fitness and Social & Lifestyle are the closest proxies.
- No published controlled comparison of a 3–7 day free trial against a paid first month for the same app type.
- I could not open the full SOSA 2025 page for direct year-on-year comparison; most 2025 figures above come from secondary sources.

## Q2. Hybrid monetisation (subscription + consumable credits)

### Takeaway
True hybrid models are a minority: about 10.7% of apps sell subscriptions plus consumables, and 2.5% sell subscriptions, consumables and lifetime. The common AI-app pattern is that the subscription covers baseline access and credits meter costly usage. I found no published, data-backed guidance on credit-pack sizing, first-pack discounts or measured cannibalisation. ShenTarot will need its own experiments here.

### Cited Findings
- **Monetisation mix (SOSA 2026):**
  - Subscriptions only: 63.5%. Subscriptions + lifetime: 23.2%. Subscriptions + consumables: 10.7%. All three: 2.5%.
  - Gaming has the most consumables at 27.5%. Asia-Pacific has the highest subscriptions + consumables combination at 12.2%. — [RevenueCat SOSA 2026](https://www.revenuecat.com/state-of-subscription-apps/)
- **RevenueCat's AI hybrid guidance (Thomas Petit, Feb 2026):**
  - "Access is predictable: subscriptions still anchor revenue, expectations, and retention."
  - Usage-heavy behaviour can be capped, metered or monetised separately, so power users "self-select into higher spend."
  - "ARPU averages hide catastrophic tail risk."
  - Free users can have negative unit economics when AI calls cost real money.
  - The post has no pack-sizing or cannibalisation data. — [RevenueCat blog: AI hybrid monetization](https://www.revenuecat.com/blog/growth/ai-hybrid-monetization)
- **Secondary coverage of SOSA 2025 (on 2024 data):** 35% of apps mix subscriptions with consumables or lifetime purchases. This figure differs from SOSA 2026's split, possibly because of different definitions. — [Subscription Insider](https://subscriptioninsider.com/article-type/news/revenuecats-state-of-subscription-apps-2025-report-ais-dominance-retention-challenges-and-the-shift-away-from-pure-subscriptions)
- **Astrology credit wallets (vendor blog, illustrative, not data):**
  - Example prices: 10 credits per AI astrologer question, 40 per compatibility report, 200 per live consultation.
  - Suggests premium members get a monthly credit allowance and buy top-ups. — [AstrologyAPI blog](https://astrologyapi.com/blog/how-to-monetize-astrology-app)
- **Nebula:** described as free + subscription with live psychic chat. I found no verifiable credit prices. — [Wikipedia: Nebula](https://en.wikipedia.org/wiki/Nebula_(spiritual_guidance)); [JPLoft blog](https://www.jploft.com/blog/how-astrology-apps-make-money)

### Inferences
These are reasoning from ShenTarot's numbers, not sourced results.
- **Cannibalisation risk:** the 40-credit pack costs $5.99, less than one month of subscription ($6.99). A user who needs about 40 readings a month can skip the subscription entirely.
  - Credits should cost noticeably more per reading than what a subscriber effectively pays.
  - Packs should be framed as top-ups or "try before subscribing", with a "subscribe and save" comparison shown at pack purchase.
- **Pack ladder:** current per-credit prices are $0.199, $0.160 and $0.150. The volume discount from 25 to 40 credits is small (about 6%), so the top pack does little to move users up.
- **Option A (anchor):** test a larger "best value" pack, for example 100 credits for $9.99–$12.99, as an anchor.
- **Option B (simplify):** drop to two packs plus the subscription.
- **First-pack discount:** a first-purchase consumable discount, for example 25 credits for $0.99 once, gives a low-friction first payment. It moves users from free to payer, a step that predicts later subscription.
  - This works mechanically because consumables can carry a distinct product ID shown only to non-payers.
  - It is untested by any source found and should be measured on later subscription rate.
- **Subscriber credit grant:** a monthly credit grant for subscribers (if the subscription is not unlimited) makes the value of subscribing explicit and protects against the "packs are cheaper" comparison.
- **Free allowance:** the free allowance (1–2 credits a day plus 10 welcome) is generous relative to typical AI-app free tiers. Given the Petit point on negative unit economics, test a lower welcome grant or gating premium spreads.

### Gaps
- No published experiments on credit-pack price elasticity, first-pack discounts or subscription cannibalisation by consumables in subscription apps.
- No verified pricing data from competitor tarot or astrology apps, such as Nebula, Co–Star or Labyrinthos.

## Q3. iOS win-back tools: win-back offers, promotional offers, offer codes, retention offers on cancellation

### Takeaway
Apple gives four levers. Each has different eligibility and rules.
- **Win-back offers:** for lapsed subscribers. Shown automatically by Apple, and in-app on iOS 18+.
- **Promotional offers:** for current and lapsed subscribers. Shown inside the app and signed server-side; RevenueCat handles this.
- **Offer codes:** eligibility can be new, existing and/or expired subscribers. Redeemed via URL or in-app sheet.
- **Introductory offers:** new users only.

RevenueCat supports all four. Its Customer Center can show a promotional offer when a user picks a cancellation reason. Reactivation benchmarks are low for annual subscribers (about 5%) and much higher for monthly (about 18–24%). That argues for putting effort into retention at the cancellation step and into monthly lapsers.

### Cited Findings: Apple win-back offers (App Store Connect help)
- **Scope:** configured per subscription product, not per group. Customers are eligible only for their most recently lapsed product in each group. The subscription must be approved by App Review first. — [Apple: Set up win-back offers](https://developer.apple.com/help/app-store-connect/manage-subscriptions/set-up-win-back-offers)
- **Limits:** up to 350 win-back offers per subscription; up to 5 active per storefront per subscription. — [Apple](https://developer.apple.com/help/app-store-connect/manage-subscriptions/set-up-win-back-offers)
- **Eligibility fields:**
  - Minimum Paid Duration: 1–24 months, or 3, 4 or 5 years.
  - Time Since Last Subscribed: both a minimum and a maximum are required, within 1–24 months.
  - Optional Wait Between Offers: 2–24 months. — [Apple](https://developer.apple.com/help/app-store-connect/manage-subscriptions/set-up-win-back-offers)
- **Types:** Pay as you go, Pay up front, or Free. The earliest start date is the next day, and an offer must run at least 3 days. — [Apple](https://developer.apple.com/help/app-store-connect/manage-subscriptions/set-up-win-back-offers)
- **Fixed after creation:** reference name, offer ID and price cannot be changed.
- **Overlap:** if offers overlap, Apple shows one, chosen by price, duration and tenure. — [Apple](https://developer.apple.com/help/app-store-connect/manage-subscriptions/set-up-win-back-offers)
- **Priority and promotion:**
  - "High" priority affects ranking on win-back sheets, Manage Subscriptions and the App Store.
  - App Store promotion needs an approved subscription image that differs from the app icon and screenshots.
  - Promoting an offer replaces in-app purchase promotions in that storefront. — [Apple](https://developer.apple.com/help/app-store-connect/manage-subscriptions/set-up-win-back-offers)
- **Where it appears:**
  - Manage Subscriptions: iOS 14.3+.
  - In-app win-back sheet: iOS 18+ (macOS 15+).
  - A redemption URL can also be shared directly. — [Apple](https://developer.apple.com/help/app-store-connect/manage-subscriptions/set-up-win-back-offers)

### Cited Findings: RevenueCat win-back support
- **Requirements:** iOS 18.0+ only. It uses StoreKit 2, so an In-App Purchase Key must be uploaded to RevenueCat. — [RevenueCat: iOS Subscription Offers](https://www.revenuecat.com/docs/subscription-guidance/subscription-offers/ios-subscription-offers)
- **Minimum SDK versions:**
  - 5.0.0+: App Store with streamlined purchasing on, and StoreView.
  - 5.6.0+: StoreKit message.
  - 5.9.0+: App Store with streamlined purchasing off, and unique URL.
  - 5.10.0+: your own paywall. — [RevenueCat](https://www.revenuecat.com/docs/subscription-guidance/subscription-offers/ios-subscription-offers)
- **API:** `eligibleWinBackOffers(forPackage:)` returns an empty array if the user is not eligible. To buy, use `PurchaseParams.with(winBackOffer:)` then `purchase(_:)`. — [RevenueCat](https://www.revenuecat.com/docs/subscription-guidance/subscription-offers/ios-subscription-offers)
- **Streamlined purchasing:** on by default, so the whole flow happens in the App Store. Turn it off (App Store Connect > Subscriptions > Streamlined Purchasing) if users must act in-app first. The app then gets `readyForPromotedProduct` and must call `startPurchase`. — [RevenueCat](https://www.revenuecat.com/docs/subscription-guidance/subscription-offers/ios-subscription-offers)
- **Testing:** streamlined purchasing can only be tested in sandbox on a physical device. — [RevenueCat](https://www.revenuecat.com/docs/subscription-guidance/subscription-offers/ios-subscription-offers)

### Cited Findings: promotional offers
- **Eligibility:** for existing and previously subscribed customers. They can be redeemed even after the user has used an intro offer. — [Apple: Set up promotional offers](https://developer.apple.com/help/app-store-connect/manage-subscriptions/set-up-promotional-offers-for-auto-renewable-subscriptions)
- **Limits:** up to 10 active offers per subscription. An offer applies to all storefronts and cannot be limited by country. After creation only the price can be edited. — [Apple](https://developer.apple.com/help/app-store-connect/manage-subscriptions/set-up-promotional-offers-for-auto-renewable-subscriptions)
- **RevenueCat:**
  - Apple enforces eligibility: the user had or has an active subscription, otherwise they see the regular product.
  - An In-App Purchase Key is needed to sign offers.
  - API: `eligiblePromotionalOffers()` / `promotionalOffer(forProductDiscount:product:)` then `purchase(package:promotionalOffer:)`. — [RevenueCat](https://www.revenuecat.com/docs/subscription-guidance/subscription-offers/ios-subscription-offers)

### Cited Findings: offer codes
- **Eligibility:** selectable in any combination of new, existing (including billing retry or grace period with auto-renew on) and expired subscribers. — [Apple: Set up offer codes](https://developer.apple.com/help/app-store-connect/manage-subscriptions/set-up-offer-codes)
- **Capacity:**
  - Up to 1 million redemptions per app per quarter, shared across subscriptions.
  - One-time codes come in batches of 500–25,000.
  - Custom codes are up to 64 characters, with up to 25,000 redemptions per batch.
  - One code per customer per offer.
  - Up to 10 active offers per subscription.
  - Offers cannot be edited, and deactivated offers cannot be reactivated. — [Apple](https://developer.apple.com/help/app-store-connect/manage-subscriptions/set-up-offer-codes)
- **Expiry:** one-time codes last at most 6 months. Custom codes can have no expiry. — [Apple](https://developer.apple.com/help/app-store-connect/manage-subscriptions/set-up-offer-codes)
- **Redemption:** via a redemption URL, the App Store "Redeem" page, or in-app on iOS 14+. — [Apple](https://developer.apple.com/help/app-store-connect/manage-subscriptions/set-up-offer-codes)
- **RevenueCat warnings:**
  - Apple's in-app redemption sheet "has proven to be extremely unstable."
  - There is no success callback.
  - Recommended alternative: link to `apps.apple.com/redeem?ctx=offercodes&id={app_id}&code={code}`, then call `syncPurchases`. — [RevenueCat](https://www.revenuecat.com/docs/subscription-guidance/subscription-offers/ios-subscription-offers)

### Cited Findings: retention offers on cancellation (RevenueCat Customer Center)
- **Cancellation survey:** the default options are "Too expensive", "Don't use the app" and "Bought by mistake".
- **Default offers:** "Too expensive" and "Don't use the app" trigger promotional offer `rc_cancel_offer`. Refund requests get `rc_refund_offer`.
- **Missing offers:** the offer IDs must exist in App Store Connect. If the SDK can't find a match, it skips the survey and proceeds.
- **Upgrades:** an offer can be on a different product in the same group, for example a discounted annual for a monthly subscriber. — [RevenueCat: Customer Center promo offers (Apple)](https://www.revenuecat.com/docs/tools/customer-center/customer-center-promo-offers-apple)
- **Docs status:** navigation differs between doc versions (an Offers tab vs Lifecycle > Retention). One page still calls Customer Center beta, which may be outdated. — [RevenueCat Customer Center config](https://www.revenuecat.com/docs/tools/customer-center/customer-center-configuration.md)

### Cited Findings: reactivation benchmarks
- **SOSA 2026 annual reactivation:** about 5%, so about 95% of cancelled annual subscribers never return. It clusters at 4.9–5.9% across geographies and 4.4–5.6% across price tiers. — [9to5Mac](https://9to5mac.com/2026/05/27/new-report-shows-annual-app-subscribers-rarely-return-after-they-cancel/); [PPC Land](https://ppc.land/95-of-annual-app-subscribers-who-cancel-never-return-revenuecat-finds/)
- **By plan type:** monthly about 18–24% (overall monthly 20.1% in SOSA 2026, up from 13.7% in 2025); weekly about 7–10%; annual about 4–6%.
- **By price:** high-priced monthly 28.9%, low-priced monthly 15.4%. Mid-range monthly Health & Fitness about 12%.
- **Average hold after reactivating:** about 4 months.
- **Tactics recommended:**
  - Fix activation and habit formation (week-1 core-feature use, D7 retention, months 2–4 churn) before investing in win-back.
  - Then run win-back campaigns, retargeting and a better cancellation flow.
  - Revisit the churned pool every 6 months. — [RevenueCat blog, Daphne Tideman, May 2026](https://www.revenuecat.com/blog/growth/20-of-your-churned-users-will-come-back-but-are-you-ready)
- **Discounts:** no published data on how discount depth affects reactivation. RevenueCat deferred it to "Part 2". — [RevenueCat blog](https://www.revenuecat.com/blog/growth/20-of-your-churned-users-will-come-back-but-are-you-ready)

### Inferences
- **Cancellation step:**
  - Set up Customer Center with `rc_cancel_offer` (for example 50% off the next 3 months on monthly, or a discounted annual offered to monthly users) and `rc_refund_offer`.
  - Add a "Don't use the app" path that leads to a re-engagement hook, such as a daily-card reminder, rather than only a discount.
- **Win-back offers:** create two tiers on each of the annual, monthly and quarterly products.
  - Lapsed 1–3 months: for example, the first month at $0.99–$1.99, paid up front.
  - Lapsed 4–12 months: for example, a deeper or free first week.
  - Use "Wait Between Offers" to stop serial discount abuse.
  - Priority on monthly is reasoned from the roughly 4× higher reactivation rate.
- **Streamlined purchasing:** keep it on unless a sign-in step is required, because Apple surfaces the offer automatically, including on the Manage Subscriptions page from iOS 14.3.
- **Offer codes:** best for email and push win-back to expired subscribers and for influencer campaigns. Use the redemption URL, not the in-app sheet, because of RevenueCat's warning.
- **Credits as a win-back lever:** a lapsed subscriber can be offered a small credit gift or a discounted credit pack, which keeps them engaged without a store offer. This is untested and needs to be measured.
- **Reach on iOS 18+:** iOS 18+ adoption is likely very high by late 2026, so the in-app win-back sheet should reach most users. I did not verify an adoption figure.

### Gaps
- I could not fetch Apple's StoreKit page "Supporting win-back offers in your app"; the body did not render. The StoreKit API names for win-back messages (`Message.Reason.winBackOffer`) are unverified.
- Promotional offer signature mechanics and per-customer redemption limits are not stated on the App Store Connect page I read.
- No published lift data comparing Apple win-back offers to promotional offers, or measuring the save rate of cancellation-flow offers.
- I did not confirm whether Apple has added offer codes for consumables (there is a separate "Create offer codes for In-App Purchases" page in the navigation that I did not read).

## Q4. Paywall experiments with measured lift (plan order, default selection, toggles, social proof)

### Takeaway
Public paywall-test results are mostly vendor case studies without sample sizes. The most reliable advice is about how to run tests, not specific lifts:
- Test price and plan structure before visuals.
- Use proceeds or revenue per user as the primary metric.
- Run pricing tests for 4–6 weeks.
- Judge on LTV over 2–3 renewal cycles.

Reported lifts: adding a discounted annual plan (+80% proceeds per user, Superwall testimonial), a decoy higher yearly tier (+12% net revenue per user, Adapty/Glam AI), and opt-in vs default trial (+10% trial conversion, Superwall testimonial).

### Cited Findings
- **Superwall experiment mechanics:**
  - Users get a sticky variant assignment.
  - Allocation below 100% creates a no-paywall holdout.
  - The default metric is proceeds per user, "because a higher-converting paywall can still earn less." — [Superwall A/B testing](https://superwall.com/features/ab-testing)
- **Superwall testimonials (no methodology):**
  - Adding an annual plan with a 60% discount next to monthly raised proceeds per user 80% and trial conversion 22%.
  - Testing opt-in trial vs default trial raised trial conversion 10%. — [Superwall: increase revenue](https://superwall.com/solutions/increase-revenue-arpu-ltv)
- **Superwall template:** a monthly-default vs annual-default test, with D30 retained revenue per install as the primary metric. This is a template, not a result. — [Superwall blog: How to A/B test a paywall](https://superwall.com/blog/how-to-ab-test-a-paywall)
- **Adapty test priority and duration:**
  - Highest impact: annual price, weekly anchor, trial length and plan order. Visual tests come after pricing is stable.
  - Run pricing tests 4–6 weeks, then follow cohorts for 2–3 renewal cycles. — [Adapty playbook](https://adapty.io/blog/markdown/paywall-experiments-playbook.md)
- **Adapty / Glam AI decoy result:** adding a $119.99 yearly plan lifted yearly conversion from 0.43% to 0.55% and net revenue per user from $0.261 to $0.292, with about 24.5k users per arm. The effect needed a large sample to read. — [Adapty](https://adapty.io/blog/markdown/glam-ai-paywall-tests.md)
- **Adapty / Prosto:** adding bi-annual and monthly options alongside a $30 annual raised revenue 30%. Plan-level figures are not in the text. — [Adapty case study: Prosto](https://adapty.io/case-studies/prosto/)
- **Price-per-day framing (Vargas case):** showing prices per day, and raising weekly and monthly intro prices to make yearly look cheaper per day, shifted plan mix toward yearly. — [RevenueCat blog](https://www.revenuecat.com/blog/growth/introductory-offers-apps)
- **RevenueCat Experiments:** includes preset experiment types for introductory offers and free-trial offers, so a paid intro vs free trial test can run natively. — [RevenueCat Experiments docs](https://www.revenuecat.com/docs/tools/experiments-v1/experiments-overview-v1)

### Inferences
Candidate tests for ShenTarot, in order. Each runs 4–6 weeks with D30/D60 revenue per install as the primary metric.
1. Monthly price $6.99 vs $9.99, keeping annual at $39.99 to widen the anchor.
2. Annual intro: $1.99 first month vs a 7-day free trial vs no intro. Measure first-renewal rate, not just conversion.
3. Plan set: 3 plans vs 2 (drop quarterly) vs adding weekly at $4.99.
4. Annual pre-selected with per-month or per-day framing and a "save X%" badge, vs the current default.
5. Credit-pack ladder and placement: show "subscribe and save" beside packs. Test a first-pack discount for never-paid users.

- **Holdout:** a Superwall- or RevenueCat-style holdout (no paywall at a given trigger) is worth running for any newly added paywall trigger.
- **Sample size:** ShenTarot's volume may be too small to detect lifts of 10–20% within weeks. Prefer fewer, bolder arms, as the Glam AI test needed about 24.5k users per arm.

### Gaps
- No independent (non-vendor) controlled studies with sample sizes for plan order, toggles or social proof.
- No published social-proof lift data found from Adapty, Superwall or Purchasely in this search. Purchasely sources were not reached.
- No tarot- or spiritual-app-specific paywall test results found.
