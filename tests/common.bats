#!/usr/bin/env bats

debug() {
  echo $@ >&3
}

@test "executable ruby" {
  command -v ruby
}

@test "executable gem" {
  command -v gem
}

@test "executable node" {
  command -v node
}

@test "executable npm" {
  command -v npm
}

@test "executable python" {
  command -v python
}

@test "executable pip" {
  command -v pip
}
