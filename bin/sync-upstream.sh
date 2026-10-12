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

# 拷贝更新到本地 skills 目录（跳过已归档、已裁剪及本地深度定制的技能）
echo "   ➔ 正在比对并同步上游技能到 skills/（保护本地定制与归档过滤）..."
SKIP_SKILLS="grill-with-docs to-spec implement implement-spec grill-me gh-driven-workflow ponytail-gain ponytail-help loop-me ask-matt wait-what"
for s_dir in "${MATT_DIR}/skills"/*; do
  [ -d "${s_dir}" ] || continue
  s_name="$(basename "${s_dir}")"
  if [ -d "${BRAIN_ROOT}/archived-skills/${s_name}" ]; then
    continue
  fi
  if echo " ${SKIP_SKILLS} " | grep -q " ${s_name} "; then
    continue
  fi
  cp -r "${s_dir}" "${BRAIN_ROOT}/skills/"
done

# 1.5 自动固化精简版 L0 路由描述 (防止被上游冗长 description 覆盖)
echo "   ➔ 正在固化 L0 极简路由描述 (Concise Catalog Patch)..."
python3 - "${BRAIN_ROOT}/skills" << 'PY_EOF'
import os, re, sys

skills_root = sys.argv[1]
overrides = {
    "codebase-design": "Deep module architecture and interface seam design discipline for non-trivial coding or refactoring.",
    "tdd": "Test-driven development loop (Red -> Green -> Refactor) at public interface seams.",
    "diagnosing-bugs": "Systematic bug diagnosis (reproduction loop, falsifiable hypotheses, root-cause fix) for complex bugs.",
    "code-review": "Dual-axis code review (Standards & Spec compliance) before delivery or when reviewing diffs/PRs.",
    "ponytail": "YAGNI minimal coding discipline: stdlib first, zero speculative abstractions, shortest working solution.",
    "ponytail-audit": "Whole-repo audit for over-engineering: ranked list of bloat and abstractions to delete or simplify.",
    "ponytail-debt": "Harvest all `ponytail:` shortcut comments across the codebase into a tracked technical debt ledger.",
    "ponytail-review": "Diff/PR review focused exclusively on cutting over-engineering, dead flexibility, and unneeded deps.",
}

for skill, desc in overrides.items():
    p = os.path.join(skills_root, skill, "SKILL.md")
    if os.path.exists(p):
        with open(p, "r", encoding="utf-8") as f:
            content = f.read()
        m = re.match(r"^---\n(.*?)\n---\n?(.*)", content, re.S)
        if m:
            body = m.group(2).lstrip()
            with open(p, "w", encoding="utf-8") as f:
                f.write(f"---\nname: {skill}\ndescription: {desc}\n---\n\n" + body)
PY_EOF

# 2. 刷新全局软链接
echo "   ➔ 正在刷新本机全局软链接..."
bash "${BRAIN_ROOT}/bin/install-global.sh"

echo "✨ [my-ai-brain] 第三方 Skills 同步完成！"
echo "   ➔ 本地 Skills 已全部升至官方最新版本（并已固化自动触发器）。"
echo "   ➔ 提示：如需将拉取到的新版 Skills 备份至你个人的 GitHub，请执行 /ai-brain-push"
