
setup() {
  NODEBREW_DIR=$HOME/.nodebrew
  RBENV_DIR=$HOME/.rbenv
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
