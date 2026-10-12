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

# 1.5 自动注入 Matt Pocock 核心技能的自动触发描述 (防止被上游被动式 description 覆盖)
echo "   ➔ 正在固化 Matt Pocock 核心工程技能的自动触发器 (Auto-Trigger Patch)..."
python3 - "${BRAIN_ROOT}/skills" << 'PY_EOF'
import os, re, sys

skills_root = sys.argv[1]
overrides = {
    "codebase-design": 'Shared vocabulary and architecture discipline for designing deep modules (module, interface, depth, seam, adapter, leverage, locality). TRIGGER AUTOMATICALLY on ANY non-trivial coding task when creating or modifying modules, designing interfaces/APIs, deciding where a seam goes, refactoring, or making code testable and AI-navigable.',
    "tdd": 'Test-driven development (vertical tracer-bullet slices, red-green loop at pre-agreed public seams). TRIGGER AUTOMATICALLY whenever implementing new features, writing business logic, fixing bugs, or writing/updating tests.',
    "diagnosing-bugs": 'Systematic diagnosis loop (tight feedback loop -> falsifiable hypotheses -> root-cause fix with regression test) for bugs and performance regressions. TRIGGER AUTOMATICALLY whenever the user reports a bug, error, crash, exception, broken behavior, failing test, or performance issue.',
    "grill-with-docs": 'A relentless interview to sharpen a plan, feature, or design while maintaining CONTEXT.md and ADRs. TRIGGER AUTOMATICALLY when the user proposes a new feature, architectural change, or underspecified requirement in a working directory.',
    "implement": '"End-to-end code implementation workflow driving /tdd at pre-agreed seams, regular typechecking/test runs, and /code-review before commit. TRIGGER AUTOMATICALLY when implementing features, specs, issues, or coding tasks."',
    "code-review": '"Review the changes since a fixed point (commit, branch, tag, or merge-base) along two axes: Standards (does the code follow this repo\'s documented coding standards?) and Spec (does the code match what the originating issue/spec asked for?). Runs both reviews in parallel sub-agents and reports them side by side. TRIGGER AUTOMATICALLY after completing feature/bug code implementation before final delivery, or when the user asks to review a branch, PR, or work-in-progress changes."'
}

for skill, desc in overrides.items():
    p = os.path.join(skills_root, skill, "SKILL.md")
    if os.path.exists(p):
        with open(p, "r", encoding="utf-8") as f:
            content = f.read()
        new_content = re.sub(
            r"(?m)^description:.*$",
            f"description: {desc}",
            content,
            count=1
        )
        with open(p, "w", encoding="utf-8") as f:
            f.write(new_content)
PY_EOF

# 2. 刷新全局软链接
echo "   ➔ 正在刷新本机全局软链接..."
bash "${BRAIN_ROOT}/bin/install-global.sh"

echo "✨ [my-ai-brain] 第三方 Skills 同步完成！"
echo "   ➔ 本地 Skills 已全部升至官方最新版本（并已固化自动触发器）。"
echo "   ➔ 提示：如需将拉取到的新版 Skills 备份至你个人的 GitHub，请执行 /ai-brain-push"
