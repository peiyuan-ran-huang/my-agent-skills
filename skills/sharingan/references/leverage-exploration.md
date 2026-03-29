# Leverage Exploration Framework

> Loaded on-demand when LE activates. See SKILL.md § Leverage Exploration for workflow.

## Section A: 5 Opportunity Types

| Type | Definition | Trigger Question | Example |
|------|-----------|-----------------|---------|
| `SKILL` | New skill idea (standalone or extension) | "Could this inspire a new skill?" | R script self-verification skill |
| `TOOL` | New tool or MCP integration | "Could this become a reusable tool?" | Config-doctor health check tool |
| `FLOW` | New workflow pattern or process | "Could this reshape how we work?" | Plan persistence across sessions |
| `INFRA` | Infrastructure improvement (hooks, logging, scripts) | "Could this improve our foundation?" | Capability-gaps logging system |
| `ENHANCE` | Enhancement to existing skill/tool/workflow | "Could this make something existing better?" | Add mode to existing audit skill |

## Section B: Feasibility Matrix

Per opportunity, evaluate four dimensions:

| Dimension | Low | Medium | High |
|-----------|-----|--------|------|
| Complexity | Single file, <100 lines | Multi-file, <500 lines | Architecture change |
| Dependencies | None, existing tools | New reference files | New MCP/packages |
| Value/Effort | Nice-to-have | Regular use | Daily workflow impact |
| Maintenance | Zero after build | Occasional updates | Version-coupled |

> Maintenance is informational context for the proposal — it does not factor into verdict rules. High-maintenance opportunities may still qualify for Build Now if other dimensions are met.

### Verdict Rules

- **Build Now**: Complexity Low/Med + Dependencies None/Low/Med + Value ≥ Medium
- **Plan First**: Complexity High OR Dependencies High, but Value High
- **Incubate**: Value unclear, or dependencies not yet available
- **Skip**: Value Low AND Complexity High, or duplicates existing capability
- **Borderline** (dependency uncertainty only): When most dimensions qualify for Build Now but one dependency is uncertain (not clearly High), use **Build Now** with an explicit risk note listing the verification prerequisite. Do not default to Plan First solely due to uncertainty — quantify what needs verification. (In proposal output and Final Report, Borderline counts as Build Now.)

## Section C: Proposal Output Format

```
### Opportunity [N]: [Title]
- Type: [SKILL/TOOL/FLOW/INFRA/ENHANCE]
- Source inspiration: [specific section/idea from source]
- What it does: [2-3 sentences, accessible to non-CS user]
- How it maps to our ecosystem: [which existing files/skills/tools it connects to]
- Feasibility: [Build Now / Plan First / Incubate / Skip] (Borderline → display as Build Now)
  - Complexity: [Low/Med/High] — [1 sentence justification]
  - Dependencies: [list] — Risk: [verification prerequisite, if Borderline verdict; omit if not applicable]
  - Value/Effort: [assessment]
- Existing overlap: [any existing skill/tool that partially covers this? or "None"]
- Related ref: [ref_*.md created by RVA for the same insight, if any — or omit this line]
```

## Section D: ai-dev-idea-todo.md Integration Rules

- Read current file before proposing additions (avoid duplicates)
- Map verdict to section: Build Now/Borderline/Plan First → Part B "High Priority Ideas", Incubate → Part B "Ideas", Skip → not added (output only)
- If opportunity matches an existing entry (search both Part A and Part B) → enrich in-place, don't create Part B duplicate. Enrichment of Part A entries stays in Part A. Enrichments do not count toward the addition limit below.
- Hard limit: max 3 todo additions per invocation (enrichment of existing entries does not count as an addition)
- Format: Part A → `- **[Title]** — [description] | Status: [status]`; Part B → `- **[Title]** — [description] — [来源: <source>, <date>] | Status: [status]`
- User must approve before any writes (including enrichments of existing entries)
- If `ai-dev-idea-todo.md` not found (non-project context or file deleted): present proposals in output only, note `[LE-4: todo file not found — proposals displayed only]`. Do not create the file automatically.

## Section E: LE Anti-Bias Rules

- "No opportunities" is legitimate and often correct — do not inflate
- Opportunity must pass the **Build Test**: describable in 2-3 specific implementation sentences (not vague "could be useful")
- Config changes disguised as opportunities → redirect to main pipeline, not LE
- Existing ecosystem duplication check by opportunity type:
  - SKILL/ENHANCE: Grep `~/.claude/skills/` for similar functionality
  - TOOL/INFRA: also check `~/.claude/hooks/`, `~/.claude/scripts/`, and MCP config (`~/.mcp.json`)
  - FLOW: check `~/.claude/rules/` and CLAUDE.md workflow sections
  - Report overlap source explicitly in the "Existing overlap" field
- Max 5 opportunities per invocation; if >5 pass Build Test, select the 5 with highest Value/Effort
