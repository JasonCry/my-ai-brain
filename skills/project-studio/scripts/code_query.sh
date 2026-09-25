#!/usr/bin/env bash
# ==============================================================================
# scripts/code_query.sh
# 代码接缝与语义图谱定向探针工具 (Codebase Seam Query Probe)
# 作用: 供 AI 或开发者在排查 Bug、评估改动影响面时毫秒级直查接缝，彻底终结全局盲搜
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

CMD="${1:-help}"
QUERY="${2:-}"

show_help() {
    cat << 'EOF'
用法:
  ./scripts/code_query.sh trace <api_or_keyword>   # 追溯 API 端到端接缝 (UI -> API -> Route -> Table)
  ./scripts/code_query.sh feature <keyword>        # 查阅功能对应的源码文件与冒烟验证路径
  ./scripts/code_query.sh list                     # 列出当前项目登记的所有业务接缝
  ./scripts/code_query.sh sync                     # 强制重新扫描并刷新当前代码接缝图谱

示例:
  ./scripts/code_query.sh trace /api/contacts
  ./scripts/code_query.sh feature "微信扫码"
EOF
}

case "$CMD" in
    trace)
        if [ -z "$QUERY" ]; then
            echo "❌ 请指定查询的路由或关键词，如: ./scripts/code_query.sh trace /api/tasks"
            exit 1
        fi
        echo "🔍 [Code Seam Trace] 正在检索接缝拓扑: '${QUERY}'..."
        SEAM_FILE="$PROJECT_ROOT/docs/ARCHITECTURE_SEAMS.json"
        if [ -f "$SEAM_FILE" ]; then
            MATCHES=$(jq -c --arg q "$QUERY" '.seams[] | select(.api_endpoint | test($q; "i")) // select(.feature | test($q; "i")) // select(.backend_route | test($q; "i"))' "$SEAM_FILE" 2>/dev/null || true)
            if [ -n "$MATCHES" ]; then
                echo "$MATCHES" | jq .
                exit 0
            fi
        fi
        
        # 若未在 json 中登记，执行快速本地启发式路由探测（< 50ms）
        echo "⚡ 在本地后端与前端执行极速定向接缝探测..."
        ROUTE_MATCH=$(grep -rn "$QUERY" "$PROJECT_ROOT/backend/src/routes" 2>/dev/null | head -3 || true)
        FE_MATCH=$(grep -rn "$QUERY" "$PROJECT_ROOT/flutter_app/lib" 2>/dev/null | head -3 || true)
        
        cat << EOF
{
  "query": "$QUERY",
  "heuristic_probe": {
    "backend_hits": [$(echo "$ROUTE_MATCH" | sed 's/^/"/' | sed 's/$/"/' | paste -sd, - || true)],
    "frontend_hits": [$(echo "$FE_MATCH" | sed 's/^/"/' | sed 's/$/"/' | paste -sd, - || true)]
  }
}
EOF
        ;;

    feature)
        if [ -z "$QUERY" ]; then
            echo "❌ 请指定功能关键词，如: ./scripts/code_query.sh feature 微信换绑"
            exit 1
        fi
        echo "🗺️ [Capability & Map Trace] 检索业务功能: '${QUERY}'..."
        CAP_FILE="$PROJECT_ROOT/docs/CAPABILITIES.md"
        if [ -f "$CAP_FILE" ]; then
            grep -i -C 1 "$QUERY" "$CAP_FILE" || echo "   未在 CAPABILITIES.md 中匹配到 '${QUERY}'"
        else
            echo "⚠️ docs/CAPABILITIES.md 尚未建立"
        fi
        ;;

    list)
        SEAM_FILE="$PROJECT_ROOT/docs/ARCHITECTURE_SEAMS.json"
        if [ -f "$SEAM_FILE" ]; then
            jq '.seams[] | {feature: .feature, api: .api_endpoint, backend: .backend_route, frontend: .frontend_view}' "$SEAM_FILE"
        else
            echo "⚠️ docs/ARCHITECTURE_SEAMS.json 尚未生成，请执行 ./scripts/auto_sync_code_index.sh 生成。"
        fi
        ;;

    sync)
        if [ -x "$PROJECT_ROOT/scripts/auto_sync_code_index.sh" ]; then
            "$PROJECT_ROOT/scripts/auto_sync_code_index.sh"
        else
            echo "❌ 未找到 $PROJECT_ROOT/scripts/auto_sync_code_index.sh"
            exit 1
        fi
        ;;

    help|*)
        show_help
        ;;
esac
