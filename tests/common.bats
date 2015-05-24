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

@test "executable bundle" {
  command -v bundle
}

@test "executable kramdown" {
  command -v kramdown
}

@test "executable node" {
  command -v node
}

@test "executable npm" {
  command -v npm
}

@test "executable coffee" {
  command -v coffee
}

@test "executable babel" {
  command -v babel
}

@test "executable python" {
  command -v python
}

@test "executable pip" {
  command -v pip
}

@test "executable go" {
  command -v go
}

@test 'set $GOPATH' {
  env | grep -F -q GOPATH
}

@test "executable ghq" {
  command -v ghq
}

@test "executable peco" {
  command -v peco
}
