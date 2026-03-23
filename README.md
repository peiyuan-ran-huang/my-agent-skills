# my-agent-skills

Reusable AI agent skills for Claude Code, synced across devices.

## Structure

```
skills/
  <skill-name>/
    SKILL.md      ← skill prompt template (EN, primary)
    SKILL_ZH.md   ← Chinese translation (reference only)
```

## First-time setup (new device)

```bash
git clone https://github.com/peiyuan-ran-huang/my-agent-skills.git ~/my-agent-skills
bash ~/my-agent-skills/sync.sh
```

## Update (existing device)

```bash
bash ~/my-agent-skills/sync.sh
```

## Skills

| Skill | Trigger | Description |
|-------|---------|-------------|
| qc | `---qc [object] [criteria] [--loop [N]] [--sub]` | Five-dimensional QC review (correctness / completeness / optimality / consistency / standards). Supports loop mode and subagent counterfactual. EN + ZH bilingual. |
| audit | `---audit [target] [--focus X] [--out path] [--lang zh/en] [--lite]` | Multi-round deep audit with parallel subagents across 3 phases: plan → dispatch → merge. Supports focus areas, output path, language override, and lite mode. EN + ZH bilingual. |
