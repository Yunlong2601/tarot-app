# AI providers and the user's own key

Status 2026-10-16: coded and tested (backend 58 tests, app 99 tests). **Not deployed.** Deploy only after the owner says so.

## What is built
- **Providers.** Anthropic Claude Haiku 5.5 is the default (`claude-haiku-5-5`, effort `low`, SDK `maxRetries: 1`, 30 s timeout). OpenAI GPT-6 Luna (`gpt-6-luna`, Responses API, `reasoning.effort: "none"`, `store: false`, `max_output_tokens` capped, 30 s timeout) is the second provider. Code: `backend/src/llm.ts`, `backend/src/route.ts`.
- **Fallback.** With our keys: the primary (`LLM_PROVIDER`, default `anthropic`), then the other provider once if its key is set. At most two calls per request. Without `OPENAI_API_KEY` there is no fallback.
- **Own key (Premium only).** You tab > Your own AI key. Key stored in Keychain (this device only) / Android Keystore via `flutter_secure_storage`; sent per request as `x-user-provider` / `x-user-key` headers over HTTPS to our Worker, which calls the provider once and keeps nothing. No fallback to our keys. No daily reading or follow-up cap in own-key mode (only the per-minute brakes: 10 a minute per install, 30 per IP). Not counted in our global daily token budget (usage rows are tagged `byok:<model>`). Free users are refused (402). Delete all my data removes the key.
- **Same rules on both paths:** crisis wording returns the fixed care message before any model call, same system prompt with prompt-injection rules, same output checks and banned-claim fallback.
- **Logs:** upstream errors log only the error class, HTTP status and provider error type; anything that looks like `sk-...` is redacted. A rejected own key returns `user_key_rejected` and is not logged.

## Owner steps (when ready)
1. Optional backup provider: create an OpenAI account, set a monthly budget, create a key, then `npx wrangler secret put OPENAI_API_KEY` in `backend/`. Verify the exact model id `gpt-6-luna` and the Responses API fields on OpenAI's docs (I read the model id from developers.openai.com/api/docs/models on 2026-10-16; the request fields are from my knowledge of the Responses API, not checked).
2. Deploy with `npm run deploy:beta` (testing) after you approve.

## Risks to decide on
- **App Store / Google Play.** Gating own-key mode behind the Premium subscription keeps the unlock inside in-app purchase. The open question is whether reviewers accept a paid feature that also needs a third-party key, and how they test it (give them a test key, or explain in the review notes). I have not verified current guideline wording: read Apple App Review Guidelines 3.1.1 (in-app purchase) and 5.1 (privacy), and Google Play's Payments policy and User Data policy before submitting.
- **Few users have API keys.** Most US tarot users will not have one; it is a niche power-user feature.
- **Provider terms.** Users are responsible for their key under their provider's terms. Check that Anthropic's and OpenAI's terms allow a user to use their own key through a third-party app.
- **Our server sees the key in transit.** It is in memory for one request and never stored, but a compromised Worker could read it. The alternative (app calls the provider directly) would put the prompt and safety checks on the phone, where they can be extracted or bypassed, so I did not choose it.
- **Abuse of our server with a user key.** No daily cap means a Premium user with a key can make up to 10 readings a minute through our Worker. Cloudflare's free plan has a daily request limit (verify the current number); consider a high safety cap (for example 500 a day) if this becomes a problem.
