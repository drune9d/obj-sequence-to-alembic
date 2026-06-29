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
  --notes "## What's new in $TAG

### Bug fixes
- Fixed incorrect face winding (reversed CCW→CW) that caused invalid geometry, disappearing mesh pieces, and playback crashes in Blender
- Fixed UV indices being misaligned to the wrong face corners due to the same winding reversal
- Fixed undefined behaviour when OBJ files contain blank lines
- Fixed face count array accumulating across frames instead of being cleared

### Performance
- OBJ frames are now read in parallel using a thread pool sized to available CPU cores — typical sequences are 4–6× faster to convert
- Per-frame vertex parsing now uses \`strtof\` instead of \`istringstream\`, giving a further 3–5× speedup for float parsing

### GUI
- Progress bar is now determinate during conversion, filling frame by frame
- Frame counter (e.g. \`12 / 300\`) shown beside the progress bar
- Build operations keep the indeterminate bouncing bar as before"

echo
echo "Draft release created for $TAG"
