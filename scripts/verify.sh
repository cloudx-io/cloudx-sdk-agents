#!/usr/bin/env bash
# Repository freshness and honesty checks. Run locally or in CI (verify.yml).
# Checks: docs links alive, doc-map stems present in live llms.txt,
# no hardcoded CloudX versions, playbook staleness, schema sanity.
set -uo pipefail

cd "$(dirname "$0")/.."
FAIL=0
WARN=0

note() { printf '%s\n' "$*"; }
fail() { printf 'FAIL: %s\n' "$*"; FAIL=1; }
warn() { printf 'WARN: %s\n' "$*"; WARN=$((WARN + 1)); }

# --- 1. Docs link check -------------------------------------------------------
note "== docs link check"
LLMS_TXT="$(curl -sf --max-time 30 https://docs.cloudx.io/llms.txt)" \
  || { fail "could not fetch https://docs.cloudx.io/llms.txt"; LLMS_TXT=""; }

# Every docs.cloudx.io URL mentioned anywhere in the repo must resolve.
URLS=$(grep -rhoE 'https://docs\.cloudx\.io[^) `"'"'"'<>]*' \
  --include='*.md' --include='*.json' . | sed 's/[.,;]$//' | sort -u)
for url in $URLS; do
  if ! curl -sf -o /dev/null --max-time 30 "$url"; then
    fail "dead link: $url"
  fi
done

# Every path stem referenced in doc-map.md must appear in live llms.txt.
# Stems containing <placeholders> are expanded against known platforms/formats
# only for the always-fetch integration pages; parameterized stems are checked
# as a prefix family (at least one live page must match the family).
if [ -n "$LLMS_TXT" ]; then
  for p in android ios react-native flutter unity; do
    echo "$LLMS_TXT" | grep -q "https://docs.cloudx.io/en/$p/integration.md" \
      || fail "llms.txt no longer lists en/$p/integration.md (doc-map stem broken)"
  done
  for family in "en/android/ad-formats/" "en/ios/ad-formats/" "en/ad-formats/" \
                "en/android/adapters/" "en/ios/adapters/" "en/networks/" \
                "en/android/integrations/first-look" "en/ios/integrations/first-look" \
                "en/mcp/"; do
    echo "$LLMS_TXT" | grep -q "https://docs.cloudx.io/$family" \
      || fail "llms.txt no longer lists any page under $family (doc-map stem broken)"
  done
fi

# --- 2. No hardcoded CloudX versions -----------------------------------------
note "== hardcoded-version lint"
# Dependency-coordinate or version-pin forms of CloudX artifacts are banned
# everywhere: this repo must never state a version the docs site owns.
PATTERNS=(
  'io\.cloudx:[A-Za-z0-9._-]+:[0-9]'          # Gradle coordinate with version
  "pod ['\"]CloudX[A-Za-z]*['\"], *['\"]"      # pinned CocoaPods pod
  'cloudx[a-z_-]*: *\^?[0-9]+\.[0-9]'          # pubspec-style pin
  'SDK Version:'                                # v1 baked-snapshot header
)
for pat in "${PATTERNS[@]}"; do
  HITS=$(grep -rInE "$pat" --include='*.md' --include='*.json' --include='*.sh' . \
    | grep -v '^\./scripts/verify.sh:' || true)
  if [ -n "$HITS" ]; then
    fail "hardcoded CloudX version matter (pattern: $pat):"
    printf '%s\n' "$HITS"
  fi
done

# --- 3. Playbook staleness ----------------------------------------------------
note "== playbook staleness (last_verified > 180 days -> warning)"
NOW=$(date +%s)
for f in playbooks/*.md; do
  LV=$(sed -n 's/^last_verified: *//p' "$f" | head -1)
  if [ -z "$LV" ]; then
    fail "$f: missing last_verified frontmatter"
    continue
  fi
  LV_EPOCH=$(date -j -f '%Y-%m-%d' "$LV" +%s 2>/dev/null || date -d "$LV" +%s 2>/dev/null) \
    || { fail "$f: unparseable last_verified '$LV'"; continue; }
  AGE_DAYS=$(( (NOW - LV_EPOCH) / 86400 ))
  if [ "$AGE_DAYS" -gt 180 ]; then
    warn "$f: last_verified $LV is ${AGE_DAYS} days old — re-verify"
  fi
done

# --- 4. Schema sanity ----------------------------------------------------------
note "== schema checks"
for j in .claude-plugin/plugin.json .claude-plugin/marketplace.json; do
  python3 -c "import json,sys; json.load(open('$j'))" 2>/dev/null \
    || fail "$j: invalid JSON"
done
for s in .agents/skills/*/SKILL.md; do
  head -20 "$s" | grep -q '^name:' || fail "$s: missing name frontmatter"
  head -20 "$s" | grep -q '^description:' || fail "$s: missing description frontmatter"
done
# Every playbook named in playbook-index.md must exist.
for pb in $(grep -oE '`[a-z-]+\.md`' .agents/skills/cloudx-integrate/references/playbook-index.md \
              | tr -d '`' | sort -u); do
  [ -f "playbooks/$pb" ] || fail "playbook-index references playbooks/$pb which does not exist"
done

# --- result ---------------------------------------------------------------------
if [ "$FAIL" -ne 0 ]; then
  note "verify: FAILED"
  exit 1
fi
note "verify: OK (${WARN} warning(s))"
