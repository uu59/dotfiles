#!/bin/bash

set -e

usage_exit () {
  echo "Usage: $0" >&2
  exit 1
}

while getopts "h" flag; do
  case "$flag" in
    h) usage_exit;;
  esac
done
shift $(( $OPTIND - 1 ))

update() {
  dir="$1"
  cmd="${2:-"git pull --rebase"}"
  install="${3:-":"}"
  if [ -d "$dir" ];then
    (
      set +e
      printf "\x1b[33mcd %s; %s\x1b[0m\n" "$dir" "$cmd"
      cd $dir
      # http://unix.stackexchange.com/a/88338
      local ret
      ret="$($cmd 2>&1)"
      if [ $? -ne 0 ];then
        color="31"
      fi
      printf "\x1b[${color:-0}m%s\x1b[0m\n" "$ret"
    )
  else
    $install
  fi
}

DOTFILES=$(dirname $0)

update-sdkman() {
  test -d "$HOME/.sdkman/" && source $HOME/.sdkman/bin/sdkman-init.sh && sdk selfupdate
}

update "$HOME/.sdkman/" "update-sdkman" 'curl -s "https://get.sdkman.io" | bash'
update "$HOME/.rbenv"
update "$HOME/.rbenv/plugins/ruby-build/"
update "$HOME/.rbenv/plugins/rbenv-vars/"
update "$HOME/.nodebrew/" "nodebrew selfupdate"
update "$HOME/.pyenv/"
update "$HOME/.jenv/"
update "$HOME" "go get -u github.com/motemen/ghq"
update "$DOTFILES" "git submodule update --remote --rebase --checkout"
update "$DOTFILES"
