# vim: set fdm=marker: 

export TERM=xterm-256color

# autoload, zle, etc {{{

local _ZSH_DIRECTORY="$HOME/.zsh"
if [[ -d "$_ZSH_DIRECTORY/zsh-completions/src" ]]; then
  # set $fpath before compinit
  fpath=($fpath "$_ZSH_DIRECTORY/zsh-completions/src")
fi
fpath=($fpath "$HOME/src/git/contrib/completion")
autoload -Uz compinit

zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin
zstyle ':completion:*' verbose no
zstyle ':completion:*' completer _complete _ignored # default: _complete _ignored
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'


fpath=($fpath "$_ZSH_DIRECTORY/prompt")
autoload -Uz promptinit
promptinit
prompt "${ZSH_THEME:-"uu59"}"

autoload -Uz edit-command-line # C-x C-e
autoload -Uz add-zsh-hook

zle -N edit-command-line

# -- vcs_info {{{
# This is default setting. updated by each prompt theme
autoload -Uz vcs_info
compinit -C

zstyle ':vcs_info:*' max-exports 3
zstyle ':vcs_info:*' enable git svn hg

zstyle ':vcs_info:*' formats '%s:[%b]'
# %m is expanded to empty string if hg-mg/stgit are unavailable
zstyle ':vcs_info:*' actionformats '%s[%b]' '%m' '<⚑ %a>'
zstyle ':vcs_info:(svn|bzr):*' branchformat '%b:r%r'

# }}}


local GIT_COMPLETION_FILE="${GIT_COMPLETION_FILE:-${HOME}/src/git/contrib/completion/git-completion.sh}"
if [ -n "$GIT_COMPLETION_FILE" -a -f "$GIT_COMPLETION_FILE" ];then
  zstyle ':completion:*:*:git:*' script $GIT_COMPLETION_FILE
fi

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
setopt nullglob # git show HEAD^とかrake foo[bar]とか使いたい

setopt transient_rprompt # http://www.machu.jp/diary/20130114.html

# 補完するかの質問は画面を超える時にのみに行う｡
local LISTMAX=0

local HISTFILE=~/.zsh-history
local HISTSIZE=100000
local SAVEHIST=100000

# http://kimoto.hatenablog.com/entry/2012/08/14/112500
local REPORTTIME=1
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

# variables & alias {{{

alias tmux="tmux -2"
alias df="LANG=C df"
alias sort="LC_ALL=C sort"


# C で標準出力をクリップボードにコピーする
# mollifier delta blog : http://mollifier.hatenablog.com/entry/20100317/p1
if which xsel >/dev/null 2>&1 ; then
  # Linux
  alias -g C='| xsel --input --clipboard'
elif which pbcopy >/dev/null 2>&1 ; then
  # Mac
  alias -g C='| pbcopy'
elif which putclip >/dev/null 2>&1 ; then
  # Cygwin
  alias -g C='| putclip'
fi

# http://unix.stackexchange.com/a/147
export LESS_TERMCAP_mb=$'\E[1;38;05;183m' # blink start
export LESS_TERMCAP_md=$'\E[1;38;05;183m' # bold start
export LESS_TERMCAP_me=$'\E[0m' # bold/underline/blink end
export LESS_TERMCAP_us=$'\E[4;38;05;15m' # underline start
export LESS_TERMCAP_ue=$'\E[0m' # underline end
export LESS_TERMCAP_mr=$'\E[1;38;05;11m' # underline end

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

# vimぽいC-w
tcsh-backward-delete-word () {
  local WORDCHARS="${WORDCHARS:s#/#}"
  zle backward-delete-word
}
zle -N tcsh-backward-delete-word
bindkey '^W' tcsh-backward-delete-word

# }}}

# -- plugins {{{
if [ -f "$_ZSH_DIRECTORY/auto-fu.zsh/auto-fu.zsh" ]; then
  # source "$_ZSH_DIRECTORY/auto-fu.zsh/auto-fu.zsh"
  # zle-line-init () {auto-fu-init;}; zle -N zle-line-init
  # zstyle ':completion:*' completer _oldlist _complete
fi

() {
  . $_ZSH_DIRECTORY/incr-0.2-custom.zsh
}

() {
  # local autosug="$_ZSH_DIRECTORY/zsh-autosuggestions/autosuggestions.zsh"
  # if [ -f "$autosug" ]; then
  #   source $autosug
  #   AUTOSUGGESTION_HIGHLIGHT_COLOR="fg=059,bg=016"
  #   zle-line-init() {
  #       zle autosuggest-start
  #   }
  #   zle -N zle-line-init
  # fi
}

() {
  local zce="$_ZSH_DIRECTORY/zce.zsh/zce.zsh"
    if [ -f "$zce" ]; then
    . $zce
    # エラーになってしまうのでコンパイルしない
    # autoload -w "$compile_to/zce"
    # zle -N zce
    bindkey '^T' zce
    () {
      setopt localoptions braceccl
      zstyle ':zce:*' keys ${(j..)$(print fjdk{a-z})}
    }
  fi
}
# }}}

# http://www.reddit.com/r/commandline/comments/12g76v/how_to_automatically_source_zshrc_in_all_open/
trap "source ~/.zshrc && rehash" USR1

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
    [ -n "${TMUX_PANE}" ] && [ $# -gt 0 ] && printf '\033]2;'${1%% *}'\033\\'
  }
  add-zsh-hook preexec tmux-pane-title-set
  tmux-pane-title-set "zsh"
fi

if [ -n "$TMUX" ]; then
  printf '\033k\033\\' # initialize
fi

# }}}

if [ -f "$HOME/.zsh/functions" ];then
  source $HOME/.zsh/functions
fi

if (which zprof > /dev/null 2>&1) ;then
  zprof | less
fi
