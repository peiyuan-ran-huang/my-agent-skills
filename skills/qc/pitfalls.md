# QC Pitfalls

<!--
  INSTRUCTIONS

  This is YOUR personal pitfall log. Add entries for mistakes or oversights
  you've encountered in daily work that QC should watch for. Each entry
  becomes an additional check item during QC reviews.

  FORMAT:
  - **Bold title** `[tag]`: One-line description of what to check.
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

- **MEMORY.md sync after config changes** `[file-modification]`: After modifying config, skill, script, or structured files, check whether MEMORY.md needs a corresponding update.
- **Citation authenticity** `[academic]`: References may be inaccurate or entirely fabricated; always cross-verify against PubMed or DOI.
- **Subagent prompt must be fully self-contained** `[skill/prompt]`: In `--sub` mode, the subagent has no access to the main agent's context. The dispatch prompt must include: severity definitions, target type/domain context, and the JSON output schema. If the subagent result lacks a specific `area_examined` or gives generic reasoning, the prompt was not sufficiently self-contained. <!-- via: v0.9.0, 2026-03-23 -->
- **Instruction-file section header mismatch** `[skill/prompt/file-modification]`: Skill spec instructions that reference section headers (e.g., "append to `## Section Name`") must exactly match the headers in the distributable files they reference. Bilingual or localized headers in personal copies diverge silently from distributed versions. <!-- via: evolution-proposal, 2026-03-23 -->
