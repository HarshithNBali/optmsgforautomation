#!/usr/bin/env bash
# ===========================================================================
# OptMsg Test Runner
# ===========================================================================
# Usage:
#   ./scripts/run_tests.sh              # Run all unit + widget tests
#   ./scripts/run_tests.sh --coverage   # Run with coverage report
#   ./scripts/run_tests.sh --unit       # Run only unit tests
#   ./scripts/run_tests.sh --widget     # Run only widget tests
#   ./scripts/run_tests.sh --file path  # Run a single test file
# ===========================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

COVERAGE=false
TEST_PATH="test/"
SINGLE_FILE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --coverage)
      COVERAGE=true
      shift
      ;;
    --unit)
      TEST_PATH="test/unit/"
      shift
      ;;
    --widget)
      TEST_PATH="test/widget/"
      shift
      ;;
    --file)
      SINGLE_FILE="$2"
      shift 2
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      exit 1
      ;;
  esac
done

echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
echo -e "${CYAN}  OptMsg Test Runner${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"

# Step 1: Analyze
echo -e "\n${YELLOW}▸ Running flutter analyze...${NC}"
if flutter analyze --no-fatal-infos 2>&1 | tail -5; then
  echo -e "${GREEN}  ✓ Analysis passed${NC}"
else
  echo -e "${RED}  ✗ Analysis failed — fix issues before running tests${NC}"
  exit 1
fi

# Step 2: Run tests
echo -e "\n${YELLOW}▸ Running tests...${NC}"
START_TIME=$(date +%s)

if [[ -n "$SINGLE_FILE" ]]; then
  TEST_CMD="flutter test $SINGLE_FILE"
elif $COVERAGE; then
  TEST_CMD="flutter test $TEST_PATH --coverage"
else
  TEST_CMD="flutter test $TEST_PATH"
fi

echo -e "  Command: ${CYAN}$TEST_CMD${NC}"
if $TEST_CMD 2>&1; then
  END_TIME=$(date +%s)
  DURATION=$((END_TIME - START_TIME))
  echo -e "\n${GREEN}  ✓ All tests passed (${DURATION}s)${NC}"
else
  END_TIME=$(date +%s)
  DURATION=$((END_TIME - START_TIME))
  echo -e "\n${RED}  ✗ Tests failed (${DURATION}s)${NC}"
  exit 1
fi

# Step 3: Coverage report (if requested)
if $COVERAGE && [[ -f "coverage/lcov.info" ]]; then
  echo -e "\n${YELLOW}▸ Coverage summary:${NC}"

  # Parse lcov.info for a quick summary
  TOTAL_LINES=$(grep -c "^DA:" coverage/lcov.info 2>/dev/null || echo 0)
  COVERED_LINES=$(grep "^DA:" coverage/lcov.info 2>/dev/null | grep -cv ",0$" || echo 0)

  if [[ $TOTAL_LINES -gt 0 ]]; then
    COVERAGE_PCT=$(awk "BEGIN {printf \"%.1f\", ($COVERED_LINES/$TOTAL_LINES)*100}")
    echo -e "  Lines: ${COVERED_LINES}/${TOTAL_LINES} (${COVERAGE_PCT}%)"

    # Check against threshold
    THRESHOLD=50
    if awk "BEGIN {exit !($COVERAGE_PCT < $THRESHOLD)}"; then
      echo -e "${YELLOW}  ⚠ Coverage below ${THRESHOLD}% target${NC}"
    else
      echo -e "${GREEN}  ✓ Coverage meets ${THRESHOLD}% target${NC}"
    fi
  fi

  # Generate HTML report if lcov is available
  if command -v genhtml &>/dev/null; then
    echo -e "\n${YELLOW}▸ Generating HTML coverage report...${NC}"
    genhtml coverage/lcov.info -o coverage/html --quiet
    echo -e "${GREEN}  ✓ Report at: coverage/html/index.html${NC}"
  else
    echo -e "\n${YELLOW}  ℹ Install lcov for HTML reports: brew install lcov${NC}"
  fi
fi

echo -e "\n${CYAN}═══════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Done.${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════${NC}"
