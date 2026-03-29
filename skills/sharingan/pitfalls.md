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
- **L2 overconfidence** `[all]`: Misclassifying L1 as L2 by checking keyword presence rather than implementation depth. Defence: two-column comparison table (current vs source) + lowest-dimension-wins rule (any gap → L1) + L1 Verification Gate (must cite file:line + source section). <!-- via: v0.8.0-rebalance -->
- **Patterns category dumping** `[skill/prompt]`: Classifying vague "interesting ideas" as `patterns` without naming a specific application scenario. The `Transferable pattern` field also requires a concrete target, not just "could inform". <!-- via: v0.8.0-rebalance -->
- **L1 inflation / filter evasion** `[all]`: Marking actual L2 insights as L1 to avoid the work of confirming no-gap across all 3 dimensions — L1 is the "path of least resistance". Defence: L1 must show ≥1 dimension gap with evidence (cite file:line + source section); no evidence → default L2. Phase 5 L1 attrition metric provides structural detection. <!-- via: v0.8.0-rebalance -->
- **Reference value padding / under-compression** `[all]`: ref_*.md exceeding 50 lines or containing non-load-bearing lines signals under-compression. A-tier references average 35 lines. Self-Critique Gate (3 questions) must pass before presenting to user. No value → one-line termination. <!-- via: v0.8.0-rebalance -->
- **Opportunity inflation** `[le]`: Low-quality ideas forced into Build Now. Build Test gate (2-3 specific implementation sentences) must pass. <!-- via: v0.9.0-le -->
- **Config backflow** `[le]`: LE output should be new capability proposals, not covert config changes. If an opportunity is really a config modification, it belongs in the main pipeline. <!-- via: v0.9.0-le -->
- **Build Now threshold too low** `[le]`: Build Now requires clear implementation path + verifiable output + Low/Med complexity. Vague ideas ("could be useful someday") go to Incubate, not Build Now. <!-- via: v0.9.0-le -->
- **RVA-LE content bleed** `[le]`: RVA ref_*.md and LE proposals must be content-isolated. Refs use pointer-level "Related LE proposal" fields (3 lines max), not feasibility/verdict language. LE proposals do not repeat ref core insight analysis. <!-- via: v0.9.0-le -->
