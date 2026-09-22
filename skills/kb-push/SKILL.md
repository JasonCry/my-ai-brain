---
name: kb-push
description: 一键将本地 SoftwareDevKnowledgeBase (软件工程知识库与 CBB 公共资产) 的新增或修改内容提交并推送到 GitHub 远程仓库，实现跨开发环境与团队共享。
---

# 软件工程知识库与 CBB 资产推送技能 (/kb-push)

当用户输入 `/kb-push`、要求将知识库推送到 GitHub、或在完成新知识沉淀/新 CBB 模块入库后，自动执行以下 Git 提交与推送流水线：

## 执行流程

1. **定位知识库目录**：
   - 路径：`${HOME}/Projects/SoftwareDevKnowledgeBase`（即 `/Users/jasonxiao/Projects/SoftwareDevKnowledgeBase`）
   - 若本地目录不存在，提示用户先执行克隆。

2. **状态检查与自检**：
   - 执行 `git status -s`
   - 若工作区干净：告知用户“当前知识库与远程仓库已保持同步，无需重复提交”。
   - 若有改动：继续执行。
   - 自检必填要素：
     - 若新增或修改了文档/CBB，是否已在 `docs/CARDS_TIYAO/` 生成对应的 L1 文渊阁提要卡？
     - 是否已在 `docs/00_OPAC_CATALOG.json` 完成索书号与检索词登记？

3. **暂存与语义化提交**：
   - 执行 `git add .`
   - 提取变更摘要（如新入库的 CBB 模块名、新排障宝典标题、新增的索书号），生成精准规范的 Commit Message：
     - 新 CBB：`feat(cbb): 新增 <组件名> 公共通用构建块与提要索引`
     - 架构/排障宝典：`docs(<部类>): 沉淀 <标题> 实战指南及文渊阁提要卡`
     - 索书号目录更新：`chore(opac): 更新 00_OPAC_CATALOG 索引与戒律`
   - 执行 `git commit -m "..."`

4. **安全推送至远程主库**：
   - 执行 `git push origin main`
   - 确保远程分支 `https://github.com/JasonCry/SoftwareDevKnowledgeBase` 实时获取最新资产。

5. **呈报入库卡片**：
   - 向用户汇报本次推送成果，包含：
     - 索书号 (Call Number)
     - 涉及分类 (经/史/子/集)
     - 提要卡路径 (Card Path)
     - CBB 组件名 (若有)
     - 远程 GitHub 提交哈希
