---
name: ai-brain-update
description: 一键从 GitHub 拉取 my-ai-brain 最新工程资产、Skills 与 SOP 规范，并即刻刷新本机全局所有 AI 工具的能力。
---

# AI Brain Updater (/ai-brain-update)

当用户输入 `/ai-brain-update` 或要求更新 AI Brain 时，自动执行以下拉取与刷新操作：

## 执行流程

### 1. 拉取云端最新资产
进入本地仓库 `~/Projects/my-ai-brain`，执行：
```bash
git pull origin main
```
检查是否有更新的提交记录、新增的 Skill、或优化的 SOP 文档。

### 2. 刷新全局软链与多工具映射
运行全局安装脚本：
```bash
bash ~/Projects/my-ai-brain/bin/install-global.sh
```
自动确保所有新加入的技能目录建立实时软链接，多 AI 适配器保持最新。

### 3. 反馈更新结果
输出本次更新摘要：
- 显示拉取到的最新 Git 提交信息（commit 概要）
- 列出是否有新技能（Skills）或 SOP 规则变更
- 告知用户所有更新已实时生效，无需重启即可直接使用！
