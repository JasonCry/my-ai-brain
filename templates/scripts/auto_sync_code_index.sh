#!/usr/bin/env bash
# ==============================================================================
# scripts/auto_sync_code_index.sh
# 通用动态架构接缝扫描器 (Universal Dynamic Architecture Seam Indexer)
# 作用:
#   - 0 硬编码：严格按当前项目的 $PROJECT_ROOT 动态扫描所有后端路由、存储层表名与前端视图
#   - 自动生成/刷新 docs/ARCHITECTURE_SEAMS.json
#   - 由 Git pre-commit 钩子增量调用，确保各项目物理隔离、永远与最新代码 100% 同步
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

mkdir -p "$PROJECT_ROOT/docs"
SEAMS_OUTPUT="$PROJECT_ROOT/docs/ARCHITECTURE_SEAMS.json"

python3 - "$PROJECT_ROOT" "$SEAMS_OUTPUT" << 'PYEOF'
import sys, os, re, json
from datetime import datetime, timezone

project_root = sys.argv[1]
output_path = sys.argv[2]
project_name = os.path.basename(project_root)

seams = []
seen_keys = set()

# Collect all frontend files for fast matching
fe_files = []
fe_root = os.path.join(project_root, "flutter_app", "lib")
if not os.path.isdir(fe_root):
    fe_root = os.path.join(project_root, "src")

if os.path.isdir(fe_root):
    for r, d, files in os.walk(fe_root):
        for fn in files:
            if fn.endswith(('.dart', '.vue', '.tsx', '.ts')):
                fe_files.append(os.path.relpath(os.path.join(r, fn), project_root))

def match_frontend(stem, content=""):
    # 1. Direct stem match in views/widgets/providers
    candidates = [f for f in fe_files if stem.lower() in os.path.basename(f).lower()]
    if candidates:
        # prioritize views, then widgets, then providers
        candidates.sort(key=lambda x: (0 if '/views/' in x else 1 if '/widgets/' in x else 2))
        return ", ".join(candidates[:2])
    return ""

def extract_table(storage_file, route_file):
    for fp in [storage_file, route_file]:
        if fp and os.path.isfile(fp):
            try:
                txt = open(fp, 'r', encoding='utf-8', errors='replace').read()
                m = re.findall(r'(?:FROM|INTO|UPDATE|TABLE\s+IF\s+NOT\s+EXISTS|TABLE)\s+([a-zA-Z0-9_]+)', txt, re.IGNORECASE)
                filtered = [t for t in m if t.lower() not in {'select', 'where', 'set', 'values', 'null', 'index', 'sqlite_master'}]
                if filtered:
                    # preserve order, unique
                    uniq = list(dict.fromkeys(filtered))
                    return ", ".join(uniq[:3])
            except Exception:
                pass
    return ""

# 1. Dynamically scan Rust backend routes (if present)
routes_dir = os.path.join(project_root, "backend", "src", "routes")
if os.path.isdir(routes_dir):
    for fn in sorted(os.listdir(routes_dir)):
        if not fn.endswith(".rs") or fn == "mod.rs":
            continue
        stem = fn[:-3]
        route_abs = os.path.join(routes_dir, fn)
        rel_route = os.path.relpath(route_abs, project_root)
        try:
            txt = open(route_abs, 'r', encoding='utf-8', errors='replace').read()
        except Exception:
            continue

        # Extract doc comment or first comment as feature description
        doc_m = re.search(r'^\s*//[/!]\s*(.+)$', txt, re.MULTILINE)
        feature_name = doc_m.group(1).strip() if doc_m else f"Backend Route: {stem}"

        # Extract route paths or handler names
        endpoints = re.findall(r'\.route\(\s*"([^"]+)"', txt)
        if not endpoints:
            fns = re.findall(r'pub\s+async\s+fn\s+([a-zA-Z0-9_]+)', txt)
            endpoints = [f"fn:{f}" for f in fns[:4]]
        endpoint_str = ", ".join(list(dict.fromkeys(endpoints))[:4]) if endpoints else f"/api/{stem}"

        storage_abs = os.path.join(project_root, "backend", "src", "storage", f"{stem}.rs")
        rel_storage = os.path.relpath(storage_abs, project_root) if os.path.isfile(storage_abs) else ""
        table_str = extract_table(storage_abs, route_abs)
        fe_match = match_frontend(stem.rstrip('s'), txt) or match_frontend(stem, txt)

        seams.append({
            "feature": feature_name,
            "api_endpoint": endpoint_str,
            "backend_route": rel_route,
            "frontend_view": fe_match,
            "storage_impl": rel_storage,
            "database_table": table_str
        })
        seen_keys.add(stem.lower())

# 2. Dynamically scan Flutter/Frontend standalone views not yet covered by a identically-named route
views_dir = os.path.join(project_root, "flutter_app", "lib", "views")
if os.path.isdir(views_dir):
    for fn in sorted(os.listdir(views_dir)):
        if not fn.endswith(".dart"):
            continue
        stem = fn.replace("_view.dart", "").replace(".dart", "")
        if stem.lower() in seen_keys or (stem.lower() + "s") in seen_keys:
            continue
        view_abs = os.path.join(views_dir, fn)
        rel_view = os.path.relpath(view_abs, project_root)
        try:
            txt = open(view_abs, 'r', encoding='utf-8', errors='replace').read()
        except Exception:
            continue

        doc_m = re.search(r'^\s*///?\s*(.+)$', txt, re.MULTILINE)
        classes = re.findall(r'class\s+([A-Za-z0-9_]+)\s+extends\s+(?:StatelessWidget|StatefulWidget|ConsumerWidget|ConsumerStatefulWidget)', txt)
        cls_label = classes[0] if classes else stem
        feature_name = doc_m.group(1).strip() if doc_m else f"View: {cls_label}"

        apis = re.findall(r'["\'](/api/[^"\']+)["\']', txt)
        api_str = ", ".join(list(dict.fromkeys(apis))[:3]) if apis else "Local / Provider State"

        seams.append({
            "feature": feature_name,
            "api_endpoint": api_str,
            "backend_route": "",
            "frontend_view": rel_view,
            "storage_impl": "",
            "database_table": ""
        })

payload = {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "project": project_name,
    "total_seams": len(seams),
    "ams_Note": "Auto-generated by scripts/auto_sync_code_index.sh. Do not hardcode entries.",
    "seams": seams
}

with open(output_path, 'w', encoding='utf-8') as f:
    json.dump(payload, f, ensure_ascii=False, indent=2)
    f.write("\n")

print(f"✅ [Auto Indexer] 已为项目 [{project_name}] 动态扫描并生成 {len(seams)} 条架构接缝 -> docs/ARCHITECTURE_SEAMS.json")
PYEOF
