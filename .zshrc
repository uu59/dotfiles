# vim: set fdm=marker: 

# autoload, zle, etc {{{

_ZSH_DIRECTORY="$HOME/.zsh"
if [[ -d "$_ZSH_DIRECTORY/zsh-completions/src" ]]; then
  # set $fpath before compinit
  fpath=($fpath "$_ZSH_DIRECTORY/zsh-completions/src")
fi

autoload -U compinit
compinit

autoload -Uz edit-command-line # C-x C-e
autoload -Uz add-zsh-hook

zle -N edit-command-line

# sudo でも補完の対象
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin

# -- vcs_info {{{
  autoload -Uz vcs_info
  zstyle ':vcs_info:*' formats '(%s)-[%b]'
  zstyle ':vcs_info:*' actionformats '(%s)-[%b|%a]'
  if [ -n "$GIT_COMPLETION_FILE" -a -f "$GIT_COMPLETION_FILE" ];then
    zstyle ':completion:*:*:git:*' script $GIT_COMPLETION_FILE
  fi
  _vcs_info () {
    psvar=()
    LANG=C vcs_info
    [[ -n "$vcs_info_msg_0_" ]] && psvar[1]="$vcs_info_msg_0_"
  }
  add-zsh-hook chpwd _vcs_info
  _vcs_info # if zsh started in vcs directory
# }}}

zle_highlight=(isearch:fg="228",underline)

setopt prompt_subst
setopt extended_history # 履歴ファイルに時刻を記録
setopt always_last_prompt   # 無駄なスクロールを避ける
setopt append_history # 複数の zsh を同時に使う時など history ファイルに上書きせず追加
setopt auto_list # 補完候補が複数ある時に、一覧表示
setopt NO_beep # ビープ音を鳴らさないようにする
setopt hist_ignore_dups # 直前と同じコマンドラインはヒストリに追加しない
#setopt hist_ignore_all_dups # 重複したヒストリは追加しない
setopt share_history # シェルのプロセスごとに履歴を共有
# 補完候補が複数あるときに自動的に一覧表示する
setopt auto_menu
# 高機能なワイルドカード展開を使用する
setopt extended_glob

setopt transient_rprompt # http://www.machu.jp/diary/20130114.html

# 補完するかの質問は画面を超える時にのみに行う｡
LISTMAX=0

HISTFILE=~/.zsh-history
HISTSIZE=100000
SAVEHIST=100000

# http://kimoto.hatenablog.com/entry/2012/08/14/112500
export REPORTTIME=1
# }}}

# platform {{{
case ${OSTYPE} in
  dargin*)
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

# }}}

# bindkey {{{
bindkey -e
#bindkey "^?"    backward-delete-char
#bindkey "^H"    backward-delete-char
#bindkey "^[[3~" delete-char
#bindkey "^[[1~" beginning-of-line
#bindkey "^[[4~" end-of-line
bindkey "^P" history-beginning-search-backward
bindkey "^N" history-beginning-search-forward
bindkey "^R" history-incremental-pattern-search-backward
bindkey "^G" history-incremental-pattern-search-forward
#bindkey "^S" history-incremental-search-forward
bindkey '\C-x\C-e' edit-command-line
bindkey '^V' vi-quoted-insert

# vimぽいC-w
tcsh-backward-delete-word () {
  local WORDCHARS="${WORDCHARS:s#/#}"
  zle backward-delete-word
}
zle -N tcsh-backward-delete-word
bindkey '^W' tcsh-backward-delete-word

# }}}

# http://www.reddit.com/r/commandline/comments/12g76v/how_to_automatically_source_zshrc_in_all_open/
trap "source ~/.zshrc && rehash" USR1

# PROMPT {{{
PROMPT2="%B%{%F{082%}%__> %b"
RPROMPT="%1(v|%{%F{190%}%1v%f|)"
_update_prompt () {
  PROMPT="${USER}%B%{%F{${MY_COLOR_PROMPT_HOST:-207}%}@${HOST}%b:%~ %B%{%F{250%}(ruby-$(rbenv version-name))%b%f%(!.#.$) "
}
add-zsh-hook precmd _update_prompt
# }}}

# GNU screen {{{

if [ -n "${STY}" ] ; then # screen
  screen-title-set () {
    [ -n "${STY}" ] && [ $# -gt 0 ] && echo -ne '\ek'${1%% *}'\e\\'
  }
  add-zsh-hook preexec screen-title-set
fi
# }}}

# function {{{

# -- colorcheck() {{{

function colorcheck() {
  local FG=0
  local BG=0

  while getopts "fb" OPTION
  do 
    case $OPTION in
      "f" ) FG=1 ;;
      "b" ) BG=1 ;;
      *   ) echo 'Usage: colorcheck [-f] [-b]'; return 0;
      ;;
    esac
  done

  if [ $FG = 0 -a $BG = 0 ];then
    FG=1;
    BG=1;
  fi

  if [ $FG = 1 ];then
    echo '\\033[0;38;05;XXXm Text \\033[0m'
    for color in `seq -f '%03g' 0 255`; do
      echo -n "\033[38;05;${color}m${color}\033[0m "
    done
    echo;
  fi

  if [ $BG = 1 ];then
    echo '\\033[48;05;XXXm Text \\033[0m'
    for color in `seq -f '%03g' 0 255`; do
      echo -n "\033[48;05;${color}m${color}\033[0m  "
    done
    echo;
  fi
}

# }}}

# http://d.hatena.ne.jp/secondlife/20080218/1203303528
# http://blog.m4i.jp/entry/2012/01/26/064329
# autoload -Uz compinit compinit
# source ~/.zsh/cdd/cdd
# chpwd() {
#     _cdd_chpwd
# }

# }}}
