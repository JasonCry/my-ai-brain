---
name: implement
description: End-to-end TDD vertical slice implementation, L2 slice editing, verify_fast.sh, and Staging receipt.
---

# Implement (Spec-Anchored & Shift-Left Implementation Loop)

基于已确认的 Spec 或工单，按垂直示踪弹切片（Vertical Tracer-Bullet Slices）完成高质量代码落地与预发验证。

## 标准执行闭环

1. **L2 微观定行与局部切片编辑**：
   - 严禁盲目整篇读取或整文件覆写大文件；先运行 `./scripts/code_query.sh outline <file>` 获取目标函数的精确 `[LStart-LEnd]` 行号，再调用 `view_file` 与 `replace_file_content` 局部修改。
2. **公共接缝处 TDD 循环 (`Red -> Green -> Refactor`)**：
   - 遵循 `tdd` 与 `ponytail` L1 核心纪律：在公共接口接缝处编写验证测试，用最少、最直接的标准库/原生代码让测试变绿，拒绝单次实现的抽象层。
3. **Shift-Left 秒级左移快检**：
   - 每完成一个切片，立即运行 `./scripts/verify_fast.sh`（秒级完成 Rust `cargo check` 与变更文件 `flutter analyze --no-pub`），将语法与类型错误消灭在重型构建之前。
4. **双轴自检与 Staging 预发验证**：
   - 复杂特性交付前执行 `/code-review`（Standards 规范轴 + Spec 契约轴对照 `docs/<category>/*_solution.md` 的 AC 清单逐项核验）。
   - 运行 `./scripts/deploy_staging.sh` 在 `localhost:3020` 完成真实 HTTP/MCP 接口与控制台 0 错误验证（严禁修改版本号、严禁推 Tag、严禁触碰生产 `3000` 端口）。
5. **输出四维验收回执并提交**：
   - 显式输出：`[代码已改] -> [单测/快检已过] -> [真实接口/Staging 3020已测] -> [生产待授权]`。
   - 更新 `changelog.md`，以携带 `#<Issue_ID>` 的 Commit Message 提交代码。
