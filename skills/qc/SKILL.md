---
name: qc
description: Use when the user explicitly invokes ---qc for a structured five-dimensional review of code, plans, documents, data, advice, or skills/prompts.
---

<!-- version: 0.5.1 | SYNC RULE: Changes to this file MUST be mirrored in SKILL_ZH.md.
Allowed differences: (1) frontmatter `name` (qc vs qc-zh), (2) frontmatter `description` language,
(3) loading behavior note in SKILL_ZH.md. Sync metric: semantic equivalence per section, NOT line-count equality. -->

# QC: Deep Review

## Trigger

Activate ONLY when `---qc` (case-insensitive) appears as the **first token** of the user message.
Ignore `---qc` occurring inside code fences, blockquotes, quotes, or inline examples.
Do NOT activate on natural language: check / review / verify / inspect / audit / 检查 / 审阅 / 复核 / 审计 or similar.
If the user clearly wants QC but uses no sentinel, do nothing — they may use `---qc` to invoke.

You now assume the role of **strict reviewer**. Conduct a thorough, meticulous, comprehensive, in-depth, and critical examination of the specified target.

## Parameter Parsing

1. Read args after `---qc`: the first semantic unit is the review target (a single word, a quoted phrase, or a file path — **file paths containing spaces must be quoted with double quotes**, e.g., `---qc "OneDrive - University of Bristol/file.R"`; if unquoted path-like tokens containing spaces are detected, ask the user to re-invoke with quotes); the rest are additional criteria
2. Target mapping: 代码/code → Code | 方案/plan → Plan | 文档/doc → Document | 数据/data → Data | 建议/advice → Advice | skill/prompt/技能/提示词 → Skill/Prompt | diff/changeset/directory/目录 → Code overlay (blast-radius scope = diff/directory); for mixed content → select the primary type based on the user's question focus or content proportion; overlay checks from secondary types
3. No arguments → auto-detect using this priority:
   1. File path mentioned in the user's current message
   2. Most recent substantive assistant output (code block, plan, document draft, etc.)
   3. Most recently edited or read file in the session
   4. (Fallback) Prompt the user to specify
4. If target content is not in current context but a clear file path or recently edited file exists → use Read to load the file before reviewing; for oversized files → read in segments, prioritising core logic sections

## Blast Radius Scan (file modifications only)

When the review target includes file modifications, perform this pre-scan before the five dimensions:

1. Identify the change set: if a diff/changeset is available, use it; otherwise list session-modified files **relevant to the review target** (not the entire session indiscriminately)
2. **Declare scan boundary explicitly** in the report (see template below): state which files are in scope and which directories were searched
3. For each changed file, search for other files that reference it — use Grep for the filename/path; check import/require/source statements; search index files (MEMORY.md, CLAUDE.md, AGENTS.md, README.md, package manifests, repo-local instruction files) for references. Scope: current working directory; also `~/.claude/` if config files are involved.
4. For each reference found, assess whether it is a substantive dependency (not just a passing mention) and whether it needs updating
5. Feed findings into the Completeness dimension below
6. For config files (`.bashrc`, `settings.json`, `mcp.json`, `MEMORY.md`, `rules/*`, `scripts/*`), also verify against any workspace instruction file that defines linked-update rules (e.g., `CLAUDE.md`, `AGENTS.md`, repo-local policy files) if present

**Boundary rule**: If the user provides only a file path (e.g., `---qc file.R`) without a diff/changeset and no session modifications exist for that file, treat it as a **standalone content review** — skip blast radius. Only perform blast radius when (a) a diff/changeset is explicitly provided, (b) the file was modified in the current session, or (c) the user explicitly asks to review modification impact.

Skip this step **only** when the review target is entirely standalone content with no file dependencies (this includes the file-path-only scenario described in the boundary rule above, as well as freestanding advice, unsaved document drafts, or plans not tied to existing files).

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
- **Skill/Prompt**: +Trigger/activation boundary clarity +Parameter parsing edge cases (spaces, quotes, empty input) +Consistency between instruction text and examples +Token cost awareness (mandatory pre-reads, growing reference files) +Portability assumptions (which runtime features are required?)

## Output Format

> **Severity definitions**: Critical = factually wrong, dangerous, or fundamentally broken; Major = significant functional gap or risk; Minor = style, edge case, or non-blocking improvement.
>
> **Overall Rating Rule**: any Critical finding → Critical; no Critical but any Major → Major; all Minor only → Minor; no findings → Pass

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
- Overall assessment (1–2 sentences)
- Improvement checklist (if any)
```

## Key Principles

- **Output calibration**: Before writing the report, read `examples.md` (format/severity calibration) and `pitfalls.md` (user-specified check items) from this skill's directory (`~/.claude/skills/qc/`). For each pitfall entry, first assess whether its trigger tag (if present) matches the current review target type and context; only apply matching entries. In the Pitfalls Check output line, report: checked X entries; Y matched context; Z triggered findings. If `pitfalls.md` grows beyond ~30 entries, scan tags/headings first and read only matching sections in full. If either file is unavailable or empty, proceed without it.
- **Pitfalls tag matching rules**: `[tag1/tag2]` — `/` means OR; an entry applies if ANY listed tag matches the current context. No tag = always applicable (same as `[all]`). Matching is contextual (AI judges applicability), not a literal string comparison against the target type name. Suggested tags: `[all]`, `[code]`, `[academic]`, `[academic/statistics]`, `[config/skill/file-modification]`, `[file-path]`, `[code/script/R/Python]`, `[skill/prompt]`.
- **Review only — no auto-fixes**: Output the review report only. Do not modify any content automatically. Fixes are the user's decision.
- **Evidence-led, not suspicion-led**: Every finding in the Findings section must have concrete evidence (direct quote, file:line, code snippet, or explicit absence citation). Uncertain items without sufficient evidence → place in the **Open Questions** section instead. Goal: zero missed real issues — but suspicions without evidence are questions, not findings.
- **Reference project-level academic rules**: If academic workflow rules (e.g., citation verification, numerical reporting standards) are present in the current context, prioritise them.
- **Additional criteria take priority**: User-specified additional criteria are checked first, on top of the five-dimensional framework.
- **Never skip Blast Radius Scan**: For any review involving file modifications, MUST perform the Blast Radius Scan before the five dimensions. When in doubt about whether it applies, perform it — false negatives are costlier than false positives.
