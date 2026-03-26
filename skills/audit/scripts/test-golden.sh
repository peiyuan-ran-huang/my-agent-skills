#!/usr/bin/env bash
# Thin executable harness for committed AUDIT golden artefacts.
# Usage:
#   test-golden.sh [PACKAGE_ROOT]
# Exit codes:
#   0 = all golden checks pass
#   1 = one or more golden checks fail
#   2 = invocation/runtime error

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  test-golden.sh [PACKAGE_ROOT]
EOF
}

die() {
  echo "ERROR: $*" >&2
  exit 2
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -gt 1 ]]; then
  usage >&2
  exit 2
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PACKAGE_ROOT_DEFAULT="$(cd "$SCRIPT_DIR/.." && pwd -P)"
PACKAGE_ROOT_INPUT="${1:-$PACKAGE_ROOT_DEFAULT}"
PACKAGE_ROOT="$(cd "$PACKAGE_ROOT_INPUT" 2>/dev/null && pwd -P)" || die "package root not found or unreadable: $PACKAGE_ROOT_INPUT"

VALIDATE_REPORT="$PACKAGE_ROOT/scripts/validate-report.sh"
GOLDEN_DIR="$PACKAGE_ROOT/goldens"

[[ -x "$VALIDATE_REPORT" || -f "$VALIDATE_REPORT" ]] || die "validate-report.sh not found: $VALIDATE_REPORT"
[[ -d "$GOLDEN_DIR" ]] || die "goldens directory not found: $GOLDEN_DIR"

pass_count=0
fail_count=0

record_pass() {
  pass_count=$((pass_count + 1))
}

record_fail() {
  fail_count=$((fail_count + 1))
  echo "FAIL: $1"
}

run_report_check() {
  local path="$1"
  if bash "$VALIDATE_REPORT" "$path"; then
    record_pass
  else
    record_fail "report validation failed: $path"
  fi
}

check_literal() {
  local path="$1"
  local needle="$2"
  local label="$3"
  if grep -Fq -- "$needle" "$path"; then
    record_pass
  else
    record_fail "$label missing from $path"
  fi
}

check_absent() {
  local path="$1"
  local needle="$2"
  local label="$3"
  if grep -Fq -- "$needle" "$path"; then
    record_fail "$label unexpectedly present in $path"
  else
    record_pass
  fi
}

run_report_check "$GOLDEN_DIR/normal-report.md"
run_report_check "$GOLDEN_DIR/richer-normal-report.md"
run_report_check "$GOLDEN_DIR/all-zero-report.md"
run_report_check "$GOLDEN_DIR/partial-report.md"

check_literal "$GOLDEN_DIR/output-verification-warning.txt" "AUDIT Output Verification Warning" "warning heading"
check_literal "$GOLDEN_DIR/output-verification-warning.txt" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "warning divider line"
check_literal "$GOLDEN_DIR/output-verification-warning.txt" "Report Path:" "warning report-path line"
check_literal "$GOLDEN_DIR/output-verification-warning.txt" "Retained Temp Files:" "warning retained-temp-files line"
check_literal "$GOLDEN_DIR/output-verification-warning.txt" "Manual Check: Readback failed; verify written outputs manually before trusting completion" "warning manual-check line"
check_absent "$GOLDEN_DIR/output-verification-warning.txt" "AUDIT Complete" "success-only summary label"
check_absent "$GOLDEN_DIR/output-verification-warning.txt" "AUDIT Partial Report" "partial-report summary label"
check_absent "$GOLDEN_DIR/partial-report.md" "AUDIT Complete" "success-only summary label"
check_absent "$GOLDEN_DIR/partial-report.md" "## Issue List" "normal Issue List scaffold"
check_absent "$GOLDEN_DIR/partial-report.md" "## Summary Statistics" "normal Summary Statistics scaffold"
check_absent "$GOLDEN_DIR/partial-report.md" "## Appendix" "normal Appendix scaffold"

echo "Summary"
echo "- Package Path: $PACKAGE_ROOT"
echo "- Golden Directory: $GOLDEN_DIR"
echo "- Pass Count: $pass_count"
echo "- Fail Count: $fail_count"

if [[ $fail_count -gt 0 ]]; then
  exit 1
fi

exit 0
