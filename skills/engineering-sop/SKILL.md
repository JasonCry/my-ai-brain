---
name: engineering-sop
description: "Full reference for Lite Mode, SOP-1 (Bug Fix), SOP-2 (Feature Idea->Ship), and SOP-3A/3B (Code Review & Architecture Deepening), aligned with mattpocock/skills."
disable-model-invocation: true
---

# 自动化工程标准作业程序 (Automated Engineering SOPs · Aligned with `mattpocock/skills`)

本技能为 `sop/engineering_sop.md` 的同步镜像参考，全面对齐 `mattpocock/skills` 官方研发闭环（`Idea -> Grill -> Spec -> Tickets -> TDD Implement -> Two-Axis Code Review -> Retro`）。

- **单一真源路径**：`~/Projects/my-ai-brain/sop/engineering_sop.md`（在已初始化的项目中同步位于 `docs/agents/engineering_sop.md`）。
- **核心路由矩阵**：
  1. **Lite Mode (2步极简通道)**：纯文案/样式微调、静态配置修正，或单文件内明确局部修复（不涉及跨前后端接缝 `UI->Route->Storage->Table` 或 Schema 变更）。
  2. **SOP-1 (Bug 缺陷攻坚 - 5步)**：建单 (`gh issue create`) -> 必红最小复现闭环 (`diagnosing-bugs`) -> 可证伪假设验证 -> TDD 极简修复 (`tdd` + `ponytail`) -> `./scripts/verify_fast.sh` + 预发四维回执 + 可选 `/retro`。
  3. **SOP-2 (新功能与特性演进 - 4步)**：（超大模糊工程先走 `/wayfinder`）-> 阶段 1 `/grill-with-docs`（盘问边界 + 实时更新 `GLOSSARY.md` 与 `docs/adr/`，必要时 `/prototype`）-> 阶段 2 `/to-spec`（单会话直接进入阶段 3；多会话走 `/to-tickets` 拆解带阻塞边的垂直切片）-> 阶段 3 `/implement` 或 `/implement-spec`（在公共 Seam 处 `Red->Green->Refactor`）-> 阶段 4 `/code-review` 双轴审查 + 预发四维回执 + `/retro`。
  4. **SOP-3A (分支/PR 双轴代码审查 - 2步)**：锁定基准 -> 并行运行 `/code-review`（Standards + Spec 双轴）与 `/ponytail-review`（净删减行数评估）-> 闭环修复。
  5. **SOP-3B (架构加深与重构治理 - 4步)**：阶段 1 `/improve-codebase-architecture` + `/ponytail-audit`（基于 Git 热点与 Deletion Test 生成可视化 HTML 报告）-> 阶段 2 `/grill-with-docs` + `design-it-twice` -> 阶段 3 切片规划（局部加深用垂直切片，全仓高爆炸半径机械重构用 `Expand -> Migrate -> Contract`）-> 阶段 4 TDD 平滑重构与双轴验收。

需要完整阶段卡片格式与细节时，请直接读取 `docs/agents/engineering_sop.md` 或 `~/Projects/my-ai-brain/sop/engineering_sop.md`。
