#!/usr/bin/env bash
# sync-skills.sh — Pull updates from GitHub and sync to ~/.claude/skills/
# Usage: bash ~/my-agent-skills/sync.sh
# Run this on any device to get the latest skills.

set -e
shopt -s nullglob

REPO_DIR="$HOME/my-agent-skills"
SKILLS_DIR="$HOME/.claude/skills"

echo "Pulling latest from GitHub..."
cd "$REPO_DIR" && git pull

echo "Syncing skills to $SKILLS_DIR ..."
for skill_dir in "$REPO_DIR/skills/"/*/; do
  skill_name=$(basename "$skill_dir")
  dest="$SKILLS_DIR/$skill_name"

  # Preserve user's pitfalls.md if it already exists at the destination
  pitfalls_backup=""
  if [[ -f "$dest/pitfalls.md" ]]; then
    pitfalls_backup=$(mktemp)
    cp "$dest/pitfalls.md" "$pitfalls_backup"
  fi

  # Full recursive copy (handles flat and nested skill layouts)
  mkdir -p "$dest"
  cp -r "$skill_dir/." "$dest/"

  # Restore user's pitfalls.md (overrides the repo template just copied)
  if [[ -n "$pitfalls_backup" ]]; then
    mv "$pitfalls_backup" "$dest/pitfalls.md"
    echo "  ⏭ $skill_name/pitfalls.md (user file preserved)"
  fi

  echo "  ✓ $skill_name"
done

echo "Done."
