#!/usr/bin/env bash
# Audit skill — revalidate archived markdown smoke reports against the current validator
# Output (stdout): Summary / Findings
# Exit codes:
#   0 = all discovered markdown smoke reports still pass the current validator
#   1 = one or more archived markdown smoke reports are stale under the current validator
#   2 = checker execution error

set -euo pipefail

on_error() {
  local line="$1"
  echo "ERROR: check-smoke-evidence.sh failed at line $line" >&2
  exit 2
}
trap 'on_error $LINENO' ERR

usage() {
  cat <<'EOF'
Usage:
  check-smoke-evidence.sh <SMOKE_ROOT> [<SMOKE_ROOT> ...]

Each SMOKE_ROOT should point to an archived smoke-evidence directory whose markdown
report artefacts can be revalidated with scripts/validate-report.sh. Discovery prefers
markdown files under any `reports/` subtree; if none exist, it falls back to root-level
`*.md` files.
EOF
}

die() {
  echo "ERROR: $*" >&2
  exit 2
}

for cmd in bash dirname find grep mktemp rm head cat sed; do
  command -v "$cmd" >/dev/null 2>&1 || die "required command not found in PATH: $cmd"
done

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -lt 1 ]]; then
  usage >&2
  exit 2
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PACKAGE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd -P)"
VALIDATOR="$PACKAGE_ROOT/scripts/validate-report.sh"
[[ -f "$VALIDATOR" && -r "$VALIDATOR" ]] || die "validator not found or unreadable: $VALIDATOR"

declare -a FINDINGS=()
declare -a ROOTS=("$@")
TOTAL_REPORTS=0
CURRENT_COUNT=0
STALE_COUNT=0
EMPTY_ROOT_COUNT=0

record_finding() {
  local severity="$1"
  local rule="$2"
  local file="$3"
  local message="$4"
  FINDINGS+=("$severity $rule $file $message")
}

emit_report_candidates() {
  local root="$1"
  if find "$root" -type f -path '*/reports/*.md' -print -quit | grep -q .; then
    find "$root" -type f -path '*/reports/*.md' -print0
  else
    find "$root" -maxdepth 1 -type f -name '*.md' -print0
  fi
}

for root in "${ROOTS[@]}"; do
  [[ -d "$root" ]] || die "smoke root not found or unreadable: $root"
  root_reports=0
  while IFS= read -r -d '' report; do
    root_reports=$((root_reports + 1))
    TOTAL_REPORTS=$((TOTAL_REPORTS + 1))
    tmp_out="$(mktemp)"
    if bash "$VALIDATOR" "$report" >"$tmp_out" 2>&1; then
      CURRENT_COUNT=$((CURRENT_COUNT + 1))
    else
      rc=$?
      if [[ $rc -eq 1 ]]; then
        STALE_COUNT=$((STALE_COUNT + 1))
        first_reason="$(grep -E '^- ' "$tmp_out" | head -n 1 | sed 's/^- //' || true)"
        if [[ -z "$first_reason" ]]; then
          first_reason="archived markdown smoke report failed the current validator"
        fi
        record_finding FAIL SE002 "$report" "archived markdown smoke report is stale under the current validator: $first_reason"
      else
        cat "$tmp_out" >&2 || true
        rm -f "$tmp_out"
        die "validate-report.sh failed unexpectedly while checking $report"
      fi
    fi
    rm -f "$tmp_out"
  done < <(emit_report_candidates "$root")

  if [[ $root_reports -eq 0 ]]; then
    EMPTY_ROOT_COUNT=$((EMPTY_ROOT_COUNT + 1))
    record_finding FAIL SE001 "$root" "no archived markdown smoke reports were found under this root"
  fi
done

echo "Summary"
echo "- Package Path: $PACKAGE_ROOT"
echo "- Validator Path: $VALIDATOR"
echo "- Smoke Roots Scanned: ${#ROOTS[@]}"
echo "- Markdown Reports Found: $TOTAL_REPORTS"
echo "- Current Count: $CURRENT_COUNT"
echo "- Stale Count: $STALE_COUNT"
echo "- Empty Root Count: $EMPTY_ROOT_COUNT"

echo
echo "Findings"
if [[ ${#FINDINGS[@]} -eq 0 ]]; then
  echo "- None"
  exit 0
fi

for finding in "${FINDINGS[@]}"; do
  echo "- $finding"
done
exit 1
