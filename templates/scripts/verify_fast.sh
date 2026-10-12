#!/usr/bin/env bash
# ==============================================================================
# scripts/verify_fast.sh
# 秒级左移质量门禁探针 (Shift-Left Inner-Loop Fast Verification)
# 作用: 在运行耗时的全量打包/部署前，基于 git diff 仅对发生变更的前/后端模块执行秒级静态与编译检查
# 用法:
#   ./scripts/verify_fast.sh          # 自动根据当前 git 改动智能检查
#   ./scripts/verify_fast.sh --all    # 强制检查全栈 (Backend + Frontend)
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

if [ "$CHECK_ALL" = true ]; then
  [ -d "$PROJECT_ROOT/backend" ] && NEED_RUST=true
  [ -d "$PROJECT_ROOT/flutter_app" ] && NEED_FLUTTER=true
else
  if echo "$CHANGED_FILES" | grep -Eq '^backend/'; then
    NEED_RUST=true
  fi
  if echo "$CHANGED_FILES" | grep -Eq '^flutter_app/'; then
    NEED_FLUTTER=true
  fi
fi

if [ "$NEED_RUST" = false ] && [ "$NEED_FLUTTER" = false ]; then
  echo "⚡ [verify_fast] 未检测到 backend/ 或 flutter_app/ 代码改动，秒级通过 ✓"
  exit 0
fi

if [ "$NEED_RUST" = true ] && [ -d "$PROJECT_ROOT/backend" ]; then
  echo "🦀 [verify_fast] 正在执行 Rust 后端秒级增量类型与编译检查 (cargo check)..."
  export CC="/Library/Developer/CommandLineTools/usr/bin/clang"
  export AR="/Library/Developer/CommandLineTools/usr/bin/ar"
  export SDKROOT="/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"
  export CFLAGS="-isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"
  export RUSTFLAGS="-C linker=/Library/Developer/CommandLineTools/usr/bin/clang -C link-arg=-isysroot -C link-arg=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"
  export CARGO_TARGET_AARCH64_APPLE_DARWIN_LINKER="/Library/Developer/CommandLineTools/usr/bin/clang"
  export OPENSSL_DIR="/opt/homebrew/opt/openssl@3"
  (cd "$PROJECT_ROOT/backend" && cargo check --quiet)
  echo "   ✅ Rust 后端 cargo check 通过 ✓"
fi

if [ "$NEED_FLUTTER" = true ] && [ -d "$PROJECT_ROOT/flutter_app" ]; then
  FLUTTER_BIN="$(command -v flutter 2>/dev/null || true)"
  if [ -n "$FLUTTER_BIN" ]; then
    echo "🎯 [verify_fast] 正在执行 Flutter 前端静态分析 (flutter analyze --no-pub)..."
    CHANGED_DART="$(echo "$CHANGED_FILES" | grep -E '^flutter_app/lib/.*\.dart$' | sed 's|^flutter_app/||' || true)"
    if [ -n "$CHANGED_DART" ]; then
      # 仅分析变更的 Dart 文件以实现秒级回执
      (cd "$PROJECT_ROOT/flutter_app" && $FLUTTER_BIN analyze --no-pub $CHANGED_DART)
    else
      (cd "$PROJECT_ROOT/flutter_app" && $FLUTTER_BIN analyze --no-pub)
    fi
    echo "   ✅ Flutter 静态分析通过 ✓"
  fi
fi

echo "🎉 [verify_fast] 左移快速门禁全部通过！"
