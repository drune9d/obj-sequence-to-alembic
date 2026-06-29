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
- Fixed frozen animation: every frame after the first failed to load (backslash paths could not be opened by the fast reader), so the cache played back as a single static frame. Animation is restored.
- The app's Rebuild / Build Converter now works when launched from Finder (Homebrew is added to PATH; previously it reported 'Homebrew was not found').
- Fixed incorrect face winding (reversed CCW→CW) that caused invalid geometry, disappearing mesh pieces, and playback crashes in Blender.
- UVs are only written when the OBJ actually contains them (previously an uninitialized, garbage UV map could be emitted).
- Hardened against blank lines and missing command-line argument values.

### Performance
- OBJ frames are read with a bounded prefetch pipeline that overlaps reading and writing across CPU cores, with faster strtof-based vertex parsing.

### GUI
- Determinate progress bar with a per-frame counter (e.g. \`12 / 300\`) during conversion.

### Diagnostics
- The log now reports how many OBJ files were found and warns if a frame cannot be read."

echo
echo "Draft release created for $TAG"
