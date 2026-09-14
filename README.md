# 🧠 my-ai-brain: 个人 AI 工程中枢资产库

> **一次沉淀，所有 AI 工具全局复用。**  
> 集中管理个人的 AI 技能库 (Skills)、工程作业程序 (SOPs)、MCP 服务配置、领域方法论与多 AI 工具规则。

---

## 🌟 核心理念 (Why my-ai-brain?)

在现代 AI 辅助研发中，我们往往同时或交替使用多种工具（**Antigravity、Claude Code、Cursor、Windsurf、GitHub Copilot**）。
过去，每个新项目或新工具都需要重新复制 prompt 和配置文件，导致工程标准割裂。

`my-ai-brain` 充当你的 **AI Dotfiles（AI 基础设施配置中枢）**：
1. **单一真源 (SSOT)**：所有 SOP 流程、架构规范、方法论只在 `sop/` 中维护一份。
2. **多工具无缝适配**：通过 `rules/` 下的矩阵适配器，自动生成各 AI 工具识别的专属入口（`CLAUDE.md`, `.cursorrules`, `AGENTS.md` 等）。
3. **极简云端同步**：托管于 GitHub 私有仓库，换电脑、重装系统、开新工程均可秒级恢复。

---

## 📁 资产库架构

```text
my-ai-brain/
├── rules/                    # 各 AI 工具统一入口适配器 (AGENTS, Claude, Cursor, Windsurf, Copilot)
├── sop/                      # 核心 SOP 规范 (Bug 攻坚流、特性演进流、架构治理流、Lite Mode)
├── skills/                   # 50+ 个成熟的专业工程技能 (涵盖 Matt Pocock 技能集与自建技能)
│   ├── diagnosing-bugs/      # 缺陷最小复现与假设验证环
│   ├── grill-me/             # 需求深度边界盘问
│   ├── codebase-design/      # 深度模块化设计
│   ├── ponytail/             # 极简与反过度设计
│   ├── tdd/                  # 测试驱动开发
│   └── ...
├── mcp/                      # MCP 服务集中注册表与多工具配置模板
│   └── mcp_servers.json      # SQLite, GitHub, Playwright, Filesystem 等通用工具
├── bin/                      # 一键自动化与同步工具
│   ├── install-global.sh     # 全局挂载脚本 (建立 ~/.local/bin/ai-brain CLI)
│   └── init-project.sh       # 项目级一键注入脚本
└── README.md
```

---

## 🚀 快速上手与日常使用指南

### 1. 本机全局安装（仅需一次）
在终端中执行：
```bash
chmod +x bin/*.sh
./bin/install-global.sh
```
这会在本机完成全局环境软链，并生成全局命令 `ai-brain`。

### 2. 为任意【新项目】注入全套 AI SOP
进入你的任何新项目目录，只需执行一行命令：
```bash
ai-brain init
# 或者在任意路径指定目标目录：
ai-brain init /path/to/your/new-project
```
该项目就会立刻拥有：
- `docs/agents/` 全套标准化 SOP 规范
- `AGENTS.md` (通用 Agent 标准)
- `CLAUDE.md` (Claude Code 自动执行 SOP 拦截)
- `.cursorrules` & `.cursor/rules/` (Cursor 自动驱动阶段卡片)
- `.windsurfrules` (Windsurf Cascade 规则)
- `.github/copilot-instructions.md` (Copilot 规则)

### 3. 如何推送到 GitHub 实现云端备份与跨机器同步？

在 GitHub 上创建一个私有仓库（建议命名为 `my-ai-brain`），然后在本地执行：

```bash
cd ~/Projects/my-ai-brain
git init
git add .
git commit -m "feat: initial commit for personal AI engineering brain"
git branch -M main
git remote add origin git@github.com:JasonCry/my-ai-brain.git
git push -u origin main
```

**当你在另一台新电脑上工作时**：
```bash
git clone git@github.com:JasonCry/my-ai-brain.git ~/Projects/my-ai-brain
cd ~/Projects/my-ai-brain
./bin/install-global.sh
```
不到 10 秒钟，新电脑上的全部 AI 工具立即获得 100% 的工程实践经验！

---

## 🛠️ 如何添加新资产？

* **添加新 Skill**：在 `skills/<skill-name>/` 下创建 `SKILL.md`，执行 `git commit && git push` 即可。
* **调优 SOP 流程**：直接编辑 `sop/engineering_sop.md`。
* **添加新 MCP**：在 `mcp/mcp_servers.json` 中配置新的服务命令。
