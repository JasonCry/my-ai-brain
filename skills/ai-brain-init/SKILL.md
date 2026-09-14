---
name: ai-brain-init
description: 一键初始化或更新个人 AI 工程中枢资产 (my-ai-brain)。自动同步全套工程 SOP、50+ 专业 Skills、多 AI 入口规则及 MCP 配置到当前环境。
---

# AI Brain Initializer (/ai-brain-init)

当用户输入 `/ai-brain-init` 或要求初始化 AI 工程环境时，自动执行以下标准化闭环：

## 执行流程

### 1. 检查并拉取云端中枢仓库
- 检查本地路径 `~/Projects/my-ai-brain`：
  - 若不存在：执行 `git clone https://github.com/JasonCry/my-ai-brain.git ~/Projects/my-ai-brain`
  - 若已存在：进入该目录执行 `git pull origin main` 确保获取最新资产与 Skills

### 2. 执行本机全局环境挂载 (Global Sync)
- 运行 `bash ~/Projects/my-ai-brain/bin/install-global.sh`
- 将所有 Skills 软链挂载到 `~/.gemini/config/skills/`
- 激活本机各 AI 工具的全局感知能力

### 3. 为当前工作区注入全套工程 SOP 与多 AI 规则 (Workspace Init)
- 运行 `bash ~/Projects/my-ai-brain/bin/init-project.sh .`
- 确保当前项目拥有：
  - `docs/agents/engineering_sop.md`（Bug 攻坚、特性演进、架构治理 3 大 SOP）
  - `AGENTS.md`、`CLAUDE.md`、`.cursorrules`、`.cursor/rules/`、`.windsurfrules`、`.github/copilot-instructions.md`

### 4. 交付反馈
向用户展示初始化成功卡片，列出已激活的能力与当前项目状态，告知用户现在可以直接开始工程实践（提 Bug、新需求或架构走查）。
