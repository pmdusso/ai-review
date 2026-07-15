#!/usr/bin/env bats

load '../helpers/setup'

@test "fan-out with two mock agents succeeds" {
  run ai_review -a qwen,gemini -s "OK" --timeout 30 <<< "review me"
  [ "$status" -eq 0 ]
  [[ "$output" == *"QWEN"* ]] || [[ "$output" == *"qwen"* ]] || [[ "$output" == *"mock qwen"* ]]
  [[ "$output" == *"mock qwen review OK"* ]]
  [[ "$output" == *"mock gemini review OK"* ]]
  [[ "$output" == *"ok=2"* ]]
}

@test "output file is written" {
  out="${BATS_TEST_TMPDIR}/report.md"
  run ai_review -a qwen -s "OK" -o "$out" <<< "review me"
  [ "$status" -eq 0 ]
  [ -f "$out" ]
  grep -q "mock qwen review OK" "$out"
}

@test "timeout yields status 124 for slow agent" {
  export MOCK_QWEN_SLEEP=5
  run ai_review -a qwen -s "OK" --timeout 1 <<< "slow"
  [ "$status" -eq 0 ]
  [[ "$output" == *"timeout=1"* ]] || [[ "$output" == *"status=124"* ]]
}
