#!/usr/bin/env bash
# Refuses a production deploy or store build that still has a test switch on.
# Run automatically before `npm run deploy` (predeploy) and by hand before a store build:
#   bash scripts/release-check.sh            # checks this repo
#   bash scripts/release-check.sh /path/to/copy
# Beta deploys use `npm run deploy:beta`, which does not run this check.
ROOT="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
fail=0
bad() { echo "RELEASE CHECK FAILED: $1"; fail=1; }

W="$ROOT/backend/wrangler.toml"
P="$ROOT/backend/package.json"
F="$ROOT/app/lib/app/flags.dart"

# 1. Test switches must not be set in the Worker config.
if grep -Eq '^[[:space:]]*(ALLOW_UNATTESTED_INSTALLS|TESTER_INSTALL_IDS)[[:space:]]*=' "$W"; then
  bad "wrangler.toml sets ALLOW_UNATTESTED_INSTALLS or TESTER_INSTALL_IDS (beta-only switches). Production needs App Attest / Play Integrity, not these."
fi
# 2. The production deploy script must not pass them either.
if grep -E '^[[:space:]]*"deploy"[[:space:]]*:' "$P" | grep -Eq 'ALLOW_UNATTESTED_INSTALLS|TESTER_INSTALL_IDS'; then
  bad "package.json 'deploy' passes a beta-only switch (use deploy:beta for those)."
fi
# 3. Tester mode in the app must be forced off in release builds.
if ! grep -E "bool testerMode" "$F" | grep -q 'kReleaseMode'; then
  bad "app/lib/app/flags.dart: testerMode is not guarded by kReleaseMode."
fi
# 4. No store build command in the docs may pass TESTER_MODE.
if grep -rEn 'flutter build (appbundle|ipa|apk|ios)[^`]*TESTER_MODE|TESTER_MODE[^`]*flutter build (appbundle|ipa|apk)' "$ROOT/docs" "$ROOT/README.md" "$ROOT/AGENTS.md" 2>/dev/null | grep -v 'release-check' | grep -q .; then
  bad "a documented store build command passes TESTER_MODE."
fi

if [ "$fail" -eq 0 ]; then echo "Release check passed."; fi
exit "$fail"
