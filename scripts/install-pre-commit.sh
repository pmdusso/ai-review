#!/usr/bin/env bash
git_root=$(git rev-parse --show-toplevel 2>/dev/null)
if [[ -z "$git_root" ]]; then
  echo "Error: Not a git repository." >&2
  exit 1
fi

hook_path="$git_root/.git/hooks/pre-commit"
if [[ -f "$hook_path" ]]; then
  echo "Warning: A pre-commit hook already exists at $hook_path" >&2
  echo "Please merge the following hook logic manually:" >&2
  echo "------------------------------------------------" >&2
  echo "if git diff --cached --name-only | grep -qE '\.(py|js|ts|sh)$'; then" >&2
  echo "  echo \"Running AI Review on staged files...\"" >&2
  echo "  git diff --cached | ./ai-review -s \"Review this diff quickly before commit. Spot glaring bugs.\" -a qwen -o .git/ai-review-precommit.md || true" >&2
  echo "fi" >&2
  echo "------------------------------------------------" >&2
  exit 1
fi

mkdir -p "$git_root/.git/hooks"
cat << 'HOOK_EOF' > "$hook_path"
#!/usr/bin/env bash
if git diff --cached --name-only | grep -qE '\.(py|js|ts|sh)$'; then
  echo "Running AI Review on staged files..."
  git diff --cached | ./ai-review -s "Review this diff quickly before commit. Spot glaring bugs." -a qwen -o .git/ai-review-precommit.md || true
fi
HOOK_EOF
chmod +x "$hook_path"
echo "Pre-commit hook installed."
