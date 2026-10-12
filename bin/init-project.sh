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

[ ! -f "${TARGET_DIR}/.cursorrules" ] && cp "${BRAIN_ROOT}/rules/.cursorrules" "${TARGET_DIR}/"
cp "${BRAIN_ROOT}/rules/engineering-sop.mdc" "${TARGET_DIR}/.cursor/rules/"
[ ! -f "${TARGET_DIR}/.windsurfrules" ] && cp "${BRAIN_ROOT}/rules/.windsurfrules" "${TARGET_DIR}/"
[ ! -f "${TARGET_DIR}/.github/copilot-instructions.md" ] && cp "${BRAIN_ROOT}/rules/copilot-instructions.md" "${TARGET_DIR}/.github/"

# 4. 注入三层渐进式代码导航探针与自动同步底座 (3-Tier Progressive Code Navigation)
echo "   ➔ 注入三层代码导航探针 (scripts/code_query.sh & auto_sync_code_index.sh)..."
mkdir -p "${TARGET_DIR}/scripts"
cp "${BRAIN_ROOT}/templates/scripts/code_query.sh" "${TARGET_DIR}/scripts/code_query.sh"
cp "${BRAIN_ROOT}/templates/scripts/auto_sync_code_index.sh" "${TARGET_DIR}/scripts/auto_sync_code_index.sh"
chmod +x "${TARGET_DIR}/scripts/code_query.sh" "${TARGET_DIR}/scripts/auto_sync_code_index.sh"

if [ ! -f "${TARGET_DIR}/docs/CAPABILITIES.md" ] && [ -f "${BRAIN_ROOT}/templates/docs/CAPABILITIES.template.md" ]; then
  cp "${BRAIN_ROOT}/templates/docs/CAPABILITIES.template.md" "${TARGET_DIR}/docs/CAPABILITIES.md"
fi
if [ ! -f "${TARGET_DIR}/llms.txt" ] && [ -f "${BRAIN_ROOT}/templates/docs/llms.template.txt" ]; then
  cp "${BRAIN_ROOT}/templates/docs/llms.template.txt" "${TARGET_DIR}/llms.txt"
fi

if [ -d "${TARGET_DIR}/.git" ]; then
  echo "   ➔ 挂载 Git pre-commit 增量索引钩子 (.git/hooks/pre-commit)..."
  mkdir -p "${TARGET_DIR}/.git/hooks"
  cp "${BRAIN_ROOT}/templates/hooks/pre-commit" "${TARGET_DIR}/.git/hooks/pre-commit"
  chmod +x "${TARGET_DIR}/.git/hooks/pre-commit"
fi

# 首次初始化生成当前项目的 docs/ARCHITECTURE_SEAMS.json
"${TARGET_DIR}/scripts/auto_sync_code_index.sh" || true

echo "✅ [my-ai-brain] 注入完成！该项目已即刻具备以下能力："
echo "   1. Antigravity / Gemini: 自动加载 AGENTS.md 与工程 SOP"
echo "   2. Claude Code: 自动识别 CLAUDE.md 并执行 3 大 SOP"
echo "   3. Cursor / Windsurf / Copilot: 全套规则自动生效"
echo "   4. 零盲搜三层代码导航: llms.txt + CAPABILITIES.md + code_query.sh (trace/outline/symbol) + Git Hook 自动随动"
