# Free-to-Paid Conversion Drivers and Benchmarks for Consumer Subscription Apps (applied to ShenTarot)

Context: ShenTarot is an iOS tarot card-scan app with AI readings. Free users get 10 welcome credits plus 1 credit a day (2 if signed in). Credit packs are US$1.99/3.99/5.99 for 10/25/40 credits. Premium is $6.99 monthly, $14.99 for 3 months, or $39.99 a year with a $1.99 first month. 1 credit = 1 reading or follow-up. ShenTarot is freemium plus hybrid, with no free trial and a paid intro offer on the annual plan.

Source caveats: most numbers below come from RevenueCat and Adapty, which sell subscription infrastructure, and from Superwall, which sells paywalls. Their samples are their own customers, and their definitions differ (for example, "conversion" at D35 versus at the paywall). RevenueCat's public pages don't show Lifestyle or "Social & Lifestyle" category medians for most funnel metrics. Those are in the gated 330+ page PDF. Astrology and tarot apps usually sit in Lifestyle or Entertainment, so Health & Fitness is used below as the nearest category with published numbers.

---

## 1. Benchmarks (2024-2026): install-to-trial, trial-to-paid, install-to-paid, paywall conversion, refunds

### Takeaway
The median freemium app converts about 2% of installs to paid by Day 35. Hard-paywall apps convert about 10-12%. Health & Fitness, the nearest category with published data, has a median install-to-paid of 2.9% and trial-to-paid of 37.7% (RevenueCat 2026). Top-decile apps run 2-5x the median. Refunds run 2-5% of payers and are higher for hard paywalls and annual plans.

### Cited Findings
**RevenueCat State of Subscription Apps 2026 (115,000+ apps, $16B+ revenue)**
- Median download-to-trial by category: Business 9.1%, Health & Fitness 6.9%, Education 6.5%, Utilities 6.5%, Gaming 4.4%, Travel 4.1%, Media & Entertainment 4.0%. Social and Lifestyle aren't shown on the public page. — [RevenueCat SOSA 2026](https://www.revenuecat.com/state-of-subscription-apps)
- Median trial-to-paid: Travel 43.5%, Health & Fitness 37.7%, Gaming 25.0%, Photo & Video 22.2%. Media & Entertainment spans 11.5% to 69.5% from low to high performers. — [RevenueCat SOSA 2026](https://www.revenuecat.com/state-of-subscription-apps)
- Median download-to-paid by D35: Health & Fitness 2.9%, Business 2.6%, Shopping 1.3%, Gaming 1.0%. — [RevenueCat SOSA 2026](https://www.revenuecat.com/state-of-subscription-apps)
- By price tier (2026): download-to-trial is 8.9% for high, 5.4% for mid and 4.4% for low prices. Download-to-paid at D35 is 2.8% for high, 2.0% for mid and 1.4% for low. Higher-priced apps convert more installs, not fewer. — [RevenueCat SOSA 2026](https://www.revenuecat.com/state-of-subscription-apps)
- Hard paywall vs freemium (2026): D35 download-to-paid is 10.7% vs 2.1%. D14 revenue per install is $2.32 vs $0.27, and D60 is $3.09 vs $0.38, about 8x. — [RevenueCat SOSA 2026](https://www.revenuecat.com/state-of-subscription-apps); [RevenueCat trends post 2026](https://www.revenuecat.com/blog/growth/subscription-app-trends-benchmarks-2026)
- 1-year retention of yearly subscribers is about the same either way (freemium 28%, hard paywall 27%, "statistically negligible"). — [RevenueCat trends post 2026](https://www.revenuecat.com/blog/growth/subscription-app-trends-benchmarks-2026)
- AI-powered apps (2026) have 41% higher Year-1 realized LTV ($30.16 median vs $21.37 for non-AI). Their monthly plans retain 36% worse over 12 months. The main report page summarizes the same finding as "churn 30% faster", so the two RevenueCat pages give different figures. — [RevenueCat trends post 2026](https://www.revenuecat.com/blog/growth/subscription-app-trends-benchmarks-2026); [RevenueCat SOSA 2026](https://www.revenuecat.com/state-of-subscription-apps)
- Revenue concentration (2026): the top 5% of apps earn 400x the bottom 25%, up from 200x in 2024. Top-quartile MRR grew 80%+ year on year, and the bottom quartile shrank more than 33%. — [RevenueCat trends post 2026](https://www.revenuecat.com/blog/growth/subscription-app-trends-benchmarks-2026)

**RevenueCat State of Subscription Apps 2025 (2024 data)**
- Trial start rate is 6.2% at the median and 20.3% at P90. 82% of trial starts happen on install day. — [RevenueCat SOSA 2025](https://www.revenuecat.com/state-of-subscription-apps-2025/)
- Download-to-trial is 9.8% for high-priced apps and 4.3% for low-priced apps. Trial-to-paid runs the other way: 47.8% for low-priced vs 28.4% for high-priced. — [RevenueCat SOSA 2025](https://www.revenuecat.com/state-of-subscription-apps-2025/)
- Health & Fitness trial-to-paid is 39.9% at the median and 68.3% for the top 10%. Media & Entertainment is 43.8% and Travel 48.7%. — [RevenueCat SOSA 2025](https://www.revenuecat.com/state-of-subscription-apps-2025/)
- D35 install-to-paid is 12.11% for hard paywalls and 2.18% for freemium. By price, it's 2.7% for high-priced and 1.5% for low-priced apps. Health & Fitness P90 is 12.1%, and the North America upper quartile is 5.5% (P90 10.5%). — [RevenueCat SOSA 2025](https://www.revenuecat.com/state-of-subscription-apps-2025/)
- D60 revenue per install is $0.31 overall at the median and $0.63 for Health & Fitness (P90 $4.19). The App Store median is $0.38 vs $0.14 on Google Play. — [RevenueCat SOSA 2025](https://www.revenuecat.com/state-of-subscription-apps-2025/)
- Year-1 realized LTV is $55.21 at the median for high-priced apps and $8.08 for low-priced apps. — [RevenueCat SOSA 2025](https://www.revenuecat.com/state-of-subscription-apps-2025/)
- Refunds run 2-5% of payers. By category: Education 4.86%, Health & Fitness 4.71%, Business 2.88%, Gaming 2.67%, Travel 1.51%. Hard paywalls see 5.8% vs 3.4% for freemium, and low-priced plans 2.2%. — [RevenueCat SOSA 2025](https://www.revenuecat.com/state-of-subscription-apps-2025/)

**Adapty State of In-App Subscriptions 2025 ($1.9B revenue, 11,000+ apps)**
- Install-to-trial is "below 12% in most cases". — [Adapty 2025 summary](https://adapty.io/blog/state-of-in-app-subscriptions-2025-in-10-minutes/)
- Adapty states a no-trial "install-to-paid" of 18-38%, highest in Lifestyle and Productivity. That range is far above every other install-to-paid benchmark here. It's probably a paywall-view-to-purchase figure or a misstatement, so don't use it as install-to-paid without checking the PDF. — [Adapty 2025 summary](https://adapty.io/blog/state-of-in-app-subscriptions-2025-in-10-minutes/)
- Refunds are 4.2% on annual plans (highest) and 2.6% on weekly plans (lowest). They run above 3% in LATAM and the US, and about 2.3% in Europe and MEA. — [Adapty 2025 summary](https://adapty.io/blog/state-of-in-app-subscriptions-2025-in-10-minutes/)
- Monthly-plan 12-month LTV for Lifestyle is $42.8. — [Adapty 2025 summary](https://adapty.io/blog/state-of-in-app-subscriptions-2025-in-10-minutes/)
- Adapty's report lists the US$1.9B revenue figure, while its English landing page says US$1.0B, so the two Adapty sources disagree. — [Adapty report page](https://adapty.io/reports/state-of-in-app-subscriptions-2025/); [Adapty PDF](https://uploads.adapty.io/state_of_in_app_subscriptions_2025.pdf)

**Paywall view-to-purchase**
- Superwall's onboarding paywalls (Feb-May 2026, 40M+ paywall opens) convert at 9.07% for single-page and 12.41% for multi-page paywalls, a 37% gap. Conversion here means trial starts plus direct purchases per paywall viewer. Paywalls with zero transactions were excluded, which pushes the averages up. — [Superwall](https://superwall.com/blog/new-postmulti-page-onboarding-paywalls-convert-37-better-than-single-page-heres-why)
- One third-party glossary gives rough ranges of 5-12% for onboarding paywall conversion and 8-20% for contextual paywalls. These aren't audited. — [mwm.ai](https://mwm.ai/glossary/paywall)

### Inferences
- A realistic baseline for ShenTarot, a freemium app with a generous free tier in Lifestyle or Entertainment, is about 1.5-3% install-to-paid by D35. A top-quartile target is about 5%. Hard-paywall figures (10-12%) don't apply unless the free tier is cut sharply.
- ShenTarot is AI-powered, so expect higher revenue per payer but faster monthly churn. That argues for pushing annual plans and credit packs over monthly.
- Health & Fitness refund rates (about 4.7%) and Adapty's annual-plan figure (4.2%) suggest budgeting 3-5% refunds on Premium. A $1.99 intro month will likely cut refund exposure in the first period.

### Gaps
- No public Lifestyle, Social & Lifestyle, or Entertainment install-to-paid medians for 2025 or 2026 from RevenueCat. They're in the gated PDF.
- No category benchmarks specific to astrology or tarot from any source. I didn't find Appfigures or Sensor Tower conversion data, since they publish revenue and download estimates, not funnel conversion.
- I found no reliable cross-industry median for paywall view-to-purchase outside onboarding placements.

---

## 2. Paywall timing and placement: onboarding vs contextual, hard vs soft, paywall views before conversion

### Takeaway
Most conversions happen on install day, so the first session matters most. Even in freemium apps, an onboarding paywall usually captures the largest share of trial starts and purchases. Contextual paywalls, shown at a value or limit moment, convert better per view and need different messaging. Hard paywalls convert about 5x more installs to paid with similar long-term retention, but have higher refunds.

### Cited Findings
- 82% of trial starts happen on install day (RevenueCat 2025). Adapty reports 89.4% of trial starts on Day 0, ranging 87-90% across regions. — [RevenueCat SOSA 2025](https://www.revenuecat.com/state-of-subscription-apps-2025/); [Airbridge summarizing Adapty](https://www.airbridge.io/en/blog/paywall-conversion-structural-decisions)
- RevenueCat's paywall guide says the onboarding paywall is "often where most conversions happen". In the Mojo app, onboarding accounts for about half of trial starts. — [RevenueCat paywall guide](https://www.revenuecat.com/blog/growth/guide-to-mobile-paywalls-subscription-apps.md)
- Grade, a vendor, claims more than 80% of paid conversions happen during onboarding. It publishes no methodology, so treat this as weak evidence. — [Grade](https://usegrade.com/blog/post/80-percent-of-paid-conversions-happen-during-onboarding)
- In a sample of 40 apps, 77.5% placed the first paywall in the final third of the onboarding flow. This is placement frequency, not outcome. — [Lazyweb](https://www.lazyweb.com/research/should-the-paywall-come-before-or-after-onboarding)
- Multi-page onboarding paywalls convert 37% better than single-page ones (12.41% vs 9.07%) but make up only 24% of onboarding paywall opens. — [Superwall 2026](https://superwall.com/blog/new-postmulti-page-onboarding-paywalls-convert-37-better-than-single-page-heres-why)
- In a JourneyStamp case study, context-specific paywalls (different messages for onboarding vs after using a premium feature) raised conversion 50%. — [Superwall JourneyStamp case study](https://superwall.com/case-studies/journeystamp)
- Hard vs freemium: D35 download-to-paid is 10.7% vs 2.1% (2026) and 12.11% vs 2.18% (2025). D60 revenue per install is 8x higher. Yearly-subscriber 1-year retention is 27% vs 28%. Monthly Year-1 retention is 12.8% hard vs 9.3% freemium (2025). Refunds are 5.8% vs 3.4% (2025). — [RevenueCat 2026 trends](https://www.revenuecat.com/blog/growth/subscription-app-trends-benchmarks-2026); [RevenueCat SOSA 2025](https://www.revenuecat.com/state-of-subscription-apps-2025/)
- Superwall says only about 50% of users who start an in-app purchase complete it. — [Superwall transaction-abandon case study](https://superwall.com/blog/17-revenue-boost-with-transaction-abandon-paywalls-a-case-study)

### Inferences
- ShenTarot's highest-intent moment is right after the first card scan and reading on Day 0. A soft paywall at the end of onboarding, showing the annual plan's $1.99 first month, plus a contextual paywall when credits run out or on a follow-up question, matches the evidence.
- Ten welcome credits may delay the "limit" moment past Day 0, when about 82-89% of conversions occur. Test fewer welcome credits, or an onboarding paywall shown before the credits are spent.
- The credits-exhausted paywall should lead with the outcome the user just wanted ("continue this reading"), not a generic pitch, in line with the JourneyStamp result.

### Gaps
- I found no published benchmark for how many paywall views it takes before a user converts. I couldn't find any for freemium apps.
- There's no head-to-head controlled data comparing onboarding and contextual paywall shares in freemium Lifestyle apps.

---

## 3. Free trial vs paid intro offer ($1.99 first month) vs no trial

### Takeaway
Longer trials convert better than short ones, and most 3-day trial cancellations happen on Day 0. Paid intro offers can lift install-to-paid sharply and cut acquisition cost, but they lower LTV and full-price renewal. The evidence for paid intros comes from a single app case study and publisher data, not large app-level benchmarks.

### Cited Findings
- Trial-to-paid by trial length (2026 median): 42.5% for 17-32 days, 37.4% for 5-9 days, 25.5% for 4 days or less. The share of apps using trials of 4 days or less still rose from 42.1% to 46.5%. — [RevenueCat SOSA 2026](https://www.revenuecat.com/state-of-subscription-apps); [RevenueCat trends 2026](https://www.revenuecat.com/blog/growth/subscription-app-trends-benchmarks-2026)
- 2025 figures: trials of 17-32 days convert at 45.7% vs 26.8% for shorter trials. Top apps exceed 60% at any trial length. — [RevenueCat SOSA 2025](https://www.revenuecat.com/state-of-subscription-apps-2025/)
- Share of trial cancellations that happen on Day 0: 55.4% for 3-day, 39.8% for 7-day, 35.7% for 14-day and 31.1% for 30-day trials. 84% of 3-day trial cancellations happen by Day 1. — [RevenueCat SOSA 2026](https://www.revenuecat.com/state-of-subscription-apps); [RevenueCat trends 2026](https://www.revenuecat.com/blog/growth/subscription-app-trends-benchmarks-2026)
- Adapty: users who start with a trial have up to 64% higher LTV, and weekly-plan Day-30 retention rises from 23% to 42% with a trial. Adapty also says trials "don't improve early conversion". — [Adapty 2025 summary](https://adapty.io/blog/state-of-in-app-subscriptions-2025-in-10-minutes/)
- A RevenueCat case study (one app, June 2025) replaced trials with intro discounts: weekly 85% off and monthly 75% off. Install-to-paid went from about 3% to about 14% at peak and about 12% on average. SKAN CPA fell from $105 to $13. LTV-30 fell from $55 to $10, and only 40% paid full price at first renewal, vs more than 50% with a free trial. Yearly conversion was the same at $40 and $60, so they stopped discounting yearly. — [RevenueCat intro offers](https://www.revenuecat.com/blog/growth/introductory-offers-apps)
- Piano's publisher data, which is web news and not mobile apps, shows paid trials (even $1) retaining 82.1% at trial end vs 61.7% for free trials. — [Spiny.ai trends summarizing Piano](https://trends.spiny.ai/?p=1160)
- RevenueCat guidance says a low intro price validates the payment method and screens for serious users, which avoids the failed charges seen at trial end. This is vendor opinion. — [RevenueCat intro offers](https://www.revenuecat.com/blog/growth/introductory-offers-apps)
- Win-back and offer types on the App Store include Free, Pay as you go and Pay up front (see section 6). — [Apple App Store Connect Help](https://developer.apple.com/help/app-store-connect/manage-subscriptions/set-up-win-back-offers/)

### Inferences
- A $1.99 first month on the annual plan is a reasonable low-friction entry and should screen out low-intent users better than a free trial. The case study suggests watching the full-price conversion at month 2. Annual plans see about 30-35% of cancellations in the first month (see section 5), so expect heavy cancellation during the $1.99 month.
- Consider an A/B test of a 7-day free trial on annual vs the $1.99 first month. Benchmarks favor trials of 5 days or more over 3-day trials.
- The case study found yearly price insensitivity between $40 and $60. ShenTarot's $39.99 annual price is at the North America median (section 5) and may have room to rise. This is untested.

### Gaps
- There's no large-sample app benchmark comparing paid intro offers with free trials on conversion and 12-month retention. RevenueCat's public pages don't break it out.
- I didn't verify which intro-offer durations Apple allows on an annual product (for example, a 1-month pay-up-front on a 1-year subscription). Check the "Set up introductory offers" page in App Store Connect Help.

---

## 4. Hybrid monetization (subscriptions + consumable credits)

### Takeaway
Hybrid models are common in Gaming but rare elsewhere. Only about 10-13% of apps combine subscriptions with consumables. RevenueCat argues for hybrid in AI apps because of usage costs, but I found no published data on whether credits cannibalize subscriptions. The working principle is to separate access (subscription) from consumption (credits).

### Cited Findings
- App mix (2026): 63.5% subscriptions only, 23.2% subscriptions plus lifetime, 10.7% subscriptions plus consumables, 2.5% all three. In Gaming, 27.5% use subscriptions plus consumables. RevenueCat says only about 10% of apps run true hybrid models. — [RevenueCat SOSA 2026](https://www.revenuecat.com/state-of-subscription-apps)
- In 2025, 35%+ of apps mixed subscriptions with consumables or lifetime purchases (Gaming 61.7%, Social & Lifestyle 39.4%). The same 2025 page also says "nearly 20%" of Social & Lifestyle apps combine subscriptions and consumables, which it doesn't reconcile with 39.4%. — [RevenueCat SOSA 2025](https://www.revenuecat.com/state-of-subscription-apps-2025/)
- RevenueCat's 2025 report also says apps combining consumables or lifetime purchases with subscriptions see stronger revenue and retention. The direction of causation isn't established. — [Subscription Insider summary of RevenueCat 2025](https://subscriptioninsider.com/article-type/news/revenuecats-state-of-subscription-apps-2025-report-ais-dominance-retention-challenges-and-the-shift-away-from-pure-subscriptions)
- RevenueCat's AI hybrid guidance: subscriptions stay the anchor for revenue and retention. Heavy usage should be capped, metered, or monetized separately so power users pay for the costs they create. "AI has real COGS", and free users can have negative unit economics. It treats cannibalization as a risk that needs guardrails but gives no data. — [RevenueCat AI hybrid monetization](https://www.revenuecat.com/blog/growth/ai-hybrid-monetization)
- RevenueCat describes hybrid as combining subscriptions with one-off purchases, consumables, ads or partnerships to match different willingness to pay. — [RevenueCat hybrid techniques](https://www.revenuecat.com/blog/growth/hybrid-monetization-techniques.md)
- A consultancy claims hybrid buyers spend several times more per year than subscription-only users. The claim is unsourced. — [ContextSDK](https://contextsdk.com/blogposts/the-hybrid-pivot-why-subscriptions-alone-no-longer-work-in-2026)

### Inferences
- In ShenTarot's current pricing, the $5.99 pack (40 credits, about $0.15 each) sits close to the $6.99 monthly plan. Cannibalization is most likely where packs cost about the same as a month of Premium. Premium should clearly beat packs on value per credit for anyone who reads more than a few times a week. Packs should serve occasional users and top-ups. Two options are to show a "Premium = X readings/month for $Y" comparison next to the packs, or to show the subscription paywall before the pack store.
- The daily free credit already acts as a retention mechanic. Packs give low-commitment buyers a first purchase, and that first purchase can later be offered an upgrade to Premium. Measure pack-buyer to subscriber conversion directly.

### Gaps
- I found no public data on whether credit packs cannibalize or complement subscriptions, and no hybrid AI-chat, astrology or tarot app reporting such data.
- I found no named consumer apps with published credit-plus-subscription results in this search.

---

## 5. Pricing presentation: annual vs monthly, per-period equivalents, number of plans, weekly plans, regional pricing

### Takeaway
Annual plans retain far better (about 44% Year-1 vs 17% monthly and about 3% weekly) and earn the most revenue per install. Weekly plans are growing and convert well up front but churn heavily. Three-plan paywalls are associated with the highest LTV (Adapty), and willingness to pay varies 2-3x by country.

### Cited Findings
- Year-1 retention by plan (2025 report): yearly 44.1%, monthly 17.0%, weekly 3.4%, all down from the prior year. Monthly retention is 22.5% at low prices, 16.4% at mid and 12.2% at high. — [RevenueCat SOSA 2025](https://www.revenuecat.com/state-of-subscription-apps-2025/)
- Revenue per install by plan (2026): D14 is $0.36 yearly, $0.18 monthly and $0.07 weekly. D60 is $0.46 yearly, $0.24 monthly and $0.09 weekly. — [RevenueCat SOSA 2026](https://www.revenuecat.com/state-of-subscription-apps)
- Annual churn timing (2026): the first month accounts for 35% of annual cancellations, then 3-10% per month after that, with a spike before renewal. — [RevenueCat trends 2026](https://www.revenuecat.com/blog/growth/subscription-app-trends-benchmarks-2026)
- First renewal rate is 61.7% (2025). 30-50% of weekly subscribers churn at the first renewal, and 15-40% of monthly subscribers. — [RevenueCat SOSA 2025](https://www.revenuecat.com/state-of-subscription-apps-2025/)
- Median prices (2026): monthly is $9.99 in North America and $3.75 in IN/SEA. Yearly is $39.99 in North America, $39.44 in Western Europe and $18.32 in IN/SEA. Weekly ranges $4.61-$7.03 across regions. — [RevenueCat SOSA 2026](https://www.revenuecat.com/state-of-subscription-apps)
- Adapty 2025 average prices: weekly is US $8.1 and Europe $8.3. Monthly is US $15.2 and Europe $13.3. Annual is US $44.6 and Europe $42.0. Annual costs about 5x weekly in Health & Fitness. — [Adapty 2025 summary](https://adapty.io/blog/state-of-in-app-subscriptions-2025-in-10-minutes/)
- Weekly plans are nearly half of all in-app subscriptions, up 10%. 65% of weekly subscribers cancel within 30 days, and 5% are still active after a year. Three-plan paywalls (weekly, monthly and annual) drive the strongest LTV. — [Adapty 2025 summary](https://adapty.io/blog/state-of-in-app-subscriptions-2025-in-10-minutes/)
- Willingness to pay differs 2-3x across countries. Weekly prices in the Netherlands are 62% above the US, and Turkey's are about 3.5x below. — [Adapty 2025 summary](https://adapty.io/blog/state-of-in-app-subscriptions-2025-in-10-minutes/)
- In the RevenueCat case study, showing prices per day and setting the yearly plan to the lowest per-day price shifted the plan mix toward yearly. — [RevenueCat intro offers](https://www.revenuecat.com/blog/growth/introductory-offers-apps)
- 2025 plan mix: 78% weekly in Gaming, 43% yearly in North America and 47% yearly in APAC. — [RevenueCat SOSA 2025](https://www.revenuecat.com/state-of-subscription-apps-2025/)

### Inferences
- ShenTarot's $39.99 annual price matches the North America median, and its $6.99 monthly price is below the $9.99 median. That makes the annual plan only about 5.7x monthly, a weak discount anchor. A typical anchor is a monthly price high enough that annual reads as a large saving. Show "$3.33/mo" on annual and a "save ~52%" badge vs monthly.
- The 3-month plan at $14.99 ($5.00/mo) sits between monthly and annual and may dilute the choice. Testing a two-plan paywall (annual and monthly) or a weekly plan is consistent with the benchmarks. Weekly plans churn heavily but fit impulsive, entertainment-style use.
- Use Apple's localized price tiers, or set lower prices manually in IN/SEA and LATAM, given the 2-3x willingness-to-pay gaps.

### Gaps
- I found no controlled study isolating the effect of showing per-week or per-month equivalents on conversion. The evidence is one case study.
- I found no data on the 3-month plan specifically.

---

## 6. Win-back and second-chance offers

### Takeaway
Second-chance offers after a user abandons the purchase sheet can add a meaningful share of revenue, per vendor case studies, but Apple may push back in review. Monthly churners reactivate most often (about 13%). Apple's native win-back offers (iOS 18+) target lapsed subscribers automatically, with configurable eligibility, and there's no public data on their uplift.

### Cited Findings
- Superwall case study: a transaction-abandon discount paywall produced 17% of total revenue and reached about 20% of paywalled users. Conversion was 8.9% vs 6.3%, though Superwall admits it's hard to know how many would have converted anyway. Refunds were 3.3% for the discounted group vs 6.8%. Superwall also says 25-40% of revenue came from this method in some of its own apps. — [Superwall case study](https://superwall.com/blog/17-revenue-boost-with-transaction-abandon-paywalls-a-case-study); [Superwall transaction abandons](https://superwall.com/solutions/transaction-abandons)
- The same case study warns that Apple says this tactic leads to "unintentional purchases" and that it can cause App Review issues. — [Superwall case study](https://superwall.com/blog/17-revenue-boost-with-transaction-abandon-paywalls-a-case-study)
- Reactivation by plan (2025): monthly churners reactivate at more than 13% in most regions, weekly at 9.37% and yearly at 4.58%. — [RevenueCat SOSA 2025](https://www.revenuecat.com/state-of-subscription-apps-2025/)
- Cancellation causes: voluntary unsubscribing is 74.5% of App Store cancellations. Billing errors are 14% on the App Store in 2026 (15.1% in 2025) and 31% on Google Play. — [RevenueCat SOSA 2025](https://www.revenuecat.com/state-of-subscription-apps-2025/); [RevenueCat trends 2026](https://www.revenuecat.com/blog/growth/subscription-app-trends-benchmarks-2026)
- Apple win-back offers have these rules:
  - Each offer is set per subscription product.
  - Eligibility depends on minimum paid duration (1-24 months or 3-5 years), time since last subscribed (1-24 months) and an optional 2-24 month wait between offers.
  - Offer types are Free, Pay as you go or Pay up front.
  - They appear on the Manage Subscriptions page (iOS 14.3+), in an in-app win-back sheet (iOS 18+), on the App Store when promoted (iOS 18+) and through a redemption URL.
  - Limits are 5 running offers per storefront per subscription and 350 in total.
  — [Apple App Store Connect Help](https://developer.apple.com/help/app-store-connect/manage-subscriptions/set-up-win-back-offers/)
- Apple's StoreKit page on win-back offers didn't render. The App Store Connect help page above is the primary source used. — [Apple StoreKit docs](https://developer.apple.com/documentation/storekit/supporting-win-back-offers-in-your-app)

### Inferences
- For ShenTarot, set up an Apple win-back offer for lapsed monthly subscribers, such as a discounted pay-up-front month, since monthly churners reactivate most often. For users who dismiss the paywall, a credit-pack fallback ("not ready? get 10 readings for $1.99") is a softer second chance than a discount. It avoids the "unintentional purchase" concern and fits the hybrid model.
- Offer codes and promotional offers can drive targeted re-engagement campaigns, but no benchmarks were found.

### Gaps
- I found no public uplift data for Apple win-back offers, promotional offers or offer codes.
- I found no independent, non-vendor measurement of exit or abandon-discount lift.

---

## 7. Retention drivers before paying (habits, notifications, streaks) and their link to conversion

### Takeaway
Evidence that pre-payment engagement drives conversion is mostly indirect. Push notifications are strongly associated with better retention (Airship). Streak mechanics drive large engagement responses (Duolingo), but I found no published data linking streaks to paid conversion. Freemium apps convert later and less than hard-paywall apps, so a freemium app has to keep users coming back to reach that later conversion.

### Cited Findings
- Airship's data (63M users, about 1,500 apps, older data) is reported as showing push can lift 90-day retention by up to 190%. Apps sending relevant pushes in the first 90 days see about 3x retention. These are secondary summaries, and I didn't verify the primary report. — [Airbridge](https://www.airbridge.io/en/blog/push-notification-strategy-for-subscription-apps); [Adapty push best practices](https://adapty.io/blog/push-notification-best-practices/)
- Personalized pushes are claimed to get up to 4x higher open rates than broadcasts. This is vendor content. — [Adapty push best practices](https://adapty.io/blog/push-notification-best-practices/)
- Adapty recommends trial-ending reminders and feature prompts to convert non-payers, but gives no conversion numbers. — [Adapty push revenue](https://adapty.io/blog/how-to-use-push-notifications-to-increase-app-revenue/)
- Duolingo's Streak Revival campaign let 15.4M learners revive streaks, including about 8M with no active streak. Its DAU-to-next-day retention (Current User Retention Rate) hit a record 84%. Paid subscribers grew 17% to 12.7M in Q2 2026. None of these figures links streaks to paying. — [Pulse 2.0 summary of Duolingo results](https://pulse2.com/duolingo-daily-active-users-reach-58-7-million-as-retention-hits-record-84-and-social-accounts-top-1-billion-organic-impressions/)
- Hard paywalls reach 5x the freemium D35 conversion with similar yearly retention. This suggests that in many freemium apps, pre-payment engagement isn't turning into payment. — [RevenueCat trends 2026](https://www.revenuecat.com/blog/growth/subscription-app-trends-benchmarks-2026)

### Inferences
- ShenTarot's daily free credit already works like a daily return habit, similar to a "daily card" ritual. Pairing it with an opt-in daily push ("your daily card is ready") and a reading streak could build the habit. The conversion trigger should come when a user wants more than the daily allowance, such as a follow-up question or a full spread.
- The extra credit for signing in raises account creation and allows email and push win-back. Measure the sign-in rate and the paid rate among signed-in users as a cohort.
- Any claim that streaks lift conversion should be validated with a holdout test in ShenTarot. No published benchmark exists.

### Gaps
- I found no quantified study linking streaks or push to free-to-paid conversion for subscription apps in 2024-2026.
- I didn't obtain Phiture or Airship primary reports, and the push retention figures are secondary.
