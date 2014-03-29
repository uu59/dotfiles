#!/bin/bash

set -ue

usage_exit () {
  echo "Usage: $0" >&2
  exit 1
}

dir=$(dirname $0)
$dir/bats/bin/bats $dir/tests $*
