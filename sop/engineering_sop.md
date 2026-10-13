# 自动化工程标准作业程序 (Automated Engineering SOPs · Aligned with `mattpocock/skills`)

本规范为日常开发中常见场景的标准化作业程序（SOP），全面对齐 `mattpocock/skills` 官方研发闭环（`Idea -> Grill -> Spec -> Tickets -> TDD Implement -> Two-Axis Code Review -> Retro`）。当在对话中感知到用户意图时，Agent **必须自动启动对应 SOP**，并主动输出**「紧凑阶段进度卡片」**，引导用户推进。

---

## 统一交互规范：紧凑阶段进度卡片 (Phase Card)

在进入任何 SOP 时，Agent 每次输出必须以如下统一格式的阶段卡片作为头部引导：

```markdown
> 📌 **[SOP 名称]** `[■■□□□] 阶段 X/Y: 阶段名称` | **关联工单**: `#ID` (若有)  
> **当前目标**: [一句话描述当前步的核心目标]  
> **下一步驱动**: [告知用户接下来需要确认的内容，或直接驱动下一步执行]
```

> **用户跳过与接管机制**：若用户显式说明“跳过”、“直接改”、“紧急修复”，Agent 记录风险后自动降级为 Lite Mode 或直接跳转到用户指定的阶段。
> **L2 编排器按需读取机制**：所有标记 `disable-model-invocation: true` 的第 2 层 `/slash` 编排器（如 `/grill-with-docs`、`/to-spec`、`/to-tickets`、`/implement`、`/implement-spec`、`/retro`、`/triage`、`/wayfinder`、`/improve-codebase-architecture`）不在 `<skills>` 常驻列表占 Token；当用户显式输入 `/command` 或 SOP 推进至对应阶段时，Agent 必须直接调用 `view_file("~/.gemini/config/skills/<skill-name>/SKILL.md")` 加载执行。

---

## ⚡ 轻量通道 (Lite Mode: 2-Step Fast Track)

**判定标准**：纯文案勘误、单个样式微调、静态配置修正，或**单文件内明确的局部逻辑修复（不涉及跨前后端接缝 `UI -> Route -> Storage -> Table` 契约修改、不涉及数据库 Schema 迁移）**。

* **阶段 1/2 [■□]: 极简建单与切片定位**
  - 执行 `gh issue create` 建立工单并在 `changelog.md` 登记（若仓库无远端 GitHub Tracker 则登记于本地 `todo.md`/`changelog.md`）。
  - 利用 L0~L2 代码导航探针（`./scripts/code_query.sh`）直接定位目标文件与精确行号 `[LStart-LEnd]`，免除多轮 `SKILL.md` 读取开销。
* **阶段 2/2 [■■]: 最小修改与快速验证闭环**
  - 遵循 L1 `ponytail` 纪律执行最小修改。
  - 先运行 `./scripts/verify_fast.sh` 完成秒级编译/静态检查；若项目包含预发脚本（如 `./scripts/deploy_staging.sh`）则完成预发内循环验证（不改版本号、不触碰生产）。
  - Git Commit 携带 `#<Issue_ID>`，验证通过后执行 `gh issue close <ID>` 关闭工单。

---

## SOP-1: Bug 缺陷攻坚流 (Bug Triage & Fix SOP)

**触发词**：发现 Bug、出错了、报错、异常、崩溃、不响应、有问题、逻辑不一致等。

### 阶段 1/5: 捕获与建单 (Capture & Issue)
* **卡片标识**：`[■□□□□] 阶段 1/5: 捕获与工单建立`
* **执行动作**：
  1. 梳理用户描述的症状、发生环境（Safari、Chrome、iOS、CLI 等）、复现概率。
  2. 执行 `gh issue create --title "..." --body "..."`（若针对外部存量多个待办工单，可引导使用 `/triage` 状态机分诊）。
  3. 在 `changelog.md` 中对应版本下登记工单。
* **驱动下一步**：向用户汇报生成的 Issue ID，并自动进入阶段 2。

### 阶段 2/5: 建立最小复现闭环 (Feedback Loop)
* **卡片标识**：`[■■□□□] 阶段 2/5: 建立最小复现闭环`
* **执行动作**（严格执行 `diagnosing-bugs` 原语）：
  1. **严禁在没有可复现的验证环之前盲目修改业务代码**。
  2. 优先构建可单步执行且必定变红（Fail）的紧致闭环：
     - 优先选：在公共接缝（Seam）处的单元测试 / 集成测试
     - 次优选：curl 脚本、headless 浏览器检查、CLI 探针
  3. 运行并确认该验证环能精确捕获用户描述的症状。
* **驱动下一步**：向用户展示复现命令及红灯输出，推进进入假设阶段。

### 阶段 3/5: 根因假设与探针验证 (Hypotheses & Probes)
* **卡片标识**：`[■■■□□] 阶段 3/5: 根因假设与探针验证`
* **执行动作**：
  1. 提出 2~4 个可证伪的假设（Format: *如果 X 是原因，则改变 Y 会使 Bug 消失*）。
  2. 检查该函数的所有调用方（`ponytail` 铁律：修根因而非修单个调用路径症状），使用带标签的临时日志（如 `[DEBUG-xxxx]`）针对性验证。
* **驱动下一步**：与用户对齐确凿根因，确认后进入修复阶段。

### 阶段 4/5: TDD 极简修复 (TDD & Minimal Fix)
* **卡片标识**：`[■■■■□] 阶段 4/5: TDD 极简修复`
* **执行动作**（协同 `tdd` 与 `ponytail` 原语）：
  1. **Red**：将复现脚本沉淀为正式回归测试用例。
  2. **Green**：编写最少、最直接的修复代码（杜绝过度设计与防御性冗余）。
  3. **Refactor**：全量清理 `[DEBUG-xxxx]` 探针代码，运行 `./scripts/verify_fast.sh` 确保编译与测试全绿。
* **驱动下一步**：汇报修复改动，进入预发验证与闭环阶段。

### 阶段 5/5: 预发验证、工单闭环与环境复盘 (Verify, Close & Optional Retro)
* **卡片标识**：`[■■■■■] 阶段 5/5: 预发验证与工单闭环`
* **执行动作**：
  1. **Staging First 预发验证**：若项目具备预发环境，默认执行 `./scripts/deploy_staging.sh`（如部署至 `localhost:3020/3021`），**未经用户明确指令严禁运行 `./scripts/deploy.sh` 触碰生产环境**。
  2. **研发与发版彻底解耦（铁律）**：日常提交仅做带 `#<Issue_ID>` 的普通 Commit，**严禁修改 `pubspec.yaml` / `Cargo.toml` / `package.json` 版本号，严禁打/推 Git Tag**（仅当用户明确要求正式发版时才调用 `./scripts/publish_release.sh`）。
  3. **反伪闭环四维证据回执**：针对真实接口与浏览器/运行时完成实测（0 运行时报错），并在结案回复中显式列出四态：`[代码已改] -> [单测已过] -> [真实接口/Staging已测] -> [生产待授权]`。
  4. Git Commit 附带 `#<Issue_ID>`，执行 `gh issue close <ID>` 关闭工单。
  5. **可选 `/retro` 环境加固**：若本次 Bug 排查耗时超过 2 轮假设或暴露了缺失的 Linter/Seam/导航指针，主动询问用户是否运行 `/retro` 将教训沉淀为确定性检查（Hook/Linter）或 `CODING_STANDARDS.md`。

---

## SOP-2: 新功能与特性演进流 (Feature Evolution SOP · Idea → Ship)

**触发词**：新需求、新功能、增加功能、想做一个、支持一下、优化交互等。

> **前置支线 · 迷雾探索 (`/wayfinder`)**：若需求属于跨多会话的超大型模糊工程（尚不清楚终点路径），先引导用户运行 `/wayfinder` 在 GitHub Issue 上建立 `wayfinder:map` 决策地图，逐个消解 `research` / `prototype` / `grilling` / `task` 决策单，待迷雾散去后再汇入本 SOP 阶段 2 (`/to-spec`)。

### 阶段 1/4: 需求深挖与领域建模 (`/grill-with-docs` + 可选 `/prototype`)
* **卡片标识**：`[■□□□] 阶段 1/4: 需求深挖与领域建模`
* **执行动作**（协同 `grilling` 与 `domain-modeling` 原语，对齐 `/grill-with-docs`）：
  1. 读取项目根 `GLOSSARY.md`（或存量 `CONTEXT.md`）及 `docs/adr/`。
  2. 对模糊边界、异常场景、状态并发进行盘问，明确 Goals 与 Out-of-Scope（Non-goals）。
  3. **实时沉淀领域资产**：一旦澄清模糊术语，立即内联更新 `GLOSSARY.md`；一旦做出不可逆、反直觉且存在真实权衡的架构决策，立即在 `docs/adr/` 生成 ADR。
  4. **可选原型支线 (`/prototype`)**：若存在仅靠对话无法拍板的 UI 手感或状态机逻辑，提示用户通过 `/handoff` + `/prototype` 在独立 `prototype/<name>` 分支快速验证后再回到主流程。

### 阶段 2/4: 结构化 Spec 合成与工单分流 (`/to-spec` + 单/多会话分流)
* **卡片标识**：`[■■□□] 阶段 2/4: 结构化 Spec 与工单分流`
* **执行动作**（对齐 `/to-spec` 与 `/to-tickets`）：
  1. **确定最高测试接缝（Seam）**：优先复用现有高层公共接缝，接缝越少越好（理想为 1 个）。
  2. **产出 Spec 并建单**：
     - 发布结构化 Spec 至 GitHub Issue（包含 Problem Statement、Solution、User Stories、Implementation Decisions、Testing Decisions、Out of Scope，打上 `ready-for-agent` 标签）；
     - 若需在仓库归档详细实施契约，基于 `docs/agents/SPEC.template.md` 写入 `docs/<category>/<feature_name>_solution.md`（严禁直接堆放在 `docs/` 根目录）。
  3. **单会话 vs 多会话分流决策**：
     - **单会话特性（默认，1 个窗口可完成）**：无需拆分子工单，直接进入阶段 3 (`/implement`)。
     - **多会话大型特性**：调用 `/to-tickets` 将 Spec 拆解为带阻塞边（`Blocked by`）的**垂直示踪弹切片（Vertical Tracer-Bullet Slices，每个切片穿透 Schema -> API -> UI -> Test 且可独立验证）**，由用户选择逐单执行 `/implement`（每单间 `/clear`）或全图并发执行 `/implement-spec`。

### 阶段 3/4: 垂直切片 TDD 实施 (`/implement` 或 `/implement-spec`)
* **卡片标识**：`[■■■□] 阶段 3/4: 垂直切片 TDD 实施`
* **执行动作**（严格执行 `tdd`、`codebase-design`、`ponytail` 原语）：
  1. 在预先对齐的公共接缝（Seam）处按 `Red -> Green -> Refactor` 每次推进一个垂直切片，严禁测试内部私有实现细节，严禁先写完所有测试再写实现。
  2.  diseñar 深模块（小接口隐藏复杂实现），拒绝透传浅模块（Pass-through）与单一实现抽象。
  3. 频繁运行 `./scripts/verify_fast.sh` 与单测文件保持秒级反馈。

### 阶段 4/4: 双轴审查、预发验证与闭环 (`/code-review` + Staging + `/retro`)
* **卡片标识**：`[■■■■] 阶段 4/4: 双轴审查与预发闭环`
* **执行动作**：
  1. **双轴并行代码审查 (`/code-review`)**：基于 Merge-base 对照 `CODING_STANDARDS.md`/Fowler 坏味道基线（**Standards 轴**）与原 Issue/Spec 验收条件（**Spec 轴**）执行双轴核验。
  2. **预发验证与四维回执**：运行 `./scripts/deploy_staging.sh` 在预发环境完成真实接口与控制台 0 报错验证（严禁擅自修改版本号或触碰生产环境），输出 `[代码已改] -> [单测已过] -> [真实接口/Staging已测] -> [生产待授权]`。
  3. 关联 `#<Issue_ID>` 提交代码（若走 PR 则遵循 `/pr` 规范生成最小可视化与 Before/After 证据），关闭工单；必要时运行 `/retro` 加固工程环境。

---

## SOP-3: 架构治理与双轴审查流 (Architecture & Code Review SOP)

**触发词**：根据用户意图自动分流为 **SOP-3A（日常代码/PR 审查）** 或 **SOP-3B（架构加深与瘦身重构）**。

### 分支 A · SOP-3A: 分支/PR 双轴代码审查流 (2 步快审)
**适用场景**：用户要求“review 下代码”、“审查当前分支/PR”、“看看最近提交有没有问题”。
* **阶段 1/2 [■□]: 锁定基准与双轴并行审查 (`/code-review` + `/ponytail-review`)**
  - 确定固定基准点（如 `main`、`HEAD~N` 或指定 Commit），确认 Diff 非空并定位关联 Issue/Spec。
  - 启动 **Standards 轴**（仓库规范 + Fowler 坏味道基线）与 **Spec 轴**（需求契约完成度）并行子 Agent 审查，同时叠加 `ponytail-review` 扫描可删减的过度设计行数（`net: -<N> lines possible`）。
* **阶段 2/2 [■■]: 问题分级报告与闭环修复**
  - 汇总双轴报告与精简建议；经用户确认后一键应用修复并运行 `./scripts/verify_fast.sh` 验证。

### 分支 B · SOP-3B: 架构加深与模块重构流 (4 步治理)
**适用场景**：用户提出“架构审查”、“模块太碎/太浅”、“代码膨胀”、“重构某模块”。
* **阶段 1/4 [■□□□]: 热点锁定与浅模块扫描 (`/improve-codebase-architecture` + `/ponytail-audit`)**
  - 读取 `GLOSSARY.md` 与 `docs/adr/`；优先结合 `git log --oneline` 锁定近期高频变更热点（YAGNI：只加深经常修改的区域）。
  - 运用 `codebase-design` 词汇表（**module, interface, depth, seam, adapter, leverage, locality**）与**删除测试（Deletion Test）**扫描浅模块与跨接缝泄漏，结合 `ponytail-audit` 识别冗余依赖与单一实现抽象。
  - 生成自包含的可视化架构候选 HTML 报告（写至 `$TMPDIR/architecture-review-<timestamp>.html` 并打开），由用户挑选要推进的候选。
* **阶段 2/4 [■■□□]: 架构边界盘问与接口深设计 (`/grill-with-docs` + `design-it-twice`)**
  - 针对用户选定的重构候选，调用 `grilling` + `domain-modeling` 对齐加深后的模块边界与保留的公共接缝测试，同步更新 `GLOSSARY.md` / `docs/adr/`。
  - 若需对比接口形态，采用 `codebase-design` 的 **Design-It-Twice** 模式给出激进极简与灵活通用两种签名供决策。
* **阶段 3/4 [■■■□]: 重构切片规划 (`Expand-Contract` vs 垂直切片)**
  - 建立 GitHub Issue 并编写 `docs/architecture/<refactor_name>_solution.md`。
  - **切片策略**：局部模块加深采用垂直示踪弹切片；跨全仓高爆炸半径的机械重构（如重命名核心类型/字段）必须采用 **`Expand -> Migrate -> Contract`（先并存扩展、再分批迁移保持 CI 全绿、最后删除旧形态）** 序列。
* **阶段 4/4 [■■■■]: TDD 平滑重构与双轴验收 (`/implement` + `/code-review`)**
  - 在公共接缝测试保护下完成重构，执行 `/code-review` 双轴审查与 `./scripts/verify_fast.sh` + 预发验证，确保系统 0 回归。
