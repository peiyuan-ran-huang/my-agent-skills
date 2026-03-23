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

Current operating rule:

- If a reviewer finds a concrete issue that is already represented above, update the existing row instead of creating a new ID.
- Only create a new ledger ID when the issue is genuinely distinct.
