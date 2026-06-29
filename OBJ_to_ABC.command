#!/bin/bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

if [ ! -x "$DIR/bin/Objs2Abc" ]; then
  echo "Objs2Abc is not built yet. Building now..."
  "$DIR/build.sh"
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 was not found. Install Python 3 or Xcode Command Line Tools, then try again."
  exit 1
fi

python3 "$DIR/gui.py"
