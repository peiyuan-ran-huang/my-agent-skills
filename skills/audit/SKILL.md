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
