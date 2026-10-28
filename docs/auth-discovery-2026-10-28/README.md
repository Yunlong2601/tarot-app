# Authentication discovery status — 2026-10-28

Published https://shentarot.com/auth.md as HTTP 200 Markdown with H1 containing auth.md. It identifies the audience, app provisioning endpoint, supported 12-hour install JWT method, Authorization bearer-header usage, expiry and failure behavior. It truthfully states independent agent registration is unavailable. Homepage advertises the guide. All 40 site tests passed; no registration endpoint was POSTed and no credential/account was issued.

Deployed Worker version: `c1e90a72-988a-478d-9c0e-1964ef51a061`. Previous pre-auth version: `dbce59b9-87eb-4a72-8df3-e55e4cd95491`. Isolated Worker-only release; static assets and backend unchanged.

The initial scanner incorrectly treated negated names of unsupported methods as support and returned pass with false ID-JAG/email/anonymous flags. Removed that ambiguous enumeration; current authMd check now fails with registrationMissing, accurately reflecting the lack of independent agent registration. Do not restore negated keywords to obtain a misleading green check. Current OAuth discovery also fails because no actual authorization server is configured. Saved both results to distinguish detector behavior from implementation evidence.

Expanded goal remains incomplete. The next architecture decision is pending in chat: add delegated OAuth access to the mobile reading API, or integrate a provider the user identifies. See oauth-integration-decision.md. No fabricated metadata or issuer is published, and no goal completion claim is made.
