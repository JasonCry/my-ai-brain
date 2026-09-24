#!/usr/bin/env bash
# ==============================================================================
# init_project_studio.sh
# 独立开发者多项目工作台标准初始化脚手架 (Project Studio Initializer)
# 作用: 在任何新老软件项目中执行，一键拉通规范、看板关联、能力大地图与发布闭环
# ==============================================================================
set -euo pipefail

PROJECT_NUM=1
OWNER="JasonCry"

echo "=============================================================================="
echo "🚀 [Project Studio] 正在初始化多项目统一工作台治理环境..."
echo "=============================================================================="

# 1. 检查 GitHub CLI 凭证与项目归属
echo "🔍 [1/6] 检查 GitHub CLI 状态与当前仓库..."
if ! gh auth status &>/dev/null; then
    echo "❌ gh CLI 未认证或状态异常，请先执行: gh auth login -h github.com"
    exit 1
fi

REPO_FULL=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || true)
if [ -z "$REPO_FULL" ]; then
    echo "❌ 未能识别当前目录的 GitHub 仓库，请确保在 git 根目录且已关联 remote"
    exit 1
fi

echo "📦 当前纳管仓库: $REPO_FULL"

# 2. 绑定至 GitHub Project #1 全局驾驶舱
echo "🔗 [2/6] 将仓库自动绑定至 GitHub Project #${PROJECT_NUM} (Jason's Software Studio)..."
gh project link "$PROJECT_NUM" --owner "$OWNER" --repo "$REPO_FULL" 2>/dev/null || echo "   (仓库已关联或已处于就绪状态)"

# 3. 初始化/增补 docs/ 核心资产 (能力大地图与端口注册表)
echo "📄 [3/6] 初始化/校验 docs/CAPABILITIES.md (防半年失忆单一事实源)..."
mkdir -p docs

if [ ! -f "docs/CAPABILITIES.md" ]; then
    cat << 'EOF' > docs/CAPABILITIES.md
# 产品能力大地图 (Capability Matrix)

> 💡 **定位与使命**：本文件是当前系统的**业务能力单一事实源**。
> 告别散落的 TODO 流水账与代码考古；每当你想了解“这个软件目前具备什么能力、由谁支持、在哪个版本固化、如何验证”，以此表为准。

---

## 🏛️ 核心业务能力矩阵

| 业务模块 | 能力项 | 状态 | 交付版本 | 核心特性说明 | 冒烟验证路径 (Smoke Path) |
| :--- | :--- | :---: | :---: | :--- | :--- |
| **基础与底座** | 核心架构与环境初始化 | 🟢 已交付 | `v1.0.0` | 基础运行环境与脚手架 | 启动服务并访问根路径，状态码 200 |
| **核心业务** | 待梳理主要功能模块 | ⏳ 规划中 | - | 核心业务模型与流转 | 待补充具体验证入口路径 |

---

> 📝 维护铁律：每次发布正式版本时，若有新增或重大重构的业务特性，必须在结项前在此处追加登记。
EOF
    echo "   ✅ 已生成带冒烟验证路径的标准 docs/CAPABILITIES.md"
else
    echo "   ✓ docs/CAPABILITIES.md 已存在"
fi

echo "🌐 [4/6] 注入全局权威端口注册表 docs/PORT_REGISTRY.md..."
cat << 'EOF' > docs/PORT_REGISTRY.md
# 全局多项目基础设施与端口注册表 (Port Allocation Registry)

> 💡 **单一事实源**：本注册表是所有独立软件项目在开发机与生产部署时的**权威端口分配图**。
> 任何新项目、新服务严禁随意占用既有端口段，杜绝本地冲突与服务踩踏。

| 端口 | 监听进程 | 项目归属 | 环境类型 | 详细用途说明 |
| :---: | :--- | :--- | :---: | :--- |
| **`3000`** | `gtd-backend` | **P12 (AI随身秘书)** | 🟢 生产 (Prod) | GTD 主应用 Web 访问与核心 API (`gtdcalendar.xyz`) |
| **`3001`** | `gtd-backend` | **P12 (AI随身秘书)** | 🟢 生产 (Prod) | 国学独立门户 Web 访问 (`guoxue.gtdcalendar.xyz`) |
| **`3002`** | `wudang-backend` | **字疏·书院** | 🟢 生产 (Prod) | 「字疏·书院」对外正式服务端口，Rust Axum + Flutter Web，FRP穿透 |
| **`3010`** | `wudang-staging` | **字疏·书院** | 🧪 预发 (Staging) | 「字疏·书院」本地测试与验收环境（Staging Gate 规范备用） |
| **`3020`** | `gtd-backend` | **P12 (AI随身秘书)** | 🧪 预发 (Staging) | GTD 主应用本地 Staging 测试与验收入口 (`localhost:3020`) |
| **`3021`** | `gtd-backend` | **P12 (AI随身秘书)** | 🧪 预发 (Staging) | 国学独立门户本地 Staging 测试与验收入口 (`localhost:3021`) |
| **`3080`** | `node` | **公共基础设施** | 🛠️ 开发与管理 | Node.js 前端开发 / Web 管理界面及脚手架辅助服务 |
| **`8445`** | `wudang-proxy` | **字疏·书院** | 🌐 移动网络放行 | 适配阿里云未备案拦截的移动端 API 高位放行端口 |
| **`3003/3023`** | (预留) | **Project 3** | 🟢 生产 / 🧪 预发 | 备用新项目标准端口段 |
EOF
echo "   ✅ docs/PORT_REGISTRY.md 已对齐"

# 4. 初始化三层状态看板 todo.md
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

# 5. 注入发布回访通知工具 scripts/notify_voc_reporters.sh
echo "📢 [5/6] 注入天使客户回访闭环工具 scripts/notify_voc_reporters.sh..."
mkdir -p scripts
cat << 'EOF' > scripts/notify_voc_reporters.sh
#!/usr/bin/env bash
# ==============================================================================
# scripts/notify_voc_reporters.sh
# 生产发布后天使客户回访闭环提醒 (Feedback Closure SLA)
# 作用: 自动检索最新闭环的 VOC 工单，生成一键复制的微信私信回访话术
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

VERSION="${1:-}"
if [ -z "$VERSION" ]; then
    if [ -f "$PROJECT_ROOT/flutter_app/pubspec.yaml" ]; then
        VERSION="v$(grep -m 1 '^version:' "$PROJECT_ROOT/flutter_app/pubspec.yaml" | awk '{print $2}' | cut -d'+' -f1)"
    elif [ -f "$PROJECT_ROOT/Cargo.toml" ]; then
        VERSION="v$(grep -m 1 '^version =' "$PROJECT_ROOT/Cargo.toml" | cut -d'"' -f2)"
    elif [ -f "$PROJECT_ROOT/package.json" ]; then
        VERSION="v$(grep -m 1 '"version":' "$PROJECT_ROOT/package.json" | cut -d'"' -f4)"
    else
        VERSION="最新版本"
    fi
fi

REPO_FULL=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || true)

echo ""
echo "=============================================================================="
echo "📢 【天使客户回访闭环清单 (Feedback Closure SLA)】"
echo "📦 当前发布版本: ${VERSION}  |  项目: ${REPO_FULL}"
echo "=============================================================================="

if ! gh auth status &>/dev/null; then
    echo "⚠️ GitHub CLI 未登录，跳过自动抓取。请手动登录 gh CLI 启用自动回访清单。"
    exit 0
fi

CLOSED_VOCS=$(gh issue list --repo "$REPO_FULL" --state closed --limit 10 --json number,title,body,closedAt 2>/dev/null || true)

if [ -z "$CLOSED_VOCS" ] || [ "$CLOSED_VOCS" = "[]" ]; then
    echo "🎉 当前无待回访的闭环客户原声工单。"
    echo "=============================================================================="
    echo ""
    exit 0
fi

COUNT=$(echo "$CLOSED_VOCS" | jq 'length')
echo "💡 最近已闭环的客户原声 (${COUNT} 项)，请在 24 小时内私信回访提建议的天使客户："
echo "------------------------------------------------------------------------------"

echo "$CLOSED_VOCS" | jq -c '.[]' | while read -r item; do
    ISSUE_NUM=$(echo "$item" | jq -r '.number')
    ISSUE_TITLE=$(echo "$item" | jq -r '.title')
    ISSUE_BODY=$(echo "$item" | jq -r '.body')

    REPORTER=$(echo "$ISSUE_BODY" | grep -Eo '提出人[：:][ ]*[^\|\n\r]+' | head -n 1 | sed -E 's/提出人[：:][ ]*//' || true)
    if [ -z "$REPORTER" ]; then
        REPORTER=$(echo "$ISSUE_BODY" | grep -Eo '反馈用户[：:][ ]*[^\|\n\r]+' | head -n 1 | sed -E 's/反馈用户[：:][ ]*//' || true)
    fi
    if [ -z "$REPORTER" ]; then
        REPORTER=$(echo "$ISSUE_TITLE" | grep -Eo '\[[^]]+\]' | head -n 1 | tr -d '[]' || true)
    fi
    if [ -z "$REPORTER" ]; then
        REPORTER="天使客户"
    fi

    CLEAN_TITLE=$(echo "$ISSUE_TITLE" | sed -E 's/^(fix|feat|chore)\([^)]+\):[ ]*//' | sed -E 's/^(修复|新增|优化)[：:][ ]*//')

    echo ""
    echo "👤 [客户]: ${REPORTER}  |  工单: #${ISSUE_NUM}"
    echo "📝 [诉求/缺陷]: ${CLEAN_TITLE}"
    echo "💬 [建议微信回访文案 (直接复制发送)]:"
    echo "------------------------------------------------------------------------------"
    cat << MSG
${REPORTER}您好！您之前向我们反馈建议的【${CLEAN_TITLE}】，
我们已经在今天发布的 ${VERSION} 正式版本中攻坚完成并上线啦！
目前功能已经部署就绪，您可以随时体验试用。非常感谢您的宝贵建议，若有任何体验问题欢迎随时指导！🙏
MSG
    echo "------------------------------------------------------------------------------"
done

echo ""
echo "=============================================================================="
echo "🎯 及时回访是天使客户转化为忠实布道者的关键飞轮！"
echo "=============================================================================="
echo ""
EOF
chmod +x scripts/notify_voc_reporters.sh
echo "   ✅ scripts/notify_voc_reporters.sh 已就绪"

# 6. 向 AGENTS.md / GEMINI.md / CLAUDE.md 三端注入刚性规约
echo "🛡️ [6/6] 注入跨机工作台协同铁律至全端 AI 指令 (AGENTS.md / GEMINI.md)..."

RULES_CONTENT="
## 🚀 Project Studio 跨机工作台协同铁律 (Mandatory)

1. **工单统一归口**：所有 Bug 修复、特性演进与客户原声（VOC）必须建 Issue 并关联至 GitHub Project #1 (\`Jason's Software Studio\`)。
2. **客户原声闭环 (VOC)**：凡客户反馈必须标注 \`VOC Reporter\` 与 \`label:voc\`；发布上线后 24 小时内必须回访客户。
3. **能力大地图同步**：每次发布新版本若包含新增业务特性，必须同步更新 \`docs/CAPABILITIES.md\` 并提供冒烟验证路径。
4. **提交追溯门禁**：所有 Git Commit 必须携带 \`#<Issue_ID>\`。
5. **端口与环境隔离**：开发与部署严格遵从 \`docs/PORT_REGISTRY.md\`，禁止任意占用其他项目端口。
"

for file in "AGENTS.md" "GEMINI.md"; do
    if [ -f "$file" ]; then
        if ! grep -q "Jason's Software Studio" "$file"; then
            echo "$RULES_CONTENT" >> "$file"
            echo "   ✅ 已向 $file 追加工作台协同铁律"
        else
            echo "   ✓ $file 已包含协同铁律"
        fi
    else
        cat << EOF > "$file"
# Agent Guidelines & Rules
$RULES_CONTENT
EOF
        echo "   ✅ 已新建 $file 并注入协同铁律"
    fi
done

echo ""
echo "=============================================================================="
echo "🎉 项目已成功接入 Jason's Software Studio 统一工作台！"
echo "🌐 全局驾驶舱: https://github.com/users/JasonCry/projects/${PROJECT_NUM}"
echo "=============================================================================="
