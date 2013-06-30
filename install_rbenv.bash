#!/bin/bash

set -ue

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

RBENV_DIR="$HOME/.rbenv"

if [ -d "$RBENV_DIR" ];then
  echo "$RBENV_DIR exists. skip"
else
  git clone https://github.com/sstephenson/rbenv $RBENV_DIR
  mkdir -p $RBENV_DIR/plugins
fi

if [ -d "$RBENV_DIR/plugins/ruby-build" ];then
  echo "$RBENV_DIR/plugins/ruby-build exists. skip"
else
  git clone https://github.com/sstephenson/ruby-build $RBENV_DIR/plugins/ruby-build
fi
