#!/usr/bin/env bash
# Smoke-test a running backend (local `npm run dev` or a deployed Worker).
#   scripts/smoke.sh http://localhost:8787
# Needs ALLOW_UNATTESTED_INSTALLS=true on the target (local testing only).
# Does not need an Anthropic key: it checks routing, auth, validation and the
# premium gate. The last step makes a real reading only if the key is set.
set -u
BASE="${1:?usage: smoke.sh BASE_URL}"
ID="123e4567-e89b-42d3-a456-426614174000"
fail=0
check() { # name expected actual
  if [ "$2" = "$3" ]; then echo "ok    $1"; else echo "FAIL  $1 (expected $2, got $3)"; fail=1; fi
}
code() { curl -s -o /dev/null -w "%{http_code}" "$@"; }

check "health" 200 "$(code "$BASE/health")"
TOKEN=$(curl -s -X POST "$BASE/v1/install" -d "{\"installId\":\"$ID\"}" | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')
check "install returns a token" yes "$([ -n "$TOKEN" ] && echo yes || echo no)"
check "reading without token is refused" 401 "$(code -X POST "$BASE/v1/reading" -d '{}')"
AUTH="authorization: Bearer $TOKEN"
check "bad body is rejected" 400 "$(code -X POST "$BASE/v1/reading" -H "$AUTH" -d '{"spread":"single","cards":[]}')"
check "unknown card is rejected" 400 "$(code -X POST "$BASE/v1/reading" -H "$AUTH" -d '{"spread":"single","cards":[{"id":"nope","reversed":false}]}')"
check "long question is rejected" 400 "$(code -X POST "$BASE/v1/reading" -H "$AUTH" -d "{\"spread\":\"single\",\"cards\":[{\"id\":\"major_00_fool\",\"reversed\":false}],\"question\":\"$(printf 'a%.0s' $(seq 1 301))\"}")"
check "follow-up needs premium" 402 "$(code -X POST "$BASE/v1/followup" -H "$AUTH" -d '{"spread":"single","cards":[{"id":"major_00_fool","reversed":false}],"reading":"The Fool invites a fresh start.","followup":"What next?"}')"
S=$(code -X POST "$BASE/v1/reading" -H "$AUTH" -d '{"spread":"single","cards":[{"id":"major_00_fool","reversed":false}],"question":"smoke test"}')
echo "info  single reading returned HTTP $S (200 = real reading; 502 = no or invalid Anthropic key; 429 = rate limit, wait a minute or restart local dev)"
exit $fail
