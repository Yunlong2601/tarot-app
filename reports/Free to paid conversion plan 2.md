# Win the first session, then earn the habit

With Tier 1 and Tier 2 shipped, ShenTarot's honest pricing is no longer what costs it hesitant users. The bigger losses now come from two moments the app barely uses: **install day**, and **the days after the first reading**. Industry data puts **82% of trial starts on install day** and **93% of first purchases within 24 hours**. A paywall shown during onboarding converts about **3.7x better per view** than one shown later. ShenTarot's onboarding is three static slides, though. It asks nothing about the user, shows no offer after the first reading, and never asks for the daily reminder except from a Settings toggle. Calm's version of that reminder ask, placed right after the first session, got a **40% opt-in** and was linked to **about 3x retention**. The next tiers therefore start with work that costs days:

- **Measurement.** The app has no product-analytics events at all.
- **A reminder ask after the first reading.**
- **Push copy that carries real content.**
- **Apple's system review prompt.**
- **Apple win-back offers**, which need only App Store Connect setup.

After that come first-session personalisation (two tap-to-answer intent questions that feed the reading, the paywall and a Day-1 push), then habit depth (a streak rest day, moon-phase rituals and a widget). Pricing tests come last, because ShenTarot's traffic is probably too small to read them quickly. None of the lifts quoted here were measured on a tarot app. They come from vendor datasets and neighbouring categories (meditation, language learning, wellness), so each one is a hypothesis for ShenTarot to test, not a forecast.

## ShenTarot already has a habit loop, but hides the two levers that move it most

A code check of this worktree shows ShenTarot already has most of a retention loop:

- card of the day;
- a streak counter on the You tab;
- a reading journal;
- a week-later look-back notification;
- a monthly recap;
- a share card;
- daily free credits;
- a referral programme, behind the `REFERRALS` build flag.

What it lacks is any way to bring that loop in front of the user. The daily reminder can be turned on only from Settings (`settings_screens.dart:29`), and its copy never changes ("Your card of the day" / "Take a quiet moment with today's card.", `reminder_service.dart:117`). All notifications are local. There is no WidgetKit extension. The only review entry point is a Settings link that opens the App Store listing (`settings_screen.dart:183`); Apple's system rating prompt is never called. The onboarding screen is three explainer slides with no questions. One line of copy carries all the personalisation: "Readings that fit your question".

Two code findings change how the plan is ordered. First, **the app has no analytics SDK and no event logging**, so paywall views, reminder opt-ins and first-reading completion cannot be counted today. RevenueCat records purchases, but not the funnel that leads to them. Every "measure" column below depends on fixing that first. Second, offer codes are redeemed through `Purchases.presentCodeRedemptionSheet()` (`subscription_service.dart:276`). RevenueCat warns that Apple's in-app redemption sheet "has proven to be extremely unstable" and gives no success callback. It recommends linking to the `apps.apple.com/redeem` URL and then calling `syncPurchases` instead ([RevenueCat](https://www.revenuecat.com/docs/subscription-guidance/subscription-offers/ios-subscription-offers)).

The evidence on where to focus is lopsided. On the conversion side, the first session dominates:

- **82% of trial starts happen on Day 0**, in every category ([RevenueCat SOSA 2025](https://www.revenuecat.com/state-of-subscription-apps-2025/)).
- **93% of first purchases happen within 24 hours** and generate 89% of first-90-day revenue. Median paywall view-to-paid is **0.85% for onboarding paywalls versus 0.23% for later ones** ([Adapty State of Paywalls 2026](https://adapty.io/state-of-paywalls/report/)).

The same Adapty report adds a counterweight that matters for ShenTarot. In Lifestyle and Utilities, **48% of revenue starts after the first session**, so a freemium app with daily credits cannot rely on Day 0 alone. That makes retention the second half of the conversion problem, not a separate one.

No tarot or astrology app has published retention data. The best habit evidence comes from neighbouring apps:

- **Calm.** Reminder users retained about 3x better, but the setting sat in Settings and fewer than 1% found it. A prompt after the first meditation got 40% of viewers to set one, with "an equal boost in retention" ([Amplitude](https://amplitude.com/blog/calm-increased-retention-amplitude)).
- **Duolingo.** Its Streak Wager lifted D7 retention by 14% ([Duolingo, 2017](https://blog.duolingo.com/how-streaks-keep-duolingo-learners-committed-to-their-language-goals)).

Both results are old (2016–2017), from vendor or company blogs, and from adjacent categories. ShenTarot's current reminder placement repeats Calm's starting mistake almost exactly.

## Tier 3: instrument, then ship the cheap habit and trust fixes (about two weeks)

Tier 3 is a set of small changes that each take hours to two days. They need no pricing decisions, and most of them also lower App Review or complaint risk. Effort grades: **S** is under a day, **M** is 2–5 days, **L** is a week or more. Every user-facing string touches all 15 locale files.

| # | Change | Why | Effort | Measure | App Store note |
|---|---|---|---|---|---|
| 21 | **Funnel events** logged to ShenTarot's own backend: onboarding step, first reading done, paywall view by entry reason, sheet choice, reminder prompt shown/accepted, push opened, widget installed. Tag each install with a stable cohort and test-variant ID, and pass the variant to RevenueCat as a subscriber attribute. | No test below can be read without it. Doing it in-house avoids adding the third-party tracking SDKs that audits flag in astrology apps. | M | Event completeness against RevenueCat purchase counts | Update the privacy nutrition label if any data is linked to identity. Keep the App Tracking Transparency (ATT) prompt out. |
| 22 | **Reminder prompt after the first completed reading**: a sheet reading "Get your card of the day each morning?" with a time picker preset to 8:00. Request notification permission only when the user taps Yes. | This is Calm's 40% opt-in pattern. Today the reminder lives only in Settings. | S | Prompt accept rate; D1/D7 return, opted-in vs not | 4.5.4: content reminders are not marketing, but pushes "must not be required for the app to function". |
| 23 | **Push copy with real content**: 15–30 rotating variants. Pre-pick tomorrow's card at scheduling time and tease its theme ("The Star is waiting: a card about hope"). Mention the streak once it reaches 3. Re-schedule on every app open. | Personalised, behaviour-based pushes beat generic ones in vendor benchmarks. Generic, over-frequent pushes raised churn in a tracker-app case. | S–M | Push open rate; day-after return | 2.5.16: notifications must relate to app content. |
| 24 | **Evening "streak at risk" push**, sent only if today's card is not drawn and the streak is 3 or more. Cancel it when the card is drawn. Use `passive` interruption level, and give it its own toggle. | Duolingo found the "at risk" signal "hugely valuable" in its widget. | S | Streak survival past day 7 | 4.5.3 bans spam. Keep it to one a day at most. |
| 25 | **Apple's system review prompt** (`in_app_review` `requestReview()`) after the 2nd or 3rd completed reading, or when a reading is saved or marked as resonant. Never on first launch, on a paywall, after a purchase or after a failed scan. Keep the Settings link. | Today the app never asks. Rating-prompt timing visibly shapes category ratings. | S | Rating volume and average per version | 5.6.1: system API only, at most 3 times in 365 days. No "Do you enjoy ShenTarot?" gate. |
| 26 | **"Request a refund" in Settings**, using StoreKit `beginRefundRequest(in:)` (iOS 15+) through a small platform channel. Place it next to the existing Manage subscription link. | This answers the "they told me Apple controls refunds" complaint common in this category's reviews. Apple suggests putting the entry in settings or help. | S–M | Refund requests; support tickets | Apple decides refunds, so never promise one. |
| 27 | **Separate "Offers and news" notification consent**: a labelled toggle with consent text, off by default. Move the "introductory offer ends in 2 days" reminder under its own clearly labelled billing toggle. | Required before any push that mentions price, a sale or Premium. | S | Opt-in rate | 4.5.4: explicit in-app consent plus an in-app opt-out. |
| 28 | **Apple win-back offers** on the monthly, quarterly and annual products: one for users lapsed 1–3 months (for example the first month at $1.99, paid up front) and one for users lapsed 4–12 months. Turn on "Wait Between Offers". Keep streamlined purchasing on. Replace the redemption sheet with the redemption URL plus `syncPurchases`. | With streamlined purchasing on, Apple shows the offer itself in Manage Subscriptions and its win-back sheet, so almost no app code is needed. | S (mostly App Store Connect) | Win-back redemptions per product | Each subscription must be approved first. Offer prices cannot be edited once created. |

Change 21 comes first because the data most likely to change ShenTarot's priorities is its own, and that data does not exist yet. Change 22 is the cheapest high-evidence move in the whole plan. Calm's case is the closest thing to a controlled result for a reflection or wellness app. It is old and vendor-published, but its mechanism is plain: a habit tool nobody finds cannot build a habit ([Amplitude](https://amplitude.com/blog/calm-increased-retention-amplitude)). The reminder sheet should come after the first reading lands, not during onboarding. At that point the user has seen what the daily card is for, and an upfront permission ask would arrive before any value.

Changes 23 and 24 fix the reminder's content. Correlational push data, from Airship's 2017 study of 63 million users, found that opted-in users who received nothing retained worse than users who had opted out, and that daily or more frequent pushes went with the highest 90-day retention ([Airship](https://grow.urbanairship.com/rs/313-QPJ-195/images/WP_App_Retention_Rates_Benchmarks.pdf)). In MoEngage's 2024 benchmark, behaviour-based personalised pushes produced **2.17x higher conversions** on iOS ([MoEngage](https://www.moengage.com/benchmarks/customer-engagement-2024/)). A tracker-app case study found that generic, over-frequent pushes raised churn ([nGrow](https://ngrow.ai/cases/amma)). Those sources together set the rule:

- one daily push at a time the user picked;
- content in the push, not a generic nudge;
- at most one conditional evening nudge.

Co-Star shows the upside of a distinctive voice. Its daily pushes get screenshotted and shared, so they double as marketing ([OMR](https://omr.com/de/co-star-app-viral/)). ShenTarot's reflective brand argues for warmth rather than Co-Star's snark, but the lesson about voice carries over.

Apple's own wording settles the boundaries for changes 25 and 27. Guideline 5.6.1 says Apple "will disallow custom review prompts", and the system prompt can appear at most three times a year ([Apple](https://developer.apple.com/app-store/ratings-and-reviews/)). Guideline 4.5.4 says pushes "should not be used for promotions or direct marketing purposes unless customers have explicitly opted in to receive them via consent language displayed in your app's UI", with an in-app opt-out ([App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)). Change 27 is what makes any later offer or win-back push legal. Change 28 is nearly free to set up. Apple configures win-back offers per product: up to five active per storefront, with eligibility set by minimum paid duration and time since the user last subscribed. Apple shows them in Manage Subscriptions on iOS 14.3+ and in an in-app win-back sheet on iOS 18+ ([Apple](https://developer.apple.com/help/app-store-connect/manage-subscriptions/set-up-win-back-offers)). Showing them on ShenTarot's own paywall needs StoreKit 2, an In-App Purchase Key uploaded to RevenueCat, and RevenueCat iOS SDK 5.10+ ([RevenueCat](https://www.revenuecat.com/docs/subscription-guidance/subscription-offers/ios-subscription-offers)). Whether the `purchases_flutter` 10.16 wrapper exposes `eligibleWinBackOffers` was not verified. Until it is, rely on Apple's own surfaces.

## Tier 4: make the first session feel tailored, then ask once (two to three weeks)

The strongest controlled evidence on onboarding personalisation comes from Headspace, run with Irrational Labs and Purchasely. Adding a short quiz roughly **doubled course starts, from 31.25% to 62.97%**, even though every user got the same Basics course. Routing users to different courses based on their answers did *not* beat the default, because the matching logic weighted the wrong needs. The lift came from users **feeling** the experience was tailored, not from better matching ([Irrational Labs](https://irrationallabs.com/case-studies/headspace-doubled-course-starts/)). That study did not report paid conversion, and its publication date is unclear. It still points to a cheap, ethical move for ShenTarot. Ask one or two questions that genuinely shape the reading, and visibly reflect the answers back.

On the paywall side, **only 2% of paywall headlines use what the app knows about the user**. In Adapty's own tests, personalised onboarding raised ARPU by **13–35%** ([Adapty](https://adapty.io/state-of-paywalls/report/)). ShenTarot already built context-aware paywall headlines in Tier 2, so feeding them a life-area value is a small extension.

| # | Change | Why | Effort | Measure | App Store note |
|---|---|---|---|---|---|
| 29 | **Two optional intent questions** after the onboarding slides, as tap chips. "What's on your mind?" (love, work, self, family, a decision, just curious) and "How does it feel right now?" (hopeful, stuck, uncertain, curious). Include an optional birthday for a zodiac sign. Show a "Skip" button on every screen. End with a 2-second reflection screen: "Focusing your first reading on work and uncertainty". | The perceived-fit effect, at about 2x the first core action in Headspace. This is the tarot equivalent of the birth-data step Nebula and Co-Star use. | M | Onboarding completion; first-reading start rate; Day-0 purchase rate | 5.1.1(v): personal data must be optional unless core. Keep the answers on the device or send them only with the reading request. |
| 30 | **Feed the answers into the reading prompt and the reading's opening line** ("You asked about work, and you said you feel stuck"). Also show a short "how your cards connect to your question" section. | This answers the category's top quality complaint: AI that reads each card on its own and ignores the question. | S–M | Reading rating; second-reading rate | 5.1.2(i): disclose that the answers go to the AI model. |
| 31 | **Soft offer after the first reading lands**, in session 1. Add a new paywall entry reason, `first_reading`, with a headline built from the life area ("Keep exploring your question about work"). It is dismissible to the free credits, and dismissing it never blocks anything. Run it as an A/B test against no offer (a holdout). | The PhotoRoom "aha, then paywall" pattern. Onboarding paywalls convert at 3.7x per view. | S (Tier 2 paywall already handles context) | Day-0 purchase rate; D7 retention; refunds, all against the holdout | 3.1.2(c): describe what the user gets. Keep the $39.99 renewal next to "Start for $1.99". |
| 32 | **Day-1 follow-up push** tied to the first reading's topic ("Yesterday's reading on work: what's shifted? Draw a clarifying card"). Send it only to users who opted in through change 22. | Reuses onboarding answers in re-engagement, which is the Co-Star and Character AI pattern. | S | Day-1 return | Content, not marketing, as long as it names no price. |
| 33 | **"Your take first" option** before the AI reading: an optional text field where the user writes what they see, which the reading then responds to. | Some users treat AI as a "second opinion" after reading the cards themselves. Their own input also strengthens the feeling that the reading is theirs, and it differentiates ShenTarot from chatbots. | M | Usage; reading rating; conversion of users who write vs those who skip | — |
| 34 | **Visible personal markers in every reading**: the question quoted back, the names of the card positions, "scanned from your deck" for scan readings, and "last time you drew…" when there is history. | Counters both "generic" complaints, repetition and cards read on their own, without hiding that the reading is AI. | S–M | Reading rating; paywall conversion after scan readings vs digital readings | — |

Change 31 reverses part of the earlier plan, so it needs explaining. The earlier report advised against a paywall *before* the first reading, and that advice stands. Hard paywalls carry higher refund rates (5.8% against 3.4% for freemium) ([RevenueCat SOSA 2025](https://www.revenuecat.com/state-of-subscription-apps-2025/)), and a hesitant user should see value before being asked to pay.

An offer *after* the first reading is different. The case studies that show 2–5x lifts from earlier paywalls (Greg, Rootd and FitnessAI) all changed other things at the same time, and none is a clean before-versus-after-value test ([RevenueCat](https://www.revenuecat.com/blog/growth/paywall-placement/)). Adapty's correlational data says apps that show the paywall after a measurable value moment get about **2.1x the trial-start rate** of immediate hard paywalls ([RocketShip HQ](https://www.rocketshiphq.com/?p=5390)).

ShenTarot's reading takes under a minute to arrive, so it can show its value fast enough to make an offer in session 1 without asking for money first. That is why change 31 must run with a holdout and be judged on D7 retention and refunds as well as purchases. A user who feels ambushed after their first reading is the user who leaves a review about subscription traps.

The questions in change 29 must also do real work, or they become theatre. Users of AI tarot complain specifically that chatbots read each card literally and on its own, missing the question ([r/tarotpractice](https://redlib.ssps.io/r/tarotpractice/comments/1kpziwp/chat_gpt)). An App Store reviewer called one AI tarot app's paid version "watered down" ([App Store](https://apps.apple.com/app/id6447095993)). Feeding the answers into the prompt (change 30) is what makes the tailoring honest.

The lesson from Nebula runs the other way. Its quiz-to-paywall flow is linked in user reports to unnoticed weekly billing and "$1 reading then $39 charge" complaints ([Apple Community](https://discussions-kr-prz.apple.com/thread/256021474)). ShenTarot should copy the quiz and not the billing. Research on AI disclosure points the same way. Across 13 experiments, people who disclosed AI use were trusted less ([University of Arizona](https://experts.arizona.edu/en/publications/the-transparency-dilemma-how-ai-disclosure-erodes-trust/)), so the better strategy is to keep the "AI · for reflection" label and pair it with visible specifics about how the reading was made. That last point is a hypothesis. No tarot app has tested it.

## Tier 5: give users a reason to return between paydays (three to five weeks)

These are the larger retention builds. Most are local Dart plus scheduled notifications. The widget needs native Swift.

| # | Change | Why | Effort | Measure | App Store note |
|---|---|---|---|---|---|
| 35 | **Streak rest day**: one automatic grace day a week, shown as "Your practice rested on Sunday", plus a freeze earned at milestones. Never ask for credits to restore a streak. | Duolingo's Weekend Amulet made users 4% more likely to return a week later and 5% less likely to lose their streak. A gentle version fits a reflection brand. | S–M | Share of streaks surviving past 7 and 30 days; weekly active days | — |
| 36 | **Moon-phase rituals**: compute New and Full Moon dates on the device. Schedule `passive` pushes ("New Moon tonight: a three-card intention spread") and add themed New Moon and Full Moon spreads that cost the normal credits. | A return reason roughly every two weeks that is native to the category, as Moonly does. Gives a natural in-app occasion for an upsell. | M | Moon-push open rate; readings on moon days; conversion from moon-spread locks | Any upsell stays inside the app. A push mentions Premium only with change 27 consent. |
| 37 | **Weekly "your week in cards"**: reuse the monthly recap logic at a weekly cadence, with a Sunday push. | The reminiscing pattern (Day One, Wrapped). Its effect is unquantified, but it reuses existing code. | S–M | Recap open rate; Monday return | — |
| 38 | **Card-of-the-day widget** for the home and lock screens: a face-down "tap to reveal" state until drawn, then the card and the streak. Build with SwiftUI WidgetKit plus an App Group, for example via the `home_widget` package. Show an in-app "Add the widget" explainer after a 7-day streak. Free for everyone, with an optional premium skin. | Duolingo widget users had "far better retention" even after controlling for commitment, and installs "skyrocketed" after an in-app explainer. Organic widget adoption is low. | L (3–5 days native) | Widget installs (App Store Connect widget usage report); D30 retention of widget users | 2.5.16: content-related only. 2.5.18: no ads in widgets. |
| 39 | **Carry over from the earlier plan, if not yet built**: one free look back for free users, and a relationship spread ("You and them"). | Relationship readings are the most consistently monetised moment in the category. Free users have never seen the look back, which the paywall lists as a feature. | M each | Look back → Premium; relationship-spread lock conversion | — |

The widget is the only item here with credible retention evidence, and that evidence is only directional. Duolingo reported that half of its widget users have streaks of six months or more, and that retention was "far better" even after controlling for commitment. It gave no percentages ([Duolingo](https://blog.duolingo.com/widget-feature)). Adoption is the catch. A self-selected 2024 reader poll found "Don't use" was the most common answer for iPhone widgets ([TidBITS](https://tidbits.com/2024/01/15/do-you-use-it-widgets-see-middling-adoption/)). The widget only pays off if it is promoted inside the app at a moment of commitment.

Co-Star appears to have moved its widget behind its subscription, judging from a user review ([App Store](https://apps.apple.com/us/app/co-star-personalized-astrology/id1264782561)). ShenTarot should not copy that. The widget's job is to build the daily habit that later converts. Paywalling it would also repeat the "paywall creep" pattern that produces Co-Star's harshest one-star reviews ([Unstar](https://unstar.app/blog/co-star-sanctuary-pattern-nebula-stellium-astrology-apps-ranked-2026)). A premium skin keeps the core free.

Streak protection (change 35) is the best-evidenced mechanic, but a punishing streak sits badly with a spiritual brand. Duolingo's Weekend Amulet result came alongside the observation that its daily active users drop 5–10% at weekends ([Duolingo](https://blog.duolingo.com/how-streaks-keep-duolingo-learners-committed-to-their-language-goals)). A grace day removes the guilt without removing the commitment. The streak must never become a credit sink, because "pay to save your streak" is exactly the kind of manipulation the earlier plan ruled out. Moon rituals (change 36) rest only on a competitor's design choice: Moonly builds its loop around New Moon and Full Moon rituals ([App Store](https://apps.apple.com/US/app/id1489889871)). There is no measured effect, so ship them as a test with their own push-open and reading counts.

Skip Live Activities. There is no ongoing event to show, no credible lift data exists, and guideline 4.5.3 names Live Activities in its anti-spam rule ([App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)). Social and friend features such as Co-Star's compatibility charts are a large build with no evidence for this audience, so leave them for later.

## Tier 6: test price and packaging one bold arm at a time, and catch churn at the door

Pricing comes last for two reasons. The earlier plan showed ShenTarot is already at or below category prices. And the published experiments needed large samples: Glam AI's decoy test ran about **24,500 users per arm** to detect a lift from 0.43% to 0.55% yearly conversion ([Adapty](https://adapty.io/blog/markdown/glam-ai-paywall-tests.md)). A small app should run fewer, bolder arms, one at a time. Each test should run **4–6 weeks**, judged on revenue per install at D30 and D60 and on first-renewal rate, not on conversion alone ([Adapty playbook](https://adapty.io/blog/markdown/paywall-experiments-playbook.md)). Superwall makes the same point: its default metric is proceeds per user, "because a higher-converting paywall can still earn less" ([Superwall](https://superwall.com/features/ab-testing)). RevenueCat Experiments can run price and intro-offer arms natively through offerings ([RevenueCat](https://www.revenuecat.com/docs/tools/experiments-v1/experiments-overview-v1)).

| # | Test or change | Arms | Effort | Primary metric | App Store note |
|---|---|---|---|---|---|
| 40 | **Cancellation save flow**: add `purchases_ui_flutter` Customer Center with a cancel survey. "Too expensive" offers `rc_cancel_offer` (for example 50% off three months, or a discounted annual for monthly users). "Don't use it" offers to turn on the daily reminder, not only a discount. Refund requests get `rc_refund_offer`. | Ship, then compare save rate across offer depths | M | Save rate; 60-day revenue of saved users | Promotional offers need an In-App Purchase Key. The offer IDs must exist in App Store Connect, or the survey is skipped. |
| 41 | **Monthly price** | $6.99 vs $9.99, annual fixed at $39.99 | S (new product) | D60 revenue per install; plan mix | New price = new product ID. Show the billed amount most prominently. |
| 42 | **Annual intro** | $1.99 first month vs 7-day free trial vs no intro | S (RevenueCat Experiments) | First-renewal rate; D60 revenue per install; refunds | Free trials are configured in App Store Connect. Show the timeline in every arm. |
| 43 | **Plan count** | Three plans vs two (drop quarterly) | S | Revenue per install; annual share | — |
| 44 | **First-pack welcome price** for users who have never paid: 25 credits for $0.99, once, in the out-of-credits sheet | On vs off | S–M (new consumable product ID) | Free-to-first-payer rate; 60-day pack-to-subscriber rate | 3.1.1: purchased credits never expire. No countdown. |
| 45 | **Pack-buyer bridge**: after a second pack purchase, show one quiet comparison ("You've spent $3.98 on 20 credits. Monthly gives 90 for $6.99") | On vs off | S | Pack-to-subscriber rate | — |
| 46 | **Offer codes for partners and lapsed users**: custom codes for creator or influencer campaigns, plus expired-subscriber codes sent by email to signed-in users. Use the redemption URL. | — | S | Redemptions per code | Offer codes can target new, existing and/or expired subscribers. Codes cannot be edited. |

The cancellation flow (change 40) is placed first because reactivation is so poor. Only about **5% of cancelled annual subscribers ever return**, against about **20% for monthly** ([9to5Mac on SOSA 2026](https://9to5mac.com/2026/05/27/new-report-shows-annual-app-subscribers-rarely-return-after-they-cancel/)). Most annual revenue lost at cancellation is lost for good. RevenueCat's Customer Center maps "Too expensive" and "Don't use the app" to a promotional offer, and can offer a different product in the same group, such as a discounted annual for a monthly subscriber ([RevenueCat](https://www.revenuecat.com/docs/tools/customer-center/customer-center-promo-offers-apple)). Its own growth team advises fixing activation and habit formation before investing in win-back ([RevenueCat](https://www.revenuecat.com/blog/growth/20-of-your-churned-users-will-come-back-but-are-you-ready)), and that ordering supports putting Tiers 3 to 5 first. No published data shows how deep a discount needs to be to save a cancellation, so start moderate and compare. Avoid discount popups when a user abandons the purchase sheet, which the earlier plan already ruled out.

The monthly price test (change 41) is the most defensible price change. The 2026 median monthly price is about **$9.99 in North America and in Health & Fitness**, while the median yearly price is **$39.99 in North America** ([RevenueCat SOSA 2026](https://www.revenuecat.com/state-of-subscription-apps/)). At $9.99 a month, ShenTarot's $39.99 annual becomes a 67% saving instead of 52%, which strengthens the anchor without touching what most subscribers pay.

The intro test (change 42) carries a known risk. In one app, replacing a trial with deep paid intros raised install-to-paid from about 3% to about 14%, but cut LTV-30 by about 81%. Only about 40% paid full price at first renewal ([RevenueCat](https://www.revenuecat.com/blog/growth/introductory-offers-apps)). Trials of 5–9 days convert at a 37.4% median, against 25.5% for trials of 4 days or less ([RevenueCat SOSA 2026](https://www.revenuecat.com/state-of-subscription-apps/)). This test therefore has to be judged at first renewal, not at signup. **Social & Lifestyle has the highest no-trial share, at 43.6%** ([RevenueCat SOSA 2026](https://www.revenuecat.com/state-of-subscription-apps/)), so the current paid intro is a legitimate default while the test runs.

The credit tests (changes 44 and 45) target a real gap in the evidence. Only **10.7% of apps** combine subscriptions with consumables ([RevenueCat SOSA 2026](https://www.revenuecat.com/state-of-subscription-apps/)), and no source publishes data on pack sizing, first-pack discounts or cannibalisation. RevenueCat's own hybrid guidance stops at the principle. Subscriptions "anchor revenue, expectations, and retention", and heavy users self-select into metered spend ([RevenueCat](https://www.revenuecat.com/blog/growth/ai-hybrid-monetization)).

A one-time $0.99 first pack tests whether a low-friction first payment predicts a later subscription. The answer exists only in ShenTarot's own data, and only if change 21 is in place.

Leave three things off the list:

- **Weekly plans.** They are the pattern this category's complaints associate with scams ([Unstar](https://unstar.app/blog/co-star-sanctuary-pattern-nebula-stellium-astrology-apps-ranked-2026)).
- **Unlimited lifetime access**, because every reading has a model cost.
- **Cutting the daily free credit**, which the earlier plan already rejected.

## Sequencing and the measurement each tier unlocks

The tiers are ordered by evidence per day of work, and each tier also builds the instrument the next one needs.

| Phase | Weeks | Ships | Decision it enables |
|---|---|---|---|
| Tier 3 | 1–2 | 21–28 | Baseline funnel: Day-0 purchase rate, reminder opt-in, D1/D7 return by cohort |
| Tier 4 | 3–5 | 29–34 | Whether tailoring and an offer after the first reading raise Day-0 revenue without raising refunds or lowering D7 |
| Tier 5 | 6–10 | 35–39 | Whether habit depth lifts D30 and the share of revenue that starts after the first session |
| Tier 6 | 8 onward, one test at a time | 40–46 | Price, intro and pack structure, judged on D60 revenue per install and first renewal |

Three guardrail metrics apply to every phase:

- **Refund rate on Premium**: keep it under about 4%, the earlier plan's target.
- **One-star reviews that mention billing**, read monthly.
- **Notification opt-outs.**

If a change raises conversion and also raises any of these, roll it back. Hesitant users in this category are watching for the moment an app turns on them. Most of the anger in its reviews is about billing and trust, not about the AI itself ([Unstar](https://unstar.app/blog/co-star-sanctuary-pattern-nebula-stellium-astrology-apps-ranked-2026)).

## Conclusion

The next gains for ShenTarot come less from persuading users to pay and more from **being present at the two times a hesitant user decides**: the minutes after the first reading, and the mornings that follow. The app already has nearly every ingredient: the reading, the daily card, the streak, the look back and the recap. What is missing is the connective tissue that turns those ingredients into a funnel:

- an ask placed at the right moment;
- a push that carries content;
- a question whose answer visibly shapes the reading;
- a widget that keeps the card in view.

Most of that work is days long, and the expensive parts (the widget and price tests) can wait until the cheap parts have produced ShenTarot's first real funnel data.

The less obvious implication is that measurement is now the binding constraint, not ideas. Every benchmark in this report comes from meditation, language, wellness or generic subscription apps, and none from tarot. ShenTarot sits at an unusual intersection: physical-card scanning, AI reflection, and credits alongside subscriptions. Its own numbers will diverge from vendor medians in ways no outside source can predict. A small in-house event log built in the first week is therefore worth more than any single feature after it. It turns the rest of this plan from borrowed hypotheses into ShenTarot's own evidence, and it does so without adding the third-party tracking that privacy audits have already flagged in the category ([Surfshark](https://surfshark.com/research/chart/astrology-apps-privacy)).
