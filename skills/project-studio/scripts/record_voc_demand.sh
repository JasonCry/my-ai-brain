#!/usr/bin/env bash
# ==============================================================================
# scripts/record_voc_demand.sh
# 客户原声与想法一键极速录入工具 (Instant VOC & Idea Ingestion Probe)
# 作用: 供 Telegram Bot (Hermes Agent)、CLI 或 Webhook 调用，将自然语言直接落盘为工单并入库全局看板
# ==============================================================================
set -euo pipefail

PROJECT="p12"
TYPE="feature"
REPORTER="用户自提"
TITLE=""
CONTENT=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --project|-p)
            PROJECT="$2"
            shift 2
            ;;
        --type|-t)
            TYPE="$2"
            shift 2
            ;;
        --reporter|-r)
            REPORTER="$2"
            shift 2
            ;;
        --title)
            TITLE="$2"
            shift 2
            ;;
        --content|-c)
            CONTENT="$2"
            shift 2
            ;;
        *)
            if [ -z "$TITLE" ]; then
                TITLE="$1"
            elif [ -z "$CONTENT" ]; then
                CONTENT="$1"
            fi
            shift
            ;;
    esac
done

if [ -z "$TITLE" ]; then
    if [ -n "$CONTENT" ]; then
        TITLE=$(echo "$CONTENT" | head -n 1 | cut -c 1-30)
    else
        echo '{"status":"error","message":"缺少标题或内容 (--title 或 --content)"}'
        exit 1
    fi
fi

if [ -z "$CONTENT" ]; then
    CONTENT="$TITLE"
fi

# 1. 映射目标仓库
REPO="JasonCry/P12_Personal_Work_Assistant"
PROJECT_DISPLAY="P12 随身秘书"
PROJECT_DIR="$HOME/Projects/P12_Personal_Work_Assistant"

shopt -s nocasematch
if [[ "$PROJECT" =~ (wudang|shuyuan|书院|字疏) ]]; then
    REPO="JasonCry/WuDangShuYuan"
    PROJECT_DISPLAY="字疏·书院"
    PROJECT_DIR="$HOME/Projects/WuDangShuYuan"
fi
shopt -u nocasematch

# 2. 映射 Label
LABELS="voc"
PREFIX="feat"
if [[ "$TYPE" =~ (bug|缺陷|报错|故障) ]]; then
    LABELS="voc,bug"
    PREFIX="fix"
elif [[ "$TYPE" =~ (idea|想法|探索) ]]; then
    LABELS="voc,enhancement"
    PREFIX="idea"
else
    LABELS="voc,enhancement"
    PREFIX="feat"
fi

FULL_TITLE="[${REPORTER}] ${PREFIX}: ${TITLE}"
NOW_TIME=$(date '+%Y-%m-%d %H:%M:%S')

ISSUE_BODY=$(cat << EOF
### 💡 用户原声归档 (Voice of Customer)
- **提出人**: ${REPORTER}
- **接收渠道**: Telegram Bot (Hermes Agent)
- **记录时间**: ${NOW_TIME}
- **诉求类型**: ${TYPE}

### 📝 用户原始描述
> ${CONTENT}

---
*本工单由 Hermes Agent 自动化接入通道经 Project Studio 军规协议直接创建。*
EOF
)

# 3. 创建 GitHub Issue
CREATE_OUTPUT=$(gh issue create \
    --repo "$REPO" \
    --title "$FULL_TITLE" \
    --body "$ISSUE_BODY" \
    --label "$LABELS" 2>/dev/null || true)

if [ -z "$CREATE_OUTPUT" ]; then
    echo "{\"status\":\"error\",\"message\":\"调用 gh issue create 失败，请检查网络或 GitHub 凭证\"}"
    exit 1
fi

ISSUE_URL="$CREATE_OUTPUT"
ISSUE_NUM=$(basename "$ISSUE_URL")

# 4. 关联至全局 Project #1 (Jason's Software Studio)
gh project item-add 1 --owner "JasonCry" --url "$ISSUE_URL" >/dev/null 2>&1 || true

# 5. 返回纯 JSON 结果供 Hermes Bot 组织自然语言回复
cat << EOF
{
  "status": "success",
  "project_name": "${PROJECT_DISPLAY}",
  "repository": "${REPO}",
  "issue_number": ${ISSUE_NUM},
  "issue_url": "${ISSUE_URL}",
  "reporter": "${REPORTER}",
  "type": "${TYPE}",
  "title": "${TITLE}",
  "timestamp": "${NOW_TIME}"
}
EOF
