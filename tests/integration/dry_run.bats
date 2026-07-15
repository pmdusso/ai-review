#!/usr/bin/env bats

load '../helpers/setup'

@test "dry-run does not require writing results and shows stats" {
  run ai_review --dry-run -a fast -s "Revise" -f "$REPO_ROOT/README.md"
  [ "$status" -eq 0 ]
  [[ "$output" == *"No content was sent"* ]]
  [[ "$output" == *"bytes:"* ]]
  [[ "$output" == *"- qwen:"* ]]
}

@test "dry-run with file missing fails" {
  run ai_review --dry-run -a fast -s "OK" -f /no/such/file.txt
  [ "$status" -ne 0 ]
}
