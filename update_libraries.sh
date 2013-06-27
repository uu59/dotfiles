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
      echo $dir
      cd $dir
      $cmd
    )
  fi
}

update "$HOME/.rbenv"
update "$HOME/.rbenv/plugins/ruby-build/"
update "$HOME/.nodebrew/" "nodebrew selfupdate"
update "$HOME/.pyenv/"

