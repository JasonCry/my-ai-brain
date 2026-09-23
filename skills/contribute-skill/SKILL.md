---
name: contribute-skill
description: >-
  Guide and workflow for authoring, testing, and contributing new skills, SOPs, or rules
  to the central my-ai-brain repository. Use when user says "贡献新skill", "新建skill",
  "创建技能", "沉淀SOP", "contribute skill", or "add skill".
---

# 贡献新技能与 SOP 工作流 (Contribute Skill & SOP Workflow)

本指南指导 Agent 与开发者如何在 `my-ai-brain` 资产库中创建新的 Skill、SOP 或规则，并自动同步挂载至 Antigravity 全局环境及推送到 GitHub。

---

## 🛠️ 一键脚手架命令 (CLI)

在终端或通过 Agent 命令执行：

```bash
# 1. 自动生成标准规范技能骨架
ai-brain add-skill <skill-name> "<skill-description>"

# 2. 本地编辑完善后，一键刷新软链使其对 Antigravity 实时生效
ai-brain sync

# 3. 一键提交并推送到 GitHub 远程仓库
ai-brain push "feat: add <skill-name> skill"
```

---

## 📋 手动创建与贡献规范 (Manual Standard)

若需要完全自定义创建，请遵循以下四步闭环：

### 步骤 1：在 `my-ai-brain/skills/` 下建立目录
所有技能统一以小写、连字符命名（kebab-case）：
```text
~/Projects/my-ai-brain/skills/<skill-name>/
├── SKILL.md            # 必选：主指令文件（含 YAML frontmatter）
├── scripts/            # 可选：可执行脚本（建议提供）
├── examples/           # 可选：参考样例
└── references/         # 可选：深层手册文档
```

### 步骤 2：编写 `SKILL.md`（高预测性标准）
`SKILL.md` 头部**必须**包含 YAML Frontmatter：

```markdown
---
name: your-skill-name
description: >-
  精确说明该技能的功能与触发时机。使用第三人称，列出关键触发动词与短语。
  例如: "Use when user asks to benchmark API latency, analyze network bottlenecks, or says '测一下接口性能'."
---

# Skill 标题

一句话定义核心能力与交付契约。

## 执行步骤
1. ...
2. ...
```

> **最佳实践**：
> - **渐进式披露 (Progressive Disclosure)**：`SKILL.md` 保持在 50~150 行以内，长篇手册放入 `references/`，避免单次塞爆模型的上下文窗口。
> - **严禁包含大文件**：单文件严禁超过 50MB，禁止放入 `*.zip`、`node_modules/` 等二进制或中间产物。

### 步骤 3：建立 Antigravity 全局软链
运行同步命令：
```bash
bash ~/Projects/my-ai-brain/bin/install-global.sh
# 或
ai-brain sync
```
这会在 `~/.gemini/config/skills/<skill-name>` 建立符号链接。Antigravity 的下一个对话轮次即可自动发现并使用该技能！

### 步骤 4：提交与推送到 GitHub
```bash
cd ~/Projects/my-ai-brain
git add skills/<skill-name>
git commit -m "feat(skills): add <skill-name> skill"
git push origin main
```
（也可以直接调用 `/ai-brain-push` 技能，由 Agent 自动完成检查与推送）。

---

## 📚 沉淀新 SOP 流程规范

若要新增或改进核心工程 SOP：
1. 编辑 `~/Projects/my-ai-brain/sop/` 下的文档（如新建 `sop/data_migration_sop.md` 或编辑 `engineering_sop.md`）。
2. 在 `skills/engineering-sop/SKILL.md` 中同步注册新 SOP 的触发矩阵与阶段进度卡片格式。
3. 执行 `ai-brain push "feat(sop): add data migration sop"`。
