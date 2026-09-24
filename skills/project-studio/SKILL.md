---
name: project-studio
description: >-
  Standardized multi-project governance and studio cockpit skill for solo founders and indie hackers.
  Enforces cross-repository aggregation under GitHub Projects (v2), customer voice (VOC) tracking,
  capability matrix documentation (docs/CAPABILITIES.md), and zero-config project scaffolding.
  Trigger when user says "初始化工作台", "接入工作台", "新建项目治理", "能力大地图", "project-studio",
  "init project studio", or asks to manage software projects systematically.
---

# 独立开发者多项目统一工作台治理技能 (Project Studio Skill)

本技能确立了独立开发者 / Solo Founder 管理多个并行软件项目的**全局驾驶舱与生命周期治理标准**。

核心哲学：**“全局看板统揽，业务能力立图；原声闭环回访，跨机随码同行。”**

---

## 🧭 四大刚性治理原则 (The Four Pillars)

1. **全局统一驾驶舱 (Single Portfolio Cockpit)**：
   - 所有软件项目（如 P12 随身秘书、字疏·书院等）统一纳管于 GitHub Project #1 (**`Jason's Software Studio`**)；
   - 严禁任何项目成为信息孤岛。

2. **产品能力大地图 (Capability Matrix as Ground Truth)**：
   - 根治“半年后失忆”铁律：禁止用随时间沉没的 TODO 流水账代替系统全貌；
   - 每个项目根目录必须维系 [docs/CAPABILITIES.md](docs/CAPABILITIES.md)，按业务能力支柱归档已交付特性、版本号与核心验证路径。

3. **天使客户原声双向闭环 (VOC Lifecycle & Closure SLA)**：
   - 客户反馈必须记录 `VOC Reporter`（提出人），打上 `label:voc`；
   - **发布即回访**：版本上线部署后，必须通过看板筛选已完成的 VOC，在 24 小时内向提建议的天使客户发信回访。

4. **规范随代码走（跨机零漂移）**：
   - 所有工作台原则与门禁必须硬编码在项目仓库的 `AGENTS.md`、`GEMINI.md` 与 `CLAUDE.md` 中；
   - 保证在任何电脑（MacBook Air / Mac Mini / 任意新设备）上打开 IDE 时，AI 均自动遵循这套规约。

---

## ⚡ 触发场景与意图匹配

当用户表达如下意图时，自动激活本技能：
- “初始化项目工作台”、“新项目接入工作台”、“/init-studio”
- “为当前项目生成能力大地图”、“生成 CAPABILITIES.md”
- “看看客户反馈有哪些没做”、“列出待回访的客户”
- “这个软件目前开发了哪些功能”

---

## 🛠️ 标准执行工作流 (Standard Workflows)

### 工作流 A：新项目/已有项目一键接入工作台 (`init-studio`)

当进入一个新仓库或尚未接入工作台的旧仓库时，执行以下动作：

1. **自动关联全局看板**：
   ```bash
   # 获取当前仓库全名（如 JasonCry/WuDangShuYuan）
   REPO_NAME=$(gh repo view --json nameWithOwner -q .nameWithOwner)
   # 绑定到全局项目 #1
   gh project link 1 --owner JasonCry --repo "$REPO_NAME"
   ```

2. **注入能力大地图脚手架 (`docs/CAPABILITIES.md`)**：
   - 扫描当前仓库的 `changelog.md`、`todo.md` 或核心代码目录；
   - 提炼该业务的 5~8 个核心能力支柱（如：核心引擎、数据持久化、安全认证、开放接口、运维基建）；
   - 输出结构化能力对照表。

3. **注入 `AGENTS.md` / `GEMINI.md` 规范锚点**：
   - 检查并追加：
     - 新建需求/Bug 必须关联 GitHub Project #1，并带 `Module` 与 `VOC Reporter`。
     - Commit 必须附带 `#IssueID`。
     - 每次 Release 发布前校验是否需要增补 `docs/CAPABILITIES.md`。

---

### 工作流 B：客户原声 (VOC) 录入与回访闭环

1. **录入反馈**：
   ```bash
   gh issue create \
     --title "VOC: [提出人] 需求概要" \
     --body "### 用户原声\n> 用户原话...\n\n### 意图研判与方案..." \
     --label "voc"
   ```
2. **挂接看板字段**：
   - 在 Project #1 中设置：`VOC Reporter = "提出人"`，`Status = "Todo"`，`Module = "所属模块"`。
3. **发布回访闭环**：
   - 当发布新版本时，筛选 `Status == Done` 且 `VOC Reporter != ""` 且未回访的条目；
   - 生成客户微信通知文案模板，提示开发者发信回访。

---

### 工作流 C：全栈能力大地图定期审计 (Feature Audit)

- 当需要了解“软件开发到什么状态”、“有哪些功能”时：
- 优先读取 `docs/CAPABILITIES.md`；
- 比对最近 10 次 Git Commit 或 Release，如有新上线特性尚未落图，主动提示用户更新。
