# Growth and monetisation framework (draft for owner review, 2026-10-17)

Objective (owner): cover costs, and grow downloads without ads through free credits, creators, social sharing and friend referral. All numbers are estimates; the frameworks are standard but nobody has validated them for this app yet.

## 1. What "cover cost" really means
Fixed costs are about US$12.5 a month (Apple fee, plus Cloudflare if the free plan runs out). The AI cost is about US$0.0003 a credit typical (up to about 10 times that), so a free user who uses 2 credits a day costs about US$0.02 a month typical.

| Monthly active users | Typical cost a month | Payers needed at US$3.50 net each | Share of users paying |
|---|---|---|---|
| 1,000 | about US$33 | 10 | 1.0% |
| 5,000 | about US$113 | 33 | 0.7% |
| 20,000 | about US$413 | 118 | 0.6% |

So the target is **0.6% to 1% of monthly users paying about US$3.50 net a month** (a blend of subscriptions and credit packs). That is far below the 2% median freemium conversion; it does not need aggressive monetisation. The real risk is not conversion, it is too few users, which is why growth is the main job.

## 2. Frameworks and how each is applied

| Framework | Idea | Application |
|---|---|---|
| **Acquisition cost logic** (freemium economics) | Free credits are the cost of acquiring a user | A free user costs about US$0.02 a month; paid ads cost US$2 to US$5 per install. Free credits are the cheapest acquisition channel you have |
| **Reciprocity** (Cialdini) | People return favours | A welcome gift of 10 credits (about US$0.003 worst case 0.03) makes the first session feel generous; a gift to a friend makes them feel they owe a try |
| **Endowment effect and loss aversion** (Kahneman) | People value what they hold and hate losing it | Show the credit balance and a gentle streak; "your 14 credits are saved" is a reason to come back. Never punish a missed day |
| **Hook model** (Eyal) | Trigger, action, variable reward, investment | Trigger: the daily-card notification. Action: draw a card. Variable reward: the reading. Investment: saved readings and journal, which also raise switching cost |
| **Fogg behaviour model** | Behaviour = motivation x ability x prompt | Ask to pay at the moment of highest motivation (credits just ran out mid-curiosity), with the lowest effort (one tap) |
| **Mental accounting and pain of paying** (Thaler, Prelec) | Small, separate "currency" purchases hurt less than a subscription | Offer small credit packs (US$1.99) as the first purchase; many users who refuse a US$39.99 plan will buy a US$1.99 pack |
| **Good-Better-Best and decoy pricing** (Ariely) | A middle option wins when flanked by a worse and a better one | Three credit packs with the middle one highlighted; a subscription as the top anchor |
| **Goal-gradient** | Effort rises near a goal | Referral progress bar: "2 of 3 friends joined: 10 credits unlock" |
| **Social proof** | People copy people | Only real numbers ("readers this week") once they exist; show creator posts, never invented reviews |
| **Peak-end rule** | People remember the peak and the end | End every reading with a warm closing screen and a share card; the paywall comes after the peak, never during a reading |
| **Value-based metric pricing** | Charge on what the customer values | Credits match value (readings); long spreads cost more credits (see 3) |
| **Viral coefficient (K-factor)** | K = invites per user x invite conversion | K of 0.25 (1 in 4 users brings a friend) lifts every 1,000 organic installs to about 1,330 |

## 3. Proposed refinements to the model

1. **Welcome gift:** 10 credits on the first day, then 2 a day. (Cost about US$0.003 typical.)
2. **Earn credits:** free ways to earn that also bring downloads: invite a friend (friend and referrer each get 10 credits once the friend finishes a reading), a daily share (a branded reading card shared outside the app, +1 credit, once a day), creators (below). Keep rewards for sharing outside the app and verify Apple and Google rules before launch.
3. **Cost by value:** a one-card reading is 1 credit, a 3-card 2, a 5-card 3, a 7-card 4, a 10-card 5, a follow-up 1. This is fairer (a 10-card reading costs about 3 times a 1-card one in AI), and makes credits scarce enough that people buy packs. (Needs owner decision; today everything is 1 credit.)
4. **Impulse packs (mental accounting):** 30 credits US$1.99, 100 credits US$4.99 (highlight), 300 credits US$9.99. Replace the 5-credit Starter Pack, which is worth less than three days of free credits.
5. **Subscription as the convenience tier:** keep US$6.99 / US$14.99 / US$39.99 with the monthly credits (90 / 120 / 150), the 5, 7 and 10-card spreads, look-back and journal. Pitch it as "stop counting" rather than "more credits".
6. **Pay moments:** show the offer when credits hit zero (best), after a share, and after a streak of 5 days; never inside a reading. Keep the exit offer (a one-time discount) for people who close the paywall.
7. **Creators (reciprocity and social proof):** a post with 50 likes earns 1 month Premium; bigger posts earn more; creators also get a personal referral code that gives their followers 10 free credits, which tracks which creators work.
8. **Trial test:** A/B test the US$1.99 first month against a 3-day free trial. Judge by revenue per 100 installs.

## 4. Funnel targets (first 90 days, assumptions)
| Stage | Target |
|---|---|
| Install to first reading | 70% |
| Day-1 retention | 35% |
| Day-7 retention | 15% |
| Monthly active share of installs | 25% |
| Invite rate (users who invite at least once) | 15% |
| Invite conversion (installs per invite) | 1.5 per inviting user |
| Paying share of monthly users | 0.6% to 1% (cost cover), 2% (healthy) |

## 5. Decision rules
- If cost per monthly user rises above US$0.10 typical, reduce free daily credits from 2 to 1 or raise credit costs for long spreads.
- If installs are under 500 by month 3, change creator and sharing tactics before changing prices.
- If paying share is under 0.5% after 5,000 monthly users, test a lower pack price and the hard-paywall variant.

## 6. Compliance notes (to verify before launch)
- Offers and creator codes must disclose paid promotion (#ad / #gifted).
- Do not reward App Store or Play reviews or ratings.
- Check Apple and Google rules on rewarding social sharing and referrals; keep rewards redeemable only for credits, not for bypassing purchases.
- Show real renewal prices next to every subscribe button; no fake "was" prices or fake scarcity.
- Do not use unverified social-proof numbers.
