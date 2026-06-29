#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required but was not found."
  echo "Install Homebrew from https://brew.sh, then run this script again."
  exit 1
fi

for formula in cmake alembic hdf5 imath zlib python-tk; do
  if ! brew list --versions "$formula" >/dev/null 2>&1; then
    echo "$formula is not installed. Installing with Homebrew..."
    brew install -y "$formula"
  fi
done

mkdir -p "$ROOT_DIR/build"
cd "$ROOT_DIR/build"

cmake -G "Unix Makefiles" ..
make

mkdir -p "$ROOT_DIR/bin"
if [ -f "$ROOT_DIR/build/Objs2Abc" ]; then
  cp "$ROOT_DIR/build/Objs2Abc" "$ROOT_DIR/bin/Objs2Abc"
fi
chmod +x "$ROOT_DIR/bin/Objs2Abc"

echo
echo "Build complete: $ROOT_DIR/bin/Objs2Abc"
