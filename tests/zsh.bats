
setup() {
  NODEBREW_DIR=$HOME/.nodebrew
  RBENV_DIR=$HOME/.rbenv
}

@test "runnable zsh" {
  DIR=$(cd "${BATS_TEST_DIRNAME}/../"; pwd)
  export ZDOTDIR=$BATS_TMPDIR/zsh-test
  ln -sf $ZDOTDIR $DIR
  run zsh -l -i -c "exit"
  [ $status -eq 0 ]
  [ "$(strings <<< $output)" = "" ]
}

@test "executable nodebrew" {
  run zsh -i -l -c 'command -v nodebrew'
  [ $status -eq 0 ]
}

@test "executable rbenv" {
  run zsh -i -l -c 'command -v rbenv'
  [ $status -eq 0 ]
}

@test "rbenv has ruby-build plugin" {
  [ -d "$RBENV_DIR/plugins/ruby-build" ]
}
