#!/usr/bin/env bash
# Audit skill — shared optimal configuration values
# All config scripts source this file via:
#   _shared="$(dirname "$(readlink -f "$0" 2>/dev/null || echo "$0")")/config-optimal-values.sh"
#   source "$_shared"

# Guard against direct execution (this file should be sourced, not run)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "ERROR: This file should be sourced, not executed directly" >&2
  exit 1
fi

# Caller must set -euo pipefail before sourcing (this file is a library, not a standalone script)

# Restrict file permissions for temp files and backups (audit P-15/P-16)
umask 077

# Optimal audit configuration (change values here only)
# Use standard model IDs without context-window suffixes (e.g., claude-opus-4-6, not claude-opus-4-6[1m])
# The [1m] suffix appears in system prompts but is not a documented settings.json model ID format.
OPTIMAL_MODEL="claude-opus-4-6"
# effortLevel API enum: "low" | "medium" | "high" | "max"
# "max" = absolute maximum thinking (Opus 4.6 only). Preferred for deep audit.
# Known bug: Claude Code UI silently downgrades "max" to "high" on interaction (github.com/anthropics/claude-code/issues/30726).
# We still set "max" as optimal — the bug is in the UI, not the value.
OPTIMAL_EFFORT="max"
# NOTE: Boolean values MUST be valid JSON literals (true/false)
# — used with jq --argjson in config-optimize.sh; "yes"/"1"/etc. will crash jq
# fastMode is NOT recommended for audit: audit is a long autonomous task, not interactive work.
# Standard mode is more appropriate. Set to false so config-check does not flag standard mode users.
OPTIMAL_FAST="false"
OPTIMAL_THINKING="true"

# File paths
SETTINGS_FILE="$HOME/.claude/settings.json"
BACKUP_FILE="$HOME/.claude/settings.json.audit-backup"

resolve_jq_bin() {
  if command -v jq >/dev/null 2>&1; then
    command -v jq
    return 0
  fi

  if command -v jq.exe >/dev/null 2>&1; then
    command -v jq.exe
    return 0
  fi

  if command -v where.exe >/dev/null 2>&1; then
    local jq_candidate
    jq_candidate="$(where.exe jq 2>/dev/null | tr -d '\r' | head -n 1 || true)"
    jq_candidate="${jq_candidate//\\//}"
    if [[ -n "$jq_candidate" && -f "$jq_candidate" ]]; then
      printf '%s\n' "$jq_candidate"
      return 0
    fi
  fi

  return 1
}

JQ_BIN="$(resolve_jq_bin || true)"
