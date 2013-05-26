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
    echo -e '\x1B['$color'm'$message'\x1B[0m'
  else
    echo $message
  fi
}

red() {
  color_message "$1" "31"
}
green() {
  color_message "$1" "32"
}
gray() {
  color_message "$1" "37"
}

(
  _dir_=$(pwd)
  cd $(cd $(dirname $0); pwd);
  git submodule update --init

  blacklist=".git .gitignore .gitmodules setup.sh README.mkd"
  for file in $(find $_dir_ -mindepth 1 -maxdepth 1); do
    if [ -z "$(echo $blacklist | grep -F $(basename $file))" ];then
      dst="$HOME/$(basename $file)"
      if [ -e "$dst" ];then
        gray "~${dst#$HOME} exists. skip"
      else
        if [ "$file" != $(basename $0) ];then
          green "symlink $file"
          ln -s $file $dst
        fi
      fi
    fi
  done
)

if [ $? -ne 0 ]; then
  red "something error?"
fi 
