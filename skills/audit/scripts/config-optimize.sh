#!/usr/bin/env bash
# Audit skill — optimize settings.json for audit (backup + modify)
# Output (stdout): OPTIMIZED: key=value ... + BACKUP: path
# Errors go to stderr
#
# Execution order (prevents orphaned backup on jq failure):
#   1. Validate JSON + generate modified content to tmp
#   2. Only THEN create backup
#   3. Replace settings with modified version

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

# Safety: refuse if backup already exists (TOCTOU note: race window exists between
# this check and backup creation below; acceptable for single-user CLI tool)
if [[ -f "$BACKUP_FILE" ]]; then
  echo "ERROR: backup already exists at $BACKUP_FILE, run config-restore.sh first" >&2
  exit 1
fi

# Step 1: Generate modified JSON to temp file FIRST (validate before committing)
# Use mktemp for unique temp file (same directory for mv atomicity)
tmp_file=$(mktemp "${SETTINGS_FILE}.XXXXXX")
trap 'rm -f "$tmp_file" "${BACKUP_FILE}.tmp" 2>/dev/null' EXIT

"$JQ_BIN" -S --arg m "$OPTIMAL_MODEL" \
   --arg e "$OPTIMAL_EFFORT" \
   --argjson f "$OPTIMAL_FAST" \
   --argjson t "$OPTIMAL_THINKING" \
   '.model = $m | .effortLevel = $e | .fastMode = $f | .alwaysThinkingEnabled = $t' \
   "$SETTINGS_FILE" > "$tmp_file"

# Validate generated JSON before proceeding
if ! "$JQ_BIN" empty "$tmp_file" 2>/dev/null; then
  echo "ERROR: jq produced invalid JSON output" >&2
  exit 1
fi

# Step 2: Only create backup AFTER jq succeeds (prevents orphaned backup on jq failure)
# Atomic backup via cp-to-tmp + mv
backup_tmp="${BACKUP_FILE}.tmp"
cp "$SETTINGS_FILE" "$backup_tmp"
mv "$backup_tmp" "$BACKUP_FILE"

# Step 3: Replace settings with modified version (best-effort atomic on Windows/NTFS)
if ! mv "$tmp_file" "$SETTINGS_FILE"; then
  echo "ERROR: failed to replace settings.json (file may be locked by another process). Backup preserved at $BACKUP_FILE, optimized config at $tmp_file" >&2
  trap - EXIT  # preserve both files for manual recovery
  exit 1
fi
# Reset trap after successful mv
trap - EXIT

# Use printf for robustness (handles model names with special chars)
printf 'OPTIMIZED: model=%s effortLevel=%s fastMode=%s alwaysThinkingEnabled=%s\n' \
  "$OPTIMAL_MODEL" "$OPTIMAL_EFFORT" "$OPTIMAL_FAST" "$OPTIMAL_THINKING"
printf 'BACKUP: %s\n' "$BACKUP_FILE"
