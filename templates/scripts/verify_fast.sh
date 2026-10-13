#!/usr/bin/env bash
# ==============================================================================
# scripts/verify_fast.sh
# 秒级左移质量门禁探针 (Shift-Left Inner-Loop Fast Verification)
# 作用: 在运行耗时的全量打包/部署前，基于 git diff 仅对发生变更的模块执行秒级静态与编译检查
# 支持技术栈: Rust (Cargo) + Flutter (Dart) + TypeScript/Node (tsconfig/package.json) + Python (pyproject/py)
# 用法:
#   ./scripts/verify_fast.sh          # 自动根据当前 git 改动智能检查
#   ./scripts/verify_fast.sh --all    # 强制检查当前仓库所有已识别技术栈
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
export PATH="/Library/Developer/CommandLineTools/usr/bin:/opt/homebrew/bin:/Users/jasonshawn/development/flutter/bin:$PATH"

CHECK_ALL=false
if [ "${1:-}" = "--all" ]; then
  CHECK_ALL=true
fi

CHANGED_FILES="$(git -C "$PROJECT_ROOT" status --porcelain 2>/dev/null | awk '{print $2}' || true)"

NEED_RUST=false
NEED_FLUTTER=false
NEED_TS_NODE=false
NEED_PYTHON=false

if [ "$CHECK_ALL" = true ]; then
  { [ -d "$PROJECT_ROOT/backend" ] || [ -f "$PROJECT_ROOT/Cargo.toml" ]; } && NEED_RUST=true
  { [ -d "$PROJECT_ROOT/flutter_app" ] || [ -f "$PROJECT_ROOT/pubspec.yaml" ]; } && NEED_FLUTTER=true
  { [ -f "$PROJECT_ROOT/tsconfig.json" ] || [ -f "$PROJECT_ROOT/package.json" ]; } && NEED_TS_NODE=true
  { [ -f "$PROJECT_ROOT/pyproject.toml" ] || [ -n "$(find "$PROJECT_ROOT" -maxdepth 2 -name '*.py' -print -quit 2>/dev/null)" ]; } && NEED_PYTHON=true
else
  if echo "$CHANGED_FILES" | grep -Eq '^(backend/|src/.*\.rs$|Cargo\.toml$)'; then
    NEED_RUST=true
  fi
  if echo "$CHANGED_FILES" | grep -Eq '^(flutter_app/|lib/.*\.dart$|pubspec\.yaml$)'; then
    NEED_FLUTTER=true
  fi
  if echo "$CHANGED_FILES" | grep -Eq '\.(ts|tsx|js|jsx|mjs|cjs)$|^package\.json$|^tsconfig\.json$'; then
    NEED_TS_NODE=true
  fi
  if echo "$CHANGED_FILES" | grep -Eq '\.py$|^pyproject\.toml$'; then
    NEED_PYTHON=true
  fi
fi

if [ "$NEED_RUST" = false ] && [ "$NEED_FLUTTER" = false ] && [ "$NEED_TS_NODE" = false ] && [ "$NEED_PYTHON" = false ]; then
  echo "⚡ [verify_fast] 未检测到源码文件改动，秒级通过 ✓"
  exit 0
fi

# 1. Rust 检查
if [ "$NEED_RUST" = true ]; then
  RUST_DIR=""
  if [ -f "$PROJECT_ROOT/backend/Cargo.toml" ]; then
    RUST_DIR="$PROJECT_ROOT/backend"
  elif [ -f "$PROJECT_ROOT/Cargo.toml" ]; then
    RUST_DIR="$PROJECT_ROOT"
  fi
  if [ -n "$RUST_DIR" ]; then
    echo "🦀 [verify_fast] 正在执行 Rust 秒级增量类型与编译检查 (cargo check)..."
    export CC="/Library/Developer/CommandLineTools/usr/bin/clang"
    export AR="/Library/Developer/CommandLineTools/usr/bin/ar"
    export SDKROOT="/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"
    export CFLAGS="-isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"
    export RUSTFLAGS="-C linker=/Library/Developer/CommandLineTools/usr/bin/clang -C link-arg=-isysroot -C link-arg=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"
    export CARGO_TARGET_AARCH64_APPLE_DARWIN_LINKER="/Library/Developer/CommandLineTools/usr/bin/clang"
    export OPENSSL_DIR="/opt/homebrew/opt/openssl@3"
    (cd "$RUST_DIR" && cargo check --quiet)
    echo "   ✅ Rust cargo check 通过 ✓"
  fi
fi

# 2. Flutter / Dart 检查
if [ "$NEED_FLUTTER" = true ]; then
  FLUTTER_DIR=""
  if [ -f "$PROJECT_ROOT/flutter_app/pubspec.yaml" ]; then
    FLUTTER_DIR="$PROJECT_ROOT/flutter_app"
  elif [ -f "$PROJECT_ROOT/pubspec.yaml" ]; then
    FLUTTER_DIR="$PROJECT_ROOT"
  fi
  FLUTTER_BIN="$(command -v flutter 2>/dev/null || true)"
  if [ -n "$FLUTTER_DIR" ] && [ -n "$FLUTTER_BIN" ]; then
    echo "🎯 [verify_fast] 正在执行 Flutter 前端静态分析 (flutter analyze --no-pub)..."
    CHANGED_DART="$(echo "$CHANGED_FILES" | grep -E '\.dart$' | sed 's|^flutter_app/||' || true)"
    if [ -n "$CHANGED_DART" ]; then
      (cd "$FLUTTER_DIR" && $FLUTTER_BIN analyze --no-pub $CHANGED_DART)
    else
      (cd "$FLUTTER_DIR" && $FLUTTER_BIN analyze --no-pub)
    fi
    echo "   ✅ Flutter 静态分析通过 ✓"
  fi
fi

# 3. TypeScript / Node 检查
if [ "$NEED_TS_NODE" = true ]; then
  if [ -f "$PROJECT_ROOT/tsconfig.json" ] && [ -x "$PROJECT_ROOT/node_modules/.bin/tsc" ]; then
    echo "📘 [verify_fast] 正在执行 TypeScript 增量类型检查 (tsc --noEmit)..."
    (cd "$PROJECT_ROOT" && ./node_modules/.bin/tsc --noEmit)
    echo "   ✅ TypeScript tsc --noEmit 通过 ✓"
  elif [ -n "$CHANGED_FILES" ]; then
    CHANGED_JS="$(echo "$CHANGED_FILES" | grep -E '\.(js|mjs|cjs)$' || true)"
    if [ -n "$CHANGED_JS" ] && command -v node >/dev/null 2>&1; then
      echo "🟢 [verify_fast] 正在执行 Node.js 语法快检 (node --check)..."
      for jsf in $CHANGED_JS; do
        if [ -f "$PROJECT_ROOT/$jsf" ]; then
          node --check "$PROJECT_ROOT/$jsf"
        fi
      done
      echo "   ✅ Node.js 语法快检通过 ✓"
    fi
  fi
fi

# 4. Python 检查
if [ "$NEED_PYTHON" = true ]; then
  CHANGED_PY="$(echo "$CHANGED_FILES" | grep -E '\.py$' || true)"
  if command -v ruff >/dev/null 2>&1 && [ -n "$CHANGED_PY" ]; then
    echo "🐍 [verify_fast] 正在执行 Python Ruff 秒级静态快检..."
    (cd "$PROJECT_ROOT" && ruff check $CHANGED_PY)
    echo "   ✅ Python Ruff 检查通过 ✓"
  elif [ -n "$CHANGED_PY" ] && command -v python3 >/dev/null 2>&1; then
    echo "🐍 [verify_fast] 正在执行 Python AST 语法编译快检 (py_compile)..."
    (cd "$PROJECT_ROOT" && python3 -m py_compile $CHANGED_PY)
    echo "   ✅ Python 语法编译检查通过 ✓"
  fi
fi

echo "🎉 [verify_fast] 左移快速门禁全部通过！"
