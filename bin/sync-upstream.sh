#!/usr/bin/env bash
# ==============================================================================
# my-ai-brain: sync-upstream.sh
# 自动拉取 upstream.json 登记的第三方开源 Skills 最新版本并合并至本地
# ==============================================================================

set -euo pipefail

BRAIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP_DIR="/tmp/ai-brain-upstream-cache"

echo "🔄 [my-ai-brain] 正在检查第三方 Skills 上游更新..."

mkdir -p "${TEMP_DIR}"

# 1. 同步 Matt Pocock 技能库
MATT_REPO="https://github.com/mattpocock/skills.git"
MATT_DIR="${TEMP_DIR}/mattpocock-skills"

echo "   ➔ 检查 Matt Pocock 官方 Skills 仓库..."
if [ -d "${MATT_DIR}/.git" ]; then
  (cd "${MATT_DIR}" && git pull origin main --quiet)
else
  git clone --depth 1 "${MATT_REPO}" "${MATT_DIR}" --quiet
fi

# 拷贝更新到本地 skills 目录
echo "   ➔ 正在比对并同步上游技能到 skills/..."
cp -r "${MATT_DIR}/skills"/* "${BRAIN_ROOT}/skills/"

# 2. 刷新全局软链接
echo "   ➔ 正在刷新本机全局软链接..."
bash "${BRAIN_ROOT}/bin/install-global.sh"

echo "✨ [my-ai-brain] 第三方 Skills 同步完成！"
echo "   ➔ 本地 Skills 已全部升至官方最新版本。"
echo "   ➔ 提示：如需将拉取到的新版 Skills 备份至你个人的 GitHub，请执行 /ai-brain-push"
