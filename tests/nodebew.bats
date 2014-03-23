#!/usr/bin/env bats

setup() {
  NODEBREW_DIR=$HOME/.nodebrew
}

@test "executable nodebrew" {
  command -v nodebrew
}

