---
name: ai-brain-sync
description: Initialize, update, push, or sync upstream for my-ai-brain engineering assets and skills.
---

# AI Brain Sync & Lifecycle Manager (/ai-brain-sync)

统一的 `my-ai-brain` 资产库管理技能（整合原 `ai-brain-init`、`ai-brain-update`、`ai-brain-push`、`ai-brain-sync-upstream`）。

## 1. 初始化当前工作区 (`init` / 初始化)
1. 检查本地路径 `~/Projects/my-ai-brain`：不存在则 `git clone git@github.com:JasonCry/my-ai-brain.git ~/Projects/my-ai-brain`，存在则 `git -C ~/Projects/my-ai-brain pull origin main`。
2. 执行全局挂载：`bash ~/Projects/my-ai-brain/bin/install-global.sh`。
3. 注入当前项目正交底座：`bash ~/Projects/my-ai-brain/bin/init-project.sh .`。

## 2. 从云端拉取更新并刷新本机 (`update` / 拉取更新)
1. 执行 `git -C ~/Projects/my-ai-brain pull origin main`。
2. 执行 `bash ~/Projects/my-ai-brain/bin/install-global.sh` 刷新全局软链与失效链接清理。

## 3. 提交并推送本地变更到 GitHub (`push` / 推送)
1. 检查 `git -C ~/Projects/my-ai-brain status -s`。
2. 若有改动，执行 `git -C ~/Projects/my-ai-brain add . && git -C ~/Projects/my-ai-brain commit -m "..." && git -C ~/Projects/my-ai-brain push origin main`。

## 4. 同步第三方上游 Skills (`sync-upstream` / 同步上游)
1. 运行 `bash ~/Projects/my-ai-brain/bin/sync-upstream.sh` 拉取 `upstream.json` 登记的上游仓库并刷新软链。
