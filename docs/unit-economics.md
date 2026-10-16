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
- Premium user, 20 readings and 30 follow-ups a day every day (heavy use): about US$0.45 typical, under US$2.30 worst case. A typical subscriber uses far less.

## Revenue per subscriber per month, after the 15% store fee
| Plan | Price | Net per month |
|---|---|---|
| Weekly | US$3.99 | about US$14.70 |
| Monthly | US$7.99 | about US$6.79 |
| Annual | US$39.99 | about US$2.83 |

## Break-even
Fixed costs are about **US$10 to US$15 a month** (Apple fee, plus US$5 Cloudflare if needed). Free users add about US$0.01 each per month.

| Free daily users | AI cost a month | Total to cover | Annual subscribers needed | Or monthly subscribers |
|---|---|---|---|---|
| 100 | about US$1 | about US$16 | 6 | 3 |
| 1,000 | about US$10 | about US$25 | 9 | 4 |
| 10,000 | about US$90 | about US$105 | 37 | 16 |

So a generous free plan is affordable: even 10,000 daily free readers cost about US$90 a month in AI, covered by a few dozen subscribers. The server's global daily token cap (currently 500,000 tokens in test mode, about US$0.50 a day) stops runaway costs; raise it as real users arrive.
