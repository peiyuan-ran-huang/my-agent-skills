# Parameter Parsing Reference

## Syntax

```
---sharingan <source> [--target <category>] [--auto] [--dry-run] [--no-ref] [--explore] [--no-explore] [context...]
```

- `<source>` (required): the external resource to learn from
- `--target <category>`: force classification to a specific category (skip Phase 2)
- `--auto`: streamline Phase 7 — skip summary re-display, but still list target files and pause for user confirmation before execution (per security.md)
- `--dry-run`: execute Phase 1-6 only; output proposal but do not modify files
- `--no-ref`: skip Reference Value Assessment at EXIT POINTs
- `--explore`: force Leverage Exploration after main pipeline completes (no prompt)
- `--no-explore`: suppress Leverage Exploration prompt entirely
- `context...`: additional instructions/context after the source

## Source Detection Heuristic (by priority)

1. `https://github.com/<owner>/<repo>` with exactly 0 further path segments (trailing `/` ignored) → GitHub repo (clone)
2. Any other URL (`http://` or `https://`), including GitHub blob/tree/issue/PR/wiki/raw URLs → URL (web resource; use fetch, not clone)
3. Image extension (`.png`, `.jpg`, `.jpeg`, `.gif`, `.webp`, `.bmp`) → Screenshot
4. Existing file/dir path (verify with Read/LS) → Local file or directory
5. None of the above → treat as context text, prompt user to provide a source

## Path Handling

File paths containing spaces must be double-quoted. E.g., `---sharingan "C:\Users\<username>\OneDrive - <Organization>\notes.md"`. If an unquoted token contains both path separators and spaces, ask the user to re-invoke with quotes.

## No Source Provided

Prompt: "Please provide a source (URL, file path, or screenshot path). Sharingan cannot auto-detect external resources from session context."

## Error Handling

| Error | Action |
|-------|--------|
| Unknown flags | Abort, ask re-invoke with correct flags |
| Duplicate flags | Abort, ask user to clarify |
| `--target` without value | Prompt for category |
| `--target` with unknown category | Validate against taxonomy.md category list; if no match → abort, suggest valid categories |
| Multiple sources | Abort, ask for exactly one source |
| `--no-ref` with non-EXIT outcome | Ignored silently (flag only applies at EXIT POINTs) |
| `--explore` + `--no-explore` | Abort, ask user to clarify |
| `--no-ref --no-explore` | Only main pipeline runs (skip both RVA and LE) |
| `--dry-run --explore` | LE runs (LE-1 through LE-3) but LE-4 outputs proposed additions without executing writes |
| `--no-ref` (without `--no-explore`) | RVA skipped, LE prompt still appears (LE activation is independent of RVA) |

## `--dry-run` Termination

After Phase 6 QC passes, output proposal (Phase 5 format), then: `[DRY RUN] Proposal ready. Re-invoke without --dry-run to execute.` If `--explore` is set (or user responds Y to prompt), proceed to Leverage Exploration in read-only mode.
