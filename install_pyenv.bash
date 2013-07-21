#!/bin/bash

set -ue

: ${PYENV_DIR:="$HOME/.pyenv"}

if [ -d "$PYENV_DIR" ];then
  echo "$PYENV_DIR is already exists." >&2
  exit 1
fi

git clone https://github.com/yyuu/pyenv $PYENV_DIR

cat <<MESSAGE >&2
Completed.
Set PATH if needed

  export PATH="\$PATH:$PYENV_DIR/bin"

  or

  PATH=(
    \$PATH
    $PYENV_DIR/versions/*/bin(N-/) # use pyenv as plain self-compiled python
  )
MESSAGE

