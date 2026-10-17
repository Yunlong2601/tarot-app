# Promotions and introductory offer: launch-day plan

Owner decision 2026-10-17: set up every promotion before launch, not later. Prices: annual US$39.99, 3 months US$14.99, monthly US$6.99; annual intro US$1.99 for the first month. Honesty rules: show the real renewal price next to the button, no fake crossed-out "was" price, say "limited time" only when it really ends, no discount above 50% as a habit.

## Already built in the app (nothing to code)
| Technique | Where |
|---|---|
| Annual plan listed first and pre-selected, "Best value" badge | `app/lib/features/paywall/paywall_screen.dart` |
| Per-month breakdown ("just $3.33/month") and "save N% vs monthly" computed from real store prices | `paywall_screen.dart` (`annualSaving`) |
| Intro offer text ("$1.99 for your first month, then $39.99 per year. Cancel any time") read from the store product | paywall + `subscription_service.dart` |
| Apple offer-code redemption sheet | paywall ("Redeem in App Store") |
| Upgrade nudge for monthly / 3-month subscribers after a few months | `annual_upgrade_card.dart` |
| Free tier (1 reading a day) as the trial | backend usage limits |
| Refer and earn (friend gets annual at US$19.99) | built, switched off: see `referral-setup.md` |

## To create in the stores before launch (owner, needs the paid Apple account)
1. **Intro offer** on `shentarot_annual`: Apple "Pay up front", 1 month, US$1.99, new subscribers; Play offer `first-month`, eligibility "never had any subscription in this app". Annual only; monthly and 3-month get no intro.
2. **Launch offer code** (honest, time-limited): Apple offer code "Launch 30%" on annual, new subscribers, pay up front for 1 year at about US$27.99, expires 30 days after launch; Play promo offer tag `launch-30` with the same end date. Use it in launch posts, the waiting list and creator posts. Do not show a crossed-out price in the app.
3. **Creator / tester codes**: a separate batch of one-time Apple codes per creator, named by creator, to see who brings paying users. Play: custom promo codes.
4. **Win-back offer** (Apple win-back offer and Play resubscribe offer): 50% off the first period for people whose subscription lapsed. Nobody is eligible on day one, but create it now so it is live when the first cancellations happen. Eligible only after a lapse of at least 30 days.
5. **Referral**: follow `referral-setup.md` and switch it on at launch.
6. **Seasonal sales**: create the offers up front, switch on only for the dates below, 3 to 5 days each.

## Seasonal calendar (year 1, start from your real launch date)
New Year (about 1 to 7 Jan, strongest), Valentine's Day (10 to 14 Feb), Chinese New Year week, Mercury retrograde windows (short), Halloween (25 to 31 Oct), Black Friday week. Never run two sales within 4 weeks of each other.

## Checkpoints
- Look at paywall views, trial/intro starts and conversion after 1,000 paywall views; compare a free-trial variant against the US$1.99 intro only then.
- Under 500 downloads by month 3: change marketing before building more.
