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

color_message() {
  local message=$1
  local color=$2
  if tty -s <&1; then
    echo -e '\e['$color'm'$message'\e[0m'
  else
    echo $message
  fi
}

green() {
  color_message "$1" "32"
}
gray() {
  color_message "$1" "37"
}

_dir_=$(pwd)
cd $(cd $(dirname $0); pwd);

for file in $(git ls-files); do
  if [ ! -f "${HOME}/${file}" ];then
    if [ "$file" != $(basename $0) ];then
      green "symlink $file"
      ln -s $_dir_/$file $HOME/$file
    fi
  else
    gray "~/$file exists. skip"
  fi
done

cd $_dir_
