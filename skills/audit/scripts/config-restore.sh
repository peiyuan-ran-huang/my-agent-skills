#!/usr/bin/env bash
# Audit skill — restore settings.json from audit backup
# Uses field-level restore: only reverts the 4 audit-managed fields,
# preserving any other changes made during the audit session.
# Output (stdout): RESTORED: ... / SKIP: ...
# Errors go to stderr

set -euo pipefail

# Source shared values (only for BACKUP_FILE and SETTINGS_FILE paths)
_shared="$(dirname "$(readlink -f "$0" 2>/dev/null || echo "$0")")/config-optimal-values.sh"
[[ -f "$_shared" ]] || { echo "ERROR: shared config not found at $_shared" >&2; exit 1; }
source "$_shared"

# Check backup exists
if [[ ! -f "$BACKUP_FILE" ]]; then
  echo "SKIP: no backup found, nothing to restore"
  exit 0
fi

# Check jq availability (needed for field-level restore)
if [[ -z "${JQ_BIN:-}" ]]; then
  # Warn that non-audit changes will be lost
  echo "WARNING: jq not found, falling back to full file restore — any changes made to settings.json during audit (outside the 4 audit fields) will be lost" >&2
  # Minimum integrity check before full restore
  if [[ ! -s "$BACKUP_FILE" ]]; then
    echo "ERROR: backup file is empty, refusing to restore" >&2
    exit 1
  fi
  if ! cp "$BACKUP_FILE" "$SETTINGS_FILE"; then
    echo "ERROR: failed to restore settings.json from backup" >&2
    exit 1
  fi
  rm -f "$BACKUP_FILE"
  echo "RESTORED: settings.json reverted from backup (full file, jq unavailable)"
  exit 0
fi

# Validate backup is valid JSON before restoring
if ! "$JQ_BIN" empty "$BACKUP_FILE" 2>/dev/null; then
  echo "ERROR: backup file is corrupted (not valid JSON), refusing to restore" >&2
  exit 1
fi

# Validate current settings.json before field-level restore
if [[ ! -f "$SETTINGS_FILE" ]] || ! "$JQ_BIN" empty "$SETTINGS_FILE" 2>/dev/null; then
  echo "WARNING: current settings.json is missing or corrupted, falling back to full file restore from backup" >&2
  mv "$BACKUP_FILE" "$SETTINGS_FILE"
  echo "RESTORED: settings.json replaced from backup (current file was missing/corrupted)"
  exit 0
fi

# Field-level restore: only revert the 4 audit-managed fields
# This prevents silently discarding user modifications made during the audit
# Use mktemp for unique temp file (same directory for mv atomicity)
tmp_file=$(mktemp "${SETTINGS_FILE}.XXXXXX")
pre_restore=""
trap 'rm -f "$tmp_file" "$pre_restore" 2>/dev/null' EXIT

"$JQ_BIN" -S --slurpfile backup "$BACKUP_FILE" '
  ($backup[0]) as $orig |
  (if ($orig | has("model")) then .model = $orig.model else del(.model) end) |
  (if ($orig | has("effortLevel")) then .effortLevel = $orig.effortLevel else del(.effortLevel) end) |
  (if ($orig | has("fastMode")) then .fastMode = $orig.fastMode else del(.fastMode) end) |
  (if ($orig | has("alwaysThinkingEnabled")) then .alwaysThinkingEnabled = $orig.alwaysThinkingEnabled else del(.alwaysThinkingEnabled) end)
' "$SETTINGS_FILE" > "$tmp_file"

# Pre-restore snapshot: if mv succeeds but jq validation fails, we can roll back (audit P-4)
pre_restore="${SETTINGS_FILE}.pre-restore"
cp "$SETTINGS_FILE" "$pre_restore"

# Best-effort atomic on Windows/NTFS
if ! mv "$tmp_file" "$SETTINGS_FILE"; then
  echo "ERROR: failed to replace settings.json (file may be locked by another process). Backup preserved at $BACKUP_FILE, restored config at $tmp_file" >&2
  trap - EXIT  # preserve both files for manual recovery
  exit 1
fi
# Reset trap after successful mv (tmp_file no longer exists)
trap - EXIT

# Validate restored settings.json before deleting backup
if ! "$JQ_BIN" empty "$SETTINGS_FILE" 2>/dev/null; then
  # Roll back to pre-restore state
  if [[ -f "$pre_restore" ]]; then
    mv "$pre_restore" "$SETTINGS_FILE"
    echo "ERROR: restored settings.json is invalid — rolled back to pre-restore state. Backup preserved at $BACKUP_FILE. To recover manually: cp '$BACKUP_FILE' '$SETTINGS_FILE'" >&2
  else
    echo "ERROR: restored settings.json is invalid and pre-restore snapshot missing. Backup preserved at $BACKUP_FILE. To recover manually: cp '$BACKUP_FILE' '$SETTINGS_FILE'" >&2
  fi
  exit 1
fi
rm -f "$pre_restore" 2>/dev/null

# Tolerant backup removal (rm failure doesn't block success message)
rm -f "$BACKUP_FILE" 2>/dev/null || echo "WARNING: could not remove backup at $BACKUP_FILE, please delete manually" >&2

echo "RESTORED: settings.json audit fields reverted (preserving other changes made during audit)"
