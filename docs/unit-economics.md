# Unit economics (estimates, 2026-10-17)

Goal (owner): Premium only needs to cover building and running costs. All figures are estimates in USD; verify prices before relying on them.

## Costs
| Item | Cost | Source / note |
|---|---|---|
| Apple Developer Program | S$148 a year (about US$110, about US$9.20 a month) | Owner's membership page |
| Google Play developer account | US$25 once | Check Play Console |
| Cloudflare Workers + D1 + KV | US$0 on the free plan at low volume; US$5 a month if the free request limit is exceeded | Verify current Cloudflare limits |
| RevenueCat | US$0 below its free revenue tier | Verify current pricing |
| AI per reading (Claude Haiku 5.5) | about US$0.0003 typical, US$0.0015 worst case with a retry | `ai-api-cost-research.md` in the project library |
| Store fee on subscriptions | 15% (Apple Small Business Program, Google Play subscriptions) | Verify enrollment and current rates |

## What a user costs per month (AI only)
- Free user, 1 reading a day, every day: 30 x US$0.0003 = **about US$0.01**; worst case US$0.045.
- Premium is sold as unlimited, with a hidden fair-use cap of 50 readings and 50 follow-ups a day. Typical subscriber, 2 readings a day: about US$0.02 a month. Heavy, 10 a day: about US$0.10. At the cap every day: about US$0.90 typical, under US$4.50 worst case.

## Revenue per subscriber per month, after the 15% store fee
| Plan | Price | Net per month |
|---|---|---|
| Monthly | US$6.99 | about US$5.94 |
| 3 months | US$14.99 | about US$4.25 |
| Annual | US$39.99 a year (new subscribers first pay US$1.99 for one month) | about US$2.83 (US$33.99 a year) |

## Break-even
Fixed costs are about **US$10 to US$15 a month** (Apple fee, plus US$5 Cloudflare if needed). Free users add about US$0.01 each per month.

| Free daily users | AI cost a month | Total to cover | Annual subscribers needed | Or monthly subscribers |
|---|---|---|---|---|
| 100 | about US$1 | about US$16 | 3 | 2 |
| 1,000 | about US$10 | about US$25 | 4 | 2 |
| 10,000 | about US$90 | about US$105 | 15 | 9 |

So a generous free plan is affordable: even 10,000 daily free readers cost about US$90 a month in AI, covered by about 3 annual subscribers at the new price per US$34 net each. Prices (owner decision 2026-10-17, repriced): annual US$39.99, 3 months US$14.99, monthly US$6.99; no weekly. The server's global daily token cap (currently 500,000 tokens in test mode, about US$0.50 a day) stops runaway costs; raise it as real users arrive.


## Repriced plan and targets (2026-10-17)
Annual US$39.99 (default, "Save 52%" vs 12 x monthly), 3 months US$14.99, monthly US$6.99, intro US$1.99 first month on annual. Annual nets about US$34 after the 15% store fee. Fixed costs about US$150 a year, so break-even is about **5 annual subscribers**.

| Scenario (year 1, no ads) | Downloads | Conversion | Active subs at month 12 | Net revenue | Profit |
|---|---|---|---|---|---|
| Very bad | 500 | 0.7% | ~1 | ~US$56 | about -US$85 |
| Pessimistic | 1,500 | 1% | ~5 | ~US$253 | about +US$100 |
| Realistic target | 6,000-12,000 | ~2.5% | 150-300 | US$5,000-10,000 | positive |
| Stretch | 40,000 | ~2.5% | ~1,000 | ~US$34,000 | positive |

Pessimistic assumptions: plan mix 50% annual / 35% monthly / 15% 3-month; 55% of annual intro subscribers pay the full price; monthly subscribers stay about 2 months; Apple US$110 + Google US$25 fees; AI about US$0.0003 a reading. Conversion rates are general industry benchmarks, not this app's data. Checkpoint: under 500 downloads by month 3 means change marketing before building more.
