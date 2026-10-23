# ShenTarot user research guide

This guide covers how to find pain points, build personas, an empathy map and a customer journey, and test the business model. Each part has the method and then a first draft for ShenTarot. The drafts are **hypotheses**: they come from desk research ([tarot-pain-points.md](tarot-pain-points.md)), not yet from talking to users. Step 1 exists to confirm or kill them.

## The order matters

```
1. Collect evidence  →  2. Pain points  →  3. Personas  →  4. Empathy map (per persona)
      →  5. Journey map (per persona)  →  6. Business model  →  7. Test with real numbers
```

Each step feeds the next. Without evidence you get personas you invented. Without personas, a journey map describes nobody.

---

## Step 1. Collect evidence (one or two weeks, close to free)

| Method | How | What you get |
|---|---|---|
| **Review mining** | Read the 1–3★ reviews of the top 5 tarot apps (Labyrinthos, Golden Thread, Mystic Mondays, Co-Star, Lumi). Paste each complaint into a sheet and tag its theme. | The real pain points, in the users' own words. Count tags: the most frequent tags are the biggest pains. |
| **Community lurking** | Read r/tarot, r/TarotReading, TikTok #tarottok comments, and tarot Discord servers. Search for "app", "AI", "subscription", "learn". | Emotions and motives that never appear in reviews. |
| **5–8 interviews** | 20 minutes each with people who own a physical deck. Find them in Reddit or Discord, or among friends. Ask about the **last time** they did a reading, never "would you use…". | The why behind behaviour. |
| **TestFlight + analytics** | Watch where people drop off: onboarding → first scan → first reading → paywall → purchase. | Real behaviour, which beats what people say. |

**Interview questions.** These are about past behaviour, not opinions.
1. Tell me about the last time you pulled cards. What was going on?
2. What did you do right after? Did you look anything up?
3. What was annoying or hard about it?
4. Have you used a tarot app? Why did you stop, or why do you keep it?
5. Have you ever paid for a reading or an app? What made it worth it, or not?
6. How do you keep track of past readings?

Rule: never pitch ShenTarot during the interview. You are there to listen.

---

## Step 2. Pain points

**Method.** Put every complaint from Step 1 on a sheet and group similar ones (affinity mapping). Score each group 1–5 on **frequency** (how many people) and **intensity** (how much it hurts or whether they would pay to fix it). High on both = build it. High on one only = maybe. Low on both = ignore.

**Draft** (from the desk research, still to be validated):

| Pain | Freq | Intensity | ShenTarot |
|---|---|---|---|
| Owning a real deck, but apps make you draw digital cards | 4 | 4 | ✅ Scan |
| Generic, copy-paste meanings | 5 | 3 | ✅ AI reads cards together |
| Bait paywalls and trial tricks | 4 | 5 | ✅ Free cards and credits |
| Overwhelm learning 78 cards | 5 | 3 | 🟡 Learn tab |
| No memory of patterns over time | 3 | 4 | 🔨 Monthly recap |
| AI flatters and kills learning | 3 | 3 | 🔨 "Read it myself first" |

---

## Step 3. Personas

**Method.** Group the interview subjects by **behaviour and goal**, not by age or gender. Two or three personas is enough. Each one has a name, a goal, a frustration, how they use tarot today, and a quote from a real interview.

**Draft personas:**

**🌙 Maya, the self-reflector (primary, the payer)**
- About 27, in a city, works in an office. Owns 1–2 decks and pulls cards 2–4 times a week, usually at night.
- **Goal:** clarity about love, career and her own feelings. Tarot is her journaling ritual.
- **Frustrations:** books are slow to look up; apps ignore her real deck; she forgets what she pulled last month.
- **Pays for:** whatever saves time and feels personal. She already pays for Co-Star, Spotify and Calm.
- *"I just want to know what these three cards mean together, for my situation."*

**📚 Leo, the learner**
- About 22, a student, with a new deck that was a gift. He feels like a fraud and doesn't remember meanings.
- **Goal:** read without the book, and eventually for friends.
- **Frustrations:** too much to memorize; AI feels like cheating.
- **Pays for:** progress he can see. He's price-sensitive and likes credit packs more than subscriptions.
- *"I want to learn it, not have an app do it for me."*

**🔮 Rose, the side-hustle reader** (later, not 1.0)
- About 35. Reads for paying clients on Etsy and TikTok.
- **Goal:** faster sessions, client notes, less burnout.
- **Pays for:** anything that saves an hour a day. She would pay a higher tier.

---

## Step 4. Empathy map (one per persona)

**Method.** Fill four boxes using interview quotes: **Says, Thinks, Does, Feels**. Then add **Pains** and **Gains**. Gaps between Says and Does are where the insight is.

**Draft for Maya:**

| | |
|---|---|
| **Says** | "Tarot is for self-reflection, not fortune telling." "I don't want another subscription." |
| **Thinks** | "Is this reading real, or just telling me what I want?" "I hope he texts back." |
| **Does** | Pulls cards at night in bed. Googles each card. Screenshots readings. Asks the same love question several times a week. |
| **Feels** | Anxious about relationships. Comforted by the ritual. A bit embarrassed to tell friends. |
| **Pains** | Slow look-ups, generic meanings, forgetting past readings, subscription traps. |
| **Gains** | Instant reading of *her own* cards, a private place for it, seeing patterns ("The Tower keeps coming up"). |

Insight: she says she wants no subscription, yet she pays for Co-Star. She pays when the value repeats every week. That is why the monthly recap matters.

---

## Step 5. Customer journey map

**Method.** Stages across the top. For each stage, note what the user **does**, **thinks or feels**, the **touchpoint**, the **pain**, and the **opportunity**. Mark the emotional low points: that is where users quit or pay.

**Draft for Maya:**

| Stage | Does | Feels | Pain | Opportunity for ShenTarot |
|---|---|---|---|---|
| **Discover** | Sees a TikTok or searches "tarot app" | Curious, skeptical | Every app looks the same | Listing leads with "Scan your real deck" |
| **Install & onboard** | Opens the app, sees permissions | Impatient | Asked to sign up or pay too early | Reading in under 60 seconds, no account |
| **First reading** | Scans 3 cards, asks about her ex | Hopeful → **aha** | Scan fails or reading is generic | Spread photo, a reading tied to her question |
| **Habit** | Returns at night | Comforted | Runs out of free credits | Daily free credit, streak, reminder |
| **Pay** | Hits the limit or wants depth | Hesitant 😟 *(low point)* | Unclear price, fear of a trap | Clear price, credit packs, cancel anytime |
| **Retain** | Weeks later | Drifts or stays | Value feels the same each time | Monthly recap: "your cards this month" |
| **Advocate** | Shares a reading | Proud | Nothing to share | Share card image (1.0.2) |

---

## Step 6. Business model (Lean Canvas, which suits a solo app better than the full Business Model Canvas)

| Box | ShenTarot draft |
|---|---|
| **Problem** | Reading a physical deck is slow; app readings are generic; apps trap people with paywalls |
| **Customer segments** | Self-reflectors who own a deck (Maya) first, then learners (Leo) |
| **Unique value proposition** | "Scan your real tarot cards and get a reading about *your* question in seconds. Private, and all 78 cards free." |
| **Solution** | On-device scan, spread photo, AI reading, Learn tab, history |
| **Channels** | App Store search (ASO), TikTok/Reels scan demos, Reddit, the shentarot.com site |
| **Revenue** | Subscriptions (weekly, monthly, annual) plus credit packs ($1.99–5.99) |
| **Cost structure** | AI per reading (about $0.002–0.01), vision per spread photo, Apple's 15–30% cut, Cloudflare, Apple developer fee |
| **Key metrics** | Install → first reading %, D7 retention, paywall → purchase %, cost per reading, subscribers |
| **Unfair advantage** | Real-deck scan plus 16 languages. The scan is hard for copycats to match quickly |

---

## Step 7. Test with real numbers (after launch)

Do the canvases match reality? Check these in RevenueCat and App Store Connect analytics:

| Metric | Healthy target for this category | If it's low |
|---|---|---|
| Install → first reading | > 60% | Onboarding is too long |
| D1 / D7 retention | > 30% / > 12% | No reason to come back: recap, reminder |
| Paywall view → purchase | 2–5% | Price, value or trust problem |
| Trial → paid (annual) | > 30% | The trial doesn't show value |

These targets are rough industry rules of thumb, not verified facts. Use them as a starting point and replace them with your own numbers once real data exists.

## Tools (free)
- **Sheet:** Google Sheets for review mining and tagging.
- **Boards:** FigJam, Miro or Canva for the empathy and journey boards. There are templates for each.
- **Interviews:** record with permission, transcribe, then ask Claude to tag the quotes.
