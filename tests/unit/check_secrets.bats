#!/usr/bin/env bats

load '../helpers/setup'

@test "secret scan aborts non-interactive without flags" {
  run ai_review --dry-run -a fast -s "OK" <<< 'api_key = "sk-abcdefghijklmnopqrstuvwxyz12"'
  [ "$status" -eq 3 ]
}

@test "--allow-secrets continues" {
  run ai_review --dry-run -a fast --allow-secrets -s "OK" <<< 'api_key = "sk-abcdefghijklmnopqrstuvwxyz12"'
  [ "$status" -eq 0 ]
  [[ "$output" == *"AI Review dry run"* ]]
}

@test "--redact continues" {
  run ai_review --dry-run -a fast --redact -s "OK" <<< 'api_key = "sk-abcdefghijklmnopqrstuvwxyz12"'
  [ "$status" -eq 0 ]
  [[ "$output" == *"AI Review dry run"* ]]
}
