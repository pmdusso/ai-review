#!/usr/bin/env bats

load '../helpers/setup'

setup() {
  if ! command -v yq >/dev/null 2>&1; then
    skip "yq not installed"
  fi
}

@test "project config applies agents and timeout" {
  mkdir -p .ai-review
  cat > .ai-review/config.yaml <<'EOF'
version: 1
agents: fast
timeout_seconds: 42
template: pr-review
redact: true
EOF
  run ai_review --dry-run <<< "hello"
  [ "$status" -eq 0 ]
  [[ "$output" == *"- qwen:"* ]]
  [[ "$output" != *"- gemini:"* ]]
  [[ "$output" == *"timeout: 42s"* ]]
  [[ "$output" == *"template: pr-review"* ]]
  [[ "$output" == *"redact: yes"* ]]
}

@test "CLI -a overrides config agents" {
  mkdir -p .ai-review
  cat > .ai-review/config.yaml <<'EOF'
version: 1
agents: fast
EOF
  run ai_review --dry-run -a balanced -s "OK" <<< "hello"
  [ "$status" -eq 0 ]
  [[ "$output" == *"- gemini:"* ]]
  [[ "$output" == *"- qwen:"* ]]
}

@test "YAML agents list is accepted" {
  mkdir -p .ai-review
  cat > .ai-review/config.yaml <<'EOF'
version: 1
agents:
  - qwen
  - gemini
EOF
  run ai_review --dry-run -s "OK" <<< "hello"
  [ "$status" -eq 0 ]
  [[ "$output" == *"- qwen:"* ]]
  [[ "$output" == *"- gemini:"* ]]
}
