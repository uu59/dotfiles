#!/usr/bin/env bats

setup() {
  RBENV_DIR=$HOME/.rbenv
}

@test "executable rbenv" {
  command -v rbenv
}

@test "rbenv has ruby-build plugin" {
  [ -d "$RBENV_DIR/plugins/ruby-build" ]
}
