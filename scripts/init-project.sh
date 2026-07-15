#!/usr/bin/env bash
# Bootstrap .ai-review/ in a consumer repository (cwd).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FORCE=0
GITIGNORE=0

usage() {
  cat <<EOF
Usage: $(basename "$0") [--force] [--gitignore]

Run from the consumer project root. Creates:
  .ai-review/config.yaml          (from templates/config.example.yaml)
  .ai-review/templates/*.txt      (bundled personas)

  --force      Overwrite existing config/templates
  --gitignore  Append '.ai-review/' to .gitignore if missing
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force) FORCE=1; shift ;;
    --gitignore) GITIGNORE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

DEST_DIR="$(pwd)/.ai-review"
DEST_CFG="$DEST_DIR/config.yaml"
DEST_TPL="$DEST_DIR/templates"
SRC_CFG="$REPO_ROOT/templates/config.example.yaml"

mkdir -p "$DEST_TPL"

if [[ -f "$DEST_CFG" && "$FORCE" -eq 0 ]]; then
  echo "skip (exists): $DEST_CFG"
else
  cp "$SRC_CFG" "$DEST_CFG"
  echo "installed: $DEST_CFG"
fi

for src in "$REPO_ROOT/templates"/*.txt; do
  [[ -f "$src" ]] || continue
  base="$(basename "$src")"
  dest="$DEST_TPL/$base"
  if [[ -f "$dest" && "$FORCE" -eq 0 ]]; then
    echo "skip (exists): $dest"
    continue
  fi
  cp "$src" "$dest"
  echo "installed: $dest"
done

if [[ "$GITIGNORE" -eq 1 ]]; then
  gi="$(pwd)/.gitignore"
  if [[ -f "$gi" ]] && grep -qxF '.ai-review/' "$gi"; then
    echo "skip: .ai-review/ already in .gitignore"
  else
    printf '\n.ai-review/\n' >> "$gi"
    echo "appended .ai-review/ to .gitignore"
  fi
fi

echo "Project ai-review config ready at $DEST_DIR"
echo "Edit $DEST_CFG then try: ai-review --dry-run -f <file>"
