---
name: kb-sync
description: Pull or push SoftwareDevKnowledgeBase (engineering knowledge base and CBB assets) with GitHub.
disable-model-invocation: true
---

# 软件工程知识库与 CBB 资产同步与推送 (/kb-sync)

统一管理 `${HOME}/Projects/SoftwareDevKnowledgeBase` 的远程拉取同步（原 `kb-sync`）与提交推送（原 `kb-push`）。

## 1. 从远程主库拉取最新变更 (Pull / Sync)
1. 若 `${HOME}/Projects/SoftwareDevKnowledgeBase` 不存在，执行 `git clone git@github.com:JasonCry/SoftwareDevKnowledgeBase.git "${HOME}/Projects/SoftwareDevKnowledgeBase"`。
2. 存在则执行 `git -C "${HOME}/Projects/SoftwareDevKnowledgeBase" pull origin main`。
3. 校验 `docs/00_OPAC_CATALOG.json` 并汇报收录资产总数。

## 2. 将本地新增/修改推送到远程主库 (Push)
1. 检查 `git -C "${HOME}/Projects/SoftwareDevKnowledgeBase" status -s`。
2. 自检是否已在 `docs/CARDS_TIYAO/` 生成 L1 提要卡并在 `docs/00_OPAC_CATALOG.json` 完成索书号登记。
3. 语义化提交并推送：`git add . && git commit -m "..." && git push origin main`，输出索书号与 Commit 哈希回执。
