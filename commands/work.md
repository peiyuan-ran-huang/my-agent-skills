---
description: "Summarize current session work: completed, incomplete, and remaining items"
allowed-tools: Read, Grep, Glob, TaskList, Bash(git status:*), Bash(git diff:*)
---
<!-- version: 1.4.0 (2026-04-21) — continuous numbering, triage criteria tightened (🟡 hard-criteria-only + bias rule), compact hint; post-compact staleness probe -->

# Session Work Summary

Review the entire conversation history and produce a structured work summary. Use the following sources and format.

## Trigger

Activate only when invoked via `/work`. Do not activate on natural language such as "summarize session", "what did we do", or similar. Ignore `/work` in code fences or blockquotes.

## Parameter Parsing

`/work` accepts no parameters. Any text after `/work` is ignored.

## Information Gathering

Collect from these sources in order:

1. **Conversation context** (primary) — scan for all work performed, decisions made, files touched, and tasks discussed
2. **TaskList** — check tracked tasks. TaskList is workspace-scoped (no session filter); match subjects against session topics, filter by status (in_progress, completed; pending excluded — not yet acted on this session). Skip silently if empty or unavailable
3. **Git status/diff** — if inside a git repo, run `git status` and `git diff --stat` to cross-validate. Skip if not a git repo
4. **File operation records** — from conversation context, compile all files Read/Edited/Written. After context compression these records degrade; note if coverage is uncertain

**Tool usage**: Read to inspect ambiguous file states; Grep to search patterns; Glob to verify paths exist (see Verification).

## Post-Compact Staleness Probe

When the current session shows **post-compact signals** — any of: `<session_knowledge source="compact">` tag, `SessionStart:compact` hook output, "session being continued from a previous conversation" preamble, or explicit `<command-name>/compact</command-name>` in the conversation — the summarized context may list items as "remaining" that were actually completed before the compact.

**Required probe before classifying any 🟢/🟡 Remaining Item** (skip if no post-compact signal present):

1. Extract the concrete artifact named by each candidate item: file path, directory, git branch, scheduled task name, or other filesystem-verifiable target.
2. Probe current state using tools already in /work's allowed-tools: `Glob` for existence/absence checks, `Read` or `Grep` for content-change checks (e.g., "was line Y added to file X?"). Non-file targets (scheduled tasks, git branches beyond `git status`/`git diff`, external API state) fall outside /work's default tool permissions — either request approval at runtime for a one-off check, or fall through to step 4. For staging dirs (`/c/tmp/to_delete/`, `.claude/_trash/<subdir>/`): empty or absent = already executed pre-compact.
3. Reclassify confirmed-done items under **Completed Work** with tag `[done pre-compact]`.
4. Items not filesystem-verifiable (e.g., external API state, in-app toggle) → tag `[unverified post-compact]` in the original tier; do NOT silently promote to Completed.

**Rationale**: summary-derived conversation context does not always reflect pre-compact execution. Cheap filesystem probe prevents giving the user a stale checklist.

## Output Format

Write in the **session's conversation language** (Chinese → Chinese, English → English), including headers. Mixed-language sessions: use the majority language; if roughly equal, default to English.

**Short session** (1-2 exchanges): one-paragraph summary covering what was discussed, files touched, and any actionable outcome. Skip the full template.

**Standard session**: use the template below. **Omit any empty section.**

If context was compressed, prepend: "[Note: earlier context was compressed — coverage may be incomplete]"

```
## Completed Work
- [description] (`file path`)

## Incomplete Work
- [description] (`file path`) — [reason / blocker]

## Remaining Items
### 🟢 Doable — can handle now in this session
1. [item] (`file path`)
2. [user action] [item] (`file path`)

### 🟡 Next Session — needs a dedicated session
3. [item] (`file path`) — [brief reason]
4. [restart] [user action] [item] (`file path`) — [brief reason]

### 🔴 Deferred — cannot act on now
5. [item] (`file path`) — [reason]

(Numbering is continuous across all tiers — user can reference items by number, e.g., "do 1, 3, 5"; if a tier is empty, subsequent tiers continue from the last used number, e.g., 0 green + 2 yellow → number them 1, 2)
(empty tiers omitted; >=3 items in a tier -> group by category)
(If >=2 🟢 items: append "Tip: run `/compact` before continuing to free up context")
(Note: [bracketed tags] are literal output; [bracketed placeholders] are filled in)
```

## Classification Rules

- **Completed** = explicitly finished this session (user confirmed, file written, task completed)
- **Incomplete** = started but not finished (task-oriented: "what was started but not done")
- **Remaining** = follow-up work for objects handled this session, including work surfaced but not attempted (object-oriented: "what does this thing still need")
- **Overlap**: fits both Incomplete and Remaining -> put in Incomplete. Remaining may cross-reference but not repeat

## Remaining Items Triage

Place each item into one tier:

- **🟢 Doable** = default tier. Anything that can be done in this session at reasonable quality. Includes multi-step tasks if the current session already has relevant context. Simple user actions (single-step, no judgment/research — e.g., toggle setting, click button) -> tag `[user action]`
- **🟡 Next Session** = only when a hard criterion applies: (1) restart-dependent (`[restart]` tag — e.g., config/hook changes needing reload), (2) external info gap (user must provide data, wait for a reply, or do research first), (3) orthogonal to current session (completely different topic/codebase area, no shared context). Complex user actions (multi-step or requires judgment/research) -> `[user action]`
- **🔴 Deferred** = cannot resolve now — needs more thought, reproduction, external deps, or real-world validation

**Bias rule**: when in doubt between 🟢 and 🟡, prefer 🟢. Context continuity from the current session is valuable; deferring has its own cost (context rebuild, user overhead).

Tags: `[restart]`, `[user action]`. May combine (e.g., `[restart] [user action]`). Within each tier, group by category (Skills / Config / Code...) only if >=3 items.

**Numbering**: Use sequential numbers (1, 2, 3...) that continue across all tiers (🟢→🟡→🔴). Do NOT restart numbering within each tier. This enables the user to reference items by number (e.g., "do 1, 3, 5").

## Formatting Rules

- Each item: one sentence + key file path in backticks (applies to all sections including Incomplete)
- Preserve file path format from session (including full OneDrive paths)
- Read-only report: do not modify files, memory, or task tracking

## Verification

After generating the report, use Glob to spot-check file paths exist on disk (paths with spaces, e.g., OneDrive paths, work correctly with the Glob tool). Annotate non-existent paths with `[path not found]`. (Glob verifies existence only, not session attribution; for git-tracked files, source 3 confirms modifications.)

**Self-review note**: this summary is generated by the same agent that performed the work. For independent review, use `/rus` or `---qc --sub`.

## Degradation Paths

| Failure | Behavior |
|---------|----------|
| TaskList unavailable or empty | Skip, proceed with other sources |
| Not a git repository | Skip git commands |
| Very short session (1-2 exchanges) | One-paragraph summary (see Output Format) |
| Context compressed (long session) | Prepend note per Output Format section |
| File records incomplete after compression | Note `[file records may be incomplete]` |
| No completed or incomplete work | Omit those sections |
| Bash unavailable | Skip git commands; proceed with other sources |
| Glob unavailable | Skip path verification |
| Read unavailable | Skip file state inspection; rely on conversation context and git diff |
| Grep unavailable | Skip pattern search; rely on conversation context |
