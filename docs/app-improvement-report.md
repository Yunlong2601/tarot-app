# ShenTarot improvement report

Date: 2026-10-23. This report follows Step 1 (collect evidence) and Step 2 (score pain points) of [user-research-guide.md](user-research-guide.md).

**What I did:** I mined reviews and listings of competing apps (Labyrinthos, Golden Thread, Co-Star, Lumi, EvaTarot, Biddy Tarot, Auraly, the Taroter and Tarot Line scanners, and others). I added tarot teacher blogs and press, and checked ShenTarot's own code to see what we already have.

**Limits:** These are web sources only. I couldn't read Reddit threads directly, and review aggregators skew negative. The **5–8 user interviews** in the guide are still needed to confirm this, and only you can run them.

---

## 🚨 The biggest finding: scanning alone is not unique

At least four App Store apps already recognise physical cards:
- [Taroter](https://apps.apple.com/app/id1597650532) scans several Rider-Waite cards at once.
- [Tarot Line](https://apps.apple.com/app/id6444258152) claims to be the "first" to recognise cards and supports Rider-Waite and Thoth.
- [Tarot of Leela](https://apps.apple.com/app/id6748875761) identifies a card and jumps to its meaning.
- [Tarot Card Meanings & Reading](https://apps.apple.com/app/id6464330408) has a camera scan.

All have very few ratings, so none has won the market yet.

**So our pitch must not be just "scan your cards".** It has to be the whole package no competitor has together:
> Scan your real deck (one card or the whole spread), get a reading about *your* question, in your language, with all 78 card meanings free and nothing stored.

---

## Evidence: tagged and scored

The score is frequency × intensity, each out of 5.

| # | Pain point (what users complain about) | Evidence | Score | ShenTarot today |
|---|---|---|---|---|
| 1 | **Billing and cancellation distrust**: charged after cancelling, trials that charge at once, refund fights | [Biddy Tarot](https://www.pissedconsumer.com/biddy-tarot/RT-F.html), [Auraly](https://ca.trustpilot.com/review/auralyapp.com), [Lumi](https://justuseapp.com/en/app/6450309122/tarot-cards-reading-meanings/reviews), [Co-Star refunds](https://unstar.app/blog/co-star-sanctuary-pattern-nebula-stellium-astrology-apps-ranked-2026) | **25** | 🟡 Clear paywall, a manage-subscription link, and a reminder before the trial ends. None of this is advertised. |
| 2 | **Card meanings locked behind paywalls** | [Kimola analysis](https://kimola.com/reports/explore-in-depth-tarot-app-user-feedback-analysis-app-store-us-155854), [Lumi](https://justuseapp.com/en/app/6450309122/tarot-cards-reading-meanings/reviews) | 20 | ✅ All 78 free |
| 3 | **Upsell creep**: more features gated every year, ads and notifications that read like upsells | [Co-Star](https://unstar.app/blog/co-star-sanctuary-pattern-nebula-stellium-astrology-apps-ranked-2026), [Labyrinthos flashing banner](https://splitmetrics.com/apps/labyrinthos-tarot-reading/id1155180220) | 16 | ✅ No ads; the paywall appears only when credits run out |
| 4 | **Generic or repetitive readings** | [EvaTarot](https://ca.trustpilot.com/review/evatarot.net), [Co-Star "recurring themes"](https://kimola.com/reports/unlock-astrology-app-insights-co-star-user-feedback-report-google-play-153861) | 16 | ✅ The AI reads the question, the positions and the card combinations |
| 5 | **No memory or patterns across readings**. Competitors charge for this: "Your Mirror", "Insights" | [Golden Thread](https://labyrinthos.co/products/golden-thread-tarot-deck), [Mystic Mondays](https://apps.apple.com/us/app/mystic-mondays/id1233064572), [TarotLingo](https://mwm.ai/apps/id/6746827482) | 16 | 🟡 History exists; no pattern view |
| 6 | **Learning: quizzes repeat cards, and similar cards are confusing** | [Labyrinthos reviews](https://justuseapp.com/en/app/1155180220/labyrinthos-tarot-reading/reviews) | 12 | 🔨 No quiz yet |
| 7 | **Account required** | [Labyrinthos Play feedback](https://kimola.com/reports/explore-user-insights-with-our-labyrinthos-tarot-feedback-report-google-play-150855) | 12 | ✅ No account needed |
| 8 | **AI-generated art backlash** | [Erethereal](https://ca.trustpilot.com/review/erethereal.com) | 9 | ✅ The original 1909 public-domain art. We don't say so anywhere. |
| 9 | **Notification fatigue** ("great when you get one a week") | [Co-Star](https://unstar.app/blog/co-star-sanctuary-pattern-nebula-stellium-astrology-apps-ranked-2026) | 9 | ✅ The daily reminder is opt-in |
| 10 | **Missing expected basics**: yes/no reading, a no-reversals option | [AlternativeTo feature lists](https://alternativeto.net/feature/yes-no-tarot), [Tarot Simple](https://apps.apple.com/app/id1546692464) | 9 | 🔨 Neither exists (checked `data/spreads.dart`) |
| 11 | **AI flatters, or kills learning** | [Fortune](https://fortune.com/2026/05/16/we-talked-to-12-tarot-card-readers-who-are-using-ai-they-split-in-2-camps-with-big-implications-for-the-technology/), [Labyrinthos reviewer](https://splitmetrics.com/apps/labyrinthos-tarot-reading/id1155180220) | 9 | 🔨 |

**Insight:** we already beat competitors on the top 3 pains (billing trust, free meanings, no upsell creep), but **nobody can see it**. The cheapest gain is to say it everywhere.

---

## Improvements, ranked

### A. Free, this week: tell people (store listing and paywall)
1. **Rewrite the store listing** around: whole-spread photo (competitors scan one card at a time) · readings about your question · all 78 cards free · no account · original 1909 art, not AI art · 16 languages.
2. **Add a trust line under the buy button:** "Cancel anytime in your Apple settings. We remind you 2 days before your trial ends." (The reminder code exists in `core/reminder_service.dart`; I will confirm it fires on a real trial before we promise it.) This answers pain #1, the biggest one.
3. **Screenshot order:** 1. spread photo → named cards, 2. a reading that quotes the user's question, 3. free card library, 4. languages.

### B. Small builds, before or with 1.0.2
4. **Yes/No spread**, one card. Expected by users, popular for quick questions, cheap to run. Add to `data/spreads.dart` with an AI prompt that gives a leaning, not a verdict.
5. **"Read reversals" toggle** in settings. Many readers don't use reversals.
6. **"About the art" line** on the card screens and the website: "Pamela Colman Smith, 1909. Public domain."

### C. Retention: what keeps people paying (1.0.2 to 1.1)
7. **"Your cards this month"** (premium). It shows the cards that keep appearing, the suit balance and one AI paragraph on the theme. Competitors charge for this. It costs about one cheap AI call per user per month.
8. **Daily card notification with the card in it**, chosen by the user: daily, weekly or off. That keeps Co-Star's habit loop without the fatigue.
9. **Repeat-question note:** "You asked this 2 days ago. Here's what came up." It builds trust and saves AI cost.

### D. Learning: win over learners (1.1)
10. **Daily quiz with spaced repetition**, so cards you get wrong come back later, not 3 times in a row. That is Labyrinthos's own complaint.
11. **"Easily confused" note** on similar cards (for example 6–7 of Cups, the Pages).
12. **"Read it myself first" mode:** the user writes their interpretation, then the AI compares. No competitor I found does this.

---

## What I need from you
- **Interviews:** run 5–8 short interviews with people who own a deck (questions in the guide, Step 1). They confirm or kill items 7–12 before we build them.
- **Go-ahead:** say "go A" and I'll draft the new store listing text and paywall trust line now.
