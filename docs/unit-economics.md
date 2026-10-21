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
- Free user, 2 readings a day, every day (owner decision 2026-10-17, was 1): 60 x US$0.0003 = **about US$0.02**; worst case US$0.09.
- Premium gets monthly credits (annual 150, 3 months 120, monthly 90) plus the free 2 a day; unused credits roll over. Worst-case AI cost at about US$0.003 a credit: annual US$0.45 a month (net revenue US$2.83), 3 months US$0.36 (net US$4.25), monthly US$0.27 (net US$5.94). Typical cost is about a tenth of that.
- Free users get 2 credits a day (60 a month), unused ones roll over (bank 20): about US$0.02 a month typical. Nobody can spend more than 50 credits a day.

## Revenue per subscriber per month, after the 15% store fee
| Plan | Price | Net per month |
|---|---|---|
| Monthly | US$6.99 | about US$5.94 |
| 3 months | US$14.99 | about US$4.25 |
| Annual | US$39.99 a year (new subscribers first pay US$1.99 for one month) | about US$2.83 (US$33.99 a year) |

## Break-even
Fixed costs are about **US$10 to US$15 a month** (Apple fee, plus US$5 Cloudflare if needed). Free users add about US$0.01 each per month.

| Free daily users | AI cost a month (2 readings a day each, typical) | Total to cover | Annual subscribers needed (net US$2.83 a month each) |
|---|---|---|---|
| 100 | about US$2 | about US$15 | 6 |
| 1,000 | about US$18 | about US$31 | 11 |
| 10,000 | about US$180 | about US$193 | 68 |

So a generous free plan is affordable: even 10,000 daily free users cost about US$180 a month in AI at typical cost, covered by 68 annual subscribers (0.7% of them). Worst-case per-reading cost is about 10 times typical, so keep the global token cap and an alert on it. Prices (owner decision 2026-10-17, repriced): annual US$39.99, 3 months US$14.99, monthly US$6.99; no weekly. The server's global daily token cap (currently 500,000 tokens in test mode, about US$0.50 a day) stops runaway costs; raise it as real users arrive.


## Repriced plan and targets (2026-10-17)
Annual US$39.99 (default, "Save 52%" vs 12 x monthly), 3 months US$14.99, monthly US$6.99, intro US$1.99 first month on annual. Annual nets about US$34 after the 15% store fee. Fixed costs about US$150 a year, so break-even is about **5 annual subscribers**.

| Scenario (year 1, no ads) | Downloads | Conversion | Active subs at month 12 | Net revenue | Profit |
|---|---|---|---|---|---|
| Very bad | 500 | 0.7% | ~1 | ~US$56 | about -US$85 |
| Pessimistic | 1,500 | 1% | ~5 | ~US$253 | about +US$100 |
| Realistic target | 6,000-12,000 | ~2.5% | 150-300 | US$5,000-10,000 | positive |
| Stretch | 40,000 | ~2.5% | ~1,000 | ~US$34,000 | positive |

Pessimistic assumptions: plan mix 50% annual / 35% monthly / 15% 3-month; 55% of annual intro subscribers pay the full price; monthly subscribers stay about 2 months; Apple US$110 + Google US$25 fees; AI about US$0.0003 a reading. Conversion rates are general industry benchmarks, not this app's data. Checkpoint: under 500 downloads by month 3 means change marketing before building more.
