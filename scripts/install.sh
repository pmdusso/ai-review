#!/usr/bin/env bash
# Install or update ai-review on this machine.
set -euo pipefail

REPO_URL="${AI_REVIEW_REPO_URL:-https://github.com/pmdusso/ai-review.git}"
INSTALL_DIR="${AI_REVIEW_INSTALL_DIR:-$HOME/code/shared/ai-review}"
BIN_DIR="${AI_REVIEW_BIN_DIR:-$HOME/.local/bin}"
INSTALL_SKILLS=1

usage() {
  cat <<EOF
Usage: $(basename "$0") [--no-skills]

Install or update ai-review:
  - clone/update checkout
  - symlink CLI into \$AI_REVIEW_BIN_DIR (default: ~/.local/bin)
  - install global templates
  - symlink skills (default):
      ~/.agents/skills/ai-review
      ~/.claude/skills/ai-review  → agents skill
      ~/.codex/skills/ai-review   → agents skill

Options:
  --no-skills   Skip agent skill symlinks
  -h, --help    Show this help

Env overrides:
  AI_REVIEW_REPO_URL, AI_REVIEW_INSTALL_DIR, AI_REVIEW_BIN_DIR
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-skills) INSTALL_SKILLS=0; shift ;;
    -h|--help) usage; exit 0 ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# When run from a clone, prefer that clone as source of truth for this install step.
if [[ -f "$SCRIPT_DIR/../ai-review" && -f "$SCRIPT_DIR/../VERSION" ]]; then
  REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
else
  REPO_ROOT=""
fi

echo "==> ai-review installer"
echo "    install dir: $INSTALL_DIR"
echo "    bin dir:     $BIN_DIR"
echo "    skills:      $(if [[ "$INSTALL_SKILLS" -eq 1 ]]; then echo "yes"; else echo "no"; fi)"

if [[ -n "$REPO_ROOT" && "$REPO_ROOT" == "$(cd "$INSTALL_DIR" 2>/dev/null && pwd || true)" ]]; then
  echo "==> Using existing checkout at $INSTALL_DIR"
elif [[ -d "$INSTALL_DIR/.git" ]]; then
  echo "==> Updating $INSTALL_DIR"
  git -C "$INSTALL_DIR" pull --ff-only
elif [[ -n "$REPO_ROOT" ]]; then
  echo "==> Installing from current checkout ($REPO_ROOT)"
  INSTALL_DIR="$REPO_ROOT"
else
  echo "==> Cloning $REPO_URL → $INSTALL_DIR"
  mkdir -p "$(dirname "$INSTALL_DIR")"
  git clone "$REPO_URL" "$INSTALL_DIR"
fi

mkdir -p "$BIN_DIR"
ln -sfn "$INSTALL_DIR/ai-review" "$BIN_DIR/ai-review"
echo "==> Symlinked $BIN_DIR/ai-review → $INSTALL_DIR/ai-review"

if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
  echo "Warning: $BIN_DIR is not in PATH. Add:"
  echo "  export PATH=\"$BIN_DIR:\$PATH\""
fi

echo "==> Installing global templates"
"$INSTALL_DIR/scripts/install-templates.sh" || true

install_skills() {
  local agents_skill="$HOME/.agents/skills/ai-review"
  local claude_skill="$HOME/.claude/skills/ai-review"
  local codex_skill="$HOME/.codex/skills/ai-review"

  mkdir -p "$HOME/.agents/skills" "$HOME/.claude/skills" "$HOME/.codex/skills"

  # Canonical skill points at the checkout; Claude/Codex link through agents when present.
  ln -sfn "$INSTALL_DIR" "$agents_skill"
  echo "==> Skill: $agents_skill → $INSTALL_DIR"

  ln -sfn "$agents_skill" "$claude_skill"
  echo "==> Skill: $claude_skill → $agents_skill"

  ln -sfn "$agents_skill" "$codex_skill"
  echo "==> Skill: $codex_skill → $agents_skill"

  if [[ ! -f "$agents_skill/SKILL.md" ]]; then
    echo "Warning: SKILL.md missing at $agents_skill/SKILL.md" >&2
  fi
}

if [[ "$INSTALL_SKILLS" -eq 1 ]]; then
  echo "==> Installing agent skills"
  install_skills
else
  echo "==> Skipping agent skills (--no-skills)"
fi

echo "==> Checking dependencies"
missing=()
for dep in bash jq; do
  if ! command -v "$dep" >/dev/null 2>&1; then
    missing+=("$dep")
  fi
done
if ! command -v yq >/dev/null 2>&1; then
  echo "Warning: yq not found (needed for .ai-review/config.yaml). Install: brew install yq"
fi
if [[ "${#missing[@]}" -gt 0 ]]; then
  echo "Error: missing required tools: ${missing[*]}" >&2
  exit 1
fi

echo "==> Checking agent CLIs (optional)"
for cli in gemini codex auggie mmx qwen claude; do
  if command -v "$cli" >/dev/null 2>&1; then
    echo "  ok: $cli"
  else
    echo "  missing: $cli"
  fi
done

export PATH="$BIN_DIR:$PATH"
echo "==> Validating"
ai-review --version
ai-review --list-agents

echo "==> Install complete."
printf '%s\n' "Quick test:  printf 'ok\\n' | ai-review --dry-run -a fast -s 'Responda OK.'"
printf '%s\n' "Full setup:  see $INSTALL_DIR/docs/install.md"
if [[ "$INSTALL_SKILLS" -eq 1 ]]; then
  printf '%s\n' "Skills: restart Claude Code / Codex to pick up ai-review."
fi
