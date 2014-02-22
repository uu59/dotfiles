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
  if [ -d "$dir" ];then
    (
      set +e
      printf "\x1b[33mcd %s; %s\x1b[0m\n" "$dir" "$cmd"
      cd $dir
      # http://unix.stackexchange.com/a/88338
      local ret
      ret=$($cmd 2>&1)
      if [ $? -ne 0 ];then
        color="31"
      fi
      printf "\x1b[${color:-0}m%s\x1b[0m\n" "$ret"
    )
  fi
}

DOTFILES=$(dirname $0)

update "$HOME/.rbenv"
update "$HOME/.rbenv/plugins/ruby-build/"
update "$HOME/.nodebrew/" "nodebrew selfupdate"
update "$HOME/.pyenv/"
update "$DOTFILES"
