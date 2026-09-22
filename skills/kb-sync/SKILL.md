---
name: kb-sync
description: 一键从 GitHub 拉取 SoftwareDevKnowledgeBase (软件工程知识库与 CBB 公共资产) 的最新宝典、提要卡与 CBB 模块，保证本地环境与各 AI 工具具备最新知识。
---

# 软件工程知识库与 CBB 资产同步技能 (/kb-sync)

当用户输入 `/kb-sync`、要求从远程更新知识库、或进入新开发环境初始化时，自动执行以下同步流程：

## 执行流程

1. **定位知识库目录**：
   - 路径：`${HOME}/Projects/SoftwareDevKnowledgeBase`（即 `/Users/jasonxiao/Projects/SoftwareDevKnowledgeBase`）
   - 若本地目录不存在：
     - 自动执行 `git clone https://github.com/JasonCry/SoftwareDevKnowledgeBase.git "${HOME}/Projects/SoftwareDevKnowledgeBase"`

2. **从远程主库拉取最新变更**：
   - 进入目录：`cd "${HOME}/Projects/SoftwareDevKnowledgeBase"`
   - 执行 `git pull origin main`

3. **刷新与校验资产总馆**：
   - 检查 `docs/00_OPAC_CATALOG.json` 是否有效解析。
   - 统计当前已收录的资产总数（经史子集、提要卡数、CBB 组件数）。

4. **汇报同步摘要**：
   - 输出最新拉取的 Commit 记录与更新的文件清单。
   - 告知用户当前中央知识库已更新至最新状态，司书侍读官 (`knowledge-navigator`) 可随时零膨胀调阅。
