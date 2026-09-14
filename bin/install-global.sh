#!/usr/bin/env bash
# ==============================================================================
# my-ai-brain: install-global.sh
# 将本资产库中的所有 Skills、全局配置软链挂载到本机全局 AI 环境
# ==============================================================================

set -euo pipefail

BRAIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🧠 [my-ai-brain] 正在配置本机全局 AI 工程环境..."

# 1. 配置 Antigravity 全局 Skills
GEMINI_SKILLS_DIR="${HOME}/.gemini/config/skills"
mkdir -p "${GEMINI_SKILLS_DIR}"
echo "   ➔ 挂载 Skills 到 Antigravity (${GEMINI_SKILLS_DIR})..."
for skill in "${BRAIN_ROOT}/skills"/*; do
  if [ -d "${skill}" ]; then
    skill_name="$(basename "${skill}")"
    # 如果目标目录存在且不是软链，先备份或直接建立软链
    if [ ! -e "${GEMINI_SKILLS_DIR}/${skill_name}" ]; then
      ln -s "${skill}" "${GEMINI_SKILLS_DIR}/${skill_name}"
    fi
  fi
done

# 2. 配置 Claude Code 全局目录（若支持）
CLAUDE_DIR="${HOME}/.claude"
mkdir -p "${CLAUDE_DIR}"

# 3. 创建全局命令行别名 `ai-brain` 方便日常使用
BIN_DIR="${HOME}/.local/bin"
mkdir -p "${BIN_DIR}"
cat << 'EOF' > "${BIN_DIR}/ai-brain"
#!/usr/bin/env bash
BRAIN_PATH="${HOME}/Projects/my-ai-brain"
case "${1:-help}" in
  init)
    bash "${BRAIN_PATH}/bin/init-project.sh" "${2:-.}"
    ;;
  sync)
    bash "${BRAIN_PATH}/bin/install-global.sh"
    ;;
  update)
    (cd "${BRAIN_PATH}" && git pull) && bash "${BRAIN_PATH}/bin/install-global.sh"
    ;;
  *)
    echo "Usage: ai-brain [init|sync|update]"
    echo "  init [dir]   - 为当前或指定项目注入全套 AI SOP 与规则"
    echo "  sync         - 同步本地 skills 到本机全局 AI 环境"
    echo "  update       - 从 GitHub 拉取最新资产并同步"
    ;;
esac
EOF
chmod +x "${BIN_DIR}/ai-brain"

echo "✅ [my-ai-brain] 本机全局配置完成！"
echo "   ➔ 已在 ~/.local/bin/ai-brain 生成 CLI 工具。"
echo "   ➔ 以后在任意新工程目录下，只需输入: ai-brain init 即可一秒生效！"
