# Changelog

All notable changes to the `my-ai-brain` project will be documented in this file.

## [Unreleased]

### Added
- feat(nav): 集成三层渐进式代码导航探针 (`code_query.sh` outline/symbol/trace) 与零盲搜 Git Hook 自动同步底座 (#2)
  - 新增 `templates/scripts/code_query.sh`（支持 L0 `feature`、L1 `trace`、L2 `outline`/`symbol` 精确起止行号 `[LStart-LEnd]` 切片）。
  - 新增零硬编码动态扫描器 `templates/scripts/auto_sync_code_index.sh` 与 `templates/hooks/pre-commit`。
  - 升级 `bin/init-project.sh`、`rules/AGENTS.md` 与 `rules/CLAUDE.md`，新项目运行 `/ai-brain-init` 即可一键自动装配。
- feat: add `experience-distill` skill and in-flow distillation SOP for global cross-device usage (#1)
  - Added `skills/experience-distill/SKILL.md` supporting zero-prompt in-flow experience distillation with triggers: `萃取经验`, `结案沉淀`, `提炼方法论`, `固化SOP`, `/distill`.
  - Added `sop/inflow_experience_distillation.md` defining cross-device collaboration and multi-machine sync SOP.
