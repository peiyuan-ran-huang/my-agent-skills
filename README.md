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
| qc | `---qc [target] [criteria] [--loop [N]] [--sub]` | Five-dimensional QC review (correctness / completeness / optimality / consistency / standards). Supports loop mode and subagent counterfactual. EN + ZH bilingual. |
| audit | `---audit [target] [--focus X] [--out path] [--lang zh/en] [--lite]` | Multi-round deep audit with parallel subagents across 3 phases: plan → dispatch → merge. Supports focus areas, output path, language override, and lite mode. EN + ZH bilingual. |
| sharingan | `---sharingan <source> [--target <cat>] [--auto] [--dry-run] [--no-ref]` | Self-optimization via external resources. 10-phase workflow to extract insights from URLs, repos, or local files and apply them to Claude Code config. Dual EXIT POINTs, built-in QC, security preflight. EN + ZH bilingual. |
