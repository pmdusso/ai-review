#!/usr/bin/env bats

load '../helpers/setup'

@test "preset fast selects only qwen" {
  run ai_review --dry-run -a fast -s "OK" <<< "content"
  [ "$status" -eq 0 ]
  [[ "$output" == *"- qwen:"* ]]
  [[ "$output" != *"- gemini:"* ]]
}

@test "preset balanced selects qwen and gemini" {
  run ai_review --dry-run -a balanced -s "OK" <<< "content"
  [ "$status" -eq 0 ]
  [[ "$output" == *"- qwen:"* ]]
  [[ "$output" == *"- gemini:"* ]]
  [[ "$output" != *"- codex:"* ]]
}

@test "preset full expands to default agents" {
  run ai_review --dry-run -a full -s "OK" <<< "content"
  [ "$status" -eq 0 ]
  [[ "$output" == *"- gemini:"* ]]
  [[ "$output" == *"- codex:"* ]]
  [[ "$output" == *"- qwen:"* ]]
  [[ "$output" != *"- claude:"* ]]
}

@test "default+claude includes claude" {
  run ai_review --dry-run -a default+claude -s "OK" <<< "content"
  [ "$status" -eq 0 ]
  [[ "$output" == *"- claude:"* ]]
}

@test "unknown agent fails" {
  run ai_review --dry-run -a nope -s "OK" <<< "content"
  [ "$status" -eq 2 ]
}
