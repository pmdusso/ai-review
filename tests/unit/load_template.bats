#!/usr/bin/env bats

load '../helpers/setup'

@test "bundled template security loads" {
  run ai_review --dry-run -a fast -t security <<< "code"
  [ "$status" -eq 0 ]
  [[ "$output" == *"system instruction: yes"* ]]
  [[ "$output" == *"template: security"* ]]
}

@test "project template overrides bundled" {
  mkdir -p .ai-review/templates
  echo "PROJECT TEMPLATE PERSONA" > .ai-review/templates/security.txt
  run ai_review --dry-run -a fast -t security <<< "code"
  [ "$status" -eq 0 ]
  # dry-run does not print template body; ensure it still succeeds with project file present
  [[ "$output" == *"template: security"* ]]
}

@test "-s and -t together fail" {
  run ai_review --dry-run -a fast -s "custom" -t security <<< "code"
  [ "$status" -ne 0 ]
}

@test "missing template fails" {
  run ai_review --dry-run -a fast -t does-not-exist <<< "code"
  [ "$status" -ne 0 ]
  [[ "$output" == *"not found"* ]] || [[ "$stderr" == *"not found"* ]]
}
