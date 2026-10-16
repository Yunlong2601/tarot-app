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
| Monthly | US$14.99 | about US$12.74 |
| 3 months | US$34.99 | about US$9.91 |
| Annual | US$99.99 (7-day trial) | about US$7.08 |

## Break-even
Fixed costs are about **US$10 to US$15 a month** (Apple fee, plus US$5 Cloudflare if needed). Free users add about US$0.01 each per month.

| Free daily users | AI cost a month | Total to cover | Annual subscribers needed | Or monthly subscribers |
|---|---|---|---|---|
| 100 | about US$1 | about US$16 | 3 | 2 |
| 1,000 | about US$10 | about US$25 | 4 | 2 |
| 10,000 | about US$90 | about US$105 | 15 | 9 |

So a generous free plan is affordable: even 10,000 daily free readers cost about US$90 a month in AI, covered by about 15 annual subscribers. Prices (owner decision 2026-10-17): annual US$99.99, 3 months US$34.99, monthly US$14.99; no weekly. The server's global daily token cap (currently 500,000 tokens in test mode, about US$0.50 a day) stops runaway costs; raise it as real users arrive.
