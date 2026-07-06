#!/usr/bin/env bash
git_root=$(git rev-parse --show-toplevel 2>/dev/null)
if [[ -z "$git_root" ]]; then
  echo "Error: Not a git repository." >&2
  exit 1
fi
mkdir -p "$git_root/.git/hooks"
cat << 'HOOK_EOF' > "$git_root/.git/hooks/pre-commit"
#!/usr/bin/env bash
if git diff --cached --name-only | grep -qE '\.(py|js|ts|sh)$'; then
  echo "Running AI Review on staged files..."
  git diff --cached | ai-review -s "Review this diff quickly before commit. Spot glaring bugs." -a qwen -o .git/ai-review-precommit.md || true
fi
HOOK_EOF
chmod +x "$git_root/.git/hooks/pre-commit"
echo "Pre-commit hook installed."
