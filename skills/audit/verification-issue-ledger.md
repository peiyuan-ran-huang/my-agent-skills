# Verification Issue Ledger

Use this ledger during concentrated maintenance cycles.

Purpose:

- give concrete findings stable IDs
- avoid resetting clean counts because the same issue was rediscovered with different wording
- keep a short history of what was fixed and why

Status values:

- `open`
- `recheck`
- `resolved`
- `stale`

Severity values:

- `blocker`
- `warning`
- `info`

| ID | Severity | Status | Zone | Lane | First Seen | Last Checked | Summary | Primary Files | Resolution / Notes |
|---|---|---|---|---|---|---|---|---|---|
| V-YYYYMMDD-001 | warning | open | yellow | calibration | YYYY-MM-DD | YYYY-MM-DD | _(example)_ A checker literal drifted after a source file was updated but the corresponding checker entry was not synchronized. | `scripts/audit-self-check.sh`, `SKILL.md` | _(example)_ Updated the checker literal to match the new source text. |
| V-20260323-001 | warning | resolved | yellow | calibration | 2026-03-23 | 2026-03-24 | Zero-discovery cross-round table omission: `phase-2-merge.md` / `report-template.md` did not explicitly require the empty `| Issue | Source | Explanation |` table when `### Cross-Round Independent Discoveries` has 0 findings, causing `validate-report.sh` failures on smoke reports. | `references/phase-2-merge.md`, `templates/report-template.md`, `README.md` | Fixed: `phase-2-merge.md` §2.4 now has explicit zero-discovery row requirement (line 84); `report-template.md` lines 114-118 define the zero-discovery variant; goldens updated. README "pending resolution" note updated to resolved. |
| V-20260323-002 | info | resolved | yellow | operational | 2026-03-23 | 2026-03-24 | Parallel smoke temp-file contention: when multiple audit runs execute concurrently (e.g., batch smoke via Agent tool), temp files using the default `audit_R[k]_temp.md` naming can collide across runs. | `templates/subagent-template.md`, `references/phase-1-dispatch.md` | Fixed: collision-prevention guidance added to `phase-1-dispatch.md` §1.4 (orchestrator-facing, alongside path contract at line 93); `subagent-template.md` line 28 retained as subagent-facing context. Enforcement remains protocol-level (LLM compliance with guidance); no runtime guard. Single audit runs unaffected. |

Current operating rule:

- If a reviewer finds a concrete issue that is already represented above, update the existing row instead of creating a new ID.
- Only create a new ledger ID when the issue is genuinely distinct.
