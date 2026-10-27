# Retention and Habit Loops for Tarot, Astrology, Spiritual and Adjacent Apps (ShenTarot)

Research date: 2026-10-27. Read this first: **I found no published D1/D7/D30 retention numbers or A/B results from any tarot or astrology app** (Co-Star, The Pattern, Labyrinthos, Golden Thread, Nebula, Moonly). The hard evidence comes from close neighbours: Duolingo (streaks, widget), Calm (reminders) and Airship (push). Several of the best-known numbers are old (2013-2017) and are flagged where used.

Code check of ShenTarot (this worktree, `app/`): notifications are **local only** (`flutter_local_notifications` in `app/lib/core/reminder_service.dart`). The daily reminder has fixed copy ("Your card of the day" / "Take a quiet moment with today's card."). Permission is asked only when the user turns the reminder on. There is also a week-later look-back push and an intro-offer billing reminder. The `ios/` folder has **no WidgetKit extension**, and there are **no remote push, Live Activities, moon-phase features or provisional authorization**.

## Which daily/weekly habit mechanics have evidence of improving D1/D7/D30 retention in this category or close neighbours?

### Takeaway
The strongest causal evidence in a close neighbour is for two things:
- **Prompting users to set a daily reminder right after their first meaningful session.** Calm reported about 3x retention and a 40% set-rate.
- **Loss-aversion features that protect a streak.** Duolingo's Streak Wager gave +14% D7, and its Weekend Amulet made users +4% more likely to return a week later.

Inside the tarot and astrology category, the observable pattern is a personalized daily item (horoscope or card) pushed once a day. Its retention has not been measured publicly.

### Cited Findings
- **Calm, reminder prompt (vendor case study, originally 2016-2017, old):**
  - Users who set a Daily Reminder had about 3x the retention, but the feature sat in Settings and fewer than 1% of users found it.
  - Calm then tested a screen, shown after the first meditation, that encourages users to set a reminder. 40% of users who saw it set one.
  - Users who set a reminder from the prompt got "an equal boost in retention."
  - Source: [Amplitude: How Calm increased retention 3X](https://amplitude.com/blog/calm-increased-retention-amplitude); [Amplitude case study](https://www.amplitude.com/case-studies/calm.md).
- **Duolingo, Streak Wager A/B (2017, old):** produced statistically significant gains in D1, D7 and D14 retention. D7 rose the most, by +14%. — [Duolingo blog, May 2017](https://blog.duolingo.com/how-streaks-keep-duolingo-learners-committed-to-their-language-goals)
- **Duolingo, Weekend Amulet (2017, old):** learners offered it were 4% more likely to return a week later and 5% less likely to lose their streak. Duolingo DAU drops 5-10% on weekends. — [Duolingo blog, May 2017](https://blog.duolingo.com/how-streaks-keep-duolingo-learners-committed-to-their-language-goals)
- **Duolingo, streak goal screen (secondary write-up):** users who picked a streak goal at onboarding retained better for weeks, even though the chosen value was never used. — [Lazyweb summary](https://lazyweb.com/research/duolingo-streak-goals-retention) (secondary, no primary numbers)
- **Duolingo, 10-day streak:** internal analysis found users who reached a 10-day streak were less likely to churn. The source itself flags selection bias. — [Lazyweb summary](https://lazyweb.com/research/duolingo-retention-experiments)
- **Co-Star:**
  - The App Store listing advertises "daily push notifications based on your horoscope for the day" and friends with chart compatibility.
  - The app has 206K ratings at 4.8.
  - A reviewer says the widget used to work without a subscription and is now restricted to subscribers. This suggests Co-Star treats the widget as a paid perk.
  - Source: [Co-Star App Store listing](https://apps.apple.com/us/app/co-star-personalized-astrology/id1264782561)
- **Co-Star push tone (2019, old, German):** the blunt or absurd daily pushes are screenshotted and shared widely on social media, so the pushes double as acquisition. — [OMR](https://omr.com/de/co-star-app-viral/). Bustle describes the daily push as snarky and friend-like — [Bustle](https://www.bustle.com/life/pattern-co-star-astrology-apps-comparison).
- **Labyrinthos:**
  - Reading journal with notes, and daily card tracking.
  - User-set reminders "every day, week, or month" from the profile tab.
  - Short lessons and quizzes.
  - Source: [Labyrinthos App Store listing](https://apps.apple.com/us/app/-/id1155180220)
- **Moonly:** builds its loop around "daily micro-rituals and mindful nudges," New Moon and Full Moon intention and release rituals, retrograde alerts and daily affirmations. Many features are paywalled. — [Moonly App Store listing](https://apps.apple.com/US/app/id1489889871); [Bustle review](https://www.bustle.com/life/moonly-astrology-app-review)
- **Nebula:** heavy goal-based onboarding personalization. ScreensDesign reports a category norm of about 8 onboarding steps with a "Free Trial - Soft Paywall." No retention data. — [ScreensDesign: Nebula](https://screensdesign.com/apps/nebula-horoscope-astrology/); [ScreensDesign: astrology apps](https://screensdesign.com/categories/astrology-apps/)
- **Day One "On This Day":** marketed as a core "reminiscing" feature, but no engagement data is published. — [Day One App Store listing](https://apps.apple.com/us/app/day-one/id1055511498)
- **RevenueCat 2025:** speculates that "habit-forming features, community engagement or premium content" explain why top-decile apps reach 68.3% trial-to-paid against a 39.9% median. This is a hypothesis, not a measured result. Nearly 30% of annual subscriptions are cancelled in the first month. — [RevenueCat State of Subscription Apps 2025](https://www.revenuecat.com/blog/company/the-state-of-subscription-apps-2025-launch.md)
- **Retention baselines (vendor blogs; methods differ):**
  - Cross-industry: about 25-26% D1, 11-13% D7 and 5-7% D30 — [Phiture](https://phiture.com/mobilegrowthstack/managing-retention-rate-benchmarks-and-expectations/).
  - Pushwoosh 2025 puts D30 at about 3.1% on iOS — [Pushwoosh](https://www.pushwoosh.com/blog/increase-user-retention-rate).
  - Health & Fitness 38/18/8% (low confidence) — [Unstar](https://unstar.app/de/blog/app-retention-benchmarks-2026).
  - No astrology or tarot category benchmark was found.

### Inferences
- ShenTarot's reminder only works if the user switches it on. Calm's result suggests the biggest cheap win is a **contextual prompt right after the first reading**, worded around the user's benefit ("Want your card of the day at 8am?"), rather than leaving the toggle in settings. Check where the toggle sits today and what share of users have it on.
- ShenTarot has a streak count but probably no **streak protection** (a freeze, a weekend pass, a grace day). This is the best-evidenced streak mechanic. It can be tied to credits, for example "a free freeze each week", or offered as a subscriber perk. Caution: in a spiritual or wellbeing app, a punishing streak may clash with the brand. A gentle version ("your practice is waiting") is safer.
- Moon-phase rituals (New Moon and Full Moon, about every 2 weeks) give a natural **non-daily re-engagement occasion** that costs almost nothing to compute locally: a moon-phase algorithm plus scheduled local notifications. It fits tarot users culturally ("New Moon spread").
- The week-later look-back and the monthly recap are the "reminiscing" pattern (Day One, Wrapped). They are differentiated, but no evidence quantifies their effect.

### Gaps
- No published D1/D7/D30 numbers or experiments from Co-Star, The Pattern, Sanctuary, Labyrinthos, Golden Thread, Nebula or Moonly. Golden Thread and The Pattern were not researched in depth.
- No quantified effect for look-back, recap or "On This Day" features.
- Duolingo's streak experiments are from 2017. No newer primary-source numbers on Streak Freeze were found.

## What notification cadence and copy patterns work without feeling spammy, and what do App Store rules say about marketing pushes?

### Takeaway
One push a day, at a time the user picked, carrying personal content (today's card or horoscope), is the category norm and is consistent with the evidence. Under-messaging opted-in users appears to hurt more than daily messaging. Apple guideline 4.5.4 requires **explicit in-app opt-in consent plus an in-app opt-out** for promotional or marketing pushes. Content reminders like "your card of the day" are not marketing, but a sale push ("50% off Premium") is.

### Cited Findings
- **App Review Guideline 4.5.4 (fetched live 2026-10-27), verbatim:** "Push Notifications should not be used for promotions or direct marketing purposes unless customers have explicitly opted in to receive them via consent language displayed in your app's UI, and you provide a method in your app for a user to opt out from receiving such messages. Abuse of these services may result in revocation of your privileges." It also says pushes "must not be required for the app to function." — [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- **Guideline 4.5.3:** do not use Apple services "to spam, phish, or send unsolicited messages to customers, including Game Center, Push Notifications, Live Activities, etc." — [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- **Guideline 2.5.16:** "Widgets, extensions, and notifications should be related to the content and functionality of your app." — [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- **Guideline 2.5.18:** display advertising "should not be included in extensions, App Clips, widgets, notifications…" — [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- **Airship 2017 benchmark (old; 63M users, correlational):**
  - Users receiving daily or more notifications had the highest 90-day retention across verticals.
  - Users who opted in but received nothing retained *worse* than opted-out users.
  - Users who received any push in the first 90 days averaged nearly 3x the retention.
  - Source: [Airship retention benchmarks PDF](https://grow.urbanairship.com/rs/313-QPJ-195/images/WP_App_Retention_Rates_Benchmarks.pdf); [App Developer Magazine](https://appdevelopermagazine.com/Insights-on-push-alert-frequency-to-improve-new-app-user-retention/)
- **Airship 2013 Good Push Index (very old):** opted-in users retained at nearly twice the rate of opted-out users and had 26% more monthly opens. Relevance of content mattered. — [Adweek](https://www.adweek.com/performance-marketing/how-to-double-user-retention-with-push-notifications-urban-airship-shares-best-practices/)
- **iOS push opt-in (2024, unverified second-hand):** a blog citing Airship's 2024 report puts iOS push opt-in at 59%, with opted-in users opening fewer than 10% of notifications. — [EngageLab](https://www.engagelab.com/blog/live-activities-examples) (could not verify against Airship directly)
- **Copy heuristics (low-quality vendor tool page):** match tone to the segment (empathy for lapsed users). It suggests 2-5 marketing pushes a week, and claims more than one a day raises uninstalls. Keep titles under 50 characters and bodies under 150. — [RaftLabs](https://www.raftlabs.com/tools/push-notification-generator)
- **Calm, timing (anecdotal):** a noon reminder became a nuisance during lunch. A user-chosen time is preferred. — [Mack Collier Substack](https://mackcollier.substack.com/p/how-calm-tripled-retention-by-asking)
- **Co-Star copy:** pushes are personal, specific to today and voice-driven (blunt or snarky). They work as shareable content. — [OMR, 2019](https://omr.com/de/co-star-app-viral/); [Bustle](https://www.bustle.com/life/pattern-co-star-astrology-apps-comparison)
- **Apple HIG (Notifications):** I could not fetch the page body, because it renders with JavaScript. From Apple's API docs, which I know but did not verify on the page this session:
  - Provisional authorization delivers quietly to Notification Center without a prompt.
  - Interruption levels are passive, active, timeSensitive and critical.
  - Treat these as needing verification: [HIG Notifications](https://developer.apple.com/design/human-interface-guidelines/notifications).

### Inferences
- ShenTarot's daily push copy is static and generic. The cheapest copy upgrade is to **put real content in the push**, done locally with no server:
  - name the drawn card or a teaser ("The Star is waiting for you", or the card's one-line theme);
  - rotate 10-20 variants;
  - reference the streak only gently.
  - Local scheduling can pre-pick tomorrow's card of the day, if the card of the day is deterministic per day.
- Keep the daily cadence at **1 a day at a time the user chose**, plus occasional event pushes (New or Full Moon, look-back, a monthly recap is ready). Use the `passive` interruption level for the recap and moon pushes so they don't feel spammy.
- Any push that mentions price, a sale, a trial or Premium needs a **separate, explicit marketing opt-in with consent text in the UI and an in-app off switch**, per 4.5.4. The existing "introductory offer ends in 2 days" reminder is arguably transactional rather than promotional, but it is safest to put it behind its own labelled toggle.
- Consider provisional authorization for the daily card at onboarding. Users see value quietly before an explicit prompt. This is a judgement call; no category data supports it.

### Gaps
- No 2023-2026 primary study on push frequency versus retention. The Airship data is from 2013 and 2017 and is correlational.
- No Co-Star or Labyrinthos push experiment data.
- Could not verify the current HIG wording on the notifications page.

## Do iOS home-screen/lock-screen widgets measurably help retention for such apps?

### Takeaway
There is directional but not rigorous evidence. Duolingo says widget users had "far better retention" even after controlling for commitment, but gives no numbers. Widget adoption is modest, so discovery and an in-app install prompt matter. Co-Star appears to use the widget as a subscriber perk. No astrology or tarot app has published widget numbers. Live Activities have no credible published lift data and fit poorly with a once-a-day card.

### Cited Findings
- **Duolingo (Aug 2023):**
  - Half of learners with the widget installed have streaks of at least 6 months.
  - Widget users had "far better retention… even after controlling for" commitment. No percentages are given.
  - Showing only the streak and whether it is "at risk" was "hugely valuable."
  - Duo's illustration changes with the time of day and whether the lesson is done.
  - Installs "skyrocketed" after an in-app promo with an animated install explainer.
  - Lock-screen widget added.
  - Source: [Duolingo blog: widget feature](https://blog.duolingo.com/widget-feature)
- **Widget adoption:** a TidBITS reader poll (about 350 respondents, Jan 2024, self-selected) found "Don't Use" was the most common answer for iPhone widgets. — [TidBITS](https://tidbits.com/2024/01/15/do-you-use-it-widgets-see-middling-adoption/). An older 2020 figure was about 15% of US iPhone users customizing with widgets in iOS 14 — [iMore](https://www.imore.com/15-us-iphone-users-using-widgets-customize-ios-14).
- **Gratitude journal app:** reportedly 25% higher retention for widget users. This is Android (Jetpack Glance), correlational and from a secondary source. — [The Note](https://thenote.app/post/en/gratitude-saw-25-higher-retention-for-widget-users-mtvlghq4wd)
- **Apple analytics:** App Store Connect has a "Home Screen Widget Usage" analytics report for measuring adoption. — [Apple docs](https://developer.apple.com/documentation/analytics-reports/home-screen-widget-usage.md)
- **Co-Star widget:** per a user review, it moved behind the subscription. — [Co-Star App Store listing](https://apps.apple.com/us/app/co-star-personalized-astrology/id1264782561)
- **Live Activities:** no rigorous case study was found. An unsourced 30-60% tap-through figure is not reliable — [MWM glossary](https://mwm.ai/glossary/live-activity). Since iOS 17, push opt-in also opts users into Live Activities by default — [Airship](https://www.airship.com/resources/explainer/ios-live-activities-explained/). Guideline 4.5.3 prohibits spamming via Live Activities — [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/).

### Inferences
- A **card-of-the-day home and lock-screen widget** is the most category-native widget. It shows today's card face, or a face-down "tap to reveal" state, plus the streak. It is a moderate build for a Flutter app:
  - a native SwiftUI WidgetKit extension;
  - an App Group to share data, for example via the `home_widget` Flutter package;
  - a timeline that refreshes at midnight.
- The "tap to reveal / not drawn yet" state mirrors Duolingo's "streak at risk" signal.
- Expect low organic adoption. Pair the widget with an in-app "Add widget" explainer, shown after a streak milestone.
- Product choice: give the widget free to drive the daily habit, or paywall it as Co-Star appears to. For a retention goal, free with a premium skin is the likely compromise. No evidence settles this.
- Skip Live Activities. There is no ongoing event that fits, and Apple's spam rule applies.

### Gaps
- No iOS-specific, controlled widget retention number from any app.
- No widget data from any tarot or astrology app.

## What does ShenTarot most likely lack, and what would be cheapest to build?

### Takeaway
ShenTarot already has the core loop: card of the day, streak, recap, milestones, journal, look-back and daily credits. It is missing four things:
- a high-visibility moment that asks for the reminder;
- content-rich, varied push copy;
- streak forgiveness;
- non-daily ritual occasions such as moon phases.

It also lacks a widget, which is the largest of these builds. Everything except the widget can be done in Dart with local notifications.

### Cited Findings
- ShenTarot uses local notifications only. The daily copy is fixed. Permission is requested only when the user enables the reminder. There is no WidgetKit extension. — local code: `app/lib/core/reminder_service.dart`, `app/ios/` (observed this session)
- The best-evidenced cheap mechanics in neighbours:
  - a reminder prompt after the first session (Calm: 40% set-rate, about 3x retention) — [Amplitude](https://amplitude.com/blog/calm-increased-retention-amplitude);
  - streak protection (Duolingo: +14% D7, +4% week-later return) — [Duolingo blog](https://blog.duolingo.com/how-streaks-keep-duolingo-learners-committed-to-their-language-goals).
- Category competitors' recurring rituals: Moonly's New and Full Moon rituals and daily micro-rituals — [Moonly listing](https://apps.apple.com/US/app/id1489889871); Labyrinthos' daily, weekly and monthly custom reminders — [Labyrinthos listing](https://apps.apple.com/us/app/-/id1155180220).

### Inferences
Ranked by cost against likely impact. All are inferences, not tested results.
1. **Post-first-reading reminder prompt** (a few hours of work). After the first AI reading, show a sheet: "Get your card of the day each morning?" with a time picker. Measure the opt-in rate and D7 for the users who opt in.
2. **Dynamic local push copy** (about 1 day). Rotate 15-30 variants. Include a card or theme teaser, a streak count when at least 3, and a gentle tone. Re-schedule each time the app opens. Also send a "streak at risk" evening push only if today's card has not been drawn and the streak is at least 3. Cancel it when the card is drawn.
3. **Streak grace or freeze** (1-2 days). Give one automatic free "rest day" per week, or a freeze earned through milestones. This avoids the guilt that clashes with a wellbeing brand.
4. **Moon-phase ritual pushes and spreads** (2-3 days). Compute New and Full Moon dates locally, schedule passive pushes ("New Moon tonight: a 3-card intention spread"), and add a themed spread. This creates a bi-weekly return reason and a natural place for a credit or premium upsell inside the app (not in the push, unless the user has given marketing consent).
5. **Weekly "your week in cards"** mini-recap (1-2 days). It reuses the monthly recap logic at a weekly cadence and is a Sunday push occasion.
6. **Marketing-push consent toggle** (half a day). Required before any promo or sale push under 4.5.4.
7. **Card-of-the-day widget, home and lock screen** (about 3-5 days, native Swift). The best evidence comes from Duolingo, but adoption is low without in-app promotion.
8. Not recommended now: Live Activities, and social/friends features (Co-Star's friend compatibility is a large build).

### Gaps
- I did not see ShenTarot analytics, such as reminder opt-in rate or streak distribution, so I could not size these opportunities.
- No category-specific evidence that streak protection or moon rituals improve retention. These are extrapolated from Duolingo and from competitors' feature choices.
