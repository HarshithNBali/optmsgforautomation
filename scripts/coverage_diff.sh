#!/bin/bash
# scripts/coverage_diff.sh
#
# Compares test coverage between current branch and a target branch (default: main).
# Ensures that PRs do not decrease coverage.
#
# Usage:
#   ./scripts/coverage_diff.sh              # Compare vs main
#   ./scripts/coverage_diff.sh develop      # Compare vs develop
#   ./scripts/coverage_diff.sh --strict     # Fail if coverage decreases at all

set -euo pipefail

TARGET_BRANCH="${1:-main}"
STRICT_MODE=false

if [ "$TARGET_BRANCH" = "--strict" ]; then
  STRICT_MODE=true
  TARGET_BRANCH="main"
fi

BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "${BOLD}═══════════════════════════════════════════════════${NC}"
echo "${BOLD}  COVERAGE DIFF vs ${TARGET_BRANCH}${NC}"
echo "${BOLD}═══════════════════════════════════════════════════${NC}"
echo ""

# Step 1: Save current coverage
CURRENT_COVERAGE_FILE="coverage/lcov.info"
if [ ! -f "$CURRENT_COVERAGE_FILE" ]; then
  echo "Running tests to generate current coverage..."
  flutter test --coverage 2>&1 | tail -5
fi

CURRENT_LINE=$(lcov --summary "$CURRENT_COVERAGE_FILE" 2>&1 | grep "lines" | grep -oP '[\d.]+%' | head -1 | tr -d '%')
echo "  Current branch coverage: ${CURRENT_LINE}%"

# Step 2: Stash any changes, checkout target, run coverage, come back
CURRENT_BRANCH=$(git branch --show-current)
STASH_RESULT=$(git stash 2>&1 || true)

echo "  Checking out ${TARGET_BRANCH} to measure baseline..."
git checkout "$TARGET_BRANCH" --quiet 2>/dev/null

# Run coverage on target branch
flutter test --coverage 2>&1 > /dev/null || true
TARGET_LINE=$(lcov --summary coverage/lcov.info 2>&1 | grep "lines" | grep -oP '[\d.]+%' | head -1 | tr -d '%')

echo "  ${TARGET_BRANCH} branch coverage: ${TARGET_LINE}%"

# Step 3: Return to original branch
git checkout "$CURRENT_BRANCH" --quiet 2>/dev/null
if echo "$STASH_RESULT" | grep -q "Saved working directory"; then
  git stash pop --quiet 2>/dev/null || true
fi

# Restore current coverage file
flutter test --coverage 2>&1 > /dev/null || true

# Step 4: Compare
DIFF=$(echo "$CURRENT_LINE - $TARGET_LINE" | bc -l)

echo ""
echo "  ${BOLD}Coverage Delta: ${DIFF}%${NC}"
echo ""

if (( $(echo "$DIFF >= 0" | bc -l) )); then
  echo "${GREEN}  ✅ Coverage has not decreased (${TARGET_LINE}% → ${CURRENT_LINE}%, delta: +${DIFF}%)${NC}"
  echo ""
  exit 0
else
  ABS_DIFF=$(echo "$DIFF" | tr -d '-')
  if [ "$STRICT_MODE" = true ]; then
    echo "${RED}  ❌ Coverage DECREASED by ${ABS_DIFF}% (${TARGET_LINE}% → ${CURRENT_LINE}%)${NC}"
    echo "${RED}  Strict mode: any decrease fails the check.${NC}"
    echo ""
    exit 1
  else
    # Allow up to 0.5% decrease (rounding, removed dead code, etc.)
    if (( $(echo "$ABS_DIFF > 0.5" | bc -l) )); then
      echo "${RED}  ❌ Coverage DECREASED by ${ABS_DIFF}% (${TARGET_LINE}% → ${CURRENT_LINE}%)${NC}"
      echo "${RED}  Decrease exceeds 0.5% tolerance. Add tests for new/changed code.${NC}"
      echo ""
      exit 1
    else
      echo "${YELLOW}  ⚠️  Coverage decreased by ${ABS_DIFF}% (within 0.5% tolerance)${NC}"
      echo ""
      exit 0
    fi
  fi
fi
