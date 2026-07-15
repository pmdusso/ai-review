#!/usr/bin/env bats

load '../helpers/setup'

@test "--help exits 0 and shows usage" {
  run ai_review --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "--version prints VERSION file" {
  run ai_review --version
  [ "$status" -eq 0 ]
  [[ "$output" == *"ai-review 0.2.0"* ]]
}

@test "--list-agents shows presets" {
  run ai_review --list-agents
  [ "$status" -eq 0 ]
  [[ "$output" == *"fast"* ]]
  [[ "$output" == *"balanced"* ]]
  [[ "$output" == *"full"* ]]
  [[ "$output" == *"qwen"* ]]
}
