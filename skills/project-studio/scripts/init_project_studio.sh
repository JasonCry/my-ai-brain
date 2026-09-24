#!/usr/bin/env bash
# ==============================================================================
# init_project_studio.sh
# 一键将当前仓库纳入 Jason's Software Studio 统一工作台治理
# ==============================================================================
set -euo pipefail

PROJECT_NUM=1
OWNER="JasonCry"

echo "🔍 [1/4] 获取当前仓库信息并检查 GitHub 凭证..."
if ! gh auth status &>/dev/null; then
    echo "❌ gh CLI 未认证或状态异常，请先执行: gh auth login -h github.com"
    exit 1
fi

REPO_FULL=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || true)
if [ -z "$REPO_FULL" ]; then
    echo "❌ 未能识别当前目录的 GitHub 仓库，请确保在 git 根目录且已关联 remote"
    exit 1
fi

echo "📦 当前仓库: $REPO_FULL"

echo "🔗 [2/4] 将仓库绑定至 GitHub Project #${PROJECT_NUM} (Jason's Software Studio)..."
gh project link "$PROJECT_NUM" --owner "$OWNER" --repo "$REPO_FULL" 2>/dev/null || echo "   (仓库已关联或已就绪)"

echo "📄 [3/4] 检查/初始化文档资产 (docs/CAPABILITIES.md & todo.md)..."
mkdir -p docs

if [ ! -f "docs/CAPABILITIES.md" ]; then
    cat << 'EOF' > docs/CAPABILITIES.md
# 产品能力大地图 (Capability Matrix)

> 💡 **定位与使命**：本文件是当前系统的**业务能力单一事实源**。
> 告别散落的 TODO 流水账；每当你想了解“这个软件目前具备什么能力、在哪个版本固化”，以此表为准。

---

## 🏛️ 核心业务能力矩阵

| 业务模块 | 能力项 | 状态 | 交付版本 | 核心特性与验证路径 |
| :--- | :--- | :---: | :---: | :--- |
| **基础与底座** | 核心架构与环境初始化 | 🟢 已交付 | `v1.0.0` | 基础运行环境与配置 |
| **核心业务** | 待梳理主要功能 | ⏳ 规划中 | - | 待补充验证路径 |

---

> 📝 维护规则：每次发布正式版本时，若有新增或重大改造的能力，在此处追加登记。
EOF
    echo "   ✅ 已生成初始 docs/CAPABILITIES.md"
else
    echo "   ✓ docs/CAPABILITIES.md 已存在"
fi

if [ ! -f "todo.md" ]; then
    cat << 'EOF' > todo.md
# 项目待办事项 (TODO)

## 全局状态看板 (Status Dashboard)

### 原声状态对照表
| 编号 | 提出人 | 概要 | 关联任务 | 状态 | 交付版本/Issue |
| :--- | :--- | :--- | :--- | :--- | :--- |
| - | - | - | - | - | - |

### 待开发任务清单
（暂无待开发任务）

### 已完成交付清单
（暂无已交付任务）

---

## 用户原声归档池 (VOC Archive)
EOF
    echo "   ✅ 已生成初始 todo.md"
else
    echo "   ✓ todo.md 已存在"
fi

echo "🛡️ [4/4] 检查/注入治理守则至 AGENTS.md..."
if [ -f "AGENTS.md" ]; then
    if ! grep -q "Jason's Software Studio" AGENTS.md; then
        cat << 'EOF' >> AGENTS.md

## 🚀 Project Studio 跨机工作台协同铁律 (Mandatory)

1. **工单统一归口**：所有 Bug 修复、特性演进与客户原声（VOC）必须建 Issue 并关联至 GitHub Project #1 (`Jason's Software Studio`)。
2. **客户原声闭环 (VOC)**：凡客户反馈必须标注 `VOC Reporter` 与 `label:voc`；发布上线后 24 小时内必须回访客户。
3. **能力大地图同步**：每次发布新版本若包含新增业务特性，必须同步更新 `docs/CAPABILITIES.md`。
4. **提交追溯门禁**：所有 Git Commit 必须携带 `#<Issue_ID>`。
EOF
        echo "   ✅ 已向 AGENTS.md 追加工作台协同铁律"
    else
        echo "   ✓ AGENTS.md 已包含协同铁律"
    fi
else
    cat << 'EOF' > AGENTS.md
# Agent Guidelines & Rules

## 🚀 Project Studio 跨机工作台协同铁律 (Mandatory)

1. **工单统一归口**：所有 Bug 修复、特性演进与客户原声（VOC）必须建 Issue 并关联至 GitHub Project #1 (`Jason's Software Studio`)。
2. **客户原声闭环 (VOC)**：凡客户反馈必须标注 `VOC Reporter` 与 `label:voc`；发布上线后 24 小时内必须回访客户。
3. **能力大地图同步**：每次发布新版本若包含新增业务特性，必须同步更新 `docs/CAPABILITIES.md`。
4. **提交追溯门禁**：所有 Git Commit 必须携带 `#<Issue_ID>`。
EOF
    echo "   ✅ 已新建 AGENTS.md 并注入协同铁律"
fi

echo ""
echo "=============================================================================="
echo "🎉 项目已成功接入 Jason's Software Studio 统一工作台！"
echo "🌐 全局看板: https://github.com/users/JasonCry/projects/1"
echo "=============================================================================="
