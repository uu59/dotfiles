#zmodload zsh/zprof && zprof
typeset -U path cdpath fpath manpath

export LS_COLORS="di=38;05;117"
export LESS="--LONG-PROMPT --ignore-case --no-init -RF"
export EDITOR="vim"
export GIT_EDITOR="vim -u $HOME/.vimrc.basic -c startinsert"
case ${OSTYPE} in
  dargin*)
    ;;
  linux*)
    export CFLAGS="-O2 -march=native -pipe"
    export CXXFLAGS="${CFLAGS}"
    ;;
esac
export GREP_OPTIONS='--binary-files=without-match --directories=skip --color=auto'
export GISTY_DIR=$HOME/gisty

path=($HOME/bin(N-/) $HOME/local/bin(N-/) /usr/local/bin /opt/bin(N-/) /usr/local/sbin(N-/) ${path})

#  --single-process --no-proxy-server \
export CHROME_OPTIONS="--no-referrers --disk-cache-dir=/tmp/chromecache --disk-cache-size=102400 \
  --media-cache-size=104800 --enable-click-to-play --purge-memory-button \
  --process-per-tab \
  --disable-sync --disable-geolocation --disable-content-prefetch --disable-preconnect --disable-connect-backup-jobs \
   "

if [ -f "$HOME/.zsh-local-only" ]; then
  . "$HOME/.zsh-local-only"
fi

if [ $+commands[rbenv] -ne 0 ]; then
  eval "$(rbenv init - --no-rehash)"
fi

path=(
  $HOME/.rbenv/bin(N-/)
  $HOME/.nodebrew/current/bin(N-/)
  $HOME/.pyenv/versions/*/bin(N-/) # use pyenv as plain self-compiled python
  $HOME/.pyenv/bin(N-/)
  ${path}
)
