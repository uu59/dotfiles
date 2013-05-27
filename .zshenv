export LS_COLORS="di=38;05;117"
export LESS="--LONG-PROMPT --ignore-case --no-init -RF"
export EDITOR="vim"
export GIT_EDITOR="vim -u $HOME/.vimrc.basic"
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

export PATH="$HOME/bin:$HOME/local/bin:$HOME/.rbenv/bin:/usr/local/bin:/opt/bin:/usr/local/sbin:${PATH}"
#  --single-process --no-proxy-server \
export CHROME_OPTIONS="--no-referrers --disk-cache-dir=/tmp/chromecache --disk-cache-size=102400 \
  --media-cache-size=104800 --enable-click-to-play --purge-memory-button \
  --process-per-tab \
  --disable-sync --disable-geolocation --disable-content-prefetch --disable-preconnect --disable-connect-backup-jobs \
   "

if [ -f "$HOME/.zsh-local-only" ]; then
  . "$HOME/.zsh-local-only"
fi

which rbenv > /dev/null 2>&1
if [ $? -eq 0 ]; then
  eval "$(rbenv init - --no-rehash)"
fi

export PATH="$HOME/.nodebrew/current/bin:$PATH"
