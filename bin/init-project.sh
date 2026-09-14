#!/usr/bin/env bash
# ==============================================================================
# my-ai-brain: init-project.sh
# 将本 AI 工程资产库中的通用 SOP、规则模板一键注入到任意目标项目仓库
# ==============================================================================

set -euo pipefail

TARGET_DIR="${1:-.}"
BRAIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🧠 [my-ai-brain] 正在为目标项目注入统一工程资产: ${TARGET_DIR}..."

# 1. 建立目录结构
mkdir -p "${TARGET_DIR}/docs/agents"
mkdir -p "${TARGET_DIR}/.cursor/rules"
mkdir -p "${TARGET_DIR}/.github"

# 2. 注入单一事实源 (SSOT) SOP 文件
echo "   ➔ 写入 SOP 规范文档 (docs/agents/)..."
cp "${BRAIN_ROOT}/sop/engineering_sop.md" "${TARGET_DIR}/docs/agents/"
[ -f "${BRAIN_ROOT}/sop/issue-tracker.md" ] && cp "${BRAIN_ROOT}/sop/issue-tracker.md" "${TARGET_DIR}/docs/agents/"
[ -f "${BRAIN_ROOT}/sop/triage-labels.md" ] && cp "${BRAIN_ROOT}/sop/triage-labels.md" "${TARGET_DIR}/docs/agents/"
[ -f "${BRAIN_ROOT}/sop/domain.md" ] && cp "${BRAIN_ROOT}/sop/domain.md" "${TARGET_DIR}/docs/agents/"

# 3. 注入多 AI 入口规则
echo "   ➔ 注入多 AI 统一规则入口 (AGENTS, Claude, Cursor, Windsurf, Copilot)..."
if [ ! -f "${TARGET_DIR}/AGENTS.md" ]; then
  cp "${BRAIN_ROOT}/rules/AGENTS.md" "${TARGET_DIR}/"
else
  if ! grep -q "## Agent skills" "${TARGET_DIR}/AGENTS.md"; then
    echo "" >> "${TARGET_DIR}/AGENTS.md"
    cat "${BRAIN_ROOT}/rules/AGENTS.md" >> "${TARGET_DIR}/AGENTS.md"
  fi
fi

if [ ! -f "${TARGET_DIR}/CLAUDE.md" ]; then
  cp "${BRAIN_ROOT}/rules/CLAUDE.md" "${TARGET_DIR}/"
else
  if ! grep -q "Automated SOP" "${TARGET_DIR}/CLAUDE.md"; then
    echo "" >> "${TARGET_DIR}/CLAUDE.md"
    cat "${BRAIN_ROOT}/rules/CLAUDE.md" >> "${TARGET_DIR}/CLAUDE.md"
  fi
fi

cp "${BRAIN_ROOT}/rules/.cursorrules" "${TARGET_DIR}/"
cp "${BRAIN_ROOT}/rules/engineering-sop.mdc" "${TARGET_DIR}/.cursor/rules/"
cp "${BRAIN_ROOT}/rules/.windsurfrules" "${TARGET_DIR}/"
cp "${BRAIN_ROOT}/rules/copilot-instructions.md" "${TARGET_DIR}/.github/"

echo "✅ [my-ai-brain] 注入完成！该项目已即刻具备以下能力："
echo "   1. Antigravity / Gemini: 自动加载 AGENTS.md 与工程 SOP"
echo "   2. Claude Code: 自动识别 CLAUDE.md 并执行 3 大 SOP"
echo "   3. Cursor: .cursorrules & .cursor/rules/ 生效"
echo "   4. Windsurf: .windsurfrules 自动生效"
echo "   5. GitHub Copilot: .github/copilot-instructions.md 生效"
