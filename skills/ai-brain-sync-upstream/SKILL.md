---
name: ai-brain-sync-upstream
description: 自动检测并拉取 Matt Pocock 等第三方开源 Skills 官方仓库的最新版本并刷新本地能力。
---

# Third-Party Skills Upstream Sync (/ai-brain-sync-upstream)

当用户输入 `/ai-brain-sync-upstream` 或要求升级第三方 Skills 时，自动执行以下拉取与合并：

## 执行流程

1. 运行上游同步脚本：
   ```bash
   bash ~/Projects/my-ai-brain/bin/sync-upstream.sh
   ```
2. 脚本会自动拉取 `upstream.json` 登记的上游仓库（如 Matt Pocock 官方 skills 仓库）的最新版本并覆盖更新本地 `skills/`。
3. 自动重新执行软链接挂载，保证全局即刻生效。
4. 检查是否有变动：
   - 进入 `~/Projects/my-ai-brain` 检查 `git status -s`。
   - 若有第三方更新拉取下来，告知用户更新了哪些第三方技能，并建议用户是否需要使用 `/ai-brain-push` 备份推送到个人的 GitHub 仓库。
