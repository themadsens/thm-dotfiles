#!/bash
# 

h() {
    local SRCH
    local res=$(READLINE_LINE="$@" __fzf_history__)
    [[ $? = 0 ]] && inject.py "$res"
}


export FZF_DEFAULT_OPTS="--exact --height=70% --border=rounded --color=hl:bold:1"
# Override this one to use ~/.bash_history
__fzf_history__() {
  local output
  output=$(
    command tac ~/.bash_history | mawk '{print "\t" $0}' |
      last_hist=$(HISTTIMEFORMAT='' builtin history 1) perl -n -l0 -e 'BEGIN { getc; $/ = "\n\t"; $HISTCMD = $ENV{last_hist} + 1 } s/^[ *]//; print $HISTCMD - $. . "\t$_" if !$seen{$_}++' |
      FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort,ctrl-z:ignore $FZF_CTRL_R_OPTS +m --read0" $(__fzfcmd) --query "$READLINE_LINE"
  ) || return
  READLINE_LINE=${output#*$'\t'}
  if [[ -z "$READLINE_POINT" ]]; then
    echo "$READLINE_LINE"
  else
    READLINE_POINT=0x7fffffff
  fi
}
