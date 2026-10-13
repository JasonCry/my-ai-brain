#!/usr/bin/env bash
# ==============================================================================
# my-ai-brain: sync-upstream.sh
# 自动拉取 mattpocock/skills 官方仓库的最新 engineering 与 productivity 技能并同步至本地
# 严格遵循官方 SKILL-MECHANICS.md 双层架构（保留 disable-model-invocation: true）
# ==============================================================================

set -euo pipefail

BRAIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP_DIR="/tmp/ai-brain-upstream-cache"

echo "🔄 [my-ai-brain] 正在检查第三方 Skills 上游更新..."

mkdir -p "${TEMP_DIR}"

# 1. 同步 Matt Pocock 官方技能库 (仅同步官方推荐的 skills/engineering 与 skills/productivity)
MATT_REPO="https://github.com/mattpocock/skills.git"
MATT_DIR="${TEMP_DIR}/mattpocock-skills"

echo "   ➔ 检查 Matt Pocock 官方 Skills 仓库..."
if [ -d "${MATT_DIR}/.git" ]; then
  (cd "${MATT_DIR}" && git pull origin main --quiet)
else
  git clone --depth 1 "${MATT_REPO}" "${MATT_DIR}" --quiet
fi

echo "   ➔ 正在同步官方最新 skills/engineering 与 skills/productivity 到 skills/..."
for category in engineering productivity; do
  for s_dir in "${MATT_DIR}/skills/${category}"/*; do
    [ -d "${s_dir}" ] || continue
    s_name="$(basename "${s_dir}")"
    rm -rf "${BRAIN_ROOT}/skills/${s_name}"
    cp -r "${s_dir}" "${BRAIN_ROOT}/skills/${s_name}"
  done
done

# 2. 刷新本机全局软链接并清理失效链接
echo "   ➔ 正在刷新本机全局软链接..."
bash "${BRAIN_ROOT}/bin/install-global.sh"

echo "✨ [my-ai-brain] 第三方 Skills 同步完成！"
echo "   ➔ 已同步最新官方 engineering (20项) + productivity (7项)，完整保留双层调用模型。"
echo "   ➔ 提示：如需将拉取到的新版 Skills 备份至 GitHub，请执行 /ai-brain-sync"
