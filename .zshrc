# vim: set fdm=marker: 

# autoload, zle, etc {{{

local _ZSH_DIRECTORY="$HOME/.zsh"
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
zstyle ':vcs_info:*' max-exports 3

zstyle ':vcs_info:*' formats '%s:[%b]'
# %m is expanded to empty string
zstyle ':vcs_info:*' actionformats '%s[%b]' '%m' '<⚑ %a>'
zstyle ':vcs_info:(svn|bzr):*' branchformat '%b:r%r'

# }}}

local GIT_COMPLETION_FILE="${GIT_COMPLETION_FILE:-${HOME}/src/git/contrib/completion/git-completion.sh}"
if [ -n "$GIT_COMPLETION_FILE" -a -f "$GIT_COMPLETION_FILE" ];then
  zstyle ':completion:*:*:git:*' script $GIT_COMPLETION_FILE
fi

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
_update_prompt () {
  PROMPT="${USER}%{%F{${MY_COLOR_PROMPT_HOST:-207}%}@${HOST}%f:%~ %{%F{248%}$(ruby_version)%f %(!.#.$) "
  (git rev-parse --is-inside-git-work-tree 2>/dev/null 1>&2)
  if [ $? -ne 0 ];then
    RPROMPT=""
    return 0
  fi

  LANG=C vcs_info
  # 0: main
  # 1: misc
  # 2: rebase/merge
  local prompt="%{%F{${MY_COLOR_PROMPT_GIT_0:-190}%}$(git_clean_or_dirty)%f"
  prompt="$prompt%F{${MY_COLOR_PROMPT_GIT_0:-190}%}$vcs_info_msg_0_%f"
  if [ -n "$vcs_info_msg_2_" ]; then
    prompt="$prompt %F{${MY_COLOR_PROMPT_GIT_2:-189}%}$vcs_info_msg_2_%f"
  fi
  RPROMPT=$prompt
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

if [ -f "$HOME/.zsh/functions" ];then
  source $HOME/.zsh/functions
fi
