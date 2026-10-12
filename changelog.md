# Changelog

All notable changes to the `my-ai-brain` project will be documented in this file.

## [Unreleased]

### Added
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
