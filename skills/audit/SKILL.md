---
name: audit
description: Use when the user explicitly invokes ---audit for a high-stakes paper, codebase, plan, data analysis, or mixed multi-component target where missed issues would be costly.
---

# AUDIT

## Trigger

Activate only when the user explicitly invokes `---audit` in any letter case.

Do not activate on:
- `检查`
- `审查`
- `审计`
- `复核`
- `audit this`
- any other natural-language phrasing that does not use the explicit trigger

## When To Use

Use for high-stakes deliverables where missing issues would be costly, such as:
- submission-bound papers or reports
- production or safety-relevant code
- mixed targets that combine multiple high-risk components
- major plans or decision documents
- consequential data analyses

If the user is unsure whether a deep audit is necessary, a lighter pre-scan such as `---qc` is often a better first step.

## When Not To Use

Do not use when:
- the user did not explicitly trigger `---audit`
- a quick lightweight scan is sufficient
- the task is to modify or fix the target rather than audit it

## Core Architecture

This skill uses a parallel subagent architecture.

- Each big round is executed by an independent subagent.
- Big round independence is guaranteed primarily by physical isolation, not by natural-language reminders.
- The main agent acts as orchestrator for planning, dispatch, merge, and degradation handling.
- Subagents must use `model: "opus"` regardless of the orchestrator model.

## Parameter Parsing

Read arguments after `---audit`.

- First capture arguments with quote-aware grouping. Any substring enclosed in matching quotes is one raw argument before further interpretation.
- When quoted arguments are present or path parsing is ambiguous, you must feed the raw args after `---audit` to `python scripts/parse-audit-args.py` via stdin or a single string argument, then treat its JSON output as the canonical parse before further heuristics.
- The first token may identify the audit target, a target type, or a file path.
- If the first token matches both a type keyword and an existing file path, file path takes priority.
- Quoted target paths that contain spaces must remain a single path argument during target identification.
- If a type keyword is followed by a quoted path, strip only the outer quotes and validate the full path string; do not probe internal fragments such as `C:/Users/jdoe/OneDrive` as standalone targets.
- Example: `---audit paper "C:/Users/jdoe/OneDrive - Example Org/Desktop/paper_target.md"` means `paper` is the type and the full quoted string is the single target path.
- The exact raw substring inside those quotes is the authoritative target path; do not rewrite it to a shorter existing prefix directory during validation.
- For any quoted target or output path containing spaces, emit a short parse preflight line before target validation, for example: `Parsed Args: type=paper | target=C:/.../paper_target.md | out=C:/.../paper_report.md`.
- If that parse preflight does not preserve the exact quoted target substring, stop and re-parse instead of diagnosing path fragments.
- Supported type keywords are:
  - `paper` / `论文`
  - `code` / `代码`
  - `plan` / `方案`
  - `data` / `数据`
  - `mixed` / `混合`
- If no argument is provided, identify the most recent substantive deliverable in the current conversation.
- If the first token is a type identifier, subsequent non-`--` arguments are treated as file paths.
- `--focus [theme]` adds one focus topic at a time and may be repeated.
- If focus additions exceed the mode cap, retain user-specified focus rounds before trimming lower-priority auto-selected themes; if focus topics alone exceed the cap, retain the earliest user-specified topics and warn about dropped extras.
- `--out [path]` sets the report path. If omitted, use the default relative report path. If the path already exists, append `_2`, `_3`, and so on.
- `--lang [zh/en]` forces report language. Without it, report language auto-matches the audit target language.
- `--lite` reduces round limits but must not skip critical verification:
  - critical checks include citation authenticity for papers, security vulnerability queries for code, and numerical consistency verification
  - non-critical auxiliary checks may be skipped in lite mode
- If the target content is not already in context, read it before audit execution.
- If no audit target can be identified, stop and prompt the user to specify one.

## Workflow Skeleton

### Phase 0

- Load `references/phase-0-planning.md`
- Run `scripts/config-check.sh` in a bash environment where `jq` is available and `$HOME/.claude/settings.json` resolves to the active Claude profile
- On Windows, prefer Git Bash; treat `C:/Windows/system32/bash.exe` or a WSL bash that cannot see the active `~/.claude` profile as incompatible and route that branch to the documented script-error fallback
- detect and guide on configuration without modifying settings mid-session
- analyse target, select themes, batch rounds, verify MCP availability, announce plan
- do not wait for user confirmation after the planning announcement; proceed directly to Phase 1

### Phase 1

- Load `references/phase-1-dispatch.md`
- Load `templates/subagent-template.md`
- populate the template and dispatch subagents in parallel

### Phase 2

- Load `references/phase-2-merge.md`
- Load `templates/report-template.md`
- collect results, deduplicate, renumber, write final output, clean up, and summarise

### Degradation

- On any failure path, degradation path, or platform-constraint branch, load `references/degradation-and-limitations.md`

## Hard Invariants

- Audit only, no modifications: do not modify the audit target; only produce the audit output.
- Exhaustiveness over speed: better to run extra rounds than to miss a substantive issue.
- Tool verification first: if something can be verified with a tool, do not rely on memory or inference.
- Strict standards: better to over-report suspected issues than to miss a real risk.
- Precise location: issue locators must identify section, paragraph, line number, or variable name.
- Actionable suggestions: preliminary suggestions must be specific enough for direct user action.
- Big round physical isolation is the primary independence guarantee; sequential fallback downgrades independence to protocol-level.
- If `~/.claude/rules/academic-workflow.md` or equivalent project-level academic rules exist in context, reference them during audit execution, especially for citation verification and numerical reporting standards.
- Severity classification:
  - Critical = factual error, security vulnerability, data loss risk, or fundamental defect
  - Major = substantive issue affecting conclusions or functionality
  - Minor = style, format, documentation precision, or defensive improvement
- Canonical runtime limits:
  - Standard mode = `3-8` big rounds, maximum `5` subagents per batch, maximum `2` batches
  - Lite mode = `2-4` big rounds, maximum `4` subagents, maximum `1` batch
  - Discovery-round caps = `7 / 3`; total sub-round caps = `14 / 6`
  - Subagent retry limit = `1`
- Configuration detection is detect-and-guide only. Because `model`, `effortLevel`, `fastMode`, and `alwaysThinkingEnabled` are cached at session start, do not auto-modify settings mid-session.
- Subagents use `model: "opus"` explicitly on every Agent call.

## Support File Load Order

### Normal Execution

- Phase 0: `references/phase-0-planning.md`
- Phase 1: `references/phase-1-dispatch.md`, then `templates/subagent-template.md`
- Phase 2: `references/phase-2-merge.md`, then `templates/report-template.md`

### Exceptional Execution

- Any failure, degradation, or platform-limitation branch: `references/degradation-and-limitations.md`

### Output Calibration

- When output examples are needed, consult `examples.md`
- When common execution mistakes need to be avoided, consult `pitfalls.md`

## Output Contract

The final report must follow `templates/report-template.md`.

- `templates/report-template.md` is the canonical source for final report structure.
- Report-language application is a runtime decision handled by parameter parsing plus Phase 2, not by the template itself.
- Simplified all-zero output is an explicit exception handled by Phase 2.

## Failure Modes

- **Discovery-verification conflation**: Verification phase uses discovery prose instead of an independent source or tool path, collapsing the D/V separation that is the skill's core architectural invariant. When the same evidence supports both discovery and verification, confirmation bias is structurally guaranteed. *Mitigation*: Require verification to use a different tool, file, or evidence source than discovery; flag V-round findings that cite the same evidence as their D-round origin.
- **Subagent model silent degradation**: Subagent launched without explicit `model` parameter defaults to a less capable model, reducing audit depth without any visible signal in the output. *Mitigation*: Always specify model explicitly in subagent dispatch; include model name in report metadata.
- **D-round shallow convergence**: The two-consecutive-empty-D-round stop condition can be satisfied when both rounds are shallow due to the same context pressure, incomplete file reads, or LLM variability, causing premature cycle exit despite undiscovered issues. *Mitigation*: Treat two consecutive empties as necessary but not sufficient when context pressure indicators are present; consider a third D round with explicit scope rotation.
- **Temp report write-tool overwrite risk**: The Write tool operates in overwrite mode. Although the protocol compensates with read-append-write (read existing → append in memory → write full content), a Read failure before write would silently destroy prior findings. The abort-on-Read-failure guard mitigates this, but the finding-loss window persists if the abort check itself fails. *Mitigation*: Verify finding count is non-decreasing across rounds; flag any round where the count drops as a potential data-loss event.
- **Cross-round dedup semantic judgment failure**: Dedup requires location + issue type + semantic sameness, but the semantic judgment is performed by the LLM without mechanical verification. Two genuinely distinct issues with overlapping location and similar phrasing can be incorrectly merged, losing one finding. *Mitigation*: When merging, log both the retained and dropped descriptions; flag merges where issue descriptions differ by more than trivial phrasing.
- **Mixed-target verification routing error**: When the target contains both prose and code, Phase 0 theme selection may bias toward the dominant type, under-representing secondary-type issues in big round assignments. At the subagent level, V-round tool path selection defaults to the dominant type when issue-bearing material is ambiguous, applying wrong verification criteria to one component type. *Mitigation*: Ensure Phase 0 allocates at least one theme to each target component type; scrutinize subagent template's mixed routing defaults for correctness.
- **Review entry-point bias**: Reviews start from documentation or prose layers instead of execution code (scripts, validators, config files), leaving implementation bugs in a trust blind spot. Issues visible only in code paths are systematically under-detected. *Mitigation*: Start at least one review pass from the execution layer rather than docs.
- **Sequential fallback independence loss**: When >=50% of first-batch subagents fail, the system degrades to sequential execution within the orchestrator context. Big round independence drops from architecture-guaranteed (physical isolation) to protocol-level (natural-language reminders and clearing protocol only), materially reducing audit reliability. The degradation note appears in the report, but readers may not grasp the severity of the independence downgrade. *Mitigation*: Report degradation status prominently in the report header; consider re-running the full audit under better conditions when sequential fallback triggers.
- **Subagent verification tool runtime failure**: A subagent's V-round verification tool may be structurally correct (name matches environment) but fail at runtime (timeout, rate limit, session break). The subagent marks findings as "could not verify," and Phase 2 aggregates tool degradation data across big rounds. However, the No-MCP supplement protocol only activates for planned MCP unavailability (detected in Phase 0), not for runtime failures; runtime-degraded verification is reported but not supplemented. Distinct from MCP tool name environment drift, which concerns name resolution; this concerns runtime availability of correctly-named tools. *Mitigation*: Subagent should attempt fallback tool paths within the same verification category before marking as unverifiable; orchestrator could extend the No-MCP supplement protocol to cover runtime failures; unverified findings must be explicitly flagged in the final report.

## Degradation Policy

When any normal-path assumption breaks, follow `references/degradation-and-limitations.md`.

If big rounds are `>=6` or the target is large, merge-phase context pressure is likely; prefer Context Mode MCP when available.

Any degraded path must be declared explicitly and must not be presented as equivalent to normal parallel isolated execution.

Sequential fallback lowers the independence guarantee and must be reported as such.

This includes:
- subagent failure
- temp-file failure
- sequential fallback
- merge interruption
- MCP unavailability
- configuration-check script failure
- context pressure
- platform limitations
