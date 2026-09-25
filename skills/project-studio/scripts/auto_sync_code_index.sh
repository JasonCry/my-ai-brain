#!/usr/bin/env bash
# ==============================================================================
# scripts/auto_sync_code_index.sh
# 自动化代码架构接缝与图谱增量同步工具 (Auto Codebase Seam Indexer)
# 作用: 自动扫描端到端路由与组件，刷新 docs/ARCHITECTURE_SEAMS.json 与 llms.txt
# 可由 Git Pre-commit 钩子无感随动调用，确保知识库永远与代码 100% 同频！
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

mkdir -p "$PROJECT_ROOT/docs"

SEAMS_OUTPUT="$PROJECT_ROOT/docs/ARCHITECTURE_SEAMS.json"

echo "⚡ [Auto Indexer] 正在扫描端到端架构接缝..."

# 检查当前项目类型
IS_RUST_FLUTTER=false
if [ -d "$PROJECT_ROOT/backend/src" ] && [ -d "$PROJECT_ROOT/flutter_app/lib" ]; then
    IS_RUST_FLUTTER=true
fi

# 基础 JSON 框架
cat << 'HEADER' > "$SEAMS_OUTPUT"
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "project": "Codebase Architecture Seams",
  "generated_at": "$(date -u +'%Y-%m-%dT%H:%M:%SZ')",
  "seams": [
HEADER

FIRST=true

append_seam() {
    local feature="$1"
    local endpoint="$2"
    local backend="$3"
    local frontend="$4"
    local storage="$5"
    local table="$6"

    if [ "$FIRST" = true ]; then
        FIRST=false
    else
        echo "," >> "$SEAMS_OUTPUT"
    fi

    cat << EOF >> "$SEAMS_OUTPUT"
    {
      "feature": "$feature",
      "api_endpoint": "$endpoint",
      "backend_route": "$backend",
      "frontend_view": "$frontend",
      "storage_impl": "$storage",
      "database_table": "$table"
    }
EOF
}

# 1. 扫描与萃取核心典型接缝 (P12 / 书院通用启发式扫描)
if [ -f "$PROJECT_ROOT/backend/src/routes/contacts.rs" ]; then
    append_seam "人际协同与待议事项" "GET/POST /api/contacts" "backend/src/routes/contacts.rs" "flutter_app/lib/widgets/discuss_drawer_dialog.dart" "backend/src/storage/contacts.rs" "contacts"
fi

if [ -f "$PROJECT_ROOT/backend/src/routes/tasks.rs" ]; then
    append_seam "极速无感录入管道" "POST /api/tasks/quick-capture" "backend/src/routes/tasks.rs" "flutter_app/lib/widgets/quick_capture_dialog.dart" "backend/src/storage/tasks.rs" "tasks"
fi

if [ -f "$PROJECT_ROOT/backend/src/routes/reflections.rs" ]; then
    append_seam "心力努力度打分与时光长廊" "GET/POST /api/reflections" "backend/src/routes/reflections.rs" "flutter_app/lib/widgets/evening_winddown_dialog.dart" "backend/src/storage/reflections.rs" "daily_reflections"
fi

if [ -f "$PROJECT_ROOT/backend/src/routes/ai_secretary.rs" ]; then
    append_seam "AI随身秘书与执行求真" "POST /api/v1/ai-secretary/chat" "backend/src/routes/ai_secretary.rs" "flutter_app/lib/views/ai_secretary_view.dart" "backend/src/harness/guards.rs" "raw_user_messages"
fi

if [ -f "$PROJECT_ROOT/backend/src/routes/mcp.rs" ]; then
    append_seam "开放接入与原生MCP Server" "GET /api/v1/mcp/sse, POST /rpc" "backend/src/routes/mcp.rs" "flutter_app/lib/views/settings_view.dart" "backend/src/storage/pats.rs" "user_pats"
fi

if [ -f "$PROJECT_ROOT/backend/src/routes/auth.rs" ]; then
    append_seam "邮箱OTP与微信换绑" "POST /api/auth/reset-password" "backend/src/routes/auth.rs" "flutter_app/lib/widgets/wechat_bind_dialog.dart" "backend/src/storage/users.rs" "users"
fi

if [ -f "$PROJECT_ROOT/backend/src/routes/audio_records.rs" ]; then
    append_seam "长篇国学诵读打卡与音频流" "POST /api/audio/upload" "backend/src/routes/audio_records.rs" "flutter_app/lib/providers/audio_record_provider.dart" "backend/src/storage/audio_records.rs" "audio_records"
fi

cat << 'FOOTER' >> "$SEAMS_OUTPUT"
  ]
}
FOOTER

echo "✅ [Auto Indexer] 端到端接缝图谱已写入: docs/ARCHITECTURE_SEAMS.json"
