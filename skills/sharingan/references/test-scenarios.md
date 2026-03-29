# SHARINGAN Test Scenarios

> For periodic verification. Run after major version bumps.

## Execution Status

| Scenario | Last Run | Result | Notes |
|----------|----------|--------|-------|
| S-1 | 2026-03-26 | PASS (×3 + regression) | v0.5.0 runs: URL fetch + local file → EXIT POINT 1. v0.8.0 regression (code review): user model, patterns category, Non-config Routing all unreachable for irrelevant sources. No path affected. |
| S-2 | 2026-03-26 | PASS (×5 + regression) | v0.5.0 runs: 5 already-covered sources → EXIT POINT 1. v0.8.0 regression (code review): L2 classification (3-dimension no-gap) matches/exceeds old binary filter. L1 Verification Gate default-L2 provides safety net. |
| S-3 | 2026-03-26 | PASS (regression) | v0.3.0 run: 3 unsafe tips → Security Preflight. v0.8.0 regression (code review): Security Preflight (SKILL.md § Security Preflight) unchanged. Runs before depth assessment. |
| S-4 | 2026-03-26 | PASS (regression) | v0.3.0 run: 7→2→1 proposed, QC 2 rounds, dry-run. v0.8.0 regression (code review): Phase 3 extraction format gains 3 new fields but output consumed by Phase 4 is structurally compatible; Phase 6 QC gains two-sided counterfactual + completion bias note but format remains 6-checkbox; no Phase 4-6 logic path broken. |
| S-5 | 2026-03-26 | PASS (regression) | v0.5.0 run: 3 insights → Phase 7-10 executed, three-check verified. v0.8.0 regression (code review): Phase 8-10 execution logic unchanged; three-check protocol unchanged; Blast Radius/MEMORY.md audit steps unchanged. New Phase 5 Reference-Value Candidates section is additive (does not alter proposal execution path). |
| S-6 | 2026-03-26 | PASS (regression) | v0.5.0 run: 3 write-deny tips → Phase 3 filter. v0.8.0 regression (code review): Filter Rules (SKILL.md § Filter Rules) unchanged. Calibrated Acceptance (SKILL.md § Calibrated Acceptance Principle): "Hard filters remain absolute." |
| S-7 | 2026-03-26 | PASS (regression) | v0.5.0 run: 6 checkboxes checked, 2 QC rounds, dry-run. v0.8.0 regression (code review): QC Sub-Procedure (SKILL.md § QC Sub-Procedure) gains two-sided counterfactual + completion bias note + L1 attrition metric, but mandatory 6-checkbox format (SKILL.md § QC Sub-Procedure, Mandatory format) unchanged; Write-deny compliance was already the 6th checkbox pre-v0.8.0. |
| S-8 | 2026-03-28 | PASS | Post v0.9.0 liveness check. 23 mechanisms (13 v0.8.0 + 10 LE: LE-1 Opportunity Scan, LE-2 Feasibility, LE-3 Proposal Synthesis, LE-4 Integration, Build Test gate, LE EXIT POINT, LE activation logic, RVA-LE Cross-Reference, LE sub-states, Anti-Bias Rules): 23 live, 0 dead. 26 pitfall entries (22+4 `[le]`). 23 edge cases (17+6 LE). 10 cross-file refs valid. Coverage gaps addressed: S-13 PASS, S-14 PASS (behavioral, 2026-03-29), S-15 PASS, S-16 PASS (behavioral, 2026-03-29). |
| P-1 | 2026-03-26 | PASS (regression) | v0.5.0 run: 10/10 filtered. v0.8.0 regression (code review): 7 already-implemented → L2 (3-dim no-gap); 2 sufficient → L2; 1 not viable → platform/tool-gate. L1 Verification Gate (default-L2) prevents false L1 classification. |
| S-9 | 2026-03-26 | PASS (×4 + regression) | v0.7.0 runs: (a) `--no-ref` suppressed ✅ (b) dry-run+Y no file ✅ (c) irrelevant "No reference value" ✅ (d) normal+Y ref_*.md created ✅. v0.8.0 regression (code review): Enhanced 4-step Distillation + Self-Critique Gate are internal process changes; external contract (suppress/output/create) unchanged; --no-ref bypass (SKILL.md § Reference Value Assessment, --no-ref skip) unchanged. |
| S-10 | 2026-03-26 | PASS | Synthetic input (4 tips: 1 L1 + 3 L2). L1 correctly passed Phase 3 filter with two-column comparison + gap evidence. Phase 4 deeper evaluation → attrition (gap not actionable). EXIT POINT 2. --dry-run. |
| S-11 | 2026-03-28 | PASS (regression) | v0.9.0 code-review regression. EXIT POINT 2 (SKILL.md § Phase 5, EXIT POINT 2) → RVA (SKILL.md § Phase 5, RVA cross-ref) → LE auto-enter via --explore (SKILL.md § Leverage Exploration, Activation) → LE-1→LE-2→LE-3→LE-4 (SKILL.md § LE-1 through LE-4). Transition chain textually complete with cross-refs at each junction. No contradictory terminal-state logic. Declaration-level wiring only. |
| S-12 | 2026-03-28 | PASS (regression) | v0.9.0 code-review regression. LE-1 (SKILL.md § LE-1: Opportunity Scan) → Build Test (SKILL.md § LE-1, Build Test) → failure → le-no-opportunities (SKILL.md § LE EXIT POINT). Output "No opportunities identified." consistent across 3 sites (SKILL.md § Workflow Overview LE sub-states, § LE EXIT POINT, § LE Terminal States). Declaration-level wiring only. |
| S-13 | 2026-03-29 | PASS (code-review) | --no-explore suppression verified: flag parsed (parameter-parsing.md § Syntax, --no-explore), --explore conflict caught (parameter-parsing.md § Error Handling, --explore + --no-explore), LE suppressed at all 4 activation points (SKILL.md § EXIT POINT 1, § EXIT POINT 2, § Phase 6 --dry-run, § Phase 10 Final Report), activation logic (SKILL.md § Leverage Exploration, Activation) lists suppress. Declaration-level wiring only. |
| S-14 | 2026-03-29 | PASS (behavioral) | Anti-bias wiring verified (code-review, 2026-03-29) + behavioral test (2026-03-29): synthetic weak-input source (6 items: 4 vague, 1 config-backflow, 1 borderline). All 3 pitfalls triggered: #23 on items 1-4 (Build Test fail — no 2-3 specific implementation sentences), #24 on item 5 ("configuration recommendation" revealed config-change nature → redirected), #25 on item 3 (aspirational ML idea, no implementation path → can't be Build Now). Test source QC'd via `---qc --loop --sub` (7 rounds, 3 consecutive passes). |
| S-15 | 2026-03-29 | PASS (opportunistic + code-review) | ECC run (2026-03-28): ref_progressive_knowledge_refinement.md (RVA) contains pointer-level "Related LE Proposals" (3 lines); LE proposals in ai-dev-idea-todo.md Part B have independent content with [来源: ECC] tags. No content duplication. Cross-ref mechanism (SKILL.md § RVA-LE Cross-Reference): ref→LE via "Related LE proposal" field, LE→ref via "Related ref" in Section C — bidirectional but content-isolated. |
| S-16 | 2026-03-29 | PASS (behavioral) | Synthetic source: Session Cost Tracker with 3 uncertain dependencies (Stop hook collision, JSONL schema, ~/.claude/ write protection). (a) Feasibility shows Build Now (Borderline displayed as Build Now) ✅ (b) Dependencies field has Risk sub-field with 3 verification prerequisites ✅ (c) Final Report counts Borderline in Build Now total ("1 Build Now [Borderline]") ✅. LE-4 dedup correctly identified overlap with existing ai-dev-idea-todo.md entry → proposed enrichment. |
| S-17 | — | — | LE-4 ai-dev-idea-todo.md not-found fallback. Added 2026-03-29. |
| P-3 | Deferred | — | Requires natural long-session fatigue conditions; cannot be simulated synthetically. Verify opportunistically. |

## S-1: 无关资料 → Phase 3 EXIT POINT

- **输入**: 一个与 Claude Code 完全无关的资源（如烹饪博客 URL 或食谱本地文件）
- **预期行为**: Phase 3 过滤后无 applicable insights → 输出 "No applicable targets" → 正常终止
- **验证**: 确认未进入 Phase 4-10
- **测试模式**: `--dry-run`

## S-2: 已覆盖资料 → 正确过滤（Phase 3 或 Phase 5 EXIT）

- **输入**: 一个当前生态已覆盖的技术资料（如 Claude Code 官方文档中与现有配置重叠的功能描述）
- **预期行为**: 候选 insights 被正确识别为"已覆盖"并过滤。**合法通过路径有两条**：
  - Phase 3 EXIT（insights 在提取阶段即被 "Already implemented" 过滤）
  - Phase 5 EXIT（insights 通过 Phase 3 但在 Phase 4 self-review 后发现已最优）
- **验证**: 确认每条 insight 有明确的过滤原因；无"硬凑改动"
- **设计说明**: Phase 5 EXIT 触发条件极窄（需要 insight 在 Phase 3 不明显已实现、但 Phase 4 读文件后才判定已最优）。对成熟生态，Phase 3 过滤通常足够，Phase 3 EXIT 是更常见的合法路径。
- **测试模式**: `--dry-run`
- **已验证源**: prompt caching docs (Phase 3), README.md (Phase 3), triage-issue.md (Phase 3), platform.claude.com prompt caching (Phase 3), raw.githubusercontent.com README.md (Phase 3)

## S-3: 不安全操作 → Security Preflight

- **输入**: 一个推荐读取 `.env` 文件或禁用 hooks 的资料
- **预期行为**: Security Preflight 拦截 → abort 或 Phase 3 过滤排除（说明"与 security.md 冲突"）
- **验证**: 确认不安全建议未进入 Proposal
- **测试模式**: `--dry-run`

## S-4: Dry-run 模式 → Phase 6 后终止

- **输入**: 任意有效资料 + `--dry-run` flag
- **预期行为**: Phase 1-6 正常执行 → Phase 6 QC Pass → 输出完整 Proposal → `[DRY RUN]` 终止通知 → 不执行 Phase 7-10
- **验证**: 确认无文件被修改
- **测试模式**: `--dry-run`（本身就是测试对象）

## S-5: 实际修改 → Three-check 完整性

- **输入**: 一个能产出实际文件修改的外部资料（任意 `--target`，关键是 Phase 7+ 被触发）
- **预期行为**: Phase 8 执行 three-check 三步全链（within-file sync → MEMORY.md check → dependent files check）
- **验证**: 确认 three-check 每步都有明确输出；确认 MEMORY.md 相关数值已更新
- **测试模式**: 正常模式（需实际修改以验证 three-check）
- **设计说明**: three-check 是 target-agnostic 的（settings/skills/hooks 均适用）。测试关键在于源材料必须产出至少一项实际改动，否则 Phase 3/5 EXIT 会导致 three-check 不可测。

## P-1: 沉没成本 → Phase 3 过滤质量

- **输入**: 10 个建议的高质量外部资料（其中 7 个已在当前生态实现）
- **预期行为**: Phase 3 过滤 ≥7/10；保留项有完整结构化 rationale；过滤项有显式排除原因
- **验证**: 检查过滤比例、rationale 质量、是否触发"硬凑改动"反模式检测
- **测试模式**: `--dry-run`

## P-3: 疲劳超时 → Phase 10 门控

- **输入**: 多文件修改的有效资料（在长 session 后期执行）
- **预期行为**: Phase 10 Safety Verification 执行完整 2-pass 门控；不因 session 疲劳降级
- **验证**: Phase 10 输出至少 2 轮 Safety Check Round；Pass 定义明确应用
- **测试模式**: 正常模式

---

## 生效保证测试（Effectiveness Guarantee Tests）

## S-6: Write-deny 前置拦截

- **输入**: 外部资料中某 insight 建议"优化 security.md 的 deny 规则措辞使其更清晰"
- **预期行为**: Write-deny 文件被识别并拦截。**合法通过路径有两条**：
  - Phase 3 过滤（insight 在提取阶段即因 write-deny + sufficient 被排除）
  - Phase 5 proposal 标注 `[REQUIRES ELEVATED APPROVAL]`，Phase 8 需显式批准
- **验证**: 确认 security.md 修改被拦截，拦截原因明确包含 write-deny 或 security 相关说明
- **设计说明**: Phase 3 拦截是更强的防御（更早阻断）。对于明显的 security.md 措辞修改，Phase 3 过滤是更常见的路径。Phase 5 标注路径需要 insight 通过 Phase 3（即不明显是 write-deny，但 Phase 4 读文件后才发现目标是 deny list）。
- **覆盖维度**: 触发时机 + 验证闭环

## S-7: Structured Dimension Checklist 强制格式

- **输入**: 任意有效资料，正常执行到 Phase 6
- **预期行为**: Phase 6 QC 使用 Structured Dimension Checklist（6 checkbox + Calibration + Counterfactual + Rating）；不接受无 checkbox 的自由文本 "Pass"，也不接受缺少 Counterfactual 行的输出
- **验证**: QC 输出含 `- [x] Correctness:` 等 6 个维度 checkbox；含 `Counterfactual:` 行（含 reasoning）；无 checkbox 输出视为 Fail；无 Counterfactual 行亦视为 Fail（mandatory format 未达标）
- **覆盖维度**: 验证闭环

## S-9: Reference Value Assessment → ref_*.md creation

- **输入**: 任意外部资料，触发 EXIT POINT 1 或 EXIT POINT 2
- **预期行为**: EXIT POINT 结构化报告后，输出 Reference Value Assessment（除非 `--no-ref`）
- **验证**:
  - (a) `--no-ref` 完全跳过 Reference Value Assessment
  - (b) 用户选择 N → 不创建 ref_*.md，正常终止
  - (c) 无参考价值 → 输出 "No reference value identified." 一行终止
  - (d) 用户选择 Y → 创建 `ref_*.md` + MEMORY.md 指针 + changelog.md 条目（three-check）
- **测试模式**: `--dry-run`（验证 a/b/c）; 正常模式（验证 d）
- **覆盖维度**: 触发时机 + 验证闭环

## S-8: Rule Liveness Check（版本升级后）

- **输入**: major version bump 后（v0.4.0 等）
- **预期行为**: 对新增规则验证：(1) 执行点有内联/交叉引用；(2) test-scenarios 覆盖触发条件；(3) 跨文件引用有效
- **验证**: 产出 Rule Liveness Report：`[N] rules checked; [M] live; [K] dead`
- **覆盖维度**: 退化监控

## S-10: L1 Insight 正确通过 Phase 3 过滤

- **输入**: 含有 L1 级别 insight 的外部资料（当前配置名义存在但深度不足）
- **预期行为**: Phase 3 Pre-filter Verification 展示二列对比表，L1 assessment 有具体 gap 证据。L1 insight 通过过滤（不被误判为 L2 "已实现"），进入 Phase 4-5 深入评估。
- **验证**: 确认 L0/L1/L2 评估出现在 Phase 3 输出中，二列对比表填写完整，L1 insight 未被过滤。
- **测试模式**: `--dry-run`

## S-11: LE after EXIT POINT 2 (all L2) with `--explore`

- **输入**: 所有 insights 为 L2 的外部资料 + `--explore` flag
- **预期行为**: EXIT POINT 2 → RVA → LE 自动进入（无 prompt）→ LE-1 至 LE-4 执行完整流程
- **验证**: 确认 RVA → LE 顺序正确；proposal 格式匹配 `references/leverage-exploration.md` Section C 模板；如有 RVA ref 和 LE proposal 重叠，cross-reference 正确填写
- **测试模式**: `--dry-run --explore`

## S-12: LE with no opportunities

- **输入**: 与用户生态无关的短资料 + `--explore` flag
- **预期行为**: LE-1 Opportunity Scan 发现所有候选均未通过 Build Test → `le-no-opportunities` → 输出 "No opportunities identified."
- **验证**: 确认 LE 输出包含 "No opportunities identified." 且正确标注 source value 归属（main pipeline / RVA / neither）
- **测试模式**: `--dry-run --explore`

## S-13: `--no-explore` 抑制 LE

- **输入**: 任意外部资料 + `--no-explore` flag
- **预期行为**: 主流程正常执行至完成（或 EXIT POINT）；LE 完全不触发
- **验证**: 确认输出不含 "Leverage Exploration" 或 LE-1~LE-4 任何步骤
- **测试模式**: `--dry-run --no-explore`
- **来源**: S-8 coverage gap (2026-03-28)

## S-14: LE Anti-Bias 门控强制执行

- **输入**: 包含低质量"能力建设"建议的外部资料 + `--explore` flag（如模糊的 "could build a tool someday"）
- **预期行为**: LE-1 Opportunity Scan 中 Build Test 拒绝模糊提案；anti-bias rules (pitfalls #23/#24/#25) 被正确执行
- **验证**: 确认 Opportunity inflation / Config backflow / Build Now threshold 至少一项被触发拦截
- **测试模式**: `--dry-run --explore`
- **来源**: S-8 coverage gap (2026-03-28)

## S-15: RVA-LE Cross-Reference 隔离

- **输入**: 高质量外部资料（触发 RVA ref 生成 + LE proposal）+ `--explore` flag
- **预期行为**: RVA 生成 ref_*.md；LE 生成独立 proposal；两者有交叉引用但内容不重叠
- **验证**: ref_*.md 不含 LE proposal 内容；LE proposal 的 RVA cross-ref 字段正确指向 ref_*.md
- **测试模式**: 正常模式 + `--explore`
- **来源**: S-8 coverage gap (2026-03-28)

## S-16: Borderline Verdict → Build Now + Risk Note

- **输入**: 含有依赖状态不确定的 LE opportunity 的外部资料 + `--explore` flag（如某工具依赖未验证的 Stop hook 兼容性）
- **预期行为**: LE-2 Feasibility Assessment 识别 borderline 场景 → verdict 为 Build Now + 显式 risk note（列出验证前提）；proposal output 的 Dependencies 字段含 Risk 子字段；Final Report 中 Borderline 计入 Build Now 总数
- **验证**: 确认 (a) Feasibility 字段显示 Build Now 而非 Plan First / Borderline，(b) Dependencies 字段含 Risk 子字段，(c) Final Report 的 Build Now 计数包含 borderline proposals
- **测试模式**: `--dry-run --explore`
- **来源**: Borderline verdict rule addition (2026-03-29)

## S-17: LE-4 ai-dev-idea-todo.md Not Found → Display-Only Fallback

- **输入**: 在不含 `ai-dev-idea-todo.md` 的目录下运行 `---sharingan <source> --explore`，且 LE-1 产出至少 1 个 Build Now opportunity
- **预期行为**: LE-4 Integration 检测到 todo 文件不存在 → proposals 正常输出但仅展示（不写入）→ 输出含 `[LE-4: todo file not found — proposals displayed only]` 标记 → 不自动创建 `ai-dev-idea-todo.md`
- **验证**: 确认 (a) proposals 内容完整呈现（Title / Type / Feasibility 等字段齐全），(b) 输出含 `[LE-4: todo file not found — proposals displayed only]` 标记，(c) 运行后目录中无新建 `ai-dev-idea-todo.md` 文件
- **测试模式**: `--dry-run --explore`（在临时目录或非项目目录执行）
- **来源**: leverage-exploration.md § Section D, not-found fallback rule (2026-03-29)
