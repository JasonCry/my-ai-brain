#!/usr/bin/env bash
# ==============================================================================
# scripts/publish_release.sh
# P12 GTD & AI 随身秘书 - 正式发版与云端发布一键触发工具
# 作用: 仅在明确发版时调用，递增版本号、打 Git Tag、推送触发云端构建流水线
# 军规: 日常日常改 Bug / 开发小需求严禁调用此脚本！
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PUBSPEC=""
DART_VER_FILE=""
if [ -f "${PROJECT_ROOT}/flutter_app/pubspec.yaml" ]; then
  PUBSPEC="${PROJECT_ROOT}/flutter_app/pubspec.yaml"
  DART_VER_FILE="${PROJECT_ROOT}/flutter_app/lib/config/app_version.dart"
elif [ -f "${PROJECT_ROOT}/pubspec.yaml" ]; then
  PUBSPEC="${PROJECT_ROOT}/pubspec.yaml"
  DART_VER_FILE="${PROJECT_ROOT}/lib/config/app_version.dart"
fi
CARGO_TOML="${PROJECT_ROOT}/backend/Cargo.toml"

DRY_RUN=false
BUMP_TYPE="patch"
MESSAGE=""
ISSUE_ID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --minor)
      BUMP_TYPE="minor"
      shift
      ;;
    --major)
      BUMP_TYPE="major"
      shift
      ;;
    --patch)
      BUMP_TYPE="patch"
      shift
      ;;
    -m|--message)
      MESSAGE="$2"
      shift 2
      ;;
    --issue|-i)
      ISSUE_ID="$2"
      shift 2
      ;;
    *)
      if [ -z "$MESSAGE" ]; then
        MESSAGE="$1"
      fi
      shift
      ;;
  esac
done

echo ""
echo "🚀 ============================================================"
echo "🚀  P12 GTD 正式发布版本流水线 (Production Release)"
echo "🚀  军规：只有在代码全部验证通过且用户明确要求上线时方可执行"
echo "🚀 ============================================================"
echo ""

# 1. 检查工作区干净度 (工作区有未暂存修改时中断，避免带入脏代码)
if [ -n "$(git status --porcelain 2>/dev/null | grep -v '^\?\?' || true)" ]; then
  echo "❌ 警告: 当前工作区有未提交的代码改动！"
  echo "   请先提交 (git commit) 或贮藏 (git stash) 日常研发改动后再执行发版。"
  git status -s
  exit 1
fi

# 2. 提取当前版本单一事实源
if [ ! -f "$PUBSPEC" ]; then
  echo "❌ 找不到 $PUBSPEC"
  exit 1
fi

CURRENT_VER=$(grep '^version:' "$PUBSPEC" | awk '{print $2}' | cut -d'+' -f1)
CURRENT_BUILD=$(grep '^version:' "$PUBSPEC" | awk '{print $2}' | cut -d'+' -f2)

MAJOR=$(echo "$CURRENT_VER" | cut -d. -f1)
MINOR=$(echo "$CURRENT_VER" | cut -d. -f2)
PATCH=$(echo "$CURRENT_VER" | cut -d. -f3)

if [ "$BUMP_TYPE" = "major" ]; then
  MAJOR=$((MAJOR + 1))
  MINOR=0
  PATCH=0
elif [ "$BUMP_TYPE" = "minor" ]; then
  MINOR=$((MINOR + 1))
  PATCH=0
else
  PATCH=$((PATCH + 1))
fi
NEW_BUILD=$((CURRENT_BUILD + 1))
NEW_VER="${MAJOR}.${MINOR}.${PATCH}"
TAG_NAME="v${NEW_VER}"

if [ -z "$MESSAGE" ]; then
  MESSAGE="Release ${TAG_NAME}"
fi

if [ -n "$ISSUE_ID" ]; then
  COMMIT_MSG="chore(release): bump version to ${TAG_NAME}+${NEW_BUILD} (#${ISSUE_ID})"
else
  COMMIT_MSG="chore(release): bump version to ${TAG_NAME}+${NEW_BUILD}"
fi

echo "📋 当前版本: v${CURRENT_VER}+${CURRENT_BUILD}"
echo "🎯 目标版本: ${TAG_NAME}+${NEW_BUILD} (晋级类型: ${BUMP_TYPE})"
echo "🏷️  发布标签: ${TAG_NAME}"
echo "📝 提交信息: ${COMMIT_MSG}"
echo ""

if [ "$DRY_RUN" = true ]; then
  echo "🔍 [Dry-Run] 演练结束，未执行任何物理修改与 Tag 推送。"
  exit 0
fi

# 3. 物理提升版本号并同步各端事实源 (JING-VER.01)
echo "📦 [1/5] 更新版本事实源 (pubspec.yaml, Cargo.toml, app_version.dart)..."
sed -i '' "s/^version: .*/version: ${NEW_VER}+${NEW_BUILD}/" "$PUBSPEC" 2>/dev/null || sed -i "s/^version: .*/version: ${NEW_VER}+${NEW_BUILD}/" "$PUBSPEC"
if [ -f "$CARGO_TOML" ]; then
  sed -i '' "s/^version = \".*\"/version = \"${NEW_VER}\"/" "$CARGO_TOML" 2>/dev/null || sed -i "s/^version = \".*\"/version = \"${NEW_VER}\"/" "$CARGO_TOML"
fi
if [ -f "${PROJECT_ROOT}/scripts/build_version_injector.sh" ]; then
  bash "${PROJECT_ROOT}/scripts/build_version_injector.sh" --sync-only
fi

# 4. Git 提交版本变更
echo "📝 [2/5] 提交版本变更至本地 Git..."
git add "$PUBSPEC"
[ -f "$CARGO_TOML" ] && git add "$CARGO_TOML"
[ -n "$DART_VER_FILE" ] && [ -f "$DART_VER_FILE" ] && git add "$DART_VER_FILE"
if [ -f "${PROJECT_ROOT}/changelog.md" ]; then
  git add "${PROJECT_ROOT}/changelog.md"
fi
git commit -m "$COMMIT_MSG"

# 5. 打上带注释的 Git Tag
echo "🏷️  [3/5] 打上 Git Release Tag: ${TAG_NAME}..."
git tag -a "${TAG_NAME}" -m "${MESSAGE}"

# 6. 推送 Commit 与 Tag 至 GitHub
echo "🚀 [4/5] 推送 Commit 与 Tag 至 GitHub 远端 (触发 GitHub Actions 云端打包)..."
git push origin "$(git rev-parse --abbrev-ref HEAD)"
git push origin "${TAG_NAME}"

# 7. 完成指引与跨机部署提醒
echo ""
echo "🎉 [5/5] 发布流水线触发成功！"
echo "============================================================"
echo "✅ GitHub Tag 已推送: ${TAG_NAME}"
echo "☁️  云端构建进度: https://github.com/JasonCry/P12_Personal_Work_Assistant/actions"
echo ""
echo "💡 生产环境部署指引 (待云端 GitHub Actions 变绿完成后):"
echo "   在生产机 (Mac Mini) 上执行:"
echo "   cd ~/Projects/P12_Personal_Work_Assistant && ./scripts/deploy_release.sh ${TAG_NAME}"
echo "============================================================"
echo ""
