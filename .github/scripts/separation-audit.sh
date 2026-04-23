#!/bin/bash
# forgepoint-labs/claude-kit separation audit
# Fails if any client/employer-specific string lands in a commit.
# Works as a pre-commit hook (checks staged) OR as a full-repo CI scan.

set -e

FORBIDDEN_PATTERNS=(
  "agility"
  "agc-"
  "agc_"
  "agc/"
  "agc\\."
  "[[:space:]]agc[[:space:]]"
  "[[:space:]]agc[[:punct:]]"
  "agilitycredit"
  "precise-id"
  "preciseid"
  "ofac"
  "equifax"
  "experian"
  "transunion"
  "vendTokenWithSession"
  "@lib/packages"
  "tenantId"
  "agc-sandbox"
  "agc-dev"
  "agc-demo"
  "agc-prod"
  "cassius"
  "monster qa"
)

VIOLATIONS=()

# Files that are allowed to contain the forbidden patterns (this script and the policy
# doc enumerate them on purpose).
SELF_EXCLUDE=(
  ".github/scripts/separation-audit.sh"
)

is_excluded() {
  local target="$1"
  for e in "${SELF_EXCLUDE[@]}"; do
    if [ "$target" = "$e" ]; then
      return 0
    fi
  done
  return 1
}

# Mode: staged (pre-commit) or full (CI)
MODE="${1:-staged}"

if [ "$MODE" = "staged" ]; then
  RAW_FILES=$(git diff --cached --name-only)
else
  RAW_FILES=$(git ls-files)
fi

FILES=""
while IFS= read -r f; do
  if [ -z "$f" ]; then
    continue
  fi
  if is_excluded "$f"; then
    continue
  fi
  FILES+="$f"$'\n'
done <<< "$RAW_FILES"

if [ -z "$FILES" ]; then
  echo "No files to check."
  exit 0
fi

for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
  matches=$(echo "$FILES" | xargs -I{} grep -liE "$pattern" {} 2>/dev/null || true)
  if [ -n "$matches" ]; then
    VIOLATIONS+=("Pattern '$pattern' found in:")
    while IFS= read -r f; do
      VIOLATIONS+=("  - $f")
    done <<< "$matches"
  fi
done

if [ ${#VIOLATIONS[@]} -gt 0 ]; then
  echo "❌ SEPARATION AUDIT FAILED - CLIENT/EMPLOYER CONTENT DETECTED"
  echo ""
  printf '%s\n' "${VIOLATIONS[@]}"
  echo ""
  echo "This repository is PUBLIC. Remove any client/employer-specific content."
  exit 1
fi

echo "✅ Separation audit passed - no forbidden content found."
