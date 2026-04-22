---
description: "Quick critical self-review of Claude's last response — lightweight /qc alternative"
allowed-tools: ""
---
<!-- version: 1.4.0 (2026-04-20) — angle rotation (always-on) + 五问 mantra hard-gate (cond) + negative-assertion scope check (cond) + --N counterfactual iteration -->

# RUS — R U Sure?

## Arguments

- `/rus` — single-pass review (default; runs angle rotation + 3-dim check + conditional deep-checks once)
- `/rus --N` where N ∈ {2, 3, 4, 5} — run N independent counterfactual passes, then aggregate
- `/rus --1` — equivalent to bare `/rus` (single-pass; does not fire the counterfactual self-deception prompt)
- `/rus --0` or `--6+` or `--abc` or other malformed — print this syntax block and refuse to execute; for N>5 suggest upgrading to `---qc --loop --sub`
- **Arg format rule**: only `--<digit>` (e.g., `--3`) is accepted; positional `3` / single-dash `-3` / equals-form `--N=3` are malformed. Text following a valid `--N` (e.g., `/rus --3 side note`) is ignored as user annotation.

## What To Do

Re-read your last substantive response and critically examine it across three dimensions. A response is substantive if it contains reasoning, analysis, or recommendations; code blocks accompanied by explanation also qualify. Bare tool-call results, status messages, and raw unnarrated outputs are non-substantive.

1. **Correctness** — Are all facts, numbers, logic, and reasoning actually right? Would this survive fact-checking? (If the response contains factual assertions of specific types, run the Factual-assertion hard-gate below as a conditional deep-check.)
2. **Completeness** — Did you miss important caveats, edge cases, alternatives, or considerations the user should know?
3. **Confidence calibration** — Did you state anything with more certainty than warranted? Are there claims that should be hedged?

### Angle rotation (always-on, single-pass input lens)

Walk the response from three perspectives, letting each surface different weak spots:

- **用户视角** (user): Did this response actually answer the user's original question, or did it drift to an adjacent topic?
- **敌方评审视角** (adversarial reviewer): What's the strongest argument a skeptical reviewer would raise against this response? What would they catch first?
- **未来自己视角** (future self): If I reread this response in six months without conversation context, what claims would sound over-confident or under-supported?

Merge findings from all three perspectives into the three-dimension check above (Correctness / Completeness / Confidence calibration). Perspectives are audit *lenses*, not separate output sections. (Exception: under `/rus --N`, each pass records a brief `Perspective scan` bullet — see §Multi-pass Mode output template — so divergence in which lens surfaced what is visible for aggregation.)

### Factual-assertion hard-gate (Correctness conditional)

<!-- mirrors CLAUDE.md §Workflow five-question mantra; re-sync on CLAUDE.md changes -->

**Trigger**: the response contains a factual assertion of any of these types:

- PMID/DOI/citation claim
- Product / feature / config-key attribution ("this comes from X", "feature Y is provided by Z")
- Historical/empirical claim ("X happened in year Y", "study Z found W")
- Negative assertion ("X is not Y", "X does not exist", "feature F was never shipped")

**Run the five-question mantra** (operationalizing the five keywords from CLAUDE.md §Workflow factual-attribution hard gate — 候选 / 权威 / 便宜 / 独立 / 置信):

1. **候选** (candidates): What alternative answers exist besides the one claimed?
2. **权威** (authority): What is the first-party canonical source — Anthropic docs / PubMed / DOI / WHO ATC / target tool's official docs?
3. **便宜** (cheap check): What is the lowest-cost verification available right now (a single grep, a WebFetch, a single doc page)?
4. **独立** (independence): Is my verification path independent of the claim's own source?
5. **置信** (confidence): After the check, what is my calibrated confidence — and am I hedging appropriately?

If any of the five questions lacks a clean answer → **hedge the claim**, do not assert confidently. If the claim cannot be quickly verified → flag as an issue in Correctness.

**Additional scope-evidence check** — fires specifically when the response contains a **negative assertion in confident tone** (no hedging words like "appears", "seems", "likely", "as far as I can tell"). This is the **highest-risk combination** per `ref_real_time_attribution_detection.md`:

- Was my search space complete? (grep empty ≠ doesn't exist; file missing ≠ feature absent; "branch never runs" ≠ all code paths audited)
- Did I distinguish absence-of-evidence from evidence-of-absence?
- Is there a broader scope (other directories, other branches, other versions) I didn't check?
- Am I confusing the current state with the permanent state?

If any scope concern is unresolved → downgrade to hedged wording ("I didn't find X in Y"), do not assert "X does not exist".

### How to genuinely re-examine (not rubber-stamp)

- Re-read your response as if **a stranger wrote it and your job is to find problems**.
- For each factual claim: "How do I know this? Could I be confusing similar concepts?"
- For each recommendation: "What's the strongest argument against this?"
- If you used numbers, re-derive or re-check them step by step.
- Re-read the user's original question: did your response actually answer what was asked, or did it drift to an adjacent topic?

## Multi-pass Mode (`--N`)

When `--N` is present, execute N independent passes before aggregating. Each pass runs **all the primary logic**: angle rotation + three-dimension check + five-question mantra (if applicable per trigger conditions) + negative-assertion scope check (if applicable per trigger conditions).

**Each pass begins with this counterfactual self-deception prompt** (internal, not output):

> "This is Pass {k}/{N}. Pretend you have never seen Pass 1..{k-1}. Re-read the original response from scratch, ignore prior findings, run angle rotation + three-dimension check + 五问 mantra (if applicable per trigger conditions) + negative-assertion scope check (if applicable per trigger conditions) again from the user's original question. Do not reference prior conclusions; do not intentionally agree or disagree with them."

Each pass independently decides whether conditional triggers fire based on its own fresh read of the target — do not carry forward Pass (k-1)'s trigger-firing state into Pass k.

Pass k receives only: the user's original question + the target response text. Do **not** feed prior-pass verdicts into later passes. Aggregation happens only after all N passes complete.

**Independence is approximated, not enforced**: passes share Claude's context (prior passes are visible despite the "pretend unseen" instruction); effectiveness degrades with higher N. For genuine context isolation, see §Escalation (`---qc --loop --sub`).

### Aggregation rules (no auto-majority-vote)

Strategy A — strict conservative. Two layers, applied independently.

**Layer A — Per-dimension verdict**:

| N-pass outcome | Output |
|---|---|
| All N OK | "D: N/N OK" |
| All N issue, lists identical | unified issue list |
| All N issue, lists differ | show each pass's list separately |
| Mixed (any OK + any issue, including 2-vs-1) | show every pass's finding verbatim, no vote |

**Layer B — Complete corrected response** (each pass produces a complete rewrite if any dimension flagged; see output template below):

| N-pass outcome | Output |
|---|---|
| All OK | single "no issues" 2-3 sentence note (current `/rus` format) |
| All issue, near-identical rewrites | unified rewrite + "N/N convergence" note |
| All issue, materially differing rewrites | **Option 1..N side-by-side**, no auto-merge |
| Mixed | each OK-pass confirmation (= its dimension verdicts without a corrected response) + each issue-pass rewrite verbatim |

**Near-identical test** (Layer B tiebreaker, err conservative): two or more pass rewrites count as near-identical only if they differ purely in paraphrase, word-ordering, or cosmetic formatting of the **same substantive edits** → unified. Any substantive difference (different claim hedged, different fact corrected, different caveat added, different scope of rewrite) → divergent, show separately per "All issue, materially differing rewrites" branch. Err toward showing the user more options than fewer.

**Why forbidden to majority-vote**: N "independent" passes aggregated as majority gives a false sense of objectivity. The divergence is the finding — tell the user, let them decide.

## Output

### Single-pass (`/rus`)

**Issues found** →

1. Briefly list each issue (what's wrong/incomplete, and why) — keep this concise. Conditional deep-check findings (五问 / scope-evidence) surface **inline within the Correctness bullet**, not as separate top-level sections.
2. Then output the **complete corrected response** that replaces your previous one. The user should be able to read this single block as the final answer without referring back to the original. Preserve all correct parts verbatim; only change what needs fixing.

**No issues found** → State which 1-2 areas carried the most uncertainty during re-examination and why they held up, or note what could not be independently verified. 2-3 sentences max.

### Multi-pass (`/rus --N`)

```
## /rus --N Self-Review

### Pass k (k=1..N)
- Perspective scan: [brief user / adversarial / future notes]
- Correctness: [OK / issues: ...] (五问 + scope-evidence inline where triggered)
- Completeness: [OK / issues: ...]
- Confidence calibration: [OK / issues: ...]
- **Pass k corrected response** (if any dimension flagged): [complete rewritten response]

### Convergence Analysis (Layer A)
- Correctness / Completeness / Confidence: [per-dimension X/N verdicts]

### Final Output (Layer B — per A strategy)
[(a) all OK → single note; (b) all issue near-identical → unified; (c) all issue divergent → Option 1..N; (d) mixed → each verbatim]
```

If the previous response is no longer in context, review the most recent substantive content available and note what could not be reviewed. If the context contains only non-substantive content (bare tool outputs, status messages), or no content exists at all, state that there is nothing to review.

No structured report. No severity labels. No templates beyond the multi-pass block above. Just corrections or confirmation (single-pass) / per-pass verdicts + aggregated final response (multi-pass).

## Escalation

For high-stakes content where self-review bias is the dominant concern → use `---qc --sub` (or `---qc --loop --sub` for consecutive-pass loop) for a full structured review with an isolated subagent counterfactual. `/rus --N` runs N passes in the same context (counterfactual-prompt approximation); `---qc --sub` provides actual context isolation via a physically separate subagent.
