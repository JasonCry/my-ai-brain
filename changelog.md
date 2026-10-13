# Changelog

All notable changes to the `my-ai-brain` project will be documented in this file.

## [Unreleased]

### Added
- perf(governance): 深度优化代码研发场景 Token 消耗、规则去重与一键穿透探针 (#8)
  - 剥离非研发技能常驻开销：将 `feynman-tutor`、`ppt-master`、`obsidian-vault`、`wizard`、`knowledge-distillation`、`knowledge-navigator`、`taste-skill`、`writing-for-agents`、`mini-deploy`（以及单机 `gtd-secretary`、`p12-memoryos`）11 项非核心技能打上 `disable-model-invocation: true`，转为 L2 显式 `/slash` 按需调用，使 System Prompt `<skills>` 目录开销从 40 项骤降至 15 项核心原语（净省 ~1,000+ Tokens）。
  - 项目规则去重与正交瘦身：重构 `bin/init-project.sh` 项目级 `AGENTS.md` 模板，剔除与全局 `GEMINI.md` 完全重复的 `Index-First` 4步大段文本，收敛为轻量本地架构指针，消除每轮对话重复注入 ~300 Tokens。
  - 消除规则互搏与思考税：在 `rules/AGENTS.md`、`rules/CLAUDE.md` 与 `sop/engineering_sop.md` 中明确规约 Lite Mode 显式豁免 `gh issue create` 与机械多轮阶段卡，升级 `commit-msg` 钩子允许 `chore(lite):` 快速放行，根治模型在微小任务下的分类犹豫与思考税。
  - 探针复合穿透升级：在 `templates/scripts/code_query.sh` 中新增 `locate <关键词>` 一键穿透指令，单次命令直接解析 Seam 接缝并内联展示核心文件 Outline 与 `[LStart-LEnd]` 切片起止行号，单次交互节约 2 轮 Tool 往返报文（~1,500 Tokens）。
  - 执行 `bin/install-global.sh` 全局刷新生效，并将 `feynman-tutor` 归一化为纯净文件目录追踪。

- feat(sop): 对齐 `mattpocock/skills` 官方全闭环机制与四大场景 SOP 健壮性升级 (#7)
  - 修复 `ponytail`、`ponytail-audit`、`ponytail-debt` 的 YAML Frontmatter 解析冒号错误，确保 `ponytail` 核心原语在 Antigravity `<skills>` 正常加载。
  - 统一领域语言文档为 `GLOSSARY.md` / `GLOSSARY-MAP.md`（向下兼容 `CONTEXT.md`），消解 `domain.md`、`domain-modeling` 与各 SOP 间的读写契约冲突。
  - 明确 L2 `/slash` 编排器 0 常驻 Token 触发协议（按需直读 `~/.gemini/config/skills/<name>/SKILL.md`），并在 `bin/init-project.sh` 注入标准 `## Agent skills` 块彻底消除 `/setup-matt-pocock-skills` 未初始化阻断。
  - 重构 `sop/engineering_sop.md`：SOP-1 补齐调用方全量排查与 `/retro` 复盘闭环；SOP-2 合并 `/grill-with-docs`、增补 `/wayfinder` 与 `/prototype` 支线，并引入单会话（直接实施）与多会话（`/to-tickets` 垂直切片）分流；SOP-3 拆分为 SOP-3A（PR 双轴快审）与 SOP-3B（架构加深与 `Expand-Contract` 重构治理）。
  - 升级 `templates/scripts/verify_fast.sh` 与 `templates/hooks/pre-commit`，新增对 TypeScript/Node 与 Python 技术栈的类型/语法增量快检与版本号防呆物理门禁。

- refactor(skills): 全面同步 GitHub 最新版 `mattpocock/skills` (`49dd158`) 并重构为官方「常驻原语 + 显式编排」双层架构 (#450)
  - 修复 `bin/sync-upstream.sh` 目录层级变更问题，精准拉取官方 `skills/engineering/*`（20 项，含新增的 `pr`、重构后的 `ask-matt` 与 `PHASE-BOUNDARIES.md`）及 `skills/productivity/*`（7 项），完整保留官方 `disable-model-invocation: true` 双层划分。
  - 将 26 个编排器/命令型技能（16 个官方编排器 + 10 个自有管理技能）统一标记为 `disable-model-invocation: true`（0 System Prompt 常驻开销，通过 `/slash` 显式调用），常驻 `<skills>` 仅保留 26 个模型自触发原语（约 1,437 Tokens）。
  - 从全局 `rules/AGENTS.md` 与 `rules/CLAUDE.md` 移除单仓专属的 `## Agent skills` (`docs/agents/*`) 硬编码指针，消除在非代码库工作区下的无效文件寻址。
- perf(skills): L0 技能路由目录极简瘦身——压缩全量 YAML `description`、合并包装器技能、归档低频课程技能 (#449)
  - 将 `skills/*/SKILL.md` 的 YAML `description` 统一压缩为 `<= 106` 字符的一句话高信噪比触发短语，正文细节保留在 `SKILL.md` Body 中按需加载。
  - 将 `ai-brain-init/push/update/sync-upstream` 4 个包装器合并为单一 `ai-brain-sync`，将 `kb-push/sync` 合并为单一 `kb-sync`。
  - 将 16 个外部课程专属与低频技能移入 `archived-skills/`（不默认挂载至全局常驻目录），并在 `bin/sync-upstream.sh` 中增加保护过滤，配合挂起非研发 `science` 插件，使常驻 `<skills>` 目录从 118 项（~11,500 Tokens）降至 62 项（~2,800 Tokens），每轮对话净省 ~76% 目录 Token 开销。
- chore(governance): 收敛项目级规则为 `AGENTS.md` 唯一入口并实现全局/项目正交分层 (#6)
  - 鉴于 Antigravity、Claude Code (v2.1.277+)、Codex、DSH、Cursor 均已原生识别项目根 `AGENTS.md`，且 `CLAUDE.md` 共存会遮蔽 `AGENTS.md`，升级 `bin/init-project.sh` 默认仅维护唯一入口 `AGENTS.md`，并自动清理项目内历史遗留的 `CLAUDE.md`、`.cursorrules`、`.cursor/rules/`、`.windsurfrules`、`.github/copilot-instructions.md`。
  - 实现全局配置（`~/.gemini/GEMINI.md`、`~/.claude/CLAUDE.md`、`~/.codex/AGENTS.md`）与项目 `AGENTS.md` 的正交分层：项目 `AGENTS.md` 托管块精简为 12 行轻量索引指针，彻底消除每次对话双重注入 70 行通用 SOP 的 Token 浪费。
  - 删除 `rules/` 下不再向项目分发的 `.cursorrules`、`engineering-sop.mdc`、`.windsurfrules`、`copilot-instructions.md` 碎片模板。
- chore(governance): 消除部署指令互搏、实现 `init-project.sh` 幂等托管块并强化 Git Hook 物理防呆门禁 (#5)
  - 统一 `sop/engineering_sop.md`、`skills/engineering-sop/SKILL.md` 及 `rules/*` 为 **Staging First (`deploy_staging.sh`) + 研发/发版解耦**，并将 Spec 产出路径规范至 `docs/<category>/<feature>_solution.md`。
  - 升级 `bin/init-project.sh` 采用 `<!-- my-ai-brain:begin/end -->` 正则幂等替换 `AGENTS.md`，根治多次注入首尾重复拼接问题。
  - 在 `templates/hooks/pre-commit` 新增日常提交禁止递增 `pubspec.yaml`/`Cargo.toml` 版本号的物理阻断门禁，并新增 `templates/hooks/commit-msg` 强制校验 `#<Issue_ID>` 与 SOP 阶段 5 四维反伪闭环验收回执。
- feat(skills): 固化 Matt Pocock 核心工程技能全自动触发链路与全局/项目双级自动挂载门禁 (#4)
  - 升级 `codebase-design`、`tdd`、`diagnosing-bugs`、`grill-with-docs`、`implement`、`code-review` 及 `engineering-sop` 的 `SKILL.md` 触发描述为 `TRIGGER AUTOMATICALLY`。
  - 在 `bin/sync-upstream.sh` 中内置 Auto-Trigger Patch，确保未来拉取 Matt Pocock 官方上游时自动保留主动触发器。
  - 升级 `bin/install-global.sh` 与 `bin/init-project.sh`，将强制读取 `SKILL.md` 的 SOP 路由矩阵幂等同步至 `~/.gemini/GEMINI.md`、`AGENTS.md`、`CLAUDE.md`、`.cursorrules`、`.windsurfrules` 与 `copilot-instructions.md`。
- feat(docling): 引入 `docling-reader` 异构文档零感知高保真精读技能与 SHA-256 影子缓存门禁 (#3)
  - 新增 `skills/docling-reader/SKILL.md` 与 `skills/docling-reader/scripts/p12_docling.py`（挂载为 `~/.local/bin/p12-docling`），内置清华 PyPI 镜像与 HF 镜像加速，支持 `.pdf`、`.docx`、`.pptx`、`.xlsx` 结构化表格与多栏还原。
  - 采用原件 100% 原位保留 + `.docling_cache/<sha256>/` 隐藏影子缓存机制，惰性加载重型依赖，二次读取 5ms 秒回。
  - 升级 `rules/AGENTS.md`、`rules/CLAUDE.md` 与 `bin/install-global.sh`，跨 Antigravity、ChatGPT/Codex、DSH、Claude Code 与 P12 智能秘书全局生效，无需人工提醒“使用 docling”。
- feat(nav): 集成三层渐进式代码导航探针 (`code_query.sh` outline/symbol/trace) 与零盲搜 Git Hook 自动同步底座 (#2)
  - 新增 `templates/scripts/code_query.sh`（支持 L0 `feature`、L1 `trace`、L2 `outline`/`symbol` 精确起止行号 `[LStart-LEnd]` 切片）。
  - 新增零硬编码动态扫描器 `templates/scripts/auto_sync_code_index.sh` 与 `templates/hooks/pre-commit`。
  - 升级 `bin/init-project.sh`、`rules/AGENTS.md` 与 `rules/CLAUDE.md`，新项目运行 `/ai-brain-init` 即可一键自动装配。
- feat: add `experience-distill` skill and in-flow distillation SOP for global cross-device usage (#1)
  - Added `skills/experience-distill/SKILL.md` supporting zero-prompt in-flow experience distillation with triggers: `萃取经验`, `结案沉淀`, `提炼方法论`, `固化SOP`, `/distill`.
  - Added `sop/inflow_experience_distillation.md` defining cross-device collaboration and multi-machine sync SOP.
