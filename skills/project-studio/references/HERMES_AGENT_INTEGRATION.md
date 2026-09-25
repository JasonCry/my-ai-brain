# Hermes Agent (Telegram Bot) 自动配置与接入指南
> 适用对象：运行在 Mac Mini 或服务器上的 Hermes Agent
> 目标：让 Hermes Agent 具备将 Telegram 中的用户反馈、Bug 与新灵感自动解析并入库到 GitHub 全局看板的能力

---

## 📋 给 Hermes Agent 的一键自配置指令包 (直接复制发给 Bot)

```markdown
你好 Hermes！请作为我的智能系统工程助手，为自己配置【软件项目需求与 Bug 自动捕获 (Project Studio VOC)】能力。

请按照以下 4 个步骤自主执行环境检查、脚本部署与规则生效：

### 步骤 1：检查 GitHub CLI 凭证
在终端运行：
```bash
gh auth status
```
- 确认是否已登录 GitHub 账号（必须具备 `JasonCry` 仓库与 Project 的读写权限）。
- 若未登录，请提示管理员执行 `gh auth login`。

---

### 步骤 2：部署一键录入底层脚本
请将以下脚本写入到 `~/.local/bin/record_voc_demand.sh`（若目录不存在请创建）或你的系统脚本目录，并赋予执行权限 `chmod +x`：

```bash
cat << 'EOF' > ~/.local/bin/record_voc_demand.sh
#!/usr/bin/env bash
set -euo pipefail

PROJECT="p12"
TYPE="feature"
REPORTER="用户自提"
TITLE=""
CONTENT=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --project|-p) PROJECT="$2"; shift 2 ;;
        --type|-t) TYPE="$2"; shift 2 ;;
        --reporter|-r) REPORTER="$2"; shift 2 ;;
        --title) TITLE="$2"; shift 2 ;;
        --content|-c) CONTENT="$2"; shift 2 ;;
        *)
            if [ -z "$TITLE" ]; then TITLE="$1";
            elif [ -z "$CONTENT" ]; then CONTENT="$1"; fi
            shift ;;
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

[ -z "$CONTENT" ] && CONTENT="$TITLE"

# 1. 映射目标仓库 (支持自然语言别名)
REPO="JasonCry/P12_Personal_Work_Assistant"
PROJECT_DISPLAY="P12 随身秘书"

shopt -s nocasematch
if [[ "$PROJECT" =~ (wudang|shuyuan|书院|字疏|国学) ]]; then
    REPO="JasonCry/WuDangShuYuan"
    PROJECT_DISPLAY="字疏·书院"
fi
shopt -u nocasematch

# 2. 映射 Label 与前缀
LABELS="voc"
PREFIX="feat"
if [[ "$TYPE" =~ (bug|缺陷|报错|故障|裂图|打不开|异常) ]]; then
    LABELS="voc,bug"
    PREFIX="fix"
elif [[ "$TYPE" =~ (idea|想法|探索|灵感) ]]; then
    LABELS="voc,enhancement"
    PREFIX="idea"
else
    LABELS="voc,enhancement"
    PREFIX="feat"
fi

FULL_TITLE="[${REPORTER}] ${PREFIX}: ${TITLE}"
NOW_TIME=$(date '+%Y-%m-%d %H:%M:%S')

ISSUE_BODY=$(cat << BODYEOF
### 💡 用户原声归档 (Voice of Customer)
- **提出人**: ${REPORTER}
- **接收渠道**: Telegram Bot (Hermes Agent)
- **记录时间**: ${NOW_TIME}
- **诉求类型**: ${TYPE}

### 📝 用户原始描述
> ${CONTENT}

---
*本工单由 Hermes Agent 自动化通道经 Project Studio 军规协议直接创建。*
BODYEOF
)

# 3. 创建 GitHub Issue (无需本地 git 仓库，直接走 API)
CREATE_OUTPUT=$(gh issue create \
    --repo "$REPO" \
    --title "$FULL_TITLE" \
    --body "$ISSUE_BODY" \
    --label "$LABELS" 2>/dev/null || true)

if [ -z "$CREATE_OUTPUT" ]; then
    echo "{\"status":"error","message":"调用 gh issue create 失败，请检查网络或 GitHub 凭证\"}"
    exit 1
fi

ISSUE_URL="$CREATE_OUTPUT"
ISSUE_NUM=$(basename "$ISSUE_URL")

# 4. 挂接至全局 Project #1 看板 (Jason's Software Studio)
gh project item-add 1 --owner "JasonCry" --url "$ISSUE_URL" >/dev/null 2>&1 || true

# 5. 返回纯 JSON 结果
cat << RESULTEOF
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
RESULTEOF
EOF
chmod +x ~/.local/bin/record_voc_demand.sh
```

---

### 步骤 3：加载常驻行为准则 (Behavior Rule)
请将以下规则注入你的系统提示词 (System Prompt) 或长期记忆库 (Long-term Memory) 中：

> **【Project Studio 需求与 Bug 捕获规则】**
> 每当在 Telegram 对话中，收到 Jason 或用户发来的以下内容：
> 1. **Bug / 故障反馈**（例如：打不开、报错、裂图、不响应、崩溃）
> 2. **新功能诉求**（例如：希望支持、能不能加一个、优化交互、增加导出）
> 3. **突发灵感想法**（例如：突然想到一个点子、探索性需求）
> 
> **你必须立即执行**：
> 提取要素并调用脚本：
> `~/.local/bin/record_voc_demand.sh --project "<p12|wudang>" --type "<bug|feature|idea>" --reporter "<提报人姓名或昵称>" --title "<15字精炼标题>" --content "<原始描述>"`
> 
> **项目判断规则**：
> - 提及“国学”、“书院”、“字疏”、“经典”、“甲骨文”、“书法”、“典籍” -> `--project wudang`
> - 提及“随身秘书”、“任务”、“日历”、“甘特图”、“备忘”、“番茄钟”或未指明特定项目的通用诉求 -> `--project p12`
> 
> **回复格式**：
> 脚本执行成功后，以 Telegram 优雅排版回执给用户：
> ```text
> 收到！已录入【{project_name}】需求看板：
> 📋 工单：#{issue_number} ({title})
> 👤 提出人：{reporter}
> 📌 状态：已自动归档至 Jason's Software Studio 全局看板
> 🔗 链接：{issue_url}
> ```

---

### 步骤 4：自检与汇报
完成上述配置后，请在本地运行一次自测命令：
```bash
~/.local/bin/record_voc_demand.sh --project p12 --type idea --reporter "Hermes自检" --title "Hermes Agent接入通道自测" --content "测试自动接入链路是否通畅"
```
测试成功后，请直接在 Telegram 回复我确认配置完毕，并附上测试 Issue 的链接！
```
