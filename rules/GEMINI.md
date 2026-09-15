# P12 Project Instructions

## Engineering Workflows

- **Automated SOP Interception Protocol (Mandatory for ALL interactions)**:
    Whenever the user mentions a bug/problem, a new feature/idea, or an architectural concern, you MUST automatically enter the corresponding SOP defined in `docs/agents/engineering_sop.md`, leading each response with the compact Phase Card:
    - **SOP-1 (Bug 缺陷攻坚流)**: Triggered by keywords like "bug", "报错", "异常", "问题", "不工作", "崩溃". Immediately display `[■□□□□] 阶段 1/5: 捕获与工单建立`, execute `gh issue create`, record in `changelog.md`, and guide through feedback loop, hypothesis testing, TDD fix, and deploy verification. (Trivial style/text fixes auto-downgrade to Lite Mode 2 steps).
    - **SOP-2 (特性演进流)**: Triggered by keywords like "新需求", "新功能", "增加", "想做", "支持". Display `[■□□□□] 阶段 1/5: 需求倾听与边界盘问`, grill boundaries, model domain concepts into `CONTEXT.md`/ADRs, create spec in `docs/`, and implement.
    - **SOP-3 (架构治理流)**: Triggered by keywords like "架构", "重构", "code review", "走查", "膨胀". Display `[■□□□] 阶段 1/4: 明确审计范围与焦点`, audit bloat/depth, generate refactor spec, and perform dual-axis review.
    - **Phase Card Format (Mandatory)**:
      ```markdown
      > 📌 **[SOP 名称]** `[■■□□□] 阶段 X/Y: 阶段名称` | **关联工单**: `#ID` (若有)
      > **当前目标**: [一句话描述] | **下一步驱动**: [主动引导下一步动作]
      ```
- **Strict GitHub-Driven Workflow (Mandatory for ALL tasks)**: For ANY bug fix, feature request, or UI modification in this repository, you MUST automatically follow the `/gh-driven-workflow` skill procedure—even if the user does NOT explicitly type `/gh-driven-workflow` in their prompt:
    1.  **Issue Creation**: Immediately run `gh issue create` to capture requirement context.
    2.  **Changelog Record**: Record the issue ID in `changelog.md` under the current release version.
    3.  **Commit Traceability**: Append `#<Issue_ID>` to all Git commit messages.
    4.  **Verification & Closure**: Verify execution via `./scripts/deploy.sh`, then close the issue using `gh issue close <ID>`.
- **Advanced Debugging Protocol**: For ANY bug, I MUST use the `advanced-systematic-debugging` skill. This mandates:
    1.  **Forensic Trace**: Map data from `UI -> Store -> Network -> Handler -> SQL -> Disk`.
    2.  **Binary Integrity**: Verify the running process (`ps aux`) matches the code (`cargo build --release` is mandatory).
    3.  **Physical Audit**: Mandatory `sqlite3` or raw file checks to verify "truth on disk".
    4.  **Fail-Fast**: Infrastructure paths (migrations, IO) must use `expect()` instead of silent suppression.
- **Mandatory Verification**: Every code change must be followed by `agent-browser` console auditing. Success requires **0 runtime errors** in the browser.
- **Documentation & Design Standards**: All design proposals, technical solution documents, and architecture plans MUST be saved to the `docs/` directory of this repository (e.g., `docs/<feature_name>_solution.md`).
- **Mandatory Deploy Pipeline**: After ANY change to Flutter source files (`flutter_app/lib/**`) or Rust backend files (`backend/src/**`), you MUST execute the deploy pipeline before considering the task complete:
    1.  Run `./scripts/deploy.sh`. This script is smart and automatically detects whether Flutter or Rust source files were modified, re-building only what is necessary and restarting `gtd-backend`.
    2.  **NEVER** `git push` without running `./scripts/deploy.sh` first. The `pre-push` git hook will automatically block pushes if either `flutter_app/lib/` or `backend/src/` has files newer than their respective release build artifacts.
    3.  **NEVER** manually edit `task_provider.dart` with incremental patches when the file structure is complex — use `git checkout` to restore from git index first, then `write_to_file` with `Overwrite: true` to write the complete file.



## UI/UX Engineering Standards (Safari Resilience)

To prevent recurring "unresponsive input" or "clipped text" bugs in Safari/macOS:
1.  **Date/Time Inputs**: 
    - **NEVER** use `opacity-0` overlays for `type="time"` on desktop, as Safari lacks a native popover.
    - **PREFER** `<select>` menus or custom dropdowns for time selection to ensure a consistent "Menu" experience.
    - **BINDING**: Use explicit `label htmlFor` associations to leverage browser-native event propagation.
2.  **Display Density**: 
    - **YYYY-MM-DD** must always be fully visible.
    - **RULE**: Use `text-[11px]` and `whitespace-nowrap` for date containers. Avoid `truncate` on core metadata.
3.  **Cross-Platform Check**: Every UI change must be verified on both **macOS Safari** (pointer) and **iOS Safari** (touch) to confirm interaction success.

## Tech Stack Specifics
- **Backend**: Rust (Axum) + SQLite (r2d2).
- **Frontend**: Flutter (Dart) + Riverpod + Dio (Cross-Platform iOS/Android/Desktop/Web).
- **Persistence**: SQLite (Back), SharedPreferences/Hive (Front cache).

## Deployment & Target Architecture Principle

- **Web & PWA Exclusive Priority**: Focus exclusively on Web and PWA delivery for this project.
- **No DMG / Desktop Installer Overhead**: Do NOT generate, package, prompt, or link to macOS `.dmg` installers or desktop binaries unless the user explicitly requests DMG generation in a prompt. All updates and builds must target Web/PWA bundles (`flutter build web --release`).
- **Dual Address Space Deployment Principle for Guoxue Module (Mandatory)**:
  - Whenever the Guoxue (国学) module, classic scriptures (`flutter_app/lib/models/classics/**`, `classic_data.dart`), ancient script & Oracle Bone databases (`oracle_bone_data.dart`, `assets/oracle_bones/**`), or related views/widgets are modified, deployment MUST be performed simultaneously across **BOTH** address spaces:
    1. **Primary GTD App**: `https://gtdcalendar.xyz` (Port 3000 -> `dist/` build bundle)
    2. **Standalone Guoxue Portal**: `https://guoxue.gtdcalendar.xyz` (Port 3001 -> `dist_guoxue/` build bundle)
  - `./scripts/deploy.sh` automatically compiles and syncs both `dist/` and `dist_guoxue/` bundles, ensuring complete data and visual consistency across both live domains.

