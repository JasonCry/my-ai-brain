---
name: ai-brain-push
description: 一键将本地对 Skills、SOP 规则或配置的修改提交并推送到个人的 GitHub my-ai-brain 仓库。
---

# AI Brain Pusher (/ai-brain-push)

当用户输入 `/ai-brain-push` 或要求将本地修改推送到 my-ai-brain 时，自动执行以下 Git 提交与推送：

## 执行流程

1. 进入本地资产库目录：`cd ~/Projects/my-ai-brain`
2. 检查改动状态：`git status -s`
   - 若无修改：告知用户当前已是最新的，无需提交。
   - 若有修改：继续执行。
3. 暂存并生成语义化 Commit 描述：
   - `git add .`
   - 根据本次修改的内容（如新增的 Skill、修改的 SOP）自动生成 Commit 信息，或采用用户提供的说明。
   - `git commit -m "..."`
4. 推送至 GitHub：
   - `git push origin main`
5. 输出推送摘要卡片，向用户展示更新的提交与涉及的资产文件。
