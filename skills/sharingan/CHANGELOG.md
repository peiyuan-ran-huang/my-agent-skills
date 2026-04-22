# Changelog

All notable changes to this project are documented here.
Only version increments of 0.1 or above get their own entry heading.
Dates represent when the version was committed, not when development started.

本文件记录所有重要变更。0.1 及以上的版本增量有独立标题。日期为提交时间，非开发开始时间。

## [v0.11.2] — 2026-04-20

### Added

- **LE-1 Calibration pre-read gate**: new `**Calibration**:` paragraph at the start of LE-1 Opportunity Scan (symmetric to QC Sub-Procedure Calibration pattern). Before enumerating opportunities, agent reads `pitfalls.md` entries tagged `[le]` plus `references/leverage-exploration.md` § E (LE Anti-Bias Rules). Degradation path: "If unavailable, proceed without and note `[degraded: LE calibration skipped]` in LE output." Closes the Declaration-execution gap (pitfall #15) for pitfalls #23 Opportunity inflation + #25 Build Now 门槛过低, which were declared in pitfalls.md but not inlined at the LE-1 execution point — tag-based trigger mechanism resists pitfall renumbering drift.
- **Test scenario S-22** (`references/test-scenarios.md`): new scenario covering LE-1 Calibration Pre-read Gate (happy path + degradation path).
- **Edge-cases.md degradation row**: new table row for "LE-1 Calibration 所需文件不可用" matching the SKILL.md degradation text.

### Design notes

Discovered via `/rus` second-order review of a 2026-04-20 sharingan `--explore` session whose LE-1 produced an Incubate proposal ("skill-inventory 轻量脚本") that was withdrawn — the proposal hit pitfalls #23/#25 but LE-1 enumeration had not read them first. Post-fix L4 `---qc --loop --sub` surfaced three additional scope misses (test-scenarios.md, edge-cases.md, this CHANGELOG.md) that weren't in the handoff Step 2 "dependent files" enumeration — expanded Three-check scope to 7 files total. Chose option α' (tag-based pre-read) over α (hardcoded `#23/#25`), β (抽 LE Sub-Procedure), γ (counterfactual 问句), δ (混合) — α' is minimal within scope, matches QC Sub-Procedure Calibration pattern, and avoids pitfall number hardcoding.

## [v0.11.1] — 2026-04-19

### Added

- **Rationale Evidence Triple**: Phase 5 Proposal Format's `Rationale` bullet is expanded from a single line into three sub-bullets — `Evidence (current state)`, `Baseline (common alternative)`, `Reasoning (user-adapted)` — forcing each proposal to ground its justification in verifiable present state, a baseline comparison, and user-specific reasoning. Addresses the failure mode where single-line Rationale silently conflates "what currently is" with "why this user".
- **Per-proposal `Without this:` counterfactual field**: new one-sentence field under each proposal's Rationale block, stating what concretely degrades or fails if the proposal is not applied. Forces the author to articulate skipping cost at proposal-authoring time rather than deferring to the downstream Phase 6 cumulative counterfactual. Semantically orthogonal to Phase 6 QC's `"Without this source, would I still propose these changes?"` (per-proposal degradation vs cumulative source-dependency test).

### Changed

- **Phase 5 Rationale requirement wording (Phase 3 External Research block)**: loosened from "MUST cite the external finding in one line" to "typically within the `Reasoning (user-adapted)` bullet, or appended as a dedicated line inside the Rationale block" — preserving the audit-trail requirement while accommodating the new multi-sub-bullet Rationale structure. Fix discovered via three-check within-file sweep after the L347-351 expansion.

### Design notes

- **Backward compatibility**: existing proposals using single-line Rationale still parse — the expansion is additive. Patch bump (v0.11.0 → v0.11.1), not minor.
- **Naming collision with Phase 6 `Without this source`**: the two `Without this...` labels are semantically distinct (per-proposal vs cumulative) and deliberately left as-is per user approval. Future v0.12+ may unify if refactor pressure warrants.
- **Derivation**: Evidence-triple and per-proposal counterfactual patterns derived from repo-analyzer's 8-phase workflow analysis, validated via L4 `---qc --loop --sub` 5-round loop (history `[m, m(R2 subagent-reopen), P, P, P]`). R2 subagent independently caught 2 blind spots — source conflation (L211-216 vs L86-95) and undefined scope metric for Trade-off Triangle trigger — that inline R1 review missed, empirically demonstrating `--sub`'s anti-self-review-bias value.

## [v0.11.0] — 2026-04-18

### Added

- **Conditional External Research (Phase 3 pre-step)**: When Phase 2 primary classification is `tool-acquisition`, auto-trigger supplemental external research before insight extraction. Three checks: maintenance signals (search for "no longer maintained / archived / abandoned" patterns), community reception (search for reviews / alternatives / comparisons), known issues (conditional GitHub issues fetch). Budget: 3 searches + 1 fetch per invocation. Auto-skipped if pressure valve already active.
- **Phase 5 Rationale requirement**: When external findings materially affect a Phase 5 proposal's Priority, the proposal's Rationale MUST cite the external finding in one line (e.g., `"Priority lowered to Low per external search: last maintained commit 2022, 47 open issues"`). Ensures external research leaves a structured audit trail rather than drifting into undocumented judgment.
- **Phase 1 Output Read scope line** (variant by source type): Multi-file source → `Read scope: <N of M files read> (<X>%); focus: [...]; skipped: [...]`. Single-document source → `Read scope: <N sections/pages read>; skipped: [...]`. Omitted for trivially small sources fully read. If Conditional External Research ran, append one line: `External research: <N> searches, key finding: <one sentence>`.
- **1 new Hard Limits row**: `External research budget per invocation | 3 searches + 1 fetch | Tool-acquisition evaluation (Phase 3 pre-step); prevent unbounded web calls`.

### Changed

- Phase 1 Output section gains the Read scope block between the Provenance line and Phase 2.
- Phase 3 Extract Insights section gains the Conditional Pre-Step subsection between the lead-in paragraph and `### Format`.

### Design notes

- **YAGNI on opt-out**: No `--no-research` flag in this version. Auto-trigger is narrow (only `tool-acquisition` primary classification) + auto-skip on pressure valve; if user feedback demands opt-out, add flag in future release.
- **YAGNI on `git log -1`**: Earlier draft included a local shallow-clone `git log -1` for last-commit-date as a maintenance signal, dropped because `--depth=1` clone only returns HEAD (single commit date ≠ commit-frequency history signal); search #1 already captures "no longer maintained" patterns with stronger signal.
- **Placement rationale**: External Research sits in Phase 3 (not `references/source-handling.md` § GitHub Repo Special Handling) because it requires Phase 2 classification and informs Phase 3 insight extraction — it's a Phase 3 concern, not a source-type-handling concern.

## [v0.10.0] — 2026-04-06

### Added

- **Source Provenance Assessment**: New Phase 1 subsection that classifies external sources as Primary/Secondary/Tertiary+ and traces secondary sources back to their primary origins before analysis. Prevents insights from being dominated by secondary information bias.
- 7 decision rules for provenance boundary scenarios (author self-post, fork classification, no-traceable-primary, aggregation, circular reference, tracing depth limit, name-only reference).
- 3-level degradation path for inaccessible primary sources (single inaccessible → format barrier → all inaccessible).
- Anti-bias safeguard: secondary claims about primary sources are verified item by item.
- Terminology note disambiguating provenance Primary/Secondary from Phase 2 taxonomy classification primary/secondary.
- `Source provenance` field in Phase 3 Insight template.
- Provenance line in Phase 1 Output.
- 2 new Hard Limits: primary source tracing per invocation (3, degraded: 1), per-primary-source read cap (6).
- Pre-tracing and mid-tracing pressure valve interaction rules in Context Management.
- 7 new edge cases (provenance scenarios) in `references/edge-cases.md`.
- 3 new test scenarios (S-18, S-19, S-20) in `references/test-scenarios.md`.
- 1 new pitfall entry: Provenance misclassification `[all]`.

### Changed

- `references/source-handling.md`: gains § Source Provenance Assessment (classification, tracing, degradation, anti-bias, terminology note).
- File Map: source-handling.md description updated; edge-cases count 23→30; test-scenarios count 17+2→20+2.
- Context Management Strategy: Phase 1 bullet gains provenance tracing clause with pressure valve interaction.

### Post-QC Cleanup (2026-04-06)

- `pitfalls.md`: #27 Provenance misclassification added (was only in qc/pitfalls.md; now in both). Total: 27 entries.
- `SKILL.md`: Phase 1 Output + Phase 3 Insight provenance templates extended with `Secondary (traced source also secondary)` and `Secondary (circular reference)`. Phase 2 gains provenance basis note (declaration-execution gap fix). Verification section gains "source provenance assessment". File Map edge-cases 30→32; test-scenarios 20+2→21+2.
- `references/source-handling.md`: Tracing Mechanism step 1 gains >3 source selection rule. Cleanup section clarified for traced primary repos. Version string clarified (tool names v0.9.0, file updated v0.10.0).
- `references/edge-cases.md`: +2 rows (Tertiary+ aggregation, mid-tracing pressure valve). Total: 32 scenarios.
- `references/test-scenarios.md`: S-21 added (Secondary with no traceable primary, Decision Rule 3/7).
- `examples.md`: Source Provenance Assessment good-example + anti-pattern added. Phase 3 Extract Insights example updated to 7-field format (was stale since v0.8.0).
- `README.md`: version v0.9.0→v0.10.0, date 2026-03-28→2026-04-06; EN+ZH feature bullet for Source Provenance Assessment.
- `memory/plugin-details.md`: edge-cases 30→32; test-scenarios S-1~S-20→S-1~S-21.

## [v0.9.0] — 2026-03-28

### Added

- **Leverage Exploration (能力建设借鉴)**: Post-pipeline extension for capability-building proposals. 5 opportunity types (SKILL/TOOL/FLOW/INFRA/ENHANCE), feasibility matrix (Build Now/Plan First/Incubate/Skip), Build Test quality gate, ai-dev-idea-todo.md integration with deduplication.
- `--explore` / `--no-explore` flags for controlling LE activation.
- RVA-LE cross-reference mechanism: bidirectional linking between ref_*.md and LE proposals.
- `references/leverage-exploration.md`: detailed LE framework (opportunity types, feasibility matrix, proposal format, integration rules, anti-bias rules).
- 3 new pitfalls (#23-#25): Opportunity inflation, Config backflow, Build Now threshold (`[le]` tag).
- 2 new examples: LE opportunity proposals + anti-pattern (Opportunity inflation).
- 5 new edge cases covering LE scenarios.
- 2 new test scenarios (S-11, S-12) for LE verification.

### Changed

- Post-pipeline extension note updated to include LE alongside RVA.
- Phase 10 Final Report template gains "Leverage Exploration" line.
- `--dry-run` now terminates main pipeline only; LE can proceed in read-only mode.
- Hard Limits table gains 2 new entries (LE opportunities: 5, todo additions: 3).
- Context Management Strategy gains LE bullet.

### Post-QC Cleanup (2026-03-28)

- `references/source-handling.md`: version string v0.5.0 → v0.9.0; Playwright CLI `goto`/`snapshot` as primary (was MCP); `/tmp/` clone convention simplified; `.git/hooks/` check excludes `.sample` files.
- `pitfalls.md`: added `[le]` to suggested tags in FORMAT comment; updated entries #12 (v0.8.0 counterfactual mitigation note) and #14 (v0.3.0 snapshot expansion note) for freshness.
- `references/test-scenarios.md`: S-8 re-run (23 mechanisms, all live), S-11 PASS (regression), S-12 PASS (regression).

### Post-QC Cleanup Round 2 (2026-03-28)

- `memory/plugin-details.md`: sharingan version v0.8.0 → v0.9.0, description updated with LE features, entry counts (25 pitfalls, 22 edge cases, S-1~S-15+P-1/P-3), leverage-exploration reference added.
- `references/source-handling.md`: 5 WNF design enhancements implemented — remote PDF URL row in tool table; git availability check before clone; symlink check in post-clone scan (step 3); deny-pattern expanded with `*.ps1, *.cmd` for Windows; no-key-files fallback guidance in Read Scope.
- `pitfalls.md`: explicit ordinal numbering `#1`–`#25` added to all entries; FORMAT comment updated to `**#N. Bold title**` pattern.
- `references/test-scenarios.md`: 3 new deferred scenarios (S-13: --no-explore suppression, S-14: LE anti-bias enforcement, S-15: RVA-LE cross-ref isolation) derived from S-8 coverage gaps; S-8 Notes updated to reference S-13/S-14/S-15.
- `SKILL.md`: File Map scenario count 12 → 15 (blast-radius fix from test-scenarios.md S-13/S-14/S-15 addition).
- `references/source-handling.md`: Remote PDF tool corrected from `WebFetch download` to `curl -sLo` (WebFetch returns text, not binary files).
- `README.md`: Files table `references/` description expanded to include `tdd-summary` and `leverage-exploration` (pre-existing gap from v0.5.0/v0.9.0).

### Post-QC Cleanup Round 3 (2026-03-29)

- `references/test-scenarios.md`: S-13 PASS (code-review: --no-explore suppression wiring), S-14 PARTIAL PASS (code-review + opportunistic: anti-bias wiring verified, no rejection in ECC run), S-15 PASS (opportunistic + code-review: RVA-LE content isolation confirmed from ECC run).
- `pitfalls.md`: added #26 (RVA-LE content isolation, `[le]` tag). Total: 26 entries (22 general + 4 `[le]`).
- `memory/plugin-details.md`: pitfall count 25 → 26 (blast-radius fix from #26 addition).
- `references/test-scenarios.md`: S-8 Notes pitfall count 25 → 26 (intra-file blast-radius fix); S-14 Notes "4 opportunities" softened to "all opportunities" (verifiability).

### Post-QC Cleanup Round 4 (2026-03-29)

- `SKILL.md`: line 406 (dry-run path) added inline "Suppressed by `--no-explore`." for consistency with lines 194/342/473 (pre-existing gap from v0.9.0 implementation, surfaced by R2 QC subagent).
- `references/test-scenarios.md`: S-8 Notes "all deferred" → "S-13 PASS, S-14 PARTIAL PASS, S-15 PASS (all verified 2026-03-29)" (historical note updated to reflect current verification status).
- `references/leverage-exploration.md`: Section B Verdict Rules added "Borderline" case guidance (Build Now + risk note for uncertain dependencies, formalized from Session Cost Tracker precedent).

### Post-QC Cleanup Round 5 (2026-03-29)

- `references/leverage-exploration.md`: Section C Dependencies field added Risk sub-field for Borderline risk notes; Section B Maintenance dimension clarified as intentionally informational-only (not factored into verdict rules).
- `references/test-scenarios.md`: S-16 added (Borderline verdict → Build Now + risk note, deferred).
- `SKILL.md`: File Map scenario count 15 → 16.
- `memory/plugin-details.md`: test-scenarios count S-1~S-15 → S-1~S-16 (blast-radius fix from S-16 addition).
- `references/leverage-exploration.md`: Section C Feasibility enum gains Borderline→Build Now display note; Section D verdict-to-section mapping adds Borderline + Skip exclusion (QC subagent: cross-file consistency).
- `SKILL.md`: LE-2 Maintenance clarified as context-only (`+ Maintenance for context`); Final Report template gains `[includes Borderline]` note (QC subagent: SKILL.md/reference alignment).
- `references/leverage-exploration.md`: Build Now verdict rule Dependencies expanded None/Low → None/Low/Med (closes Medium dependencies gap — Medium = "New reference files", internal to ecosystem, no external risk).

### Post-QC Cleanup Round 6 (2026-03-29)

- `references/test-scenarios.md`: S-17 added (LE-4 ai-dev-idea-todo.md not-found fallback, deferred).
- `SKILL.md`: File Map scenario count 16 → 17.

## [v0.8.0] — 2026-03-26

### Added

- **Implementation Depth Assessment** (L0/L1/L2): Replaces binary "already implemented" filter with three-level system using two-column comparison across Coverage/Depth/Quality dimensions. "Lowest dimension wins" aggregation. L1 Verification Gate requires file:line + source section evidence.
- **14th taxonomy category: `patterns`**: Transferable design principles and cross-domain techniques. Must name specific application scenario.
- **Non-config Insight Routing**: Pattern-only and user-growth-only insights follow dedicated path through Phase 4-5 with reclassification possibility. Reference-value candidates listed separately.
- **User model consultation** (Phase 2): Reads MEMORY.md User Profile to inform classification scope.
- **Expanded extraction format**: 6 fields (Source, Direct applicability, Transferable pattern, User growth, Depth, Priority) replacing old 3-field format. Anti-laziness rule for "None" fields.
- **Two-sided Counterfactual**: (a) action bias test + (b) source value test with explicit resolution rules. L1 insights not penalized for source-dependency.
- **L1 attrition metric**: Structural check in Phase 5 output against completion bias. Zero attrition = red flag.
- **Enhanced Reference Value Distillation**: 4-step gated process (Essence Extraction → Application Mapping → Conflict & Overlap Scan → Compression Draft) with ≤50-line budget, structured template, and Self-Critique Gate. Trigger expanded to include Phase 10 Final Report.
- Test scenario S-10 (L1 insight passes Phase 3 filter).
- 4 new pitfalls (#19-#22): L2 overconfidence, patterns dumping, L1 inflation, reference compression.
- 3 new examples: L1 depth assessment, L1 full-journey, patterns category anti-pattern.
- 3 new edge cases (pattern-only source, user-growth-only, mixed batch).

### Changed

- **Calibrated Acceptance Principle** replaces "Critical Acceptance": L2 filters confidently, L0/L1 passes forward for deeper evaluation, hard filters remain absolute.
- **Completion bias awareness** note added to QC Sub-Procedure.
- EXIT POINT 1 and 2 templates updated with L-level vocabulary and pattern/growth awareness.
- Phase 4 output restructured into L0/L1/reference-value sections.
- Phase 5 gains Reference-Value Candidates subsection.
- Final Report template gains "Reference Value" line.
- All counterfactual examples in examples.md updated to two-sided format.

## [v0.7.0] — 2026-03-23

### Added

- **Reference Value Assessment** at EXIT POINTs: even when no config changes are warranted, optionally captures long-term reference value from the source. Creates `ref_*.md` in memory with YAML frontmatter. Suppressed by `--no-ref`.
- `--no-ref` flag added to parameter parsing.
- New pitfall: "Reference Assessment scope creep" (`[all]`).
- Test scenario S-9 (4 variants) covering `--no-ref`, dry-run, irrelevant source, and normal ref creation.

### Patch (v0.7.1)

- Examples.md synced with SKILL.md Phase 6/9 format changes
- Self-review bias note added to QC Sub-Procedure
- Phase 4 dedup: files already read during Phase 3 Pre-filter Verification are not re-read
- Pitfalls entry count references changed to generic phrasing for distributable files

## [v0.5.0] — 2026-03-20

### Changed

- **Major refactor** of the core workflow structure.
- Rule liveness check (S-8): 17 rules checked, 17 live, 0 dead post-refactor.
- New pitfalls from ecosystem hardening: "Pitfall entry freshness" and "Taxonomy rename drift" (`[skills]`).

## [v0.3.0] — 2026-03-18

### Added

- **TDD verification** completed (8/8 scenarios PASS). Full TDD artifacts archived locally.
- **Phase 10 formal 2-pass gate**: "2 consecutive passes, max 4 rounds" — previously the weakest enforcement point.
- **Phase 3 pre-filter verification**: mandatory file read before applying "already implemented" filters.
- **Before Snapshot expansion**: control-flow modifications now capture up to 50 lines (was 10).
- 5 new pitfalls from TDD green-refactor: abort logging, Phase 10 gate (now [FIXED]), QC confirmation bias, Phase 3 pre-read, snapshot narrowness.
- 3 new pitfalls from evolution proposals: state-machine drift, fail-open parser, declaration-execution gap.

### Changed

- Rationalization Table (28 entries) and Red Flags Checklist (22 items) formalised in `references/tdd-summary.md`.

## [v0.1.0] — 2026-03-17

### Added

- Initial release: 10-phase workflow for extracting insights from external resources.
- Dual EXIT POINTs (Phase 3 and Phase 5) normalising "no changes" as legitimate outcome.
- 13-category taxonomy (`taxonomy.md`).
- Security preflight (deny list for credentials, prompt injection detection).
- Inline QC sub-procedure (2 consecutive passes, max 6 rounds).
- Three-check protocol integration.
- `SKILL.md`, `taxonomy.md`, `examples.md`, `pitfalls.md` (7 initial entries).
- `references/`: parameter-parsing, source-handling, edge-cases (14 scenarios), test-scenarios, tdd-summary.
- `--target`, `--auto`, `--dry-run` flags.
- Context management strategy with pressure valve.

---

*Note: versions v0.2, v0.4, and v0.6 involved incremental refinements not individually documented at the time of development. Key changes from those versions are incorporated into the next documented version above.*
