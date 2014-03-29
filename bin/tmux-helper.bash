#!/bin/bash

# プロセスに紐付いたttyを取得する http://bit.ly/1eDpRpu
function search_tty() {
  local pid=${1:-$$} tty=""
  while [[ 1 -lt $pid ]]; do
    [[ -d /proc/$pid/fd ]] || break
    tty=$(readlink /proc/$pid/fd/1 2>/dev/null | awk '{print $1}')
    [[ -c $tty ]] && { echo "$tty"; return 0; }
    pid=$(perl -pe 's/\(.*\)/()/' /proc/$pid/stat | awk '{print $4}')
  done
  return 1
}

current_tmux() {
  local format="$1"
  if [ -n "$ACTIVE_WINDOW_ID" -a -n "$ACTIVE_PANE_ID" ];then
    tmux list-panes -s -F "#{window_id} #{pane_id} $1" | grep -F "$ACTIVE_WINDOW_ID $ACTIVE_PANE_ID" | awk '{print $3}'
  else
    tmux list-panes -s -F "#{?widow_active,*,}#{?pane_active,*,} $1" | awk '/\*\*/ {print $2}'
  fi
}

current_tmux_tty() {
  current_tmux "#{pane_tty}"
}
current_tmux_pane() {
  current_tmux "#{window_index}.#{pane_index}"
}


tmux_join_pane() {
  local mode="${1:-"-s"}"

  select=$(
  tmux list-panes -s -F '#{window_index}.#{pane_index} #{?window_active,*,}#{?pane_active,*,}#{pane_title} [#{pane_width}x#{pane_height}] histroy:#{history_size}/#{history_limit}' | \
    grep -v -F "**" | percol | awk -F" " '{print $1}'
  )
  if [ -n "$select" ];then
    tmux last-window
    tmux last-pane
    tmux join-pane $mode $select
  fi
}

cmd=$1
shift
$cmd "$@"
