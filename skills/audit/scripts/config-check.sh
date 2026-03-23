#!/usr/bin/env bash
# Audit skill — check current settings against optimal audit configuration
# Output (stdout): STATUS: OK / STATUS: MISMATCH + DIFF/MATCH lines
# Errors go to stderr

set -euo pipefail

# Source shared values
_shared="$(dirname "$(readlink -f "$0" 2>/dev/null || echo "$0")")/config-optimal-values.sh"
[[ -f "$_shared" ]] || { echo "ERROR: shared config not found at $_shared" >&2; exit 1; }
source "$_shared"

# Check jq availability
[[ -n "${JQ_BIN:-}" ]] || { echo "ERROR: jq not found in PATH (jq or jq.exe required)" >&2; exit 1; }

# Check settings file exists
if [[ ! -f "$SETTINGS_FILE" ]]; then
  echo "ERROR: settings file not found at $SETTINGS_FILE" >&2
  exit 1
fi

# Validate settings file is valid JSON
if ! "$JQ_BIN" empty "$SETTINGS_FILE" 2>/dev/null; then
  echo "ERROR: settings.json is not valid JSON" >&2
  exit 1
fi

# Read current values (UNSET if field missing; use `has` to distinguish false from missing)
cur_model=$("$JQ_BIN" -r 'if has("model") then .model | tostring else "UNSET" end' "$SETTINGS_FILE")
cur_effort=$("$JQ_BIN" -r 'if has("effortLevel") then .effortLevel | tostring else "UNSET" end' "$SETTINGS_FILE")
cur_fast=$("$JQ_BIN" -r 'if has("fastMode") then .fastMode | tostring else "UNSET" end' "$SETTINGS_FILE")
cur_thinking=$("$JQ_BIN" -r 'if has("alwaysThinkingEnabled") then .alwaysThinkingEnabled | tostring else "UNSET" end' "$SETTINGS_FILE")

# Compare each field
diff_count=0
diffs=""
matches=""
model_mismatch="false"

if [[ "$cur_model" != "$OPTIMAL_MODEL" ]]; then
  diffs+="DIFF: model current=$cur_model optimal=$OPTIMAL_MODEL"$'\n'
  model_mismatch="true"
  diff_count=$((diff_count + 1))
else
  matches+="MATCH: model $cur_model"$'\n'
fi

if [[ "$cur_effort" != "$OPTIMAL_EFFORT" ]]; then
  diffs+="DIFF: effortLevel current=$cur_effort optimal=$OPTIMAL_EFFORT"$'\n'
  diff_count=$((diff_count + 1))
else
  matches+="MATCH: effortLevel $cur_effort"$'\n'
fi

if [[ "$cur_fast" != "$OPTIMAL_FAST" ]]; then
  diffs+="DIFF: fastMode current=$cur_fast optimal=$OPTIMAL_FAST"$'\n'
  diff_count=$((diff_count + 1))
else
  matches+="MATCH: fastMode $cur_fast"$'\n'
fi

if [[ "$cur_thinking" != "$OPTIMAL_THINKING" ]]; then
  diffs+="DIFF: alwaysThinkingEnabled current=$cur_thinking optimal=$OPTIMAL_THINKING"$'\n'
  diff_count=$((diff_count + 1))
else
  matches+="MATCH: alwaysThinkingEnabled $cur_thinking"$'\n'
fi

# Output result
if [[ $diff_count -eq 0 ]]; then
  echo "STATUS: OK"
  # Also output field values on OK for observability
  printf "%s" "$matches"
else
  echo "STATUS: MISMATCH"
  if [[ "$model_mismatch" == "true" ]]; then
    echo "MODEL_MISMATCH: true"
  fi
  echo "DIFF_COUNT: $diff_count"
  printf "%s" "$diffs"
  printf "%s" "$matches"
  # Exit 0 on MISMATCH: stdout STATUS line distinguishes OK/MISMATCH;
  # non-zero exit codes are reserved for actual errors (exit 1).
  # Previous exit 2 caused SKILL.md fallback ("non-zero exit code") to
  # misclassify MISMATCH as a script error — see audit P-5.
fi
