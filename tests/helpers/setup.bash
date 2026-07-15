#!/usr/bin/env bash
# bats helper: prepend mock CLIs and expose REPO_ROOT / AI_REVIEW

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export REPO_ROOT
export AI_REVIEW="${REPO_ROOT}/ai-review"
export MOCK_BIN="${REPO_ROOT}/tests/helpers/mock-clis"
export PATH="${MOCK_BIN}:${PATH}"

# Isolate HOME and cwd so global/project config does not leak into tests.
export HOME="${BATS_TEST_TMPDIR:-${BATS_TMPDIR}/home-$$}/home"
mkdir -p "$HOME"
export TEST_CWD="${BATS_TEST_TMPDIR:-${BATS_TMPDIR}/cwd-$$}/work"
mkdir -p "$TEST_CWD"
cd "$TEST_CWD" || exit 1

# Clear overrides that could leak from the developer environment.
unset AI_REVIEW_GEMINI_MODEL AI_REVIEW_CODEX_MODEL AI_REVIEW_AUGGIE_MODEL
unset AI_REVIEW_MMX_MODEL AI_REVIEW_QWEN_MODEL AI_REVIEW_CLAUDE_MODEL
unset AI_REVIEW_TIMEOUT_SECONDS AI_REVIEW_QWEN_AUTH_TYPE AI_REVIEW_HOME

ai_review() {
  "$AI_REVIEW" "$@"
}
