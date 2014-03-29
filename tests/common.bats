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

@test "runnable zsh" {
  DIR="${BATS_TEST_DIRNAME}/../"
  export ZDOTDIR=$BATS_TMPDIR/zsh-test
  mkdir -p $ZDOTDIR
  cp -a $DIR/.zsh* $ZDOTDIR/
  cp -a $DIR/.zsh/* $ZDOTDIR/
  run zsh -l -i -c exit
  [ $status -eq 0 ]
}
