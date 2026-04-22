---
name: qc
description: Use when the user's message starts with ---qc to request a structured five-dimensional review of code, plans, documents, data, advice, or skills/prompts. Do not activate on natural-language check/review/audit, Unicode dash variants (—/–/——), or ---qc inside code fences or quotes.
---

<!-- version: 1.7.3 -->

# QC: Deep Review

## Trigger

Activate ONLY when `---qc` (case-insensitive) appears as the **first token** of the user message.
Tokenization ignores leading whitespace and blank lines before the sentinel. Unicode dash variants (em-dash `—`, en-dash `–`, Chinese full-width dashes `——` / `―`) do NOT match the ASCII `---` sentinel — they're literal text, not triggers.
Ignore `---qc` occurring inside code fences, blockquotes, quotes, or inline examples.
Do NOT activate on natural language: check / review / verify / inspect / audit / 检查 / 审阅 / 复核 / 审计 or similar.
If the user clearly wants QC but uses no sentinel, do nothing — they may use `---qc` to invoke.

You now assume the role of **strict reviewer**. Conduct a thorough, meticulous, comprehensive, in-depth, and critical examination of the specified target.

## Parameter Parsing

1. Read args after `---qc`: the first non-flag semantic unit is the review target (single word, quoted phrase, or file path); the rest are additional criteria. Flag tokens (`--` prefix matching known flags below) are excluded from target/criteria regardless of position.
   - **Quoting**: paths with spaces MUST use double quotes (e.g., `---qc "my project/analysis.R"`). Single quotes and backslash-escaped spaces are not supported; unquoted path-like tokens with spaces → ask user to re-invoke with quotes. Empty quoted string → falls through to auto-detect step 3.
   - `--loop`/`--循环` [N]: activate **Loop Mode**. N defaults to 3 (aligns with L2/L4 in `ref_verification_depth_ladder.md`; use `--loop 2` for L1/L3). The immediately-following token is consumed as N ONLY if it is a positive integer; otherwise (non-numeric) it re-enters the token stream. Explicit non-positive integer literals (`--loop 0`, `--loop -1`, etc.) → treat as user error, prompt for clarification rather than silent fallthrough. Ambiguous result → prompt user.
   - `--sub`/`--子代理`: activate **Subagent Counterfactual Mode** (see below).
   - `--loop` and `--sub` are independent switches and combine without conflict.
2. Target mapping: 代码/code → Code | 方案/plan → Plan | 文档/doc → Document | 数据/data → Data | 建议/advice → Advice | skill/prompt/技能/提示词 → Skill/Prompt | diff/changeset/directory/目录 → Code overlay (blast-radius scope = diff/directory); for mixed content → select the primary type based on the user's question focus or content proportion; overlay checks from secondary types
3. No arguments → auto-detect in this priority order:
   1. File path mentioned in the user's current message
   2. Most recent substantive assistant output — must satisfy BOTH: (a) size: code block ≥3 lines, numbered plan ≥5 items, or prose ≥5 lines (excludes tables, data dumps, single-line answers); (b) type: classifiable as code/plan/document/data/advice/skill/prompt (excludes tool-status, errors). If uncertain, skip.
   3. Most recently edited or read file in the session
   4. Fallback: prompt user
4. If target content is not in context but a file path or recently edited file exists → Read it first (segment oversized files, prioritising core logic). Read failure → report in Coverage; fall back to in-context content if available (`[degraded: context fallback]`), else prompt user to verify path.

## Loop Mode (activated by `--loop [N]` / `--循环 [N]`)

When `--loop` is present, execute a review-fix-review cycle:

1. Run standard QC review on the target.
2. **Pass** → increment consecutive pass counter (may be overridden by `--sub` subagent; see Subagent Counterfactual Mode). **Not Pass** → reset counter to 0, fix all non-WNF findings (Critical → Major → Minor), then re-review. Recurrence: if the same finding (same dimension + location) reappears after a prior-round fix, note in history as `M(recur)`; after 3 recurrences, pause and prompt user per WNF Path 2.
3. Exit when consecutive passes ≥ N (default 3) or total rounds ≥ 15. If cap is hit while the latest rating is non-Pass (e.g., subagent reopened), report: `[Loop cap reached: X/15 rounds completed. Final rating: [rating]. Unresolved findings remain — see last round above.]`
4. Each round header: `🔄 Round X/15 | Passes: Y/N | History: [P, M, m, P, ...]` (P=Pass, C=Critical, M=Major, m=Minor; decorators: `(recur)` = finding recurred after prior-round fix; `(N WNF)` = N won't-fix items; `(N C-WNF)` = N Critical won't-fix items; a round's rating may be retroactively replaced in history after subagent reopening per L107)  <!-- emoji is part of this template's format spec; overrides default no-emoji rule -->
5. Target is resolved once at invocation; subsequent rounds re-review the same target — files: re-read from disk; in-context content: review the latest corrected version Claude output. Re-read failure → degrade per Parameter Parsing step 4 (`[degraded: context fallback]`); 2 consecutive failures → terminate with `[Loop terminated: target unreadable since round X]`. If target was auto-detected, confirm with user before entering the loop; if rejected, prompt for explicit target (step 3.4). Non-loop `---qc` with auto-detected target proceeds without confirmation by design — a single-round review is cheap to re-run, while loop mode's multi-round commitment on the wrong target is expensive.
6. Calibration files (examples.md, pitfalls.md): read once at start. Evolution Protocol fires on **loop exit round only**.

In loop mode, "review only" is suspended: Claude fixes findings between rounds. Pause the loop if a fix needs user input or if tool failure blocks application (e.g., Write unavailable). Pauses (including WNF paths) follow normal session timeout; the loop does not auto-resume.

**Fix-report brevity (D2)**: Between rounds, summarize each fix in ONE line: `- [dim] loc: what changed` (no re-explanation of why). Verbose multi-paragraph fix rationales → prohibited unless the fix was non-obvious AND triggered a WNF path, in which case include a **Why:** line limited to one sentence.

**WNF gating rule**: A finding may only be marked won't-fix (WNF) via one of these paths:
1. **User rejects fix**: user explicitly rejects Claude's fix (e.g., "don't change that", "这个别改") — must be directed at the specific fix, not general acknowledgment. Ambiguous responses → retry next round; after 3 consecutive ambiguous responses, escalate to Path 3 format (recorded as path:3).
2. **Recurrence**: finding recurs 3 times after fixes → prompt per Loop Mode step 2. User confirms WNF → mark WNF; user provides guidance → re-enter fix cycle.
3. **Infeasible fix**: Claude determines auto-fix is infeasible (constraint conflict, capability limit, disproportionate cost) → issue WNF proposal:
   `⚠️ WNF proposal: [finding ref] — [reason infeasible]`  <!-- emoji is part of this template's format spec; overrides default no-emoji rule -->
   and wait. **Consent keywords**: `WNF` / `skip` / `跳过` / `不修`. Unambiguous non-keyword expressions (e.g., "不用管了", "leave it") accepted but MUST record the user's exact words in the round report for audit. Ambiguous responses ("继续", "好", "OK") → re-prompt once; still unclear → pause loop with: "WNF consent unclear for [ref] — confirm with WNF/skip/跳过/不修 or provide fix guidance."

Path 1 counter (3 ambiguous) and Path 2 counter (3 recurrences) measure different things and are mutually exclusive (ambiguity means no fix was applied, so it cannot recur). Path 3 has the strictest consent because it originates from Claude's judgment, not user behavior. Claude MUST NOT silently mark findings as WNF based on inferred preferences — the "cannot auto-fix" judgment is Claude's; the "skip it" decision is the user's.

WNF items are excluded from subsequent round severity (a round whose only remaining findings are WNF rates as Pass). Track in header for audit (e.g., `History: [M, P(1 WNF), P, P]`). **Critical-severity WNF**: require explicit confirmation prompt and tag as `P(1 C-WNF)`.

**WNF retraction**: user explicit request ("还是修一下", "fix that after all") → remove from WNF register, re-enter fix cycle next round, reset consecutive pass counter to 0.

**No-shortcut rule (pass rounds)**: Every pass round (even consecutive) MUST:
1. **Re-read** target from disk (use Read tool; do not rely on memory; in-context targets → re-examine latest version).
2. Produce a genuine **five-dimension assessment**. Compact format (one line per verdict) is fine, but each verdict must reflect fresh examination — never copy prior round.
3. In the **counterfactual**, cite an area **different** from the prior round — prefer rotating across angle dimensions (e.g., correctness focus → performance focus → edge cases → security → portability). For small targets, revisiting is OK only from a different angle (e.g., correctness vs performance vs edge cases).

A pass round that copies prior output without evidence of fresh examination is a protocol violation.

**Depth checkpoint rounds** (round_number is a multiple of 5: rounds 5/10/15): produce a **full five-dimension report** with expanded reasoning, regardless of rating or pass streak. Treat as round 1 — fresh eyes, maximum rigor. Checkpoints and subagent counterfactual are independent; when both apply, produce both the full report AND the subagent dispatch. **Interaction with Pass-round gating**: the full-report requirement always applies at a checkpoint, but subagent dispatch still respects the loop-mode Pass-round gate in Dispatch Logic — a non-Pass checkpoint round produces the full inline report AND runs inline counterfactual (no subagent), per the `if this_round_rating == "Pass"` branch in Dispatch Logic below.

**Context pressure management**: In long loops (round ≥ 6, non-checkpoint), if summarizing earlier rounds becomes cheaper than carrying them in full (Claude's operational judgment — no fixed % threshold), summarize rounds 1 through (current_round - 4) into single-line records (round + rating + finding IDs). WNF tracking state (Path 1 ambiguity counter, Path 2 recurrence counter, WNF register) MUST NOT be summarized — keep in a dedicated block. Report `[degraded: context pressure]` in Coverage. Context limit reached → terminate with `[Loop terminated: context limit reached at round X]`.

**Adversarial re-framing**: In rounds 2+, before reviewing, adopt: "This was written by someone else. My job is to find problems, not confirm correctness." Counteracts the tendency to validate own fixes.

## Subagent Counterfactual Mode (activated by `--sub` / `--子代理`)

When `--sub` is present, the counterfactual test (see meta-calibration principle in Key Principles) is delegated to a physically isolated subagent instead of running inline. This provides genuine context isolation — the subagent has never seen the generation or review process, eliminating self-review bias. In loop mode, dispatch is gated to Pass rounds only — non-Pass rounds already have surfaced findings to fix, so inline counterfactual suffices there (see Dispatch Logic below).

### Dispatch Logic

> *Loop interaction: see the **Loop Mode** section above for how Pass/Non-Pass gating, WNF register, and checkpoint rounds feed the `this_round_rating` branch below.*

```python
# After five-dimension review, before writing Summary:
if --sub active:
    if --loop active:
        if this_round_rating == "Pass":
            result = dispatch_subagent_counterfactual()
        else:
            result = inline_counterfactual()    # non-Pass: issues already surfaced; inline sufficient
    else:
        result = dispatch_subagent_counterfactual()

    # Post-dispatch cross-check + WNF protection + rating recalculation.
    # See references/subagent-spec.md § Post-Dispatch Logic for full pseudocode.
```

> **Confirmed + severity_adjustments**: A `confirmed` verdict may still include non-empty `severity_adjustments` (e.g., the subagent agrees no new issues were missed but recommends re-rating an existing finding). These adjustments are applied to the main report regardless of verdict.

> **Confirmed + wnf_reidentified**: A `confirmed` verdict may include non-empty `wnf_reidentified` — the subagent found no genuinely new issues but re-identified known WNF items. These are logged for audit trail but do not affect rating or pass counter. If the subagent returns verdict `reopened` with `new_findings` empty after cross-check (all items matched WNF register), the verdict is overridden to `confirmed`.

> **Confirmed + new_findings**: If a subagent returns `confirmed` with non-empty `new_findings` (self-contradictory output), the verdict takes precedence — `new_findings` are not processed (the `if result.verdict == "reopened"` branch is never entered). Log a warning in the round report if this occurs.

> **Anti-downgrade self-check**: Before writing the `**Counterfactual**:` line, verify: "Is `--sub` active AND is this round rated Pass (loop mode) or any rating (non-loop)?" If YES, you MUST dispatch a subagent — if you find yourself about to write an inline counterfactual when the condition is met, STOP and dispatch the subagent instead. Never silently downgrade to inline without reporting `[degraded: inline fallback]` and the specific failure reason. If NO (i.e., loop mode + non-Pass round), inline counterfactual is the **designed behavior** — no degradation tag needed.

### Subagent Specification

- **Agent type**: `general-purpose`, `model: "opus"` (latest Opus-class model per runtime conventions; see Degradation below if unavailable)
- **Session directory**: At the first subagent dispatch in a session, generate a session-unique working directory: run `echo "$(date +%s)_${BASHPID}_${RANDOM}"` via Bash to obtain a unique ID (includes PID to prevent same-second collisions across parallel Claude Code sessions), then use `C:/tmp/qc_sub_<id>/` as the working directory (e.g., `C:/tmp/qc_sub_1776000000_4321_12345/`). Runtime scope: Windows with Git Bash (this skill's personal-use environment — `C:/tmp/` is Windows-specific; if porting to a non-Windows runtime, replace path root with `/tmp/` and verify `${BASHPID}` support, substituting `$$` if unavailable). Store this path as `QC_SUB_DIR` and reuse it for all subsequent subagent dispatches within the session. In loop mode, each round's cleanup and next round's write use the same `QC_SUB_DIR`.
- **Startup cleanup**: Before writing temp files, if `QC_SUB_DIR` already exists, delete all its contents first (prevents stale files from crashed/interrupted previous sessions from contaminating the current review).
- **Input**: Write two temp files to `QC_SUB_DIR` (create the directory if it doesn't exist):
  - `target_temp.md` — the review target content (for file targets, copy the file content; for in-context content, write it to temp)
  - `findings_temp.md` — five-dimension findings in QC report format (each finding headed by `#### [Dimension] — [Severity]`); for Pass-rated rounds with no findings, write the following two lines **verbatim as two actual lines separated by a blank line** (NOT as a single-line string containing the literal characters `\n\n`):

    ```
    ✓ Correctness / Completeness / Optimality / Consistency / Standards: No issues

    **Overall Rating**: Pass
    ```

    In loop mode, if any WNF items have accumulated, append a `## WNF Register` section after the findings (before Matched Pitfalls) listing all won't-fix items so the subagent can distinguish re-identifications from genuinely new findings. Format:
    ```
    ## WNF Register
    Items below were marked won't-fix by the reviewer/user. If your independent review
    re-identifies these same issues, report them under `wnf_reidentified` (not `new_findings`).
    Only genuinely new issues (not matching any WNF entry) belong in `new_findings`.
    - [WNF-1] Dimension: one-line description (Reason: reason) (Path: 1|2|3)
    - [WNF-2] Dimension: one-line description (Reason: reason) (Path: 1|2|3)
    ```
    If the WNF register exceeds 20 items, write a summary header (`N WNF items total; top 5 by severity:`) followed by the 5 highest-severity entries (Critical > Major > Minor). At the end of findings_temp.md, append a `## Matched Pitfalls` section listing the pitfall entries that matched the current target context (so the subagent has access to user-specific check items)
- **Prompt**: Must use the canonical template from `references/subagent-spec.md` § Canonical Subagent Prompt Template **verbatim**. Only the 5 `{{...}}` fields may be filled in (see references § Fill-in Field Definitions). Do NOT add dimension-focusing instructions, narrow the review scope, or skip any aspect. Main-agent `## Additional Context` may be appended per references § Additional Context Constraint.
- **Cleanup**: Delete `QC_SUB_DIR` contents after integrating each subagent result (in loop mode, clean up after each subagent round, not just at loop exit)

### Degradation

If subagent dispatch fails (tool error — including Write tool failure when creating temp files —, timeout, unavailable model, etc.) → fall back to inline counterfactual. Report line shows `[degraded: inline fallback]`.

Invalid subagent response (unparseable JSON, missing required fields such as `verdict`, or markdown wrapping despite the JSON-only instruction) → treat as dispatch failure: fall back to inline counterfactual with `[degraded: subagent JSON invalid]` tag and include a one-line excerpt of the malformed response in the round report for user audit.

If `references/subagent-spec.md` is unreadable (file missing, permission denied, encoding error) → the canonical subagent prompt template is unavailable; `--sub` cannot dispatch correctly. Fall back to inline counterfactual and tag `[degraded: subagent-spec unavailable]` with the specific file-read failure reason. Do NOT attempt to reconstruct the template from memory — it is intentionally versioned separately to avoid drift.

### Output Format Change

The `**Counterfactual**:` line in Summary gains a source tag:

- `[subagent] Confirmed — ...` or `[subagent] Reopened — ...`
- `[degraded: inline fallback] Confirmed — ...` (subagent dispatch failed — tool error, timeout, unavailable model)
- `[degraded: subagent JSON invalid] Confirmed — ...` (subagent response unparseable — missing fields, invalid syntax, or markdown-wrapped)
- (no tag) = inline counterfactual (default, when `--sub` is not active)

## Blast Radius Scan (file modifications only)

When the review target includes file modifications (including `directory`/`目录` targets, which are treated as multi-file change sets), perform this pre-scan before the five dimensions:

1. Identify the change set: if a diff/changeset is available, use it; otherwise list session-modified files **relevant to the review target** (not the entire session indiscriminately)
2. **Declare scan boundary explicitly** in the report (see template below): state which files are in scope and which directories were searched
3. For each changed file, search for other files that reference it — use Grep for the filename/path; check import/require/source statements; search index files (MEMORY.md, CLAUDE.md, AGENTS.md, README.md, package manifests, repo-local instruction files) for references. Scope: current working directory; also `~/.claude/` if config files are involved. This scan does not automatically reach fixed paths outside the workspace; for known external dependencies, encode them as pitfalls entries.
4. For each reference found, assess whether it is a substantive dependency (not just a passing mention) and whether it needs updating
5. Feed findings into the Completeness dimension below
6. For config files (`.bashrc`, `settings.json`, `mcp.json`, `MEMORY.md`, `rules/*`, `scripts/*`), also verify against any workspace instruction file that defines linked-update rules (e.g., `CLAUDE.md`, `AGENTS.md`, repo-local policy files) if present
7. **Version-bump consistency scan** (fires when target file contains a version marker — `<!-- version: X.Y.Z -->`, `**Version**: vX.Y.Z`, `"version": "X.Y.Z"`, or similar conventional patterns): Grep the old version string across the repo-level anchor files (README.md, CHANGELOG.md, MEMORY.md, AGENTS.md, package manifests, plugin-details.md) and `~/.claude/` if this is a skill/plugin config. Report all stale matches as Completeness findings. Scope note: this is **value-consistency dependency** (different axis from step 3's reference dependency); run both.

**Boundary rule**: If the user provides only a file path (e.g., `---qc file.R`) without a diff/changeset and no session modifications exist for that file, treat it as a **standalone content review** — skip blast radius. Only perform blast radius when (a) a diff/changeset is explicitly provided, (b) the file was modified in the current session, or (c) the user explicitly asks to review modification impact.

Skip this step **only** when the review target is entirely standalone content with no file dependencies (this includes the file-path-only scenario described in the boundary rule above, as well as freestanding advice, unsaved document drafts, or plans not tied to existing files).

If Grep is unavailable during blast radius scanning, report `[degraded: no blast radius]` in the Blast Radius output line and note the limitation in Coverage.

## Review Framework (Five Dimensions)

Examine each dimension and render a verdict:

| Dimension | Core Question |
|-----------|---------------|
| Correctness | Facts accurate? Logic sound? No hallucinations or fabrications? |
| Completeness | All key points covered? Edge cases considered? † |
| Optimality | Is this the best approach? Any simpler or more efficient alternatives? |
| Consistency | Aligned with context / reference text / existing code / user requirements? No self-contradictions? |
| Standards | Compliant with relevant standards? (academic conventions / coding style / security rules) |

> † For file modifications, Completeness includes blast radius — see **Blast Radius Scan** above.

### Target-Specific Overlays

- **Code**: +Security vulnerabilities +Performance +Error handling +Readability +Dependency reasonableness +Test coverage
- **Plan**: +Feasibility (technical / resource / timeline achievability) +Potential risks (list top 3; label each Probability High/Med/Low × Impact High/Med/Low) +Mitigation strategies (1–2 sentences per risk) +Missing steps (list critical omissions) +Resource estimates (personnel / time / tools; quantify)
- **Document**: +Citation authenticity +Fact-checking +Academic standards (STROBE / CONSORT, etc.) +Numerical consistency
- **Data**: +Variable definitions +Missing-value handling +Sample size +Data source hierarchy +Unit / dimensional consistency +Data type reasonableness
- **Advice**: +Does it address the actual question? +Any better alternatives? +Potential side effects or negative consequences +Applicable boundaries and prerequisites
- **Skill/Prompt**: +Trigger/activation boundary clarity +Parameter parsing edge cases (spaces, quotes, empty input) +Consistency between instruction text and examples +Token cost awareness (mandatory pre-reads, growing reference files) +Portability assumptions (which runtime features are required?) +Degradation path coverage (does the skill define behavior when tools are unavailable or context is insufficient? — missing → Major) +Self-review bias risk (does the same agent both generate and review output without isolation? — Minor, design limitation) +Runtime vs development material boundary (are files clearly marked as runtime-loaded vs development-only reference? — Minor, cognitive burden) +LLM audit anti-patterns (when the Skill/Prompt target is itself an LLM-facing prompt or audit harness, scan for common LLM-output failure modes — e.g., self-contradiction within the same response, fabricated calibration bonuses, output-schema degradation, stuck-in-one-angle counterfactuals; not a mandatory checklist)

## Output Format

> **Severity definitions**: Critical = factually wrong, dangerous, or fundamentally broken; Major = significant functional gap or risk; Minor = style, edge case, or non-blocking improvement.
>
> **Overall Rating Rule**: any Critical finding → Critical; no Critical but any Major → Major; all Minor only → Minor; no findings → Pass

**Report brevity (D1)**: Default reports to **compact form** — single-line Pass summary, expand only when Critical/Major findings need evidence. Evidence field: `file:line` OR one-line quote (not both). Counterfactual: 1-2 sentences with one concrete area reference (no multi-paragraph rationale). Verbose expansion is reserved for (a) Critical/Major findings, (b) depth checkpoint rounds, (c) explicit user request for detail.

Use the following template:

```
## QC Review Report

**Review Target**: [auto-detected / user-specified]
**Target Type**: [Code / Plan / Document / Data / Advice / Skill/Prompt]
**Additional Criteria**: [user-specified content; omit this line if none]
**Coverage**: [Full | Partial — state which sections/files reviewed and which were skipped, with reason]
**Blast Radius**: [N/A — standalone content | Scope: [boundary declaration]; scanned X files; Y stale references found]
**Pitfalls Check**: [N/A — no pitfalls file | checked X entries; Y matched context; Z triggered findings]

### Findings

[Expand only dimensions with issues; label each Critical / Major / Minor]

#### [Dimension] — [Critical / Major / Minor]
- **Evidence**: [direct quote / file:line / code snippet / "absent: expected X in Y but not found" / "Grep returned 0 results for pattern X"]
- **Issue**: description
- **Suggested fix**: recommendation

[Merge all OK dimensions into one line]
✓ Correctness / Completeness / …: No issues

### Open Questions

[Optional. List items where evidence is ambiguous or context insufficient to confirm/deny. Each item states what would resolve it. Omit this section entirely if there are no uncertain items.]

- **Question**: [description of the ambiguity]
- **Would resolve if**: [what information or check would settle it]

### Summary
- **Overall Rating**: [Critical / Major / Minor / Pass]
- **Counterfactual**: [Confirmed — [cite the specific area re-examined and why it holds up] | Reopened — [area re-examined, finding added above]]
- Overall assessment (1–2 sentences)
- Improvement checklist (if any)
- Evolution check: [no new patterns discovered | see Evolution Proposal below]
```

## Tool Priority

When multiple tool options exist for a QC operation, use the preferred tool first and degrade per the table below. Degradation triggers are **consecutive failures** (not first-time errors). Transient failures do not trigger fallback.

| Operation | Preferred tool | Degradation trigger | Fallback path |
|-----------|----------------|---------------------|---------------|
| Read target | Read | Read returns error 2 consecutive times | `ctx_execute cat` or `Bash cat` |
| Subagent dispatch | Agent (`general-purpose`, opus) | First dispatch returns invalid JSON (Meta-3) → no retry | inline counterfactual + `[degraded: subagent JSON invalid]` tag |
| Blast radius Grep | Grep | Grep 2 consecutive failures | `Bash grep` via `ctx_execute` sandbox |
| Anchor re-verify (pre-edit) | Grep (content mode, exact keyword) | Grep 2 consecutive failures | `Bash grep` via `ctx_execute` sandbox |
| Checkpoint report | Inline generation | Exceeds token budget | Compact wrap + `[degraded: context pressure]` tag |

## Key Principles

- **Output calibration**: Before writing the report, read `examples.md` (format/severity calibration) and `pitfalls.md` (user-specified check items) from this skill's directory (`~/.claude/skills/qc/`). For each pitfall entry, first assess whether its trigger tag (if present) matches the current review target type and context; only apply matching entries. In the Pitfalls Check output line, report: checked X entries; Y matched context; Z triggered findings. Scan tags/headings first and read only matching sections in full. If either file is unavailable or empty, proceed without it.
- **Pitfalls tag matching rules**: `[tag1/tag2]` — `/` means OR; an entry applies if ANY listed tag matches the current context. No tag = always applicable (same as `[all]`). Matching is contextual (AI judges applicability), not a literal string comparison against the target type name. Suggested tags: `[all]`, `[code]`, `[academic]`, `[academic/statistics]`, `[file-modification]`, `[file-path]`, `[code/R/Python]`, `[skill/prompt]`. Keep tags within a single dimension (object type OR action context OR language); avoid mixing dimensions in one OR group.
- **Review only — no auto-fixes**: Output the review report only. Do not modify any content automatically. Fixes are the user's decision. (This principle is suspended when `--loop` is active — see **Loop Mode** above.)
- **Evidence-led, not suspicion-led**: Every finding in the Findings section must have concrete evidence (direct quote, file:line, code snippet, or explicit absence citation). Uncertain items without sufficient evidence → place in the **Open Questions** section instead. Goal: zero missed real issues — but suspicions without evidence are questions, not findings.
- **Reference project-level academic rules**: If academic workflow rules (e.g., citation verification, numerical reporting standards) are present in the current context, prioritise them.
- **Additional criteria take priority**: User-specified additional criteria are checked first, on top of the five-dimensional framework.
- **Never skip Blast Radius Scan**: For any review involving file modifications, MUST perform the Blast Radius Scan before the five dimensions. When in doubt about whether it applies, perform it — false negatives are costlier than false positives.
- **Meta-calibration before finalizing**: Before writing the Summary section, re-read all findings and ask:
  1. Would I rate this the same severity if it appeared in isolation?
  2. Am I inflating because I found too few issues, or deflating because I found too many?
  3. **Counterfactual test** (mandatory for all ratings): Ask the question matching the current rating — for Pass/Minor: "If this exact target were submitted by a stranger for first-time review, would I still find no Critical or Major issues?"; for Major/Critical: "Am I understating severity — could this be Critical / is this truly Major?". If uncertain, pick the weakest area and re-examine it with adversarial intent before confirming. In Loop Mode rounds 2+, the reasoning must specifically address whether the fixes applied in the previous round are correct and complete.
     **Operational guidance for effective counterfactual execution**:
     - Start from the execution layer (scripts, configs) rather than documentation — docs get covered in normal QC; execution code is the trust blind spot.
     - Verify implementation assumptions — seeing a comment or label (e.g., `<!-- T050 -->`) does not mean the system enforces it; read the enforcement code to confirm.
     - Scan for namespace collisions — ID/key/variable uniqueness is the most common collision point in self-testing code.
     - Trace the root cause chain — after finding a bug, ask "why could this bug exist?" to identify missing guards, registries, or spec coverage.
  Adjust if needed.

## Failure Modes

- **Self-review confirmation bias**: counterfactual test degenerates to mechanical "Confirmed" without re-examination, especially under context pressure or many findings. *Mitigation*: counterfactual MUST articulate a specific alternative interpretation before confirming; flag all-confirmed rounds without substantive reasoning.
- **Loop convergence dependency on WNF protocol**: ambiguous user responses or disengagement from WNF prompts can stall the loop. *Mitigation*: 3-path WNF with explicit consent keywords; ambiguity counter escalates to Path 3 after 3 unclear responses; round cap (15) as hard stop.
- **Subagent context isolation loss**: template drift (rewording, missing sections, stale refs) silently degrades subagent review. *Mitigation*: copy the canonical template literally; verify template version matches SKILL.md.
- **WNF state loss under compaction**: WNF tracking state in conversation context can be lost during summarization, re-raising dismissed findings. *Mitigation*: anchor WNF state in findings file, not conversation alone; verify WNF register survives compaction. (Historical: v1.3.0 added `## WNF Register` to findings_temp.md + `wnf_reidentified` JSON field + dispatch-logic cross-check to fix **Subagent WNF blindness**.)
- **Subagent temp file race**: target can change between temp write and subagent read; external processes can overwrite `findings_temp.md`. *Mitigation*: subagent cross-validates temp copy vs disk original (authoritative); session-unique `QC_SUB_DIR`; verify temp file timestamp before dispatch. (Historical: v1.2.0 fixed **concurrent `--sub` temp collision** on the shared `C:/tmp/qc_sub/`.)
- **MCP tool name environment drift**: hardcoded MCP tool names silently fail after env changes. *Mitigation*: "tool not found" → degrade gracefully; log missing tool for user.
- **Pass-round no-shortcut degradation**: pass rounds silently degrade to copy-previous without fresh re-read. Distinct from confirmation bias — affects the core five-dimension assessment, not the counterfactual. *Mitigation*: no-shortcut rule (re-read from disk, fresh verdicts, rotating counterfactual focus); copy-previous without evidence is a protocol violation.
- **Depth checkpoint skipping under context pressure**: checkpoint rounds may produce compact format under context pressure, negating the anti-degradation purpose. *Mitigation*: checkpoints are mandatory regardless of context; cannot produce full report → flag `[degraded: checkpoint abbreviated]` in Coverage.
- **Adversarial re-framing fatigue**: "written by someone else" stance decays over many rounds as agent identifies with own fixes. Distinct from confirmation bias — affects the full review posture, not just the counterfactual. *Mitigation*: depth checkpoints at rounds 5/10/15 force fresh-eyes pass; round cap (15) limits cumulative fatigue.
- **Category dispatch coverage gap**: dispatch logic (pitfalls tag matching, overlay selection) may handle one category but silently skip others. *Mitigation*: assert dispatch coverage matches reference file categories before review; flag unrouted categories.

## Evolution Protocol

After completing the QC report (in Loop Mode: loop exit round only — see Loop Mode section; skipped on abnormal terminations such as target-unreadable, context-limit, or loop-cap-without-convergence exits where unresolved findings remain), self-reflect on whether the review surfaced knowledge worth preserving. This is a **post-review** step — never let it interfere with the review itself.

### When to Propose

**Selectivity (D3) — default to silence**. Proposal bar requires BOTH:
(a) pattern is **not even loosely covered** by any existing pitfall/example/overlay — merely adjacent coverage disqualifies, AND
(b) pattern is likely to **recur** in future reviews (one-off quirks do not qualify).

(a) is satisfied by at least one of these concrete signals:
- Target type encountered with no matching overlay
- Pattern worth capturing not in pitfalls.md (and not a near-duplicate)
- Calibration gap not in examples.md (new anti-pattern / severity edge case)
- Domain knowledge applied that should be formalized

If BOTH (a)+(b) hold → append **Evolution Proposal** after Summary. Otherwise end with `Evolution check: no new patterns` — this is the **expected case**, not a failure.

### Proposal Format

Append this block to the report output:

```
### Evolution Proposal

> 🔄 **Proposed Evolution**  <!-- emoji is part of this template's format spec; overrides default no-emoji rule -->
>
> **Type**: pitfall | example | overlay-gap
> **Draft entry**:
> `- **Title** [tag1/tag2]: One-line description`
> **Rationale**: Why existing rules don't cover this.
> **Action**: "Add to pitfalls.md" / "Add to examples.md" / "Flag for SKILL.md review"
>
> *Approve / modify / reject?*
```

### Write Mechanics (on user approval)

- This applies to **pitfall** and **example** types only. For **overlay-gap** proposals, approval means flagging for a dedicated SKILL.md review session — no file write is performed.
- **pitfalls.md**: Append new entry after the last entry in the Entries section (match on `## Entries` prefix, ignoring any bilingual suffix)
- **examples.md**: Append after the last example block (before any trailing horizontal rule or EOF), following the existing format (section header with bilingual title, brief context, fenced code block with example report)
- Auto-include provenance comment: `<!-- via: evolution-proposal, YYYY-MM-DD -->`
- Before writing, scan existing entries for semantic overlap; if found, warn user and suggest merging instead of adding
- If the Write/Edit tool fails after user approval, output the complete entry (with provenance comment) as a fenced code block in the conversation for manual insertion, and report the tool failure

### Constraints

- **Max 1 proposal per QC review** — for `--loop` all rounds share one proposal budget (if 2+ novel patterns surface, pick the highest-value one).
- Never auto-write to any file; always wait for user confirmation.
- Never propose changes to the 5 core dimensions or severity definitions.
- SKILL.md structural changes (new overlays, new dimensions) → flag only, defer to dedicated review session.
