# Audit Self-Check Specification

This document defines the `audit-self-check` maintenance checker for the `audit/` skill package.

The goal is to catch structural drift, canonical-source drift, fixture drift, and script-layer drift before those regressions become user-visible.

## Goals

The checker answers four questions:

1. Is the package structure still complete?
2. Are the canonical runtime authorities still where they are supposed to be?
3. Are the most drift-prone fixed lines and contracts still textually present?
4. What still requires manual reviewer judgment?

This checker is a maintenance aid, not a substitute for real smoke tests.

## Inputs And Scope

### In Scope

- file existence and non-emptiness
- frontmatter shape for entry files
- entry-layer boundary anchor presence
- canonical-source existence and role integrity
- script-layer existence and key output-contract strings
- reference/template anchor presence
- selected text-level regression fixtures
- severity-aware verification-ledger schema integrity
- a final manual follow-up list

### Out Of Scope

- proving the skill is still "heavyweight enough" in tone and rigor
- proving MCP, LSP, or Context Mode MCP is available at runtime
- replacing fresh-session smoke tests

## Suggested File Name And Placement

Recommended location:

- [audit-self-check-spec.md](audit-self-check-spec.md)

Current implementation path:

- `scripts/audit-self-check.sh`

Optional Windows wrapper later:

- `scripts/audit-self-check.ps1`

The core logic should stay in Bash to align with the existing script layer.

## Auto-Check Modules

> **Note:** For detailed check logic, read `scripts/audit-self-check.sh` directly. The script is the ground truth; this spec provides design context only.

| Module | Purpose | Primary Authority |
|--------|---------|-------------------|
| **M1. File Layout Check** | Verify live package matches declared layout | `README.md` |
| **M1b. Verification Ledger Schema Check** | Ensure V2 close condition remains machine-checkable (header shape, allowed severity/status values, unique IDs) | `verification-v2.md`, `verification-issue-ledger.md`, `contracts/maintenance-contracts.tsv` |
| **M2. Entry Frontmatter Check** | Ensure entry files follow skill-format constraints | `SKILL.md` |
| **M3. Entry Boundary Anchor Check** | Catch silent loss of critical entry-layer boundaries (triggers, type keywords, flags, degradation policy) | `SKILL.md` |
| **M4. Canonical Source Map Check** | Ensure one clear authority per runtime domain; detect README overreach | `README.md`, `contracts/maintenance-contracts.tsv` |
| **M5. Script Contract Check** | Catch script-layer drift via key output-contract strings and structural invariants | All `scripts/*.sh` files |
| **M6. Reference And Template Anchor Check** | Verify execution layers expose expected anchor sections and entry files preserve the support-file load-order contract | `references/*.md`, `templates/*.md` |
| **M7. Fixed-Line Fixture Check** | Protect highest-value text-level regression fixtures via literal-presence checking | `test-scenarios.md` |
| **M8. Scenario And Calibration Asset Presence Check** | Ensure maintenance assets expose minimum intended coverage (checklist items, scenario headings, example calibration) | `test-scenarios.md`, `examples.md`, `contracts/maintenance-contracts.tsv` |
| **M9. Self-Probe And Harness Checks** | Verify the checker, golden harness, and smoke-evidence scripts behave correctly under clean, broken, stale, empty, and error conditions by running nested probes | `scripts/audit-self-check.sh`, `scripts/test-golden.sh`, `scripts/check-smoke-evidence.sh` |

## Manual Review Modules

The checker should always emit a manual follow-up list for the items below.

### R2. Heavyweight Strength Review

Manual reviewer question:

- Has any edit made the skill softer, less explicit, less isolated, or less exhaustive?

### R3. Example Calibration Review

Manual reviewer question:

- Do the examples still calibrate maintainers toward the right report shape, or do they accidentally normalize weaker output?

### R4. Fresh-Session Smoke Tests

Manual reviewer question:

- Has a real fresh-session smoke test been run for:
  - `paper`
  - `code`
  - `plan`
  - `data`
  - `mixed`
- If the run used Claude Code CLI, did `claude auth status` show `"loggedIn": true` before the smoke attempt?
- If the non-interactive prompt began with `---audit`, was it passed via stdin or another non-argv input path rather than as a bare prompt argument?
- Has at least one targeted degraded-path drill also been run for:
  - MCP unavailable
  - sequential fallback
  - merge interruption / partial-output salvage
  - config-check anomaly or failure path
  - incompatible Windows bash path (`C:/Windows/system32/bash.exe` or foreign WSL bash)
- If archived markdown smoke reports are being reused as report-shape evidence, do they still pass the current `scripts/validate-report.sh` shape validator?
- If not, were they marked stale and excluded from the acceptance decision rather than silently counted as current report-shape evidence?
- If archived smoke evidence is non-markdown or in-thread only, was it reviewed against its own canonical source or fixture instead of being misclassified as something `validate-report.sh` can prove?
- If a CLI smoke attempt failed before the session started because Claude Code was unauthenticated or a leading `---audit` prompt was misparsed as an option, was that recorded as an operator / harness prerequisite failure rather than as an `audit` runtime regression?
- If a direct fresh-session `paper` smoke with a quoted OneDrive absolute path containing spaces still collapses to a prefix directory, was that recorded as the documented platform limitation rather than treated as a normal pass?
- When that limitation is observed, has one mitigated `paper` smoke also been run using either a staged no-space temp path or `audit_object_temp.md`?

### R5. Environment Reality Check

Manual reviewer question:

- If Claude Code CLI is the intended release-acceptance path, is it actually authenticated (`claude auth status` => `"loggedIn": true`)?
- Are MCP, LSP, Context Mode MCP, Bash, and `jq` actually available in the intended environment?

### R6. Final Sign-Off Discipline

Manual reviewer question:

- Does this change blur or silently reassign canonical source ownership?
- Does this change introduce behaviour that lacks fixture coverage or an explicit smoke-test decision?

## Failure Severity Policy

- `FAIL` — release-blocking structural or contract break (missing file, malformed frontmatter, missing critical anchor/fixture/keyword)
- `WARN` — likely drift needing reviewer judgment (README overreach, asymmetric anchors, thin coverage)

Manual reviewer follow-ups are not a third finding severity. They are emitted separately in the `Manual Follow-Ups` section.

## Exit Contract

- exit `0` — no `FAIL` findings (WARN and manual follow-ups may still be present)
- exit `1` — one or more `FAIL` findings
- exit `2` — checker execution error (unreadable input, parsing failure, missing dependency)

## Suggested Output Format

Each run emits three sections:

1. **Summary** — package path, timestamp, total/pass/fail/warn/manual counts
2. **Findings** — severity, rule id, file, message. Rule id prefixes: `L`=layout, `F`=frontmatter, `EA`=entry-anchor, `C`=canonical-source, `S`=script, `R`=reference/template, `T`=text fixture, `A`=asset/scenario
3. **Manual Follow-Ups** — heavyweight-strength, example calibration, fresh-session smoke tests (including quoted-OneDrive limitation + mitigated smoke), archived smoke revalidation, environment reality, canonical-source-ownership, fixture-coverage/smoke-decision

## Known Non-Automatable Areas

- Cannot prove the skill still feels heavyweight or product-grade
- Cannot prove examples are pedagogically safe
- Cannot replace live smoke tests
- Cannot prove runtime tools are actually available
- Cannot turn archived smoke evidence into a substitute for fresh-session runtime evidence
