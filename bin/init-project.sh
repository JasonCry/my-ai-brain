#!/usr/bin/env bash
# ==============================================================================
# my-ai-brain: init-project.sh
# 将本 AI 工程资产库中的通用 SOP、轻量正交索引与 Git Hooks 一键幂等注入目标项目
# 架构原则:
#   1. 全局配置 (~/.gemini/GEMINI.md, ~/.claude/CLAUDE.md, ~/.codex/AGENTS.md) 承载跨项目通用 SOP；
#   2. 项目根目录仅维护唯一入口 AGENTS.md（主流 AI 工具全部原生识别），不生成重复的 CLAUDE.md / .cursorrules 等影子文件。
# ==============================================================================

set -euo pipefail

TARGET_DIR="${1:-.}"
BRAIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🧠 [my-ai-brain] 正在为目标项目注入统一工程资产 (All-in AGENTS.md 正交模式): ${TARGET_DIR}..."

# 1. 建立目录结构并清理历史遗留的多余影子规则文件（避免遮蔽 AGENTS.md）
mkdir -p "${TARGET_DIR}/docs/agents"
rm -f "${TARGET_DIR}/CLAUDE.md" \
      "${TARGET_DIR}/.cursorrules" \
      "${TARGET_DIR}/.windsurfrules" \
      "${TARGET_DIR}/.github/copilot-instructions.md" \
      "${TARGET_DIR}/.cursor/rules/engineering-sop.mdc"
rmdir "${TARGET_DIR}/.cursor/rules" "${TARGET_DIR}/.cursor" 2>/dev/null || true

# 2. 注入单一事实源 (SSOT) SOP 参考文档与结构化 Spec 契约模板
echo "   ➔ 写入 SOP 规范文档与 Spec 模板 (docs/agents/)..."
cp "${BRAIN_ROOT}/sop/engineering_sop.md" "${TARGET_DIR}/docs/agents/"
[ -f "${BRAIN_ROOT}/templates/docs/SPEC.template.md" ] && cp "${BRAIN_ROOT}/templates/docs/SPEC.template.md" "${TARGET_DIR}/docs/agents/"
[ -f "${BRAIN_ROOT}/sop/issue-tracker.md" ] && cp "${BRAIN_ROOT}/sop/issue-tracker.md" "${TARGET_DIR}/docs/agents/"
[ -f "${BRAIN_ROOT}/sop/triage-labels.md" ] && cp "${BRAIN_ROOT}/sop/triage-labels.md" "${TARGET_DIR}/docs/agents/"
[ -f "${BRAIN_ROOT}/sop/domain.md" ] && cp "${BRAIN_ROOT}/sop/domain.md" "${TARGET_DIR}/docs/agents/"

# 3. 幂等注入项目级 AGENTS.md 正交轻量托管块（不重复拷贝全局已有的大段通用 SOP）
echo "   ➔ 幂等同步项目唯一规则入口 (AGENTS.md)..."
python3 - "${TARGET_DIR}/AGENTS.md" << 'PY_EOF'
import os, re, sys

target_path = sys.argv[1]

block = """<!-- my-ai-brain:begin -->
## 🧠 Project-Level AI Brain Index & References (Orthogonal to Global Rules)

> 全局通用规则（沟通契约、SOP 1~3 阶段卡与 L1/L2 渐进式技能纪律、Docling 门禁）已由本机全局配置（`~/.gemini/GEMINI.md`、`~/.claude/CLAUDE.md`、`~/.codex/AGENTS.md`）统一注入，此处不再重复拷贝。

- **Index-First 三层代码定位与左移快检（严禁全仓盲目 `grep`）**：
  1. **L0 宏观锁域**：读取 `llms.txt` 或执行 `./scripts/code_query.sh feature <关键词>`（检索 `docs/CAPABILITIES.md`）。
  2. **L1 中观溯源**：执行 `./scripts/code_query.sh trace <API或模块名>`（检索 `docs/ARCHITECTURE_SEAMS.json`）。
  3. **L2 微观定行**：执行 `./scripts/code_query.sh outline <文件>` 或 `./scripts/code_query.sh symbol <符号>` 获取 `[LStart-LEnd]`，再用 `view_file` 按行切片读写。
  4. **Shift-Left 秒级快检**：在重型构建前优先运行 `./scripts/verify_fast.sh` 完成增量编译与静态检查。
- **Automated Engineering SOPs & Spec Template**:
  - **SOP Reference**: `docs/agents/engineering_sop.md`
  - **Structured Spec Template**: `docs/agents/SPEC.template.md`

## Agent skills

### Issue tracker

Issues and specs for this repo live in GitHub Issues (via the `gh` CLI). See `docs/agents/issue-tracker.md`.

### Triage labels

Default five canonical triage roles (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context layout (`GLOSSARY.md` at repo root, compatible with legacy `CONTEXT.md`, and `docs/adr/`). See `docs/agents/domain.md`.
<!-- my-ai-brain:end -->
"""

if os.path.exists(target_path):
    with open(target_path, "r", encoding="utf-8") as f:
        existing = f.read()
    if "<!-- my-ai-brain:begin -->" in existing:
        updated = re.sub(
            r"<!-- my-ai-brain:begin -->.*?<!-- my-ai-brain:end -->\n?",
            block,
            existing,
            flags=re.S
        )
    else:
        updated = existing.rstrip() + "\n\n" + block
else:
    header = "# Agent Guidelines & Engineering Standards\n\n> 本文件为当前项目唯一的 AI 工程开发与架构规范入口（Antigravity、Claude Code、Codex、DSH、Cursor 均自动识别）。\n\n"
    updated = header + block

with open(target_path, "w", encoding="utf-8") as f:
    f.write(updated)
PY_EOF

# 4. 注入三层渐进式代码导航探针、秒级快检与自动同步底座
echo "   ➔ 注入三层代码导航探针与秒级快检 (scripts/code_query.sh, verify_fast.sh, auto_sync_code_index.sh)..."
mkdir -p "${TARGET_DIR}/scripts"
cp "${BRAIN_ROOT}/templates/scripts/code_query.sh" "${TARGET_DIR}/scripts/code_query.sh"
cp "${BRAIN_ROOT}/templates/scripts/auto_sync_code_index.sh" "${TARGET_DIR}/scripts/auto_sync_code_index.sh"
[ -f "${BRAIN_ROOT}/templates/scripts/verify_fast.sh" ] && cp "${BRAIN_ROOT}/templates/scripts/verify_fast.sh" "${TARGET_DIR}/scripts/verify_fast.sh"
chmod +x "${TARGET_DIR}/scripts/code_query.sh" "${TARGET_DIR}/scripts/auto_sync_code_index.sh" "${TARGET_DIR}/scripts/verify_fast.sh" 2>/dev/null || true

if [ ! -f "${TARGET_DIR}/docs/CAPABILITIES.md" ] && [ -f "${BRAIN_ROOT}/templates/docs/CAPABILITIES.template.md" ]; then
  cp "${BRAIN_ROOT}/templates/docs/CAPABILITIES.template.md" "${TARGET_DIR}/docs/CAPABILITIES.md"
fi
if [ ! -f "${TARGET_DIR}/llms.txt" ] && [ -f "${BRAIN_ROOT}/templates/docs/llms.template.txt" ]; then
  cp "${BRAIN_ROOT}/templates/docs/llms.template.txt" "${TARGET_DIR}/llms.txt"
fi

if [ -d "${TARGET_DIR}/.git" ]; then
  echo "   ➔ 挂载 Git pre-commit 与 commit-msg 物理门禁钩子 (.git/hooks/)..."
  mkdir -p "${TARGET_DIR}/.git/hooks"
  cp "${BRAIN_ROOT}/templates/hooks/pre-commit" "${TARGET_DIR}/.git/hooks/pre-commit"
  chmod +x "${TARGET_DIR}/.git/hooks/pre-commit"
  if [ -f "${BRAIN_ROOT}/templates/hooks/commit-msg" ]; then
    cp "${BRAIN_ROOT}/templates/hooks/commit-msg" "${TARGET_DIR}/.git/hooks/commit-msg"
    chmod +x "${TARGET_DIR}/.git/hooks/commit-msg"
  fi
fi

# 首次初始化生成当前项目的 docs/ARCHITECTURE_SEAMS.json
"${TARGET_DIR}/scripts/auto_sync_code_index.sh" || true

echo "✅ [my-ai-brain] 注入完成！该项目已收敛为 All-in AGENTS.md 正交模式："
echo "   1. 唯一入口: AGENTS.md (Antigravity / Claude Code / Codex / DSH / Cursor 全工具原生识别，零影子文件污染)"
echo "   2. 正交分层: 全局配置管通用 SOP，项目 AGENTS.md 仅管项目契约与轻量索引（消除双重 Token 注入）"
echo "   3. 物理门禁: llms.txt + code_query.sh + Git Hooks (版本防呆 + #IssueID 校验 + 接缝自动随动)"
