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
cat << 'CLI_EOF' > "${BIN_DIR}/ai-brain"
#!/usr/bin/env bash
BRAIN_PATH="${HOME}/Projects/my-ai-brain"
case "${1:-help}" in
  init)
    bash "${BRAIN_PATH}/bin/init-project.sh" "${2:-.}"
    ;;
  sync)
    bash "${BRAIN_PATH}/bin/install-global.sh"
    ;;
  status)
    echo "📊 [my-ai-brain] 当前资产库状态:"
    (cd "${BRAIN_PATH}" && git status)
    ;;
  push)
    MSG="${2:-feat: update skills and engineering assets}"
    echo "🚀 [my-ai-brain] 正在提交并推送到 GitHub 远程仓库..."
    (cd "${BRAIN_PATH}" && git add . && git commit -m "${MSG}" && git push origin main)
    echo "✨ 推送完成！"
    ;;
  update)
    echo "🔄 正在从 GitHub 同步最新 AI 工程资产..."
    (cd "${BRAIN_PATH}" && git pull origin main) && bash "${BRAIN_PATH}/bin/install-global.sh"
    echo "✨ 同步完成！当前所有 AI 工具已具备最新工程能力。"
    ;;
  kb-sync|kb-pull)
    KB_PATH="${HOME}/Projects/SoftwareDevKnowledgeBase"
    if [ ! -d "${KB_PATH}" ]; then
      echo "📥 [KnowledgeBase] 正在克隆中央知识库..."
      git clone https://github.com/JasonCry/SoftwareDevKnowledgeBase.git "${KB_PATH}"
    else
      echo "🔄 [KnowledgeBase] 正在从 GitHub 同步最新知识与 CBB..."
      (cd "${KB_PATH}" && git pull origin main)
    fi
    echo "✨ 知识库同步完成！"
    ;;
  kb-push)
    KB_PATH="${HOME}/Projects/SoftwareDevKnowledgeBase"
    MSG="${2:-feat: update knowledge base docs and cbb assets}"
    echo "🚀 [KnowledgeBase] 正在提交并推送到 GitHub 远程仓库..."
    (cd "${KB_PATH}" && git add . && git commit -m "${MSG}" && git push origin main)
    echo "✨ 知识库推送完成！所有开发环境现已共享最新资产。"
    ;;
  kb-status)
    KB_PATH="${HOME}/Projects/SoftwareDevKnowledgeBase"
    echo "📊 [KnowledgeBase] 当前知识库资产状态:"
    (cd "${KB_PATH}" && git status)
    ;;
  *)
    echo "Usage: ai-brain [init|sync|status|push|update|kb-sync|kb-push|kb-status]"
    echo "  init [dir]   - 为当前或指定项目注入全套 AI SOP 与规则"
    echo "  sync         - 刷新本地 skills 软链到本机各 AI 工具"
    echo "  status       - 查看本地 my-ai-brain 资产库改动状态"
    echo "  push [msg]   - 一键将本地新技能与修改推送到 GitHub 仓库"
    echo "  update       - 从 GitHub 拉取最新资产并自动刷新全局能力"
    echo "  kb-sync      - 从 GitHub 同步 SoftwareDevKnowledgeBase 最新知识与 CBB"
    echo "  kb-push [msg]- 一键将本地沉淀的新知识与 CBB 推送至 GitHub 共享"
    echo "  kb-status    - 查看中央知识库 Git 改动状态"
    ;;
esac
CLI_EOF
chmod +x "${BIN_DIR}/ai-brain"

echo "✅ [my-ai-brain] 本机全局配置完成！"
echo "   ➔ 已建立实时软链：只要 my-ai-brain 仓库更新，Antigravity/多 AI 即刻无感生效！"
echo "   ➔ 终端随时可用: ai-brain [sync|status|push|update|init]"
