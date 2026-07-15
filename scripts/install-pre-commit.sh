#!/usr/bin/env bash
# Install a pre-commit hook in the *consumer* git repository (cwd), not in ai-review itself.
set -euo pipefail

STRICT=0

usage() {
  cat <<EOF
Usage: $(basename "$0") [--strict]

Installs a git pre-commit hook in the repository at the current working directory.
Requires \`ai-review\` on PATH (install via scripts/install.sh).

The hook:
  - runs only when staged files match common code extensions
  - uses preset \`fast\` (qwen) and \`--redact\`
  - writes a report to .git/ai-review-precommit.md
  - by default never blocks the commit (\`|| true\`)

  --strict   Fail the commit if ai-review exits non-zero
  -h, --help Show this help

This is opt-in advisory review, not a merge gate.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --strict) STRICT=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if ! command -v ai-review >/dev/null 2>&1; then
  echo "Error: ai-review not found on PATH. Run scripts/install.sh first." >&2
  exit 1
fi

git_root=$(git rev-parse --show-toplevel 2>/dev/null || true)
if [[ -z "$git_root" ]]; then
  echo "Error: Not a git repository (run from a consumer project)." >&2
  exit 1
fi

hook_path="$git_root/.git/hooks/pre-commit"

fail_clause="|| true"
if [[ "$STRICT" -eq 1 ]]; then
  fail_clause=""
fi

hook_body=$(cat <<HOOK_EOF
#!/usr/bin/env bash
# Installed by ai-review scripts/install-pre-commit.sh
if ! command -v ai-review >/dev/null 2>&1; then
  echo "ai-review not on PATH; skipping pre-commit review." >&2
  exit 0
fi
if git diff --cached --name-only | grep -qE '\\.(py|js|ts|tsx|jsx|sh|go|rs|java|rb|php)$'; then
  echo "Running AI Review on staged files (fast + redact)..."
  git diff --cached | ai-review -a fast --redact \\
    -s "Review rápido pré-commit. Bugs óbvios apenas." \\
    -o .git/ai-review-precommit.md ${fail_clause}
fi
HOOK_EOF
)

if [[ -f "$hook_path" ]]; then
  echo "Warning: A pre-commit hook already exists at $hook_path" >&2
  echo "Please merge the following hook logic manually:" >&2
  echo "------------------------------------------------" >&2
  printf '%s\n' "$hook_body" >&2
  echo "------------------------------------------------" >&2
  exit 1
fi

mkdir -p "$git_root/.git/hooks"
printf '%s\n' "$hook_body" > "$hook_path"
chmod +x "$hook_path"
echo "Pre-commit hook installed at $hook_path"
if [[ "$STRICT" -eq 1 ]]; then
  echo "Mode: strict (non-zero ai-review exit blocks commit)"
else
  echo "Mode: advisory (commit always proceeds; see --strict)"
fi
