#!/usr/bin/env bash
# Install bundled templates to user global config or project .ai-review/
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC_DIR="$REPO_ROOT/templates"

PROJECT=0
FORCE=0

usage() {
  cat <<EOF
Usage: $(basename "$0") [--project] [--force]

  (default)  Copy templates/*.txt → ~/.config/ai-review/templates/
  --project  Copy templates/*.txt → ./.ai-review/templates/ (cwd)
  --force    Overwrite existing files

Does not copy config.example.yaml (use scripts/init-project.sh for that).
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT=1; shift ;;
    --force) FORCE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ ! -d "$SRC_DIR" ]]; then
  echo "Error: templates directory not found at $SRC_DIR" >&2
  exit 1
fi

if [[ "$PROJECT" -eq 1 ]]; then
  DEST="$(pwd)/.ai-review/templates"
else
  DEST="${HOME}/.config/ai-review/templates"
fi

mkdir -p "$DEST"
copied=0
skipped=0

for src in "$SRC_DIR"/*.txt; do
  [[ -f "$src" ]] || continue
  base="$(basename "$src")"
  dest="$DEST/$base"
  if [[ -f "$dest" && "$FORCE" -eq 0 ]]; then
    echo "skip (exists): $dest"
    skipped=$((skipped + 1))
    continue
  fi
  cp "$src" "$dest"
  echo "installed: $dest"
  copied=$((copied + 1))
done

echo "Done. copied=${copied} skipped=${skipped} dest=${DEST}"
