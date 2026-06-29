# Releasing

These notes are for maintainers.

## Build The Release Zip

From the repo root:

```bash
scripts/package_release.sh
```

This creates:

```text
dist/OBJ-Sequence-to-Alembic-macOS.zip
```

The zip contains:

- `OBJ Sequence to Alembic.app`
- `README.md`
- `LICENSE`

The app bundle contains the GUI, converter binary, rebuild script, C++ source,
and the `head-poses` sample sequence.

## Publish With GitHub CLI

Install and authenticate GitHub CLI first:

```bash
brew install gh
gh auth login
```

Then run:

```bash
scripts/publish_release.sh v1.0.0
```

By default the script creates a draft release so the release page can be checked
before publishing.
