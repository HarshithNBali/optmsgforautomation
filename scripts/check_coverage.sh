#!/bin/bash
# scripts/check_coverage.sh
# 
# Enforces code coverage thresholds. Use in CI/CD pipelines and locally.
# Exits with code 1 if coverage is below thresholds.
#
# Usage:
#   ./scripts/check_coverage.sh                          # Use defaults (90% line, 85% branch)
#   ./scripts/check_coverage.sh --min-line 90 --min-branch 85
#   ./scripts/check_coverage.sh --report                 # Generate detailed report
#   ./scripts/check_coverage.sh --diff main              # Compare coverage vs branch

set -euo pipefail

# Defaults
MIN_LINE_COVERAGE=90
MIN_BRANCH_COVERAGE=85
MIN_CRITICAL_COVERAGE=95
COVERAGE_FILE="coverage/lcov.info"
REPORT_MODE=false
DIFF_BRANCH=""
CRITICAL_PATHS="auth|security|api_client|token|session|encryption|payment|stripe"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --min-line) MIN_LINE_COVERAGE="$2"; shift 2 ;;
    --min-branch) MIN_BRANCH_COVERAGE="$2"; shift 2 ;;
    --min-critical) MIN_CRITICAL_COVERAGE="$2"; shift 2 ;;
    --coverage-file) COVERAGE_FILE="$2"; shift 2 ;;
    --report) REPORT_MODE=true; shift ;;
    --diff) DIFF_BRANCH="$2"; shift 2 ;;
    --critical-paths) CRITICAL_PATHS="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
BOLD='\033[1m'

echo ""
echo "${BOLD}═══════════════════════════════════════════════════${NC}"
echo "${BOLD}  CODE COVERAGE CHECK${NC}"
echo "${BOLD}═══════════════════════════════════════════════════${NC}"
echo ""

# Check coverage file exists
if [ ! -f "$COVERAGE_FILE" ]; then
  echo "${RED}ERROR: Coverage file not found: $COVERAGE_FILE${NC}"
  echo "Run 'flutter test --coverage' first."
  exit 1
fi

# Check lcov is available
if ! command -v lcov &> /dev/null; then
  echo "${YELLOW}WARNING: lcov not found. Installing...${NC}"
  if command -v apt-get &> /dev/null; then
    sudo apt-get install -y lcov
  elif command -v brew &> /dev/null; then
    brew install lcov
  else
    echo "${RED}ERROR: Cannot install lcov. Please install manually.${NC}"
    exit 1
  fi
fi

# Filter out generated files and excluded patterns
FILTERED_FILE="coverage/lcov_filtered.info"
lcov --remove "$COVERAGE_FILE" \
  '*.g.dart' \
  '*.freezed.dart' \
  '*.gr.dart' \
  '*.gen.dart' \
  '*.mocks.dart' \
  '**/generated/**' \
  '**/main.dart' \
  '**/firebase_options.dart' \
  '**/l10n/**' \
  -o "$FILTERED_FILE" \
  --quiet 2>/dev/null || cp "$COVERAGE_FILE" "$FILTERED_FILE"

# Parse overall coverage
OVERALL_SUMMARY=$(lcov --summary "$FILTERED_FILE" 2>&1)
LINE_COVERAGE=$(echo "$OVERALL_SUMMARY" | grep "lines" | grep -oP '[\d.]+%' | head -1 | tr -d '%')
BRANCH_COVERAGE=$(echo "$OVERALL_SUMMARY" | grep "branches" | grep -oP '[\d.]+%' | head -1 | tr -d '%')

# Handle case where branch coverage might not be reported
if [ -z "$BRANCH_COVERAGE" ]; then
  BRANCH_COVERAGE="N/A"
fi

echo "  ${BOLD}Overall Coverage:${NC}"
echo ""

# Check line coverage
if (( $(echo "$LINE_COVERAGE >= $MIN_LINE_COVERAGE" | bc -l) )); then
  echo "  ${GREEN}✅ Line coverage:   ${LINE_COVERAGE}% (target: ${MIN_LINE_COVERAGE}%)${NC}"
  LINE_PASS=true
else
  echo "  ${RED}❌ Line coverage:   ${LINE_COVERAGE}% (target: ${MIN_LINE_COVERAGE}%)${NC}"
  LINE_PASS=false
fi

# Check branch coverage
if [ "$BRANCH_COVERAGE" != "N/A" ]; then
  if (( $(echo "$BRANCH_COVERAGE >= $MIN_BRANCH_COVERAGE" | bc -l) )); then
    echo "  ${GREEN}✅ Branch coverage: ${BRANCH_COVERAGE}% (target: ${MIN_BRANCH_COVERAGE}%)${NC}"
    BRANCH_PASS=true
  else
    echo "  ${RED}❌ Branch coverage: ${BRANCH_COVERAGE}% (target: ${MIN_BRANCH_COVERAGE}%)${NC}"
    BRANCH_PASS=false
  fi
else
  echo "  ${YELLOW}⚠️  Branch coverage: not reported${NC}"
  BRANCH_PASS=true
fi

echo ""

# Check critical module coverage
echo "  ${BOLD}Critical Module Coverage (target: ${MIN_CRITICAL_COVERAGE}%):${NC}"
echo ""

CRITICAL_PASS=true
while IFS= read -r file; do
  if [ -n "$file" ]; then
    FILE_SUMMARY=$(lcov --summary "$FILTERED_FILE" --include "*${file}*" 2>&1 || true)
    FILE_LINE=$(echo "$FILE_SUMMARY" | grep "lines" | grep -oP '[\d.]+%' | head -1 | tr -d '%' || echo "0")
    if [ -n "$FILE_LINE" ] && [ "$FILE_LINE" != "0" ]; then
      if (( $(echo "$FILE_LINE < $MIN_CRITICAL_COVERAGE" | bc -l) )); then
        echo "  ${RED}  ❌ ${file}: ${FILE_LINE}%${NC}"
        CRITICAL_PASS=false
      else
        echo "  ${GREEN}  ✅ ${file}: ${FILE_LINE}%${NC}"
      fi
    fi
  fi
done < <(lcov --list "$FILTERED_FILE" 2>&1 | grep -iE "$CRITICAL_PATHS" | awk '{print $1}' | sort -u)

echo ""

# Coverage diff against branch
if [ -n "$DIFF_BRANCH" ]; then
  echo "  ${BOLD}Coverage Diff vs ${DIFF_BRANCH}:${NC}"
  echo ""
  
  # Get list of changed files
  CHANGED_FILES=$(git diff "$DIFF_BRANCH" --name-only --diff-filter=ACMR | grep '\.dart$' | grep '^lib/' || true)
  
  if [ -n "$CHANGED_FILES" ]; then
    UNCOVERED_NEW_LINES=0
    while IFS= read -r file; do
      FILE_COV=$(lcov --list "$FILTERED_FILE" 2>&1 | grep "$file" | awk '{print $2}' || echo "N/A")
      if [ "$FILE_COV" == "N/A" ] || [ -z "$FILE_COV" ]; then
        echo "  ${RED}  ⚠️  ${file}: NO COVERAGE${NC}"
        UNCOVERED_NEW_LINES=$((UNCOVERED_NEW_LINES + 1))
      else
        echo "  ${GREEN}  ✓ ${file}: ${FILE_COV}${NC}"
      fi
    done <<< "$CHANGED_FILES"
    
    if [ $UNCOVERED_NEW_LINES -gt 0 ]; then
      echo ""
      echo "  ${RED}  WARNING: ${UNCOVERED_NEW_LINES} changed file(s) have no coverage${NC}"
    fi
  else
    echo "  No changed Dart files detected."
  fi
  echo ""
fi

# Report mode — detailed per-file breakdown
if [ "$REPORT_MODE" = true ]; then
  echo "  ${BOLD}Detailed Per-File Coverage:${NC}"
  echo ""
  echo "  ${BOLD}Files below ${MIN_LINE_COVERAGE}% coverage:${NC}"
  echo ""
  
  lcov --list "$FILTERED_FILE" 2>&1 | tail -n +3 | head -n -1 | while IFS='|' read -r file lines_cov func_cov; do
    PCT=$(echo "$lines_cov" | grep -oP '[\d.]+%' | head -1 | tr -d '%' || echo "100")
    if [ -n "$PCT" ] && (( $(echo "$PCT < $MIN_LINE_COVERAGE" | bc -l 2>/dev/null || echo 0) )); then
      printf "  ${RED}  %6s%%  %s${NC}\n" "$PCT" "$file"
    fi
  done
  
  echo ""
  echo "  ${BOLD}Files with 0% coverage:${NC}"
  echo ""
  
  lcov --list "$FILTERED_FILE" 2>&1 | tail -n +3 | head -n -1 | while IFS='|' read -r file lines_cov func_cov; do
    PCT=$(echo "$lines_cov" | grep -oP '[\d.]+%' | head -1 | tr -d '%' || echo "100")
    if [ -n "$PCT" ] && [ "$PCT" = "0.0" ]; then
      printf "  ${RED}  0.0%%    %s${NC}\n" "$file"
    fi
  done
  
  echo ""
fi

# Final verdict
echo "${BOLD}═══════════════════════════════════════════════════${NC}"
if [ "$LINE_PASS" = true ] && [ "$BRANCH_PASS" = true ] && [ "$CRITICAL_PASS" = true ]; then
  echo "${GREEN}${BOLD}  ✅ COVERAGE CHECK PASSED${NC}"
  echo "${BOLD}═══════════════════════════════════════════════════${NC}"
  echo ""
  exit 0
else
  echo "${RED}${BOLD}  ❌ COVERAGE CHECK FAILED${NC}"
  echo "${BOLD}═══════════════════════════════════════════════════${NC}"
  echo ""
  
  if [ "$LINE_PASS" = false ]; then
    echo "${RED}  Line coverage ${LINE_COVERAGE}% is below minimum ${MIN_LINE_COVERAGE}%${NC}"
  fi
  if [ "$BRANCH_PASS" = false ]; then
    echo "${RED}  Branch coverage ${BRANCH_COVERAGE}% is below minimum ${MIN_BRANCH_COVERAGE}%${NC}"
  fi
  if [ "$CRITICAL_PASS" = false ]; then
    echo "${RED}  One or more critical modules below ${MIN_CRITICAL_COVERAGE}%${NC}"
  fi
  echo ""
  exit 1
fi
