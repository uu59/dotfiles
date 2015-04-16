#zmodload zsh/zprof && zprof
export PROMPT4="+ %x:%I $ "
typeset -U path cdpath fpath manpath

export LS_COLORS="di=38;05;117"
export LESS="--LONG-PROMPT --ignore-case --no-init -RF -i"
export EDITOR="vim"
export GIT_EDITOR="vim -u $HOME/.vimrc.basic"
case ${OSTYPE} in
  dargin*)
    ;;
  linux*)
    export CFLAGS="-O2 -march=native -pipe"
    export CXXFLAGS="${CFLAGS}"
    export MAKE_OPTS="-j $(grep -w -F -c processor /proc/cpuinfo)"
    ;;
esac
export GOPATH="$HOME/gopath"

path=($HOME/bin(N-/) $HOME/local/bin(N-/) /usr/local/bin /opt/bin(N-/) /usr/local/sbin(N-/) $GOPATH/bin(N-/) ${path})

#  --single-process --no-proxy-server \
export CHROME_OPTIONS="--no-referrers --disk-cache-dir=/tmp/chromecache --disk-cache-size=102400 \
  --media-cache-size=104800 --enable-click-to-play --purge-memory-button \
  --disable-sync \
  --disable-geolocation \
  --disable-content-prefetch \
  --disable-preconnect \
  --disable-prerender-local-predictor \
  --disable-connect-backup-jobs \
  --disable-print-preview \
   "
#export CHROMIUM_USER_FLAGS="\
#  --disable-manager-for-sync-signin \
#  --disable-preconnect \
#  --disable-prerender-local-predictor \
#  --disable-translate \
#  --renderer-process-limit=5 --disable-sync --disk-cache-size=1024000 --disable-print-preview\
#  "

if [ -f "$HOME/.zsh-local-only" ]; then
  . "$HOME/.zsh-local-only"
fi

path=(
  #$HOME/.rbl/current/bin(N-/)
  $HOME/dotfiles/bin
  $HOME/.rbenv/bin(N-/)
  $HOME/.nodebrew/current/bin(N-/)
  $HOME/.pyenv/versions/*/bin(N-/) # use pyenv as plain self-compiled python
  $HOME/.pyenv/bin(N-/)
  ${path}
)

if [ $+commands[rbenv] -ne 0 ]; then
  rbenv_init(){
    # eval "$(rbenv init - --no-rehash)" is crazy slow (it takes arround 100ms)
    # below style took ~2ms
    export RBENV_SHELL=zsh
    source "$HOME/.rbenv/completions/rbenv.zsh"
    rbenv() {
      local command
      command="$1"
      if [ "$#" -gt 0 ]; then
        shift
      fi

      case "$command" in
      rehash|shell)
        eval "`rbenv "sh-$command" "$@"`";;
      *)
        command rbenv "$command" "$@";;
      esac
    }
    path=($HOME/.rbenv/shims $path)
  }
  rbenv_init
  unfunction rbenv_init
fi

if [ $+commands[nodebrew] -ne 0 ]; then
  export NODE_PATH=$HOME/.nodebrew/current/lib/node_modules
fi
