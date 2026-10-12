#!/usr/bin/env bash
# ==============================================================================
# scripts/code_query.sh
# 三层渐进式代码导航与行号切片探针 (3-Tier Progressive Code Navigation Probe)
# 作用:
#   - 宏观 (L0): feature <kw>  -> 检索 llms.txt 与 docs/CAPABILITIES.md
#   - 中观 (L1): trace <kw>    -> 检索 docs/ARCHITECTURE_SEAMS.json 端到端链路
#   - 微观 (L2): outline <file> / symbol <name> -> 毫秒级提取函数签名与精确起止行号 [LStart-LEnd]
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

CMD="${1:-help}"
QUERY="${2:-}"

show_help() {
    cat << 'EOF'
用法 (3-Tier Progressive Code Navigation):
  1. 宏观锁域 (L0):
     ./scripts/code_query.sh feature <keyword>        # 检索 llms.txt 与 docs/CAPABILITIES.md 锁定模块文件
  2. 中观溯源 (L1):
     ./scripts/code_query.sh trace <api_or_keyword>   # 追溯端到端接缝 (UI -> API -> Route -> Storage -> Table)
     ./scripts/code_query.sh list                     # 列出当前项目所有已登记的端到端架构接缝
     ./scripts/code_query.sh sync                     # 动态扫描当前项目并刷新 docs/ARCHITECTURE_SEAMS.json
  3. 微观定行 (L2 · 直通 view_file 切片):
     ./scripts/code_query.sh outline <file_path>      # 实时提取文件内所有类/函数签名及精确起止行号 (LStart-LEnd)
     ./scripts/code_query.sh symbol <symbol_name>     # 跨文件精准定位函数/结构体/组件定义所在的文件与起止行号

示例:
  ./scripts/code_query.sh feature "日程"
  ./scripts/code_query.sh trace /api/tasks
  ./scripts/code_query.sh outline backend/src/routes/tasks.rs
  ./scripts/code_query.sh symbol QuickCaptureDialog
EOF
}

case "$CMD" in
    feature)
        if [ -z "$QUERY" ]; then
            echo "❌ 请指定功能关键词，如: ./scripts/code_query.sh feature 日历"
            exit 1
        fi
        echo "🗺️ [L0 Macro Trace] 检索业务能力地图: '${QUERY}' (Project: $(basename "$PROJECT_ROOT"))"
        if [ -f "$PROJECT_ROOT/llms.txt" ]; then
            echo "--- llms.txt ---"
            grep -i -n -C 1 "$QUERY" "$PROJECT_ROOT/llms.txt" || echo "  (llms.txt 无直接命中)"
        fi
        if [ -f "$PROJECT_ROOT/docs/CAPABILITIES.md" ]; then
            echo "--- docs/CAPABILITIES.md ---"
            grep -i -n -C 1 "$QUERY" "$PROJECT_ROOT/docs/CAPABILITIES.md" || echo "  (CAPABILITIES.md 无直接命中)"
        fi
        ;;

    trace)
        if [ -z "$QUERY" ]; then
            echo "❌ 请指定查询的路由或关键词，如: ./scripts/code_query.sh trace /api/tasks"
            exit 1
        fi
        echo "🔍 [L1 Seam Trace] 正在检索端到端接缝拓扑: '${QUERY}'..."
        SEAM_FILE="$PROJECT_ROOT/docs/ARCHITECTURE_SEAMS.json"
        if [ -f "$SEAM_FILE" ] && command -v jq >/dev/null 2>&1; then
            MATCHES=$(jq -c --arg q "$QUERY" '.seams[] | select((.api_endpoint // "" | test($q; "i")) or (.feature // "" | test($q; "i")) or (.backend_route // "" | test($q; "i")) or (.frontend_view // "" | test($q; "i")) or (.database_table // "" | test($q; "i")))' "$SEAM_FILE" 2>/dev/null || true)
            if [ -n "$MATCHES" ]; then
                echo "$MATCHES" | jq .
            fi
        fi

        echo "⚡ [Realtime Route & Call Probe] 定向扫描当前项目路由与调用点..."
        for dir in "$PROJECT_ROOT/backend/src/routes" "$PROJECT_ROOT/backend/src/storage" "$PROJECT_ROOT/src" "$PROJECT_ROOT/flutter_app/lib"; do
            if [ -d "$dir" ]; then
                REL_DIR="${dir#$PROJECT_ROOT/}"
                HITS=$(grep -rnI "$QUERY" "$dir" 2>/dev/null | head -8 | sed "s|$PROJECT_ROOT/||g" || true)
                if [ -n "$HITS" ]; then
                    echo "📂 [$REL_DIR]:"
                    echo "$HITS" | sed 's/^/  /'
                fi
            fi
        done
        ;;

    outline|symbols)
        if [ -z "$QUERY" ]; then
            echo "❌ 请指定源码文件路径，如: ./scripts/code_query.sh outline backend/src/routes/tasks.rs"
            exit 1
        fi
        TARGET_FILE="$QUERY"
        if [ ! -f "$TARGET_FILE" ] && [ -f "$PROJECT_ROOT/$QUERY" ]; then
            TARGET_FILE="$PROJECT_ROOT/$QUERY"
        fi
        if [ ! -f "$TARGET_FILE" ]; then
            echo "❌ 文件不存在: $QUERY"
            exit 1
        fi

        python3 - "$TARGET_FILE" "$PROJECT_ROOT" << 'PYEOF'
import sys, os, re

filepath = sys.argv[1]
project_root = sys.argv[2]
rel_path = os.path.relpath(filepath, project_root)

with open(filepath, 'r', encoding='utf-8', errors='replace') as f:
    lines = f.readlines()

total = len(lines)
print(f"📄 File: {rel_path} (Total: {total} lines)")
print("💡 Tip: Use view_file(StartLine, EndLine) with the exact [LStart-LEnd] range below.\n")

ext = os.path.splitext(filepath)[1].lower()

# Patterns for Rust, Dart, TS/JS, Python
decl_patterns = [
    # Rust
    (r'^\s*(pub(\([^)]+\))?\s+)?(async\s+)?fn\s+([a-zA-Z0-9_]+)', 'fn'),
    (r'^\s*(pub(\([^)]+\))?\s+)?(struct|enum|trait|type)\s+([a-zA-Z0-9_]+)', 'type'),
    (r'^\s*impl(<[^>]*>)?\s+([a-zA-Z0-9_:<>\s]+)', 'impl'),
    (r'^\s*\.route\(\s*"([^"]+)"', 'route'),
    # Dart / Flutter / TS / JS
    (r'^\s*(abstract\s+)?(class|mixin|enum|extension|interface|type)\s+([a-zA-Z0-9_<>]+)', 'class'),
    (r'^\s*(export\s+)?(default\s+)?(async\s+)?function\s+([a-zA-Z0-9_]+)', 'fn'),
    (r'^\s*(Future<[^>]+>|Stream<[^>]+>|Widget|void|bool|int|double|String|dynamic|final\s+[a-zA-Z0-9_<>]+)\s+([a-zA-Z0-9_]+)\s*\(', 'method'),
    # Python
    (r'^(\s*)(async\s+)?def\s+([a-zA-Z0-9_]+)\s*\(', 'def'),
]

def find_block_end(start_idx, lines, ext):
    if ext == '.py':
        base_indent = len(lines[start_idx]) - len(lines[start_idx].lstrip())
        end_idx = start_idx
        for i in range(start_idx + 1, len(lines)):
            stripped = lines[i].strip()
            if not stripped or stripped.startswith('#'):
                continue
            indent = len(lines[i]) - len(lines[i].lstrip())
            if indent <= base_indent:
                break
            end_idx = i
        return end_idx + 1
    else:
        brace_depth = 0
        found_open = False
        for i in range(start_idx, min(len(lines), start_idx + 800)):
            # Strip simple string literals and line comments to avoid brace mismatch
            clean = re.sub(r'//.*$', '', lines[i])
            clean = re.sub(r'"(?:\\.|[^"\\])*"', '""', clean)
            clean = re.sub(r"'(?:\\.|[^'\\])*'", "''", clean)
            for ch in clean:
                if ch == '{':
                    brace_depth += 1
                    found_open = True
                elif ch == '}':
                    brace_depth -= 1
                    if found_open and brace_depth <= 0:
                        return i + 1
            if not found_open and ';' in clean and i >= start_idx:
                return i + 1
        return start_idx + 1

count = 0
for idx, line in enumerate(lines):
    for pat, kind in decl_patterns:
        m = re.search(pat, line)
        if m:
            sig = line.strip()
            if sig.endswith('{'):
                sig = sig[:-1].strip()
            if len(sig) > 92:
                sig = sig[:89] + '...'
            end_line = find_block_end(idx, lines, ext)
            start_line = idx + 1
            loc = f"L{start_line}-L{end_line}" if end_line > start_line else f"L{start_line}"
            print(f"  {loc:<12} [{kind:<6}]  {sig}")
            count += 1
            break

if count == 0:
    print("  (未检测到标准顶层符号，可执行 grep 或直接按行查看)")
PYEOF
        ;;

    symbol)
        if [ -z "$QUERY" ]; then
            echo "❌ 请指定要定位的函数名/结构体/类名，如: ./scripts/code_query.sh symbol quick_capture"
            exit 1
        fi
        echo "🎯 [L2 Symbol Locator] 正在定位符号定义: '${QUERY}'..."
        python3 - "$PROJECT_ROOT" "$QUERY" << 'PYEOF'
import sys, os, re

project_root = sys.argv[1]
query = sys.argv[2]
skip_dirs = {'.git', 'node_modules', 'target', 'build', '.dart_tool', 'dist', 'dist_guoxue', '.next', 'vendor'}
valid_exts = {'.rs', '.dart', '.ts', '.tsx', '.js', '.vue', '.py', '.go'}

pat = re.compile(
    rf'\b(fn|struct|enum|trait|class|mixin|interface|type|def|function|Widget)\s+{re.escape(query)}\b'
    rf'|(\b{re.escape(query)}\s*\([^;{{]*\)\s*(async\s*)?\{{)'
)

hits = []
for root, dirs, files in os.walk(project_root):
    dirs[:] = [d for d in dirs if d not in skip_dirs]
    for fn in files:
        ext = os.path.splitext(fn)[1].lower()
        if ext not in valid_exts:
            continue
        full = os.path.join(root, fn)
        try:
            with open(full, 'r', encoding='utf-8', errors='replace') as f:
                lines = f.readlines()
        except Exception:
            continue
        for i, line in enumerate(lines):
            if pat.search(line):
                # compute end line
                depth = 0
                found = False
                end_l = i + 1
                for j in range(i, min(len(lines), i + 500)):
                    clean = re.sub(r'//.*$', '', lines[j])
                    for ch in clean:
                        if ch == '{':
                            depth += 1
                            found = True
                        elif ch == '}':
                            depth -= 1
                            if found and depth <= 0:
                                end_l = j + 1
                                break
                    if found and depth <= 0:
                        break
                rel = os.path.relpath(full, project_root)
                sig = line.strip()
                if len(sig) > 85:
                    sig = sig[:82] + '...'
                hits.append((rel, i + 1, end_l, sig))

if not hits:
    print(f"  未找到符号 '{query}' 的显式声明，尝试轻量子串定位:")
    os.system(f'grep -rnI --exclude-dir={{.git,target,build,node_modules,dist,dist_guoxue,.dart_tool}} "{query}" "{project_root}" | head -10 | sed "s|{project_root}/||g"')
else:
    for rel, s, e, sig in hits[:15]:
        print(f"  📍 {rel}  [L{s}-L{e}]")
        print(f"     └─ {sig}")
PYEOF
        ;;

    list)
        SEAM_FILE="$PROJECT_ROOT/docs/ARCHITECTURE_SEAMS.json"
        if [ -f "$SEAM_FILE" ] && command -v jq >/dev/null 2>&1; then
            jq '.seams[] | {feature: .feature, api: .api_endpoint, backend: .backend_route, frontend: .frontend_view, table: .database_table}' "$SEAM_FILE"
        else
            echo "⚠️ docs/ARCHITECTURE_SEAMS.json 尚未生成，请执行 ./scripts/code_query.sh sync 生成。"
        fi
        ;;

    sync)
        if [ -x "$PROJECT_ROOT/scripts/auto_sync_code_index.sh" ]; then
            "$PROJECT_ROOT/scripts/auto_sync_code_index.sh"
        else
            echo "❌ 未找到可执行脚本: $PROJECT_ROOT/scripts/auto_sync_code_index.sh"
            exit 1
        fi
        ;;

    help|*)
        show_help
        ;;
esac
