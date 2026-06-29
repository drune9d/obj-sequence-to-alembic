#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
REPO="${GITHUB_REPOSITORY:-drune9d/convert_objs_to_abc}"
TAG="${1:-}"
ZIP_PATH="$ROOT_DIR/dist/OBJ-Sequence-to-Alembic-macOS.zip"

if [ -z "$TAG" ]; then
  echo "Usage: scripts/publish_release.sh <tag>"
  echo "Example: scripts/publish_release.sh v1.0.0"
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI is required to publish releases."
  echo "Install it with: brew install gh"
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "GitHub CLI is not authenticated."
  echo "Run: gh auth login"
  exit 1
fi

"$ROOT_DIR/scripts/package_release.sh"

if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "Using existing tag: $TAG"
else
  git tag "$TAG"
fi

git push origin "$TAG"

gh release create "$TAG" "$ZIP_PATH" \
  --repo "$REPO" \
  --draft \
  --title "OBJ Sequence to Alembic $TAG" \
  --notes "macOS app bundle for converting OBJ sequences to Alembic .abc files."

echo
echo "Draft release created for $TAG"
