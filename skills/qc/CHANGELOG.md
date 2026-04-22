# Changelog

All notable changes documented here. 0.1+ increments get own heading; 0.0.1 patches are `### Patched` subsections. Dates = commit date, not dev start.
本文件记录所有重要变更。0.1+ 有独立标题；0.0.1 补丁为 `### Patched` 子节。日期=提交日期。

## [v1.7] — 2026-04-20

- **Branch B — 3 P1 patches**: (i) P1-2 description hardening (L3 frontmatter +40 chars explicit negative triggers: natural-language check/review/audit, Unicode dashes, fenced/quoted sentinel); (ii) P1-3 new `## Tool Priority` section (12-line table mapping 5 QC operations to preferred tools + consecutive-failure fallback paths; closes 反模式 2 工具漂移 gap); (iii) P1-1 file split — new `references/subagent-spec.md` (canonical prompt template + post-dispatch pseudocode + fill-ins + Additional Context Constraint).
- **Body size**: 419 → 330 lines (-21%, ~1760 tokens saved per QC invocation).
- **Verification**: Each patch L4 `---qc --loop --sub` independently — P1-2 3/3 Pass/3 rounds + 3 subagents; P1-3 3/3 Pass/3 rounds + 3 subagents; P1-1 1 Minor (R1 pitfall #19 body↔references header mismatch, fixed) + 3/3 Pass/4 rounds + 4 subagents. 10 subagent counterfactuals total, all JSON-first with pre-verified claims (mitigations for pitfalls #50/#52).
- **Targeted split rationale** (per handoff): Body retains ALL per-round rules (Dispatch if/else, 4 edge-case blockquotes, Subagent Specification, Degradation, Output Format Change). Only quasi-static content moved to references/. Per-load visibility of 反模式 1 (约束衰减) + 反模式 2 (工具漂移) defenses NOT eroded — R2 subagent independently verified.
- **Evolution Proposal rejected** (user decision after /rus adversarial re-check): R3 subagent's distinctness claim was based on main-agent summary of #40 (not full text) and missed #40(b) "cross-file authoritative summary vs inventory drift" variant; R1 empirical evidence shows #19 already caught this session's drift, so new entry would be signal dilution. Meta-learning on Evolution Protocol's distinctness-check limitations logged in memory/changelog.md.
- Version bump: 1.6.0 → 1.7.0 (SKILL.md L6, CHANGELOG.md, MEMORY.md L57, memory/changelog.md).
- **Handoff source**: `C:/tmp/branch-b-handoff-20260420-130453.md` (session 9cc30531, ≥8-round L4 pre-validated).

### Patched — 2026-04-21 (v1.7.3)

- **4-change structural patch set** (closes 4 deferred items from v1.7.2 — R14 Major / R15 Minor×3 / OQ5 / L249 true fix). **SKILL.md 3 substantive edits**: (L150–165 Blast Radius Scan) add new **step 7 — version-bump consistency scan** (fires on version-marker regex `<!-- version: X.Y.Z -->` / `**Version**: vX.Y.Z` / `"version": "X.Y.Z"`; greps repo-level anchor files README/CHANGELOG/MEMORY/AGENTS/package manifests/plugin-details + `~/.claude/` for skill configs; scope-note "value-consistency dependency ≠ step 3's reference dependency; run both") — closes R14 Major, restores Dim 9 shortboard 9→10, partially addresses OQ3 (version-drift subset only; broader repo-level anchor undercoverage queued for v1.7.4 audit); (L135–139 Degradation) add 3rd rule: `references/subagent-spec.md` unreadable → `[degraded: subagent-spec unavailable]` tag + "Do NOT reconstruct template from memory" (intentionally versioned separately to avoid drift) — closes OQ5 Evolution Proposal; (L249 pitfalls threshold) remove dead conditional "If `pitfalls.md` grows beyond ~30 entries" → "Scan tags/headings first..." (Option A, simplification over B/C) — closes v1.7.2 deferred (c), aligns SKILL.md with operational reality post-56-entry growth.
- **pitfalls.md 3 appends**: entries #57 (empty target auto-detect silent default — SKILL.md Parameter Parsing step 3.4 edge case), #58 (`--loop` non-positive integer literal — v1.5.0 rejection semantics reminder), #59 (duplicate/nested `--loop` flag — undefined parse behavior) — closes R15 Minor×3.
- **Pre-execution count drift noted**: plan QC-verified assumed pitfalls.md pre-edit = 55 entries (Round-1 recount including same-day #55 addition); actual pre-edit count at execution time = 56 (entry #56 "Subagent 跨轮 fix 互相撤销 → default WNF 非 apply" added 2026-04-21 via `security-review.sh` L4 QC CHECK 9 R3→R5 cycling, between plan QC pass and v1.7.3 execution). Numbering adjusted #56/#57/#58 → #57/#58/#59; post-edit count target 58 → 59. Pitfall #41 (mid-loop filesystem drift) + #45 (AI data specs need verification) exemplars — plan's numeric claims went stale between authoring and execution; pre-edit Read count-verify beat blind apply.
- **Deferred to v1.7.4**: OQ2 trigger override for user explicit-intent patterns ("执行 ---qc …" vs dedicated `/qc` prefix vs L12 absolute status quo) — requires design judgment on false-positive vs UX trade-off; not bundled with structural fixes.
- **Review rigor summary**: Plan L4 pre-verified via `---qc --loop --sub` (Rounds 1-6, History `[m, m, m, P, P, P]` — 3/3 consecutive Pass exit; 9 fixes applied across Rounds 1-3: R1 pitfalls count drift cascade + OQ3 overclaim + grep false-fail; R2 L104/L108 same-class error-scan per pitfall #46; R3 `memory/changelog.md` missing from File Manifest per pitfall #54). Rounds 4-6 inline-fallback counterfactual per SKILL.md L137 (plan-mode Write restriction blocks subagent temp file creation at `C:/tmp/qc_sub_*/`) with explicit `[degraded: inline fallback]` tag per L105 anti-downgrade self-check. Post-edit `---qc --loop --sub` on this change set is mandatory per L4 (pending).
- **Version drift syncs** (enforced by new Blast Radius step 7): README.md L3 `v1.7.2 → v1.7.3` + MEMORY.md plugin-details `qc v1.7.2 → qc v1.7.3`.
- Version bump: 1.7.2 → 1.7.3 (SKILL.md L6, README.md L3, MEMORY.md plugin line).

### Patched — 2026-04-21 (v1.7.2)

- **Darwin-driven 5-point surgical patch set** (post L4-deliberation; Option A from darwin Phase 0-2 → qc loop R1-R15 15 findings → `/necess --3` 3/3 convergent drop of 1 edit → `/rus --3` mixed → Version B with 2-C wording chosen). **SKILL.md 4 edits**: (L24) `--loop [N]` 默认值加 L0-L4 ladder cross-ref ("aligns with L2/L4 … `--loop 2` for L1/L3") — closes Dim 9 short-board on discoverability; (L72) context-pressure threshold 主观描述 → 操作性 ("if summarizing earlier rounds becomes cheaper than carrying them in full (Claude's operational judgment — no fixed % threshold)") — closes Dim 5 short-board without false-precision numeric fabrication; (L80) `### Dispatch Logic` header 加 Loop Mode cross-ref blockquote — closes Dim 2 coupling short-board; (L6) version bump.
- **Rejected fixes** (via `/necess --3` 3/3 RETRACT): L249 "~30 entries" → "~50 entries" threshold raise — math: pitfalls.md count 54 entries, both 30 and 50 thresholds fire tag-scan mode, edit would be functional no-op (cosmetic). True fix (remove conditional / change semantics) deferred to v1.7.3 backlog.
- **Version drift syncs** (from qc loop R4 + R11 findings, pre-existing multi-bump drift): README.md L3 `v1.6.0 → v1.7.2` (skipped v1.7.0 + v1.7.1 bumps) + MEMORY.md plugin-details `qc v1.7.1 → qc v1.7.2`.
- **Deferred to v1.7.3 backlog**: (a) Dim 9 systemic version-bump multi-file checklist as explicit skill feature (R14 Major — post-fix Dim 9 caps at 9 until); (b) R15 edge-case pitfalls (empty target / `--loop 0` / nested loop); (c) L249 threshold true fix (remove or redefine semantics).
- **Review rigor summary**: darwin 10-dim Phase 0.5 test prompts + Phase 1 baseline + Phase 2 ranked fixes → qc self-review loop R1-R15 (15 findings, Critical 0/Major 3/Minor 11/Info 1) → `/necess --3` 5-gate × 3 passes (dropped L249 on Gate 1 failure) → `/rus --3` 3-dim × 3 passes (L72 wording promoted from 2-B subjective to 2-C operational after mixed-pass divergence). Pre-edit re-read of SKILL.md L6/L24/L72/L80/L249 per R10 finding; R12 edit-ordering simplified (single-line replaces don't shift).
- Version bump: 1.7.1 → 1.7.2 (SKILL.md L6, README.md L3, MEMORY.md plugin line).

### Patched — 2026-04-20 (v1.7.1)

- **A+D pointer-only enhancement**: (i) `## Target-Specific Overlays` → Skill/Prompt line (SKILL.md L186) appended on-demand pointer to an external personal memory ref (`ref_llm_audit_antipatterns.md`, §A 7 runtime patterns / §B 3 completeness principles / §C 4 LLM-as-auditor meta patterns); (ii) `## Loop Mode` → No-shortcut rule point 3 (L66) appended pointer to §Meta-4 as angle-dimension rotation candidate list. Pure pointer additions, zero internal logic change, no new hard checks. *(Path containing the maintainer's username was anonymized in v1.7.3; see v1.7.3 entry.)*
- **Rationale**: Option A+D selected after three rounds of `/rus` deliberation on whether ref_llm_audit_antipatterns.md's 14 items (§A 7 + §B 3 + §C 4) should be inlined as hard checks. Empirical evidence base for preemptive hard-check paths (B-lite / B-full) was empty — v1.7 Branch B's 10 subagent counterfactuals recorded no findings missed due to absent B.3 failure-path check, and ref source authority is MEDIUM (skill-craft provenance risk + ref v0.4 same-day finalize). Evolution Protocol organic accretion preferred: if future real Skill/Prompt reviews surface genuine gaps traceable to specific ref sections, escalate with empirical support then.
- Version bump: 1.7.0 → 1.7.1 (SKILL.md L6).

## [v1.6] — 2026-04-17

- **File compression project** (v4 plan, Phases 1–6): SKILL.md line reduction + 3 additional failure modes (Pass-round no-shortcut degradation, Depth checkpoint skipping under context pressure, Adversarial re-framing fatigue; 7→10 total) (Phases 1–2, prior sessions); examples.md 449→391 (-12.9%), pitfalls.md 90→68 (-24.4%), README.md 145→96 (-33.8%), CHANGELOG.md 212→132 (-37.7%) (Phases 3–6).
- **Techniques**: Bilingual merge (EN/ZH paragraph pairs → single lines), header comment compression, DRY (per-version changelog → feature summary + pointer). All 46 pitfall entries and QC-functional content preserved intact.
- **SKILL_ZH.md deprecated**: moved to `_trash/` (SKILL.md is the sole runtime file; Chinese translations merged into bilingual format in other files).
- Version bump: 1.5.0 → 1.6.0 (SKILL.md, README.md, CHANGELOG.md, MEMORY.md).

## [v1.5] — 2026-04-04

- **Failure Modes section**: 7 architecture-level failure modes with mitigations between Key Principles and Evolution Protocol. Covers: self-review confirmation bias, loop convergence WNF dependency, subagent context isolation, WNF state compaction loss, temp file race condition, MCP tool name drift, category dispatch coverage gap.
- Synced to SKILL_ZH.md. Version bump: 1.4.0 → 1.5.0.

## [v1.4] — 2026-04-02

- **WNF Gating Rule hardening**: (1) WNF tracking state excluded from context summarization — maintained in dedicated block. (2) Loop Mode recurrence handling forward-references WNF Path 2 (single source of truth). (3) WNF retraction mechanism ("fix that after all" / "还是修一下").
- Affected files: SKILL.md, SKILL_ZH.md. Version sync: CHANGELOG.md, README.md, MEMORY.md.

## [v1.3] — 2026-03-31

- **WNF Register for subagent**: `findings_temp.md` includes `## WNF Register` in loop mode so subagent distinguishes re-identifications from new findings. New `wnf_reidentified` JSON field. Post-dispatch cross-check: WNF-matching `new_findings` reclassified; WNF-only reopens overridden to confirmed (no pass counter reset). >20 items → top 5 by severity. Affected: SKILL.md, SKILL_ZH.md, examples.md (+WNF-aware example), pitfalls.md (+entry #25).
- **Root cause**: v1.2 subagents reopened all-WNF findings as new (observed: 7 rounds, R4 subagent reported 6 WNF items as new).

## [v1.2] — 2026-03-29

- **Session-unique temp directory**: `C:/tmp/qc_sub/` → per-session `C:/tmp/qc_sub_<timestamp>_<PID>_<random>/` (`QC_SUB_DIR`). Eliminates concurrent session collisions (pitfalls #21/#23). Prompt template gains 5th fill-in field.

## [v1.1] — 2026-03-26

- **6-subagent parallel QC round**: 13 findings (5 Major + 8 Minor) from 6 independent opus reviews
- Fix recurrence cap (3× → user escalation); non-WNF fix queue; in-context content fix mechanism
- Auto-detect rejection path; depth checkpoint + subagent interaction; cross-validation fallback
- Post-reopen history update; sync rule expansion (+translation notes); Evolution Protocol cross-ref
- Version bump: 1.0.0 → 1.1.0

### Patched — 2026-03-26

- Parameter parsing: double quotes only (no single quotes/backslash escapes)
- Confirmed + severity_adjustments note; Write tool failure degradation path
- MEMORY.md sync (v0.9.2 → v1.1.0); README chronological fix; "(changed in v1.0)" annotation
- Temp path reverted to `C:/tmp/qc_sub/`: `~/.claude/tmp/` caused permission prompts

## [v1.0] — 2026-03-25

### Changed

- **Subagent dispatch simplified**: fires every pass round (not just final); eliminates cross-round counter tracking
- **No-shortcut rule**: pass rounds require disk re-read + five-dimension assessment + varied counterfactual focus. Must show genuine re-examination, not copied verdicts.
- **Depth checkpoint rounds**: every 5th round (5/10/15) requires full expanded report regardless of pass streak
- **Canonical subagent prompt**: fixed ~55-line verbatim template with 4 fill-in fields + cross-validation step (subagent reads original file from disk to detect stale temp copies)
- Anti-downgrade self-check; Evolution Protocol timing ("final round" → "loop exit round"); round cap 10 → 15
- **Design trade-off**: deliberately trades token efficiency for review reliability — every pass dispatches subagent + genuine five-dimension re-examination instead of one-line confirmations

### Patched (2026-03-26) — v1.0.1 (superseded by v1.1.0)

- Temp path reverted from `~/.claude/tmp/qc_sub/` to `C:/tmp/qc_sub/` (permission prompts). Later re-applied in v1.1 Patched after v1.1.0 initially kept `~/.claude/tmp/`.

## [v0.9] — 2026-03-23

### Patched — v0.9.2

- **Loop Mode WNF specification** (Major fix): rejected-fix → WNF; excluded from severity; tracked in header (`History: [M, P(1 WNF), P, P]`). Previously undefined (only in pitfalls.md).
- Emoji override comments on Loop Mode header + examples.md Evolution Proposal
- Rating-aware counterfactual: question varies by current rating (Pass/Minor vs Major/Critical)

### Patched — v0.9.1

- Subagent temp path portability (`C:/tmp/` → `~/.claude/tmp/`); Parameter Parsing rewrite (flag-position-independent)
- `--loop [N]` consumption rule; degradation path (+unavailable model); pitfalls.md 4th starter entry
- README trigger syntax completed (+`--loop [N]`, `--sub` flags)

### Added

- **Subagent Counterfactual Mode** (`--sub`/`--子代理`): isolated opus subagent for counterfactual via temp files + structured JSON (verdict, area_examined, reasoning, severity_adjustments, new_findings). Loop mode: final round only. Fallback: inline with `[degraded: inline fallback]`. Examples + pitfall added to examples.md/pitfalls.md.

### Changed

- Parameter Parsing step 1 refactored to order-independent flag list (`--loop`/`--循环`, `--sub`/`--子代理`).

## [v0.8] — 2026-03-22

### Added

- **Loop Mode** (`--loop [N]`/`--循环 [N]`): review-fix-review cycle; N consecutive passes (default 3) or 10 rounds. Target resolved once; calibration files read once; Evolution Protocol on final round only.
- **Counterfactual Test**: mandatory meta-calibration — "If submitted by a stranger, would I still find no Critical or Major issues?" Summary includes `**Counterfactual**:` line (Confirmed/Reopened, no N/A).
- **Adversarial Re-framing**: rounds 2+ adopt "find problems, not confirm correctness" stance.

### Changed

- Parameter Parsing extended for `--loop`/`--循环`; "Review only" notes loop mode suspension.

## [v0.7] — 2026-03-20

- Meta-calibration principle (severity inflation/deflation bias check before Summary)
- 3 Skill/Prompt overlay items: degradation path coverage (Major), self-review bias (Minor), runtime/development boundary (Minor)
- Tighter auto-detect step 2: explicit inclusion criteria (code ≥3L, plan ≥5 items, prose ≥5L) + exclusion criteria

## [v0.6] — 2026-03-17 (patched 2026-03-18, 2026-03-19)

- **Evolution Protocol**: post-review self-reflection proposing new pitfalls/examples. Propose-and-confirm design: skill suggests, user approves. Write Mechanics: append location, provenance comments (`<!-- via: -->`), overlap detection.
- **Patch 03-19**: Distributable sanitization (personal seed → `set.seed(7)`; hardcoded count → `N`); pitfalls.md repo template restored to 2 starter entries
- **Patch 03-18**: README ability claim narrowed; EN/ZH drift fixed ("三步联检规则" → "联动更新规则"); frontmatter tightened; blast radius boundary clarified; pitfalls tags simplified; examples aligned

## [v0.5] — 2026-03-17

- **Skill/Prompt target overlay**: first-class review type with dedicated checks (trigger logic, description, checklist, portability)
- **Open Questions section**: ambiguous findings routed separately from findings
- Coverage + Target Type + Blast Radius scope declarations; evidence-led principle; formalized pitfalls tag semantics
- Portability claims narrowed; trigger contract tightened (first-token rule); EN/ZH sync → section-level semantic equivalence

## [v0.4] — 2026-03-16

- **Pitfalls mechanism** (`pitfalls.md`): user-supplied domain-specific mistake log, auto-checked during reviews
- Inline severity definitions (Critical / Major / Minor thresholds); trigger tag precision matching

## [v0.3] — 2026-03-16

- **Blast Radius Scan**: Grep-based cross-file dependency check for file modifications
- Anti-pattern #4 in `examples.md`

## [v0.2] — 2026-03-15

- Evidence requirements + structured output template. First Codex review.

## [v0.1] — 2026-03-15

- Initial release: five-dimensional review (Correctness, Completeness, Optimality, Consistency, Standards)
- `SKILL.md` (EN) + `SKILL_ZH.md` (ZH) + `examples.md` + `README.md`
