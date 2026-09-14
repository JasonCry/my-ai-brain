#!/usr/bin/env bash
# ==============================================================================
# my-ai-brain: install-global.sh
# 将本资产库中的所有 Skills、全局配置软链挂载到本机全局 AI 环境
# ==============================================================================

set -euo pipefail

BRAIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🧠 [my-ai-brain] 正在配置本机全局 AI 工程环境..."

# 1. 配置 Antigravity 全局 Skills (采用软链接，保证 git pull 后实时自动生效)
GEMINI_SKILLS_DIR="${HOME}/.gemini/config/skills"
mkdir -p "${GEMINI_SKILLS_DIR}"
echo "   ➔ 软链挂载 Skills 到 Antigravity (${GEMINI_SKILLS_DIR})..."
for skill in "${BRAIN_ROOT}/skills"/*; do
  if [ -d "${skill}" ]; then
    skill_name="$(basename "${skill}")"
    target="${GEMINI_SKILLS_DIR}/${skill_name}"
    
    # 若目标已是正确的软链接，跳过
    if [ -L "${target}" ] && [ "$(readlink "${target}")" = "${skill}" ]; then
      continue
    fi
    
    # 若存在且不是正确软链接（如旧物理文件夹），安全替换
    rm -rf "${target}"
    ln -s "${skill}" "${target}"
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
    echo "🔄 正在从 GitHub 同步最新 AI 工程资产..."
    (cd "${BRAIN_PATH}" && git pull origin main) && bash "${BRAIN_PATH}/bin/install-global.sh"
    echo "✨ 同步完成！当前所有 AI 工具已具备最新工程能力。"
    ;;
  *)
    echo "Usage: ai-brain [init|sync|update]"
    echo "  init [dir]   - 为当前或指定项目注入全套 AI SOP 与规则"
    echo "  sync         - 刷新本地 skills 软链到本机各 AI 工具"
    echo "  update       - 从 GitHub 拉取最新资产并自动刷新全局能力"
    ;;
esac
EOF
chmod +x "${BIN_DIR}/ai-brain"

echo "✅ [my-ai-brain] 本机全局配置完成！"
echo "   ➔ 已建立实时软链：只要 my-ai-brain 仓库更新，Antigravity/多 AI 即刻无感生效！"
echo "   ➔ 终端随时可用: ai-brain update 升级。"
