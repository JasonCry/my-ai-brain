---
name: implement-spec
description: >-
  Implement a multi-slice technical specification (docs/<category>/*_solution.md) using
  tracer-bullet vertical slices, subagent context pointers, verify_fast.sh, and Staging verification.
---

# Implement Spec (Multi-Slice Spec Execution)

基于 `docs/<category>/<feature>_solution.md` 实施包含多个垂直切片（Vertical Slices）的复杂特性。

## 执行步骤

1. **解析契约与任务依赖图 (Task Graph)**：
   - 读取 Spec 文件顶部的 YAML Frontmatter（`issue_id`, `affected_seams`, `verify_commands`）与第 3 节垂直示踪弹切片清单。
2. **上下文指针通信 (Sparse Context Pointers)**：
   - 若委派 Subagent 并行调研或实施子切片，仅传递文件路径与 `[LStart-LEnd]` 行号指针（通过 `./scripts/code_query.sh outline` 获取），所有调研中间笔记保存在项目 `docs/` 对应子目录或会话 `scratch/` 目录中（**严禁写往工作区外的 `/tmp` 或不可写目录**）。
3. **逐切片 TDD 与秒级快检**：
   - 每个垂直切片遵循 `Red -> Green -> Refactor` 循环，并在切片完成后立即运行 `./scripts/verify_fast.sh` 验证编译与静态分析零报错。
4. **双轴审查与 Staging 预发闭环**：
   - 所有切片合流后，启动 `/code-review` 双轴（Standards + Spec）并行审查，逐项勾选 Spec 中的 `Acceptance Criteria`。
   - 执行 `./scripts/deploy_staging.sh` 在 `localhost:3020` 验证真实接口与控制台 0 错误，输出四维回执 `[代码已改] -> [单测/快检已过] -> [真实接口/Staging 3020已测] -> [生产待授权]`。
