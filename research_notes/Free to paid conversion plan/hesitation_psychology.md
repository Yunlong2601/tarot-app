# Payment Hesitation in Freemium Apps: Psychology, Ethical Levers, and Paywall Rules (for ShenTarot)

Context: ShenTarot is an iOS app that scans tarot cards and gives AI readings. It sells credits and subscriptions and is positioned for entertainment and self-reflection only. These notes were compiled 2026-10-26.

Source-type legend:
- **[PR]**: peer-reviewed academic paper.
- **[WP]**: academic working paper, not yet peer-reviewed or in revision.
- **[REG]**: regulator, legal text, or platform rule (Apple).
- **[LAW]**: law-firm commentary on regulation.
- **[PRAC]**: practitioner or vendor content (RevenueCat, Superwall, blogs).
- **[ADV]**: advocacy group.

How the classic papers were cited: they are well-established and cited by DOI from the researcher's own knowledge. Their content was not re-fetched in this session, so the report writer should treat their one-line summaries as standard textbook characterizations. Every other source was retrieved in this session via search or fetch.

---

## 1. Why free users hesitate to pay (drivers of hesitation)

### Takeaway
Hesitation is mostly rational risk-management, not irrationality. Users are unsure of the value they will get, fear a renewal "trap" (and they are right to; inertia is real and measured), increasingly discount anything labelled "AI", and feel the pain of paying most sharply when price is separated from a moment of value. Several biases (loss aversion, endowment, IKEA effect, "free" as a special price) can be used ethically to make value felt *before* the ask. They become manipulative when they are used to obscure cost or exploit inertia.

### Cited Findings

**Fear of subscription traps and inertia (the strongest modern evidence)**
- A large field experiment ran at a European newspaper paywall. Contracts varied in renewal policy (auto-renew vs. auto-cancel), trial length, and trial price. It found strong inertia: a 53–75% chance of not taking a desired action within a month. Auto-renew takers were about 7x more likely to still be subscribed after the promo — [Miller, Sahni & Strulov-Shlain, "Sophisticated Consumers with Inertia" (NBER conference version)](https://conference.nber.org/conf_papers/f176634/f176634.pdf) [WP]
- Consumers are partly "sophisticated." 24–36% of potential subscribers avoided auto-renewal offers, and 9% avoided subscribing at all for two years because they had been offered an auto-renew contract. Consumers anticipated only about one-sixth of their own inertia — [BFI working paper page](https://bfi.uchicago.edu/working-paper/sophisticated-consumers-with-inertia-long-term-implications-from-a-large-scale-field-experiment/) [WP]
- The January 2026 version reports that auto-renewal helps the firm short-term but lowers subscription take-up by 35% and total subscribers by 23% over 20 months. The 2023 version gave smaller effects (−24% subscriptions, −10% subscribers over two years). Cite the specific version — [Wharton-hosted Jan 2026 draft](https://marketing.wharton.upenn.edu/wp-content/uploads/2026/02/Strulov-Shlain-Avner-PAPER-Subscriptions.pdf); [Stanford GSB summary](https://www.gsb.stanford.edu/index%2Ephp/insights/auto-renew-snags-new-subscribers-its-not-good-way-keep-them); [HEC summary](https://www.hec.edu/en/auto-renew-exploits-inertia-hurts-long-term-profits) [WP + PRAC summaries]
- Classic evidence that people mis-predict their own future usage of flat-fee contracts (gym members overpay relative to per-visit pricing) — [DellaVigna & Malmendier 2006, "Paying Not to Go to the Gym," AER](https://doi.org/10.1257/aer.96.3.694) [PR]

**Unclear value and the hard paywall vs. freemium trade-off**
- In RevenueCat's State of Subscription Apps data, hard-paywall apps show much higher median download-to-paid conversion than freemium. Secondary summaries give 12.1% vs. 2.2% (2025 edition) and 10.7% vs. 2.1% (newer edition). Hard paywalls also show higher refund rates (5.8% vs. 3.4%) — [SaaStr summary of RevenueCat report](https://saastr.com/the-top-10-learnings-from-revenuecats-state-of-subscription-apps-how-115000-mobile-apps-deliver-16b-in-revenue-whats-working-whats-quietly-killing-growth); [Airbridge: hard paywall vs freemium 2026](https://www.airbridge.io/en/blog/hard-paywall-vs-freemium-2026) [PRAC, secondary; numbers conflict between editions]
- RevenueCat itself notes that a hard paywall "forces a binary decision before the user has fully experienced the product" — [RevenueCat: Hard paywall vs freemium](https://www.revenuecat.com/blog/growth/hard-paywall-vs-freemium) [PRAC]

**"AI slop" skepticism: an AI disclosure penalty**
- 16 preregistered experiments (N = 27,491) found a persistent "AI disclosure penalty": people devalue creative writing labelled as AI-generated. The effect was mediated by perceived authenticity and lasted across 15 months — [Raj, Berg & Seamans, "The AI Disclosure Penalty" (Prolific citation listing)](https://citations.prolific.com/paper/the-artificial-intelligence-disclosure-penalty-humans-persistently-devalue-ai-generated-creative-wri) [PR, per listing reported as 2026 in a Journal of Experimental Psychology outlet; venue not independently verified]
- A survey experiment (N = 547) found a "disclosure paradox." People say AI use should be disclosed, yet rate disclosed-AI communication as less trustworthy and less authentic — [Macquarie Univ. publisher version](https://research-management.mq.edu.au/ws/portalfiles/portal/520543860/Publisher_version.pdf) [PR]
- In an NIM experiment (1,100 U.S. participants), willingness to read and willingness to pay both dropped when a book was attributed to AI — [NIM: Transparency without trust](https://www.nim.org/publikationen/detail/transparency-without-trust) [Research institute]
- Industry figures report that trust in AI content fell from 73% to 55% (Capgemini), and 32% of consumers say they would trust a brand less if its content were AI-generated (YouGov 2026). These are secondary citations — [MarTech](https://martech.org/consumers-like-ai-content-until-they-know-its-ai/) [PRAC, secondary]

**Payment pain, coupling, and mental accounting**
- Prelec & Loewenstein's "double-entry" mental accounting model has two parts. Paying generates immediate "pain" that is attenuated when payment is decoupled from consumption, and consumption is less enjoyable when each unit is tied to its cost. This is the "taxi-meter" effect that per-use pricing can create — [Prelec & Loewenstein 1998, "The Red and the Black," Marketing Science](https://doi.org/10.1287/mksc.17.1.4) [PR]
- Mental accounting: people evaluate gains and losses in separate mental "accounts" and use transaction utility (perceived deal quality vs. a reference price) — [Thaler 1985, Marketing Science](https://doi.org/10.1287/mksc.4.3.199) [PR]
- Payment depreciation: the perceived cost of a prepaid amount fades over time, so consumption of prepaid goods drops as the payment recedes. This bears on prepaid credit packs vs. pay-at-use — [Gourville & Soman 1998, JCR](https://doi.org/10.1086/209531) [PR]
- Flat-rate bias: many consumers choose flat-rate plans even when pay-per-use would be cheaper. Drivers include an "insurance" effect and a "taxi-meter" effect (wanting to avoid feeling the meter run) — [Lambrecht & Skiera 2006, JMR](https://doi.org/10.1509/jmkr.43.2.212) [PR]
- Less transparent payment forms ("Monopoly money") are spent more easily. Pain of paying is weaker when the money is less visible — [Raghubir & Srivastava 2008, J. Exp. Psych: Applied; APA press release](https://www.apa.org/news/press/releases/2008/09/credit-cash) [PR]

**Loss aversion, endowment, IKEA effect, sunk cost**
- Loss aversion: losses loom larger than equivalent gains — [Kahneman & Tversky 1979, Econometrica](https://doi.org/10.2307/1914185) [PR]
- Endowment effect: people value what they own more than identical items they don't own — [Kahneman, Knetsch & Thaler 1990, JPE](https://doi.org/10.1086/261737) [PR]
- IKEA effect: people value things more after investing their own effort in creating them — [Norton, Mochon & Ariely 2012, J. Consumer Psychology](https://doi.org/10.1016/j.jcps.2011.08.002) [PR]
- Sunk-cost effect: prior investment increases continued investment — [Arkes & Blumer 1985, OBHDP](https://doi.org/10.1016/0749-5978(85)90049-4) [PR]

**Price anchoring, decoys, and "free"**
- Decoy (asymmetric dominance) effect: adding an inferior option that is dominated by one target option increases that target's choice share — [Huber, Payne & Puto 1982, JCR](https://doi.org/10.1086/208899) [PR]
- "Zero price effect": a free option is valued disproportionately, beyond what the price difference justifies — [Shampanier, Mazar & Ariely 2007, Marketing Science](https://doi.org/10.1287/mksc.1060.0254) [PR]
- Apple explicitly limits how anchoring may be displayed. The billed amount must be the most prominent pricing element, and per-week "equivalent" prices or savings must appear in a "subordinate position and size" — [Apple: Auto-renewable subscriptions](https://developer.apple.com/app-store/subscriptions/) [REG]

**Free-trial anxiety**
- Blinkist's case: users' biggest complaint was being charged at the end of the 7-day trial. A redesigned "honest" paywall with a trial timeline and reminder was followed by +23% trial sign-ups and −55% customer-service complaints (some sources also report about 4% better trial retention or fewer cancellations). These are secondary write-ups, and the exact reminder timing differs between sources — [UX Planet case study (Blinkist designer)](https://uxplanet.org/how-solving-our-biggest-customer-complaint-at-blinkist-led-to-a-23-increase-in-conversion-b60ad514134b); [B2B Pricing Insights](https://b2bpricinginsights.substack.com/p/4-min-read-how-blinkists-new-paywall) [PRAC]

### Inferences
- For ShenTarot, the dominant hesitation drivers are likely: (1) "is an AI tarot reading worth money?" (value uncertainty plus the AI penalty); (2) "will I get trapped in a renewal?" (inertia fear, which the Miller et al. data shows is rational); and (3) "what does a credit actually cost me?" (credit abstraction).
- The AI-disclosure penalty argues against hiding AI (which is also dishonest). It argues for making the *personal* and *crafted* parts salient: the user's own spread, their question, the card imagery they scanned. That raises authenticity without overclaiming.
- Per-reading credit costs shown at the moment of reading may trigger the "taxi-meter" pain (Prelec & Loewenstein; Lambrecht & Skiera). A subscription with generous or unlimited light use decouples payment from consumption and may feel better to heavy users. Light users may prefer small credit packs (insurance vs. meter trade-off). This is a design hypothesis, not a tested result for this app.
- Miller et al. suggest that aggressive auto-renew trials can *shrink* the long-run subscriber base by scaring off sophisticated users. Offering a clear reminder, or an option that does not auto-convert, is plausibly both ethical and long-run positive.

### Gaps
- No peer-reviewed study specific to paid AI tarot, astrology, or "spiritual entertainment" apps was found.
- The RevenueCat primary report was not fetched directly. Its conversion figures come via secondary summaries that disagree across editions.
- No peer-reviewed study was found on how "AI skepticism" specifically affects willingness to pay for AI *advice or interpretation* (as opposed to creative writing).

---

## 2. Trust builders that reduce hesitation

### Takeaway
The evidence-backed trust levers are transparency at the point of purchase (exact billed amount, trial length, renewal date), a proactive reminder before a trial converts, and frictionless, visible cancellation. Practitioner data (Blinkist) suggests transparency can *raise* conversion while cutting complaints. Letting users experience a real sample of premium output before asking reduces value uncertainty, and the hard-paywall data shows the cost of not doing so (higher refunds).

### Cited Findings
- Apple requires sign-up screens to show: subscription name, duration, and what is provided; the full renewal price, "shown clearly and prominently," localized; and a way to sign in or restore purchases. App and metadata must link to Terms of Use and Privacy Policy — [Apple: Auto-renewable subscriptions](https://developer.apple.com/app-store/subscriptions/) [REG]
- For free trials Apple says: "clearly indicate how long the free trial lasts and the price billed once the free trial is over" — [Apple: Auto-renewable subscriptions](https://developer.apple.com/app-store/subscriptions/) [REG]
- Apple recommends making it easy to reach the system cancel UI ("always make it easy for people to access the system-provided management UI where they can cancel"). It points to `showManageSubscriptions(in:)` for in-app management — [Apple: Auto-renewable subscriptions](https://developer.apple.com/app-store/subscriptions/) [REG]
- Blinkist's transparent trial timeline (what happens today, when the reminder arrives, when the charge happens) was associated with +23% trial sign-ups and −55% complaints — [UX Planet](https://uxplanet.org/how-solving-our-biggest-customer-complaint-at-blinkist-led-to-a-23-increase-in-conversion-b60ad514134b) [PRAC]
- Superwall offers automated trial-ending reminders and markets a trial-to-paid lift, but publishes no numbers. One newsletter anecdote reports a 27% trial-start rate after adding a "we'll remind you" screen, with no control group — [Superwall: Free Trial Reminders](https://superwall.com/features/free-trial-reminders); [SaaS Accelerator anecdote](https://saas-accelerator.beehiiv.com/p/this-simple-fix-increased-his-conversion-to-27) [PRAC, weak evidence]
- An explicit trial-timeline UI appeared on only 39 of the sampled paywalls (3.2%), so the pattern is under-used — [Lazylanding Labs research note](https://lazylanding-labs.onrender.com/research/paywall-trial-timeline-ui-prevalence.md) [PRAC, unknown methodology]
- RevenueCat reports that emphasizing the risk-free nature of a trial across multiple touchpoints raised conversion in its testing — [RevenueCat: Paywall conversion boosters](https://www.revenuecat.com/blog/growth/paywall-conversion-boosters.md) [PRAC]
- Hard-paywall apps have higher refund rates (5.8% vs. 3.4% freemium), which is consistent with paying before value is understood — [SaaStr summary](https://saastr.com/the-top-10-learnings-from-revenuecats-state-of-subscription-apps-how-115000-mobile-apps-deliver-16b-in-revenue-whats-working-whats-quietly-killing-growth) [PRAC, secondary]

### Inferences
Recommended for ShenTarot:
- Before any trial starts, show a three-step timeline ("Today: full access → Day X: we remind you → Day Y: billed $Z/year unless cancelled") and send a local notification reminder. This needs explicit notification opt-in, and the reminder should be framed as a service, not marketing.
- Put a "Manage / cancel subscription" link in Settings and on the paywall's footer. Use Apple's `showManageSubscriptions`.
- Give refund clarity honestly. On iOS, refunds for IAP are handled by Apple (reportaproblem.apple.com / StoreKit refund request API). The app must not promise its own "money-back guarantee" that it cannot fulfil. It *can* explain how to request a refund from Apple.
- Show a full sample premium reading (e.g., a deep, multi-card spread) on a fixed example spread before asking. Alternatively, give a free first premium reading on the user's own cards. Either lets users judge quality and counters AI skepticism.
- Use social proof only if it is real: App Store rating, real review excerpts with consent. Fabricated testimonials or counts are prohibited (FTC and Apple 2.3.1 misleading marketing).

### Gaps
- No controlled, peer-reviewed study was found isolating the effect of trial reminders on conversion. Evidence is practitioner and anecdotal.
- No sourced data was found on social-proof effects specific to subscription paywalls.
- Whether Apple itself sends trial-ending reminders to all users was not verified in this session. The fetched page only confirms Apple-sent notices for price increases.

---

## 3. Credits and virtual currency: perception and fairness

### Takeaway
Research consistently shows that abstract tokens weaken the felt link to money and can change choices. That is exactly why EU regulators (CPC Network, 2025) now treat in-app currencies as money for consumer-law purposes and demand that real prices be shown. Credits feel fair when the conversion to real money and the cost per action are obvious, packs map to real use without forced leftovers, and credits never expire (an Apple requirement anyway).

### Cited Findings
- **Medium maximization:** inserting an intermediate "medium" such as points changes choices. In one study, about 3/4 chose the shorter task for the preferred reward, but once points were added, over half chose the longer task with more points. Points create "an illusion of advantage" — [Hsee et al. 2003, "Medium Maximization," JCR (RePEc)](https://ideas.repec.org/a/oup/jconrs/v30y2003i1p1-14.html); [AcaWiki summary](https://acawiki.org/Medium_maximization) [PR]
- **Less transparent payment forms are spent more freely** — [Raghubir & Srivastava 2008 (APA release)](https://www.apa.org/news/press/releases/2008/09/credit-cash) [PR]
- **Apple 3.1.1:** "Any credits or in-game currencies purchased via in-app purchase may not expire, and you should make sure you have a restore mechanism for any restorable in-app purchases." Under 3.1.2(a), subscriptions may include consumable credits and discounted access to consumables — [Apple App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) [REG]
- **EU CPC Network "Key Principles on In-game Virtual Currencies" (21 March 2025, non-binding):** in-game currencies whose main function is payment are treated as digital representations of monetary value and fall under EU consumer law. The principles call for clear pricing in real currency, no hiding of costs or forcing excess currency purchases, respect for withdrawal rights, and attention to vulnerable users and minors — [Reed Smith Q&A](https://www.reedsmith.com/articles/qas-on-the-eu-consumer-protection-authorities-joint-guidance-paper/); [ZwillGen](https://www.zwillgen.com/gaming/cpcn-announces-virtual-currency-consumer-protection-guidelines/); [Principles PDF (mirror)](https://esportslegal.news/wp-content/uploads/2025/03/Key-principles-on-in-game-virtual-currencies.pdf) [REG via LAW]
- The cited legal basis is UCPD Arts 6(1)(d) and 7, and CRD Art 6(1)(e). Fines of up to €800k or 6% of turnover are noted, and the principles are relevant to non-EU firms targeting EU users. Industry groups (EGDF, Video Games Europe) dispute the legal theory — [Reed Smith](https://www.reedsmith.com/articles/qas-on-the-eu-consumer-protection-authorities-joint-guidance-paper/); [Baker McKenzie](https://connectontech.bakermckenzie.com/european-consumer-protection-network-issues-new-key-principles-on-in-game-virtual-currencies-impact-for-gaming-and-gambling-entities-in-belgium-the-eu-and-beyond/) [LAW]
- BEUC (consumer advocacy) argues that firms "hide the real cost" via paid virtual currencies and calls for banning premium virtual currencies in the forthcoming Digital Fairness Act — [BEUC checklist, March 2026](https://www.beuc.eu/sites/default/files/publications/BEUC-X-2026-019_Checklist_Towards_the_Digital_Fairness_Act.pdf) [ADV]
- The FTC's 2022 dark patterns report flags calling apps "free" when they contain in-app purchases — [Venable summary](https://www.venable.com/insights/blogs/2022/09/the-ftc-brings-more-light-to-dark-patterns-in-new) [LAW]

### Inferences
Fair vs. manipulative credit design for ShenTarot:
- **Fair:**
  - 1 credit = 1 clearly named action (e.g., "1 credit = 1 deep reading").
  - Show the real-money price per reading next to each pack (e.g., "10 readings · $4.99 · ≈$0.50/reading").
  - Show the credit cost *before* the user taps "Read," and show the remaining balance.
  - Credits never expire.
  - Pack sizes match real use patterns.
  - Restore works.
- **Manipulative (avoid):**
  - Odd exchange rates (e.g., 1,000 gems where a reading costs 350) that leave stranded balances.
  - Pack sizes engineered so a reading always costs slightly more than the balance.
  - Hiding real-currency equivalents.
  - Expiring "bonus" credits that pressure spending.
  - Countdown-timer packs.
- A hybrid model (subscription with included monthly credits, plus à la carte packs) is expressly allowed by Apple 3.1.2(a). It may suit both "insurance" seekers and light users (Lambrecht & Skiera).

### Gaps
- No peer-reviewed study was found specifically on AI-app "credits" (as opposed to game currencies or loyalty points). The inference that results transfer is the author's.
- Whether the CPC principles have been revised after the June 2025 industry workshop was not confirmed.

---

## 4. Dark patterns to avoid and the legal/platform rules that constrain paywalls

### Takeaway
Apple's own rules already bar the worst patterns: misleading price display, scam or bait-and-switch subscriptions, forced actions, and expiring credits. US federal click-to-cancel was vacated in July 2025, but the FTC reopened rulemaking in March 2026 and keeps enforcing ROSCA and Section 5. In the EU, a mandatory online "withdrawal button" applies from 19 June 2026, and a Digital Fairness Act targeting subscription traps and dark patterns is in preparation. Designing to the strictest standard (easy cancel, clear renewal terms, reminders) is the safe default.

### Cited Findings

**Apple App Review Guidelines (verified 2026-10-26; page shows no last-updated date)** — [developer.apple.com/app-store/review/guidelines](https://developer.apple.com/app-store/review/guidelines/) [REG]
- **3.1.1:** digital features must be unlocked via IAP. Purchased credits "may not expire." Non-subscription free trials must, before the trial starts, "clearly identify its duration, the content or services that will no longer be accessible when the trial ends, and any downstream charges."
- **3.1.2(a):** subscriptions must provide "ongoing value," last at least 7 days, and work across the user's devices. Users must "get what they've paid for without performing additional tasks" (e.g., social posting). "Apps that attempt to scam users will be removed… This includes apps that attempt to trick users into purchasing a subscription under false pretenses or engage in bait-and-switch and scam practices."
- **3.1.2(c):** "Before asking a customer to subscribe, you should clearly describe what the user will get for the price," and comply with Schedule 2 of the Developer Program License Agreement.
- **2.3.1(a):** promoting a false price or services not offered is grounds for removal. **2.3.2:** in-app promotions must indicate whether items need additional purchase. **3.2.2(x):** apps can't force ratings or reviews to access functionality.
- Apple's subscription page adds that the billed amount must be the most prominent price element, and any per-period breakdown must be "subordinate." Free trials must show length and post-trial price — [Apple: Auto-renewable subscriptions](https://developer.apple.com/app-store/subscriptions/) [REG]
- Note: guideline 5.6 (Developer Code of Conduct, which covers manipulative practices) was not captured in the fetch because the page was truncated. Verify it directly.

**US: FTC**
- The FTC staff report "Bringing Dark Patterns to Light" was released September 2022 (dated 9.14.2022, announced 9.15.2022). It catalogs dark patterns in e-commerce, children's apps, and subscriptions: disguised ads, making cancellation difficult, burying key terms or junk fees, and tricking users into sharing data — [FTC report page](https://www.ftc.gov/reports/bringing-dark-patterns-light); [Orrick summary](https://infobytes.orrick.com/2022-09-23/ftc-reports-use-dark-patterns/) [REG + LAW]
- **Click-to-cancel:** the Eighth Circuit vacated the FTC's amended Negative Option ("Click-to-Cancel") Rule in its entirety on **July 8, 2025**. The ground was procedural: the FTC did not produce a preliminary regulatory analysis required when impact exceeds $100M — [Benesch](https://www.beneschlaw.com/publication/eighth-circuit-cancels-ftcs-click-to-cancel-rule/); [Keller & Heckman](https://www.khlaw.com/insights/eighth-circuit-court-appeals-strikes-down-ftcs-click-cancel-rule) [LAW] (**Verified: vacated July 2025.**)
- The FTC published an ANPRM on the Negative Option Rule (announced **March 11, 2026**; Federal Register about March 13; comments due about April 13, 2026). It asks about re-adopting click-to-cancel provisions. ROSCA and Section 5 enforcement continues (e.g., Amazon Prime 2023, Uber 2025) — [Gibson Dunn](https://www.gibsondunn.com/ftc-restarts-negative-option-rulemaking-after-eighth-circuit-vacatur-enforcement-under-rosca-continues/); [Jones Day, May 2026](https://www.jonesday.com/en/insights/2026/05/ftc-revives-clicktocancel-rule-new-risks-for-subscription-businesses); [CCIA/SIIA comments](https://ccianet.org/wp-content/uploads/2026/04/CCIA-and-SIIA-Comments-in-Response-to-the-FTCs-Negative-Option-Rule-ANPRM.pdf) [LAW]
- State auto-renewal laws (e.g., California's ARL) remain in force despite the federal vacatur — [Lowenstein Sandler](https://www.lowenstein.com/news-insights/publications/client-alerts/ftc-click-to-cancel-rule-on-hold-but-california-s-automatic-renewal-law-remains-intact-what-companies-need-to-know-privacy) [LAW]

**EU**
- **Withdrawal button:** Directive (EU) 2023/2673 adds Art 11a to the Consumer Rights Directive. Member states had to transpose it by, and it applies from, **19 June 2026**. Online distance contracts with a withdrawal right need an easy-to-find "withdraw from contract here" function, available throughout the withdrawal period. Germany has enacted its implementation — [Hogan Lovells via JD Supra](https://www.jdsupra.com/legalnews/eu-consumer-protection-law-update-new-9377759/); [Greenberg Traurig, May 2026](https://www.gtlaw.com/en/insights/2026/5/eu-consumer-law-new-withdrawal-button-requirements-for-online-contracts); [iubenda](https://www.iubenda.com/en/blog/online-withdrawal-function-eu-directive-2023-2673/) [LAW/PRAC]
- **Digital Fairness Act:** a planned proposal targeting dark patterns, subscription traps (e.g., cancellation harder than sign-up), and in-game currencies. As of these sources (May 2026), no formal Commission proposal was confirmed published — [CMS](https://cms.law/en/aut/legal-updates/inside-the-eu-s-planned-digital-fairness-act-digital-design-subscription-traps-and-influencer-marketing); [Heuking, 8 May 2026](https://www.heuking.de/en/news-events/newsletter-articles/detail/digital-fairness-act-implementation-obligations-companies-need-to-prepare-for.html); [Bird & Bird](https://www.twobirds.com/en/insights/2025/eu-–-consultation-on-the-digital-fairness-act) [LAW]
- BEUC asks for one-month-notice cancellation of auto-renewals via an easy cancel button — [BEUC](https://www.beuc.eu/sites/default/files/publications/BEUC-X-2026-019_Checklist_Towards_the_Digital_Fairness_Act.pdf) [ADV]
- **DSA Art 25** (Regulation (EU) 2022/2065) bans deceptive or manipulative interface design by *online platforms*. Its applicability to a non-UGC app like ShenTarot is doubtful, but the UCPD covers misleading or aggressive practices generally. (From author knowledge; not fetched this session.)

**Academic dark-pattern taxonomy**
- A crawl of about 11K shopping sites found 1,818 dark pattern instances, in categories including sneaking, urgency, misdirection, social proof, scarcity, obstruction, and forced action — [Mathur et al. 2019, "Dark Patterns at Scale," PACM HCI (CSCW)](https://doi.org/10.1145/3359183) [PR] (figures from author knowledge)

### Inferences
Concrete "do not" list for ShenTarot's paywall:
- Do not make the per-week price larger than the billed annual amount (Apple).
- Do not use fake countdown timers or "only today" offers that recur.
- Do not use confirm-shaming dismiss buttons ("No, I don't want clarity in my life").
- Do not hide or delay the close (X) button.
- Do not pre-select the trial or auto-renew toggles in a misleading way.
- Do not fabricate reviews or "X people are reading now."
- Do not use expiring paid credits.
- Do not create a hard cancel path.
- Do not promise outcomes (prediction accuracy, life results). That would conflict with the honest "entertainment and self-reflection" positioning and with 2.3.1 misleading-marketing rules.
- Since Apple handles cancellation and refunds for IAP, the main in-app duty is to *surface* the paths, not build them. Even so, EU Art 11a and future FTC rules make in-app visibility of cancellation prudent.

### Gaps
- Apple guideline 5.6 wording was not captured (page truncated). Verify it directly.
- How the EU Art 11a withdrawal button interacts with Apple-processed IAP (where Apple is the merchant of record) was not established. Seek legal advice.
- The status of the FTC Negative Option rulemaking after the April 2026 comment period (whether an NPRM was issued) is unconfirmed.
- Whether the Digital Fairness Act proposal was published after May 2026 is unconfirmed.

---

## 5. Specific ethical techniques with evidence

### Takeaway
The best-supported ethical levers make value felt before the ask:
- Contextual (value-moment) paywalls shown when the user is trying to use a feature.
- Previews of genuine premium output, which create curiosity and let users judge quality.
- Endowed or visible progress.
- Soft limits that leave the free tier usable.
- Onboarding that personalizes, using real inputs rather than fake "calculating" theatre.

Most quantitative evidence here is practitioner (A/B testing vendors), and should be treated as directional.

### Cited Findings
- **Contextual vs. onboarding paywalls:** Superwall advises against reusing the same paywall for onboarding and feature gating, and recommends tailoring to the decision at hand — [Superwall newsletter vol. 3](https://superwall.com/blog/the-superwall-newsletter-volume-3); [Superwall: feature-based paywalls](https://superwall.com/blog/how-to-create-feature-based-paywalls-for-higher-conversions) [PRAC]. RevenueCat reports that onboarding drove about 50% of trial starts at one app (Mojo), and that moving the paywall earlier raised paywall views by 50% — [RevenueCat: paywall tests](https://www.revenuecat.com/blog/paywall-tests-grow-app-revenue/) [PRAC]. Benchmarks of about 5–12% conversion for onboarding paywalls vs. 8–20% for contextual ones are unsourced — [mwm.ai glossary](https://mwm.ai/glossary/paywall) [PRAC, unverified]
- **Endowed progress:** customers given a loyalty card with 2 of 10 stamps pre-filled completed it more often than those with an empty 8-stamp card, despite equal remaining effort — [Nunes & Drèze 2006, JCR](https://doi.org/10.1086/500480) [PR]
- **Curiosity/information gap:** curiosity arises when people notice a gap in their knowledge, which motivates closing it. This is the basis for teaser or preview designs — [Loewenstein 1994, Psychological Bulletin](https://doi.org/10.1037/0033-2909.116.1.75) [PR]
- **IKEA effect / endowment:** effort invested (scanning one's own cards, writing a question, saving a journal of readings) increases valuation — [Norton et al. 2012](https://doi.org/10.1016/j.jcps.2011.08.002); [Kahneman et al. 1990](https://doi.org/10.1086/261737) [PR]
- **Free-tier "zero price" power:** a free option exerts outsized pull, which suggests keeping a meaningful free tier, while recognizing that the step from $0 to any price is psychologically large — [Shampanier et al. 2007](https://doi.org/10.1287/mksc.1060.0254) [PR]
- **Hard vs. soft walls:** hard paywalls convert more downloads but refund more. The best-converting strategies also churn fastest — [SaaStr/RevenueCat summary](https://saastr.com/the-top-10-learnings-from-revenuecats-state-of-subscription-apps-how-115000-mobile-apps-deliver-16b-in-revenue-whats-working-whats-quietly-killing-growth); [Airbridge](https://www.airbridge.io/en/blog/paywall-conversion-structural-decisions) [PRAC]
- **Trial length:** one summary reports longer trials (17–32 days) having the highest trial conversion (45.7%), but figures vary across sources — [Airbridge](https://www.airbridge.io/en/blog/hard-paywall-vs-freemium-2026) [PRAC, secondary]
- **Personalized paywalls:** Phiture describes using user surveys to set paywall features and pricing — [Phiture](https://phiture.com/mobilegrowthstack/how-to-determine-paywall-features-and-pricing-with-user-surveys/) [PRAC]
- **Transparent trial timeline:** see Blinkist above (+23% sign-ups, −55% complaints) — [UX Planet](https://uxplanet.org/how-solving-our-biggest-customer-complaint-at-blinkist-led-to-a-23-increase-in-conversion-b60ad514134b) [PRAC]

### Inferences
Ethical application ideas for ShenTarot, labelled as hypotheses to A/B test:
1. **Value-moment paywall:** after a free basic reading, offer "Go deeper on this spread" (premium deep reading, follow-up questions, card-by-card detail). The offer is tied to the user's own cards and question, so it is contextual and leverages IKEA and endowment effects.
2. **Honest preview:** show the first paragraph or the section headings of the premium interpretation of *their* spread, with the rest clearly labelled premium. This uses the curiosity gap. To stay ethical, the visible part must be genuine output, not a bait text that differs from what is delivered (bait-and-switch per Apple 3.1.2(a)).
3. **Free sample of premium:** give one free premium reading (or a welcome credit grant) so users judge quality themselves. This directly addresses AI skepticism and value uncertainty.
4. **Gentle limits:** keep a recurring free allowance (e.g., a daily single-card draw). Paywall depth and volume, not the core ritual. This preserves zero-price goodwill and avoids hard-wall refunds.
5. **Endowed progress that is real:** e.g., a "reading journal" that shows streaks or saved spreads. Never fake pre-filled progress the user did not earn in a way that misrepresents status.
6. **Onboarding personalization:** ask the user's focus (love, career, self-reflection) and use it in the readings. Avoid fake "analyzing your energy…" loaders that imply unreal computation.
7. **Trust strip on every paywall:**
   - "Cancel anytime in Settings → Subscriptions."
   - The exact billed price and date.
   - "We'll remind you before your trial ends."
   - "For entertainment and self-reflection."
   - Restore Purchases.
   - Terms and Privacy links.

### Gaps
- No peer-reviewed study was found directly comparing contextual vs. onboarding paywalls, or soft vs. hard limits, in mobile apps. All comparative figures are vendor or practitioner.
- No sourced evidence was found on "personalized paywall" lift beyond vendor descriptions.
- NN/g and Baymard material on paywalls was not retrieved in this session (tool budget). The report writer should not attribute claims to them from these notes.
