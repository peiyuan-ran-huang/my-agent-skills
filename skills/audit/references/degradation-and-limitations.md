<!-- Degradation and limitations reference. -->

# Degradation And Limitations

This file is the canonical source for failure handling, degradation paths, context-pressure guidance, and platform limitations in this `audit` skill.

The parent `SKILL.md` must still retain the corresponding hard summaries for:
- degradation-policy existence
- key fallback boundaries
- platform constraints that materially affect execution

This file is not the source of truth for normal planning, dispatch, merge, or template structure. It only governs what to do when those paths degrade, fail, or hit platform constraints.

## Failure Handling

| Failure Type | Handling |
|--------------|----------|
| Subagent timeout or crash | The orchestrator retries once using a new subagent with the same prompt. |
| Retry still fails | Note in the report: `⚠️ R[k] incomplete due to subagent error`. |
| Temp file not generated | Treat as failure and handle as above. |
| Temp file incomplete | Retain existing content and note `⚠️ R[k] may be incomplete`. |
| First batch `>=50%` failure, including all-fail | Degrade to **sequential execution mode**. Automatically switch to `--lite` limits with max 4 big rounds. Retain any successful subagent results and supplement with sequential rounds for the remaining themes. Select the 4 themes using the Phase 0 priority order: `--focus` themes first, then list order. Note in the report: `Degraded to sequential mode. ⚠️ Big round independence downgraded to protocol-level (not architecture-guaranteed); audit result reliability may be reduced`. During sequential fallback, follow the subagent template's D/V protocol, write to temp files using the same 9-field format, use the same tool list, and clear prior big round findings at the start of each new sequential big round. Clearing protocol: output a separator `=== New sequential big round: [theme] — prior findings cleared ===` and reference only audit target files during D rounds, without reading or referencing prior big round temp files. |
| Orchestrator context exhaustion during merge | Immediately write a partial report containing completed merges, skip remaining deduplication and numbering, note `⚠️ Merge interrupted due to context limits; see temp files for unprocessed rounds: [list paths]`, and do not delete temp files. |
| Non-first batch subagents all fail | Mark all big rounds in that batch as incomplete, generate a partial report based on existing batch results, and note `Batch [b] incomplete`. |

### Partial Report Output Contract

When a degradation path writes a partial report instead of a normal successful final report:
- write a distinct degraded output, not the normal success report
- use the fixed degraded header `# AUDIT Partial Report`
- include the fixed metadata lines:
  - `**Audit Target**: [name/path]`
  - `**Target Type**: [Paper / Code / Plan / Data Analysis / Mixed (note primary + secondary type)]`
  - `**Completion Status**: Partial report due to degradation`
  - `**Completed Big Rounds**: [list]`
  - `**Incomplete Big Rounds**: [list]`
  - `**Retained Temp Files**: [list paths / None]`
  - `**Interruption Note**: [canonical degradation note]`
- include only the successfully completed or successfully merged material available at interruption time
- do not claim full deduplication, full numbering, or clean completion when the degraded path interrupted those steps
- always surface the partial-report path explicitly in the conversation rather than letting the run look like clean completion
- use the fixed degraded conversation summary:

```text
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
AUDIT Partial Report
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Completed Big Rounds: [list]
Incomplete Big Rounds: [list]
Partial Report Path: [path]
Retained Temp Files: [list paths / None]
Next Action: Manual follow-up required before trusting audit completeness
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Output Verification Warning Contract

If final report write succeeds but post-write readback fails:
- retain temp files
- do not emit the success summary `AUDIT Complete`
- emit the fixed warning summary:

```text
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
AUDIT Output Verification Warning
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Report Path: [path or main path (+ appendix path)]
Retained Temp Files: [list paths]
Manual Check: Readback failed; verify written outputs manually before trusting completion
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## MCP And Tool Availability

### Subagent MCP Unavailable

If subagent MCP is unavailable:
- Phase 0 planning announces the limitation.
- Phase 1 binds the MCP-free tool-table variant within `templates/subagent-template.md`.
- Phase 2 performs the orchestrator-side supplement protocol for issues marked `could not verify`.

This file defines the degradation classification. The concrete normal-path supplement steps remain in `references/phase-2-merge.md`.

### Tool Failure Inside A Subagent

If a tool call fails or returns no results:
- mark the issue as `could not verify`
- do not fabricate verification conclusions

The detailed execution wording remains in `templates/subagent-template.md`.

### Configuration Check Script Failure

If the configuration check script errors during Phase 0:
- skip configuration check
- explain that the script encountered an error
- proceed with planning

If stdout exists but no `STATUS:` line is present:
- display the raw script output
- flag the anomaly

The step-by-step planning behaviour remains in `references/phase-0-planning.md`.

## Context Pressure Guidance

### Orchestrator Context Pressure

The subagent architecture inherently mitigates context overflow risk because each big round runs in an independent subagent.

However, if:
- the number of big rounds is `>=6`, or
- the audit target is large

then the orchestrator merge phase may still face context pressure.

Recommendation:
- run with Context Mode MCP enabled when available

### Subagent Context Pressure

Subagent-side D3-plus segmented reading behaviour belongs to `templates/subagent-template.md`, not this file.

## Known Platform Limitations

- **Subagent model**: Explicitly specify `model: "opus"` in every Agent call. Default model inheritance behaviour is inconsistently documented across sources: some tool definitions imply parent inheritance, while external documentation suggests a default Sonnet behaviour. Explicit specification eliminates this ambiguity.
- **Reasoning effort**: Phase 0.0 operates in detect-and-guide mode and does not apply configuration optimisation at audit start. Users who want maximum reasoning depth should configure `settings.json` before launching the session. Whether subagents inherit effort settings has no official documentation guarantee. This is a platform limitation, not something the skill can fully control. Audit quality is primarily ensured through multi-round D/V cycles and tool-assisted verification, not solely through single-pass reasoning depth.
- **Environment variable fallback**: Not currently used. The Agent tool's `model: "opus"` parameter is the sole mechanism for specifying the subagent model. If future platform versions introduce environment-variable overrides, this section should be updated.
- **settings.json hot-reload limitation**: `effortLevel`, `fastMode`, `alwaysThinkingEnabled`, and `model` are cached at session start. Modifications to `~/.claude/settings.json` after a session has started have no effect on the running session. The `ConfigChange` hook fires on file-system notification only, not runtime reload. Relevant issue trail: `#30726`, `#13532`, `#10623`, `#22679`. This is why Phase 0.0 uses detect-and-guide mode rather than auto-modification; to run the audit at optimal settings, modify the config file and restart the session before triggering `---audit`.
- **Fresh-session quoted OneDrive paper-path limitation**: Some fresh sessions may still rewrite a quoted OneDrive-style paper target path to an existing prefix directory even after the mandatory helper-parser plus parse-preflight flow. Treat that as a live entry/adherence limitation, not as permission to weaken the quote-aware parsing contract. If this occurs, disclose it explicitly and mitigate by staging the paper at a no-space temp path or by materialising the content into `audit_object_temp.md`; do not claim the direct quoted-path branch succeeded.
