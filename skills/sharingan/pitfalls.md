# SHARINGAN Pitfalls

<!--
  INSTRUCTIONS

  This is YOUR personal pitfall log. Add entries for mistakes or oversights
  you've encountered when using sharingan that inline QC (Phase 6/9) should
  watch for. Each entry becomes an additional check item during QC reviews.

  FORMAT:
  - **Bold title** `[tag1/tag2]`: One-line description of what to check.
    `/` = OR: entry matches if ANY tag applies to the review context.
    No tag = always applicable (same as `[all]`).
    Matching is contextual (AI judges applicability), not literal.
    Suggested tags: `[all]`, `[code]`, `[academic]`, `[academic/statistics]`,
    `[file-modification]`, `[file-path]`, `[code/R/Python]`, `[skill/prompt]`

  PROVENANCE (optional):
  Entries added via Evolution Protocol may include a trailing HTML comment:
  `<!-- via: evolution-proposal, YYYY-MM-DD -->`
  This distinguishes auto-proposed entries from manually added ones.

  LANGUAGE:
  Any — this is your file; AI agents read all languages.
-->

## Entries

- **MEMORY.md / changelog.md sync** `[file-modification]`: After modifying config, skill, script, or structured files, check whether MEMORY.md and changelog.md need corresponding updates.
- **Multi-file version consistency** `[file-modification]`: Version numbers may appear in multiple locations (SKILL.md comment, README.md header, MEMORY.md entry); changing one requires updating all.
