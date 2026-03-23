# SHARINGAN Taxonomy: 分类体系参考

> 本文件供 Phase 2 (Classification) 使用。SKILL.md 中有类别概要表，此处提供每类别的详细说明。

## Categories

### `global-instructions`
- **Target**: `~/.claude/CLAUDE.md`
- **典型 insights**: workflow 规则、output style 偏好、全局行为约束
- **审查要点**: CLAUDE.md 极简（目前 ~34 行），新增内容必须足够重要；避免与 rules/ 重复
- **Three-check**: 被 MEMORY.md "Operational Notes" 引用；被所有 session 加载

### `rules`
- **Target**: `~/.claude/rules/*` (all rule files; includes `.md` rules and supporting files like `.R` examples)
- **典型 insights**: 新的学术写作规范、安全策略、代码风格规则
- **审查要点**: 检查是否与现有 rule 文件重复或冲突；security.md 修改需额外谨慎
- **Three-check**: 被 CLAUDE.md 引用路径；被 MEMORY.md 间接引用

### `memory`
- **Target**: `~/.claude/projects/<project>/memory/*`（MEMORY.md + topic files）
- **典型 insights**: 新的操作经验、工具使用教训、配置变更记录
- **审查要点**: MEMORY.md 150 行软上限（140+ 时警告）；lessons.md 仅收录高复发/高代价问题
- **Three-check**: MEMORY.md 是全局索引文件，改动影响所有 session

### `settings`
- **Target**: `~/.claude/settings.json`, `~/.claude/settings.local.json`
- **典型 insights**: 权限规则优化、hook 配置、plugin 管理
- **审查要点**: mid-session 修改无效（settings 缓存）；allow list 自动增长需周期清理
- **Three-check**: 被 MEMORY.md "Plugin Ecosystem" 引用数值

### `hooks`
- **Target**: `~/.claude/hooks/*.sh`
- **典型 insights**: 新的安全防护 hook、自动化 hook
- **审查要点**: hook 冲突风险（lessons.md §4）；执行顺序不可控；hook 平均耗时 ~694ms
- **Three-check**: 被 settings.json hooks 数组引用；被 MEMORY.md Hooks 条目引用

### `scripts`
- **Target**: `~/.claude/scripts/*` (`.sh`, `.bat`, and related documentation)
- **典型 insights**: 维护脚本优化、新的自动化脚本
- **审查要点**: Windows/Git Bash 兼容性；grep BRE 语法陷阱（lessons.md §1）
- **Three-check**: 被 MEMORY.md 引用；被 CLAUDE.md three-check protocol 涉及

### `skills`
- **Target**: `~/.claude/skills/*/ (SKILL.md + supporting files)`（custom skills: qc, audit, claudeception, agent-reach, sharingan, etc.）
- **典型 insights**: 现有 skill 的改进、新的 trigger 模式、更好的 output format
- **审查要点**: 修改他人 skill 时检查 EN/ZH sync 要求（pitfalls #2）；token cost 意识
- **Three-check**: 被 MEMORY.md Plugin Ecosystem 引用；changelog.md（`memory/` 或目标 skill 自身）需更新

### `mcp`
- **Target**: `~/.mcp.json` (plus `settings*.json` for `enabledMcpjsonServers` and `.claude.json` backup)
- **典型 insights**: 新 MCP server 推荐、现有 server 配置优化
- **审查要点**: Windows MCP command 规则（lessons.md §2）；需在 enabledMcpjsonServers 中列出
- **Three-check**: 被 MEMORY.md "Plugin Ecosystem" 引用；被 .claude.json 备份

### `workflows`
- **Target**: 跨多个文件的流程模式
- **典型 insights**: 新的工作流模式、现有流程优化
- **审查要点**: 涉及多文件改动，three-check 范围更大；需全面理解依赖图
- **Three-check**: 可能涉及 CLAUDE.md + rules + scripts 的联动

### `new-skill`
- **Target**: 创建 `~/.claude/skills/<name>/` 新目录
- **典型 insights**: 外部资料启发的全新 skill idea
- **审查要点**: 先检查现有 marketplace skills 中是否已有类似功能；遵循 skill-creator 规范
- **Three-check**: 创建后需在 MEMORY.md Plugin Ecosystem 中新增条目

### `new-rule`
- **Target**: 创建 `~/.claude/rules/<name>.md`
- **典型 insights**: 外部资料启发的新行为规则
- **审查要点**: 检查是否可以合并到现有 rule 文件；避免规则膨胀
- **Three-check**: 创建后需检查是否需要在 CLAUDE.md 中引用

### `tool-acquisition`

- **Target**: 取决于工具类型（skill → `~/.claude/skills/`，MCP → `~/.mcp.json`，package → system）
- **典型 insights**: 外部资料推荐安装新工具、下载新 plugin、或自主开发新功能
- **审查要点**: 必须回答 4 个问题——①可信度（来源、作者、stars、维护活跃度）②功能重叠（现有工具是否已覆盖？）③成本收益（token overhead、依赖、维护负担 vs 实际价值）④ build vs buy（下载现成 vs 自己开发？）
- **Hard gate**: skill 类必须经过 `/skill-vetter`；MCP server 必须经过 security.md § MCP Server Security 审查；npm/pip 包需警告供应链风险。如 `/skill-vetter` 不可用（加载失败、文件缺失），则 tool-acquisition 流程必须 abort——fail-closed, not fail-open。
- **Three-check**: 安装后需在 MEMORY.md Plugin Ecosystem 中新增条目

### `other`
- **Target**: 用户确认
- **行为**: 暂停并请用户指定具体的优化目标
- **使用场景**: 资料涉及的领域不属于上述任何类别（罕见）
