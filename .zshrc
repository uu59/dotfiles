# vim: set fdm=marker: 

#export TERM=xterm-256color
local _ZSH_DIRECTORY="${HOME:-$ZDOTDIR}/.zsh"

autoload -Uz add-zsh-hook
autoload -Uz edit-command-line # C-x C-e
zle -N edit-command-line

if [ -f "$HOME/.zsh/functions" ];then
  source $HOME/.zsh/functions
fi

# zplug {{{
#source ~/.zplug/zplug
#
#zplug "mollifier/anyframe"
#zplug "zsh-users/zsh-completions"
#zplug "hchbaw/zce.zsh"
#zplug load
# }}}

# prompt {{{

# set $fpath before compinit
fpath=(
  "$_ZSH_DIRECTORY/prompt"
  $fpath
  "$_ZSH_DIRECTORY/zsh-completions/src"(N-/)
  "$_ZSH_DIRECTORY/anyframe"(N-/)
  "$_ZSH_DIRECTORY/fpath"(N-/)
  "$HOME/src/git/contrib/completion"(N-/)
)
autoload -Uz anyframe-init
anyframe-init
alias peco="REPORTTIME=0 peco --rcfile=$_ZSH_DIRECTORY/pecorc.json"
zstyle ":anyframe:selector:" use peco
zstyle ":anyframe:selector:peco:" command "peco --rcfile=$_ZSH_DIRECTORY/pecorc.json" # `alias peco` doesn't work?

autoload -Uz promptinit
promptinit
prompt "${ZSH_THEME:-"test2"}"
# }}}

# vcs_info {{{
# This is default setting. updated by each prompt theme
autoload -Uz vcs_info

# zstyle ':vcs_info:*' max-exports 3
# zstyle ':vcs_info:*' enable git svn hg
# zstyle ':vcs_info:*' formats '%s:[%b]'
# # %m is expanded to empty string if hg-mg/stgit are unavailable
# zstyle ':vcs_info:*' actionformats '%s[%b]' '%m' '<⚑ %a>'
# zstyle ':vcs_info:(svn|bzr):*' branchformat '%b:r%r'

# }}}

# variables {{{

zstyle -e ':completion:*:default' list-colors 'reply=("${PREFIX:+=(#bi)($PREFIX:t)(?)*==38;5;158=0}:${(s.:.)LS_COLORS}")'
zle_highlight=(isearch:fg="228",underline)

setopt bsd_echo
setopt prompt_subst # PROMPTの中身を展開
setopt extended_history # 履歴ファイルに時刻を記録
setopt always_last_prompt   # 無駄なスクロールを避ける
setopt append_history # 複数の zsh を同時に使う時など history ファイルに上書きせず追加
setopt auto_list # 補完候補が複数ある時に、一覧表示
setopt NO_beep # ビープ音を鳴らさないようにする
setopt hist_ignore_dups # 直前と同じコマンドラインはヒストリに追加しない
#setopt hist_ignore_all_dups # 重複したヒストリは追加しない
setopt share_history # シェルのプロセスごとに履歴を共有
setopt auto_menu # 補完候補が複数あるときに自動的に一覧表示する
setopt magic_equal_subst     # コマンドラインの引数で --prefix=/usr などの = 以降でも補完できる

setopt extended_glob
setopt glob
setopt no_nomatch # git show HEAD^とかrake foo[bar]とか使いたい

setopt transient_rprompt # http://www.machu.jp/diary/20130114.html

# 補完するかの質問は画面を超える時にのみに行う｡
local LISTMAX=0

local HISTFILE=~/.zsh-history
local HISTSIZE=100000
local SAVEHIST=100000

# http://kimoto.hatenablog.com/entry/2012/08/14/112500
local REPORTTIME=1

# http://unix.stackexchange.com/a/147
export LESS_TERMCAP_mb=$'\E[1;38;05;183m' # blink start
export LESS_TERMCAP_md=$'\E[1;38;05;183m' # bold start
export LESS_TERMCAP_me=$'\E[0m' # bold/underline/blink end
export LESS_TERMCAP_us=$'\E[4;38;05;15m' # underline start
export LESS_TERMCAP_ue=$'\E[0m' # underline end
export LESS_TERMCAP_mr=$'\E[1;38;05;11m' # underline end
# }}}

# platform {{{
case "${OSTYPE}" in
  darwin*)
    alias ls="ls -G"
    alias seq="gseq" # mainly for colorcheck()
    ;;
  linux*)
    alias apti="sudo apt-get install"
    alias apts="sudo apt-cache search"
    alias aptf="sudo apt-file search"
    alias ls="ls -G --color=auto"
    ;;
esac
# }}}

# alias {{{

alias tmux="tmux -2"
alias df="LANG=C df"
alias sort="LC_ALL=C sort"
# http://blog.uu59.org/2014-02-28-grep-ignore-case-fast.html
# grep: warning: GREP_OPTIONS is deprecated; please use an alias or script   
alias grep="LANG=C grep --binary-files=without-match --directories=skip --color=auto"


# C で標準出力をクリップボードにコピーする
# mollifier delta blog : http://mollifier.hatenablog.com/entry/20100317/p1
alias -g C="| copy-to-clipboard"

# }}}

# bindkey {{{
bindkey -e
#bindkey "^?"    backward-delete-char
#bindkey "^H"    backward-delete-char

# Fix Delete/Home/End key
# http://zshwiki.org/home/zle/bindkeys
bindkey "${terminfo[kdch1]}" delete-char
bindkey "${terminfo[khome]}" beginning-of-line
bindkey "${terminfo[kend]}" end-of-line

bindkey "^P" history-beginning-search-backward
bindkey "^N" history-beginning-search-forward
bindkey "^R" history-incremental-pattern-search-backward
bindkey "^G" history-incremental-pattern-search-forward
#bindkey "^S" history-incremental-search-forward

# quickly launch for edit-command-line
my-edit-command-line () {
  local EDITOR="${GIT_EDITOR:-${EDITOR:-vim}}"
  edit-command-line
}
zle -N my-edit-command-line
bindkey '^[\C-e' my-edit-command-line # ESC C-e
bindkey '^[e' my-edit-command-line # ESC e

bindkey '^V' vi-quoted-insert

bindkey '^]'   vi-find-next-char
bindkey '^[^]' vi-find-prev-char

# vimぽいC-w
tcsh-backward-delete-word () {
  local WORDCHARS="${WORDCHARS:s#/#}"
  zle backward-delete-word
}
zle -N tcsh-backward-delete-word
bindkey '^W' tcsh-backward-delete-word

# ^T is a prefix for plugins
bindkey -r "^T"
# }}}

# plugins {{{
() { # auto-fu {{{
  local src="$_ZSH_DIRECTORY/auto-fu.zsh/auto-fu.zsh" 
  if [ -f "$src" ]; then
    # source "$_ZSH_DIRECTORY/auto-fu.zsh/auto-fu.zsh"
    # zle-line-init () {auto-fu-init;}; zle -N zle-line-init
    # zstyle ':completion:*' completer _oldlist _complete
  fi
} # }}}

() { # incr-0.2 {{{
  #. $_ZSH_DIRECTORY/incr-0.2-custom.zsh
  # リモートがらみの補完は重いのでしない
  #zstyle ':completion:*:files' remote-access no
} # }}}

() { # autosuggestions {{{
  # local autosug="$_ZSH_DIRECTORY/zsh-autosuggestions/autosuggestions.zsh"
  # if [ -f "$autosug" ]; then
  #   source $autosug
  #   AUTOSUGGESTION_HIGHLIGHT_COLOR="fg=059,bg=016"
  #   zle-line-init() {
  #       zle autosuggest-start
  #   }
  #   zle -N zle-line-init
  # fi
} # }}}

() { # anyframe {{{
  # easy to type binding because probably most common used
  # bindkey '^T^t' anyframe-widget-insert-git-branch

  bindkey '^T^k' anyframe-widget-kill
  # bindkey '^T^f' anyframe-widget-insert-filename
  bindkey '^T^g' anyframe-widget-cd-ghq-repository
  bindkey '^T^h' anyframe-widget-hotdog
  bindkey '^T^b' anyframe-widget-git-branch
  bindkey '^T^r' anyframe-widget-rake-spec
}
# }}}

() { # easy-moton {{{
  local easy_motion="$_ZSH_DIRECTORY/zsh-easy-motion/easy_motion.plugin.zsh"
  if [[ -f "$easy_motion" ]]; then
    . "$easy_motion"
    bindkey '^T^t' vi-easy-motion
  fi
}
# }}}
# }}}

# terminal multiplexer {{{

# GNU screen {{{

if [ -n "${STY}" ] ; then # screen
  screen-title-set () {
    [ -n "${STY}" ] && [ $# -gt 0 ] && echo -ne '\ek'${1%% *}'\e\\'
  }
  add-zsh-hook preexec screen-title-set
fi
# }}}

# tmux {{{
if [ -n "$TMUX_PANE" ] ;then
  tmux-pane-title-set () {
    [[ -n "${TMUX_PANE}" ]] && [[ $# -gt 0 ]] && printf '\033]2;%s\033\\' $1
  }
  tmux-preexec () {
    if [[ -n $TMUX_PANE ]] && [[ $# -gt 0 ]]; then
      case "$2" in
        ssh\ *)
          tmux-pane-title-set "ssh:${3/ssh /}"
          ;;
        *)
          tmux-pane-title-set "$1"
          ;;
      esac
    fi
  }
  tmux-precmd () {
    tmux-pane-title-set "zsh"
  }
  add-zsh-hook preexec tmux-preexec
  add-zsh-hook precmd tmux-precmd
fi

if [ -n "$TMUX" ]; then
  printf '\033k\033\\' # initialize
fi

# }}}

# }}}

# completion {{{

local GIT_COMPLETION_FILE="${GIT_COMPLETION_FILE:-${HOME}/src/git/contrib/completion/git-completion.sh}"
if [ -n "$GIT_COMPLETION_FILE" -a -f "$GIT_COMPLETION_FILE" ];then
  zstyle ':completion:*:*:git:*' script $GIT_COMPLETION_FILE
fi

autoload -Uz compinit
compinit -C

zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin
zstyle ':completion:*' verbose no
zstyle ':completion:*' completer _complete _ignored # default: _complete _ignored
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'


# debug
# r () {
#   compdef -d rake
#   unfunction _rake
#   . ~/.zsh/_rake
# }

. ~/.zsh/_rake


# }}}


# Don't use slow completion (looks remote-access no solved)
#for slowcomp in gem npm knife; do
#  compdef -d $slowcomp
#done

# http://www.reddit.com/r/commandline/comments/12g76v/how_to_automatically_source_zshrc_in_all_open/
trap "source ~/.zshrc && rehash" USR1

# debug for speed
if (command -v zprof > /dev/null 2>&1) ;then
  zprof | less
fi

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

if [ -f "$HOME/.zsh-local-only" ]; then
  . "$HOME/.zsh-local-only"
fi

pkg-config-rehash() {
  # Mainly for libxml2 and libxslt, `gem i nokgoiri`
  if (( ! $+commands[brew] ));then
    echo "$0 supports Homebrew-powered OSX only"
    return 1
  fi

  {
    local REPORTTIME=1000
    export PKG_CONFIG_PATH="$(find "$(brew --cellar)" -name 'pkgconfig' -type d | grep lib/pkgconfig | sort -r | tr '\n' ':' | sed s/.$//)"
  }
}
