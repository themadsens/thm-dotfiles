
SHELL=$BASH
export LC_CTYPE=en_US.UTF-8
umask 022

if [ -n "$PS1" ] ;then
   _PS1=$PS1
   #[[ $0 != -* && $- != *l* ]] && . /etc/profile 
   PATH=/bin/:/usr/bin
   source /etc/profile 
   HISTCONTROL=ignoredups
   IGNOREEOF=3
   HISTSIZE=999000
   HISTFILESIZE=999000

   source ~/thm-dotfiles/.sh-common

  # [[ $BASH_COMPLETION ]] || . /etc/bash_completion
   for f in bash_completion ;do
      for d in /etc/ /usr/local/etc ;do
         [ -f $d/$f ] && source $d/$f
      done
   done
   for f in ~/.bash_completion.d/* ;do
      [ -r $f ] && source $f
   done

   ttprompt() {
      case "$1" in
         1) echo "${TOOLCHAIN_PS1_LABEL/#tt/ tt${TARGET_PLATFORM/#V26/26}}" ;;
         *) echo "${TOOLCHAIN_PS1_LABEL/#tt/[tt${TARGET_PLATFORM/#V26/26}] }" ;;
      esac
   }
   __col() {
      [[ $TERM == xterm*  || $TERM == screen* || $TERM == linux ]] && echo -n '\[\e[3'${1}'m\]'
   }
   PS1="[$(__col 1)\h $(__col 2)\W$(__col 3)\$(exitrep)\$(ttprompt 1)$(__col 9)]\\\$ "
   NOTTPS1=$PS1

   run() { local A=$1 ; shift ; open "/Applications/${A}.app" "$@"; }
   __run() {
      mapfile -t COMPREPLY < <(ls -1d /Applications/{,*/}*.app | \
                               grep -i "/$2" | \
                               sed -e 's,^/Applications/,,' -e 's/.app$//' -e 's/ /\\ /g');
   }
   complete -F __run run

   [ -f /etc/rc.d/functions ] && USECOLOR=yes source /etc/rc.d/functions

   if [[ -d ~/.qfc && $_PS1 != tmux-ssh- ]] ;then
      # See https://github.com/themadsens/qfc
      source ~/.qfc/bin/qfc.sh
      #qfc_quick_command 'vim' '\C-p' 'vim $0'
      #qfc_quick_command 'cd' '\C-b' 'cd $0'
   fi
   unset _PS1

   function timerep() {
      local timeRep=$TIMESHOW ; [[ $timeRep ]] || timeRep=$TIMEREPORT
      [[ ! -n $timeRep ]] && return
      times > /tmp/.time$$
      local no timeStart cmd timeNow
      timeNow=$(tr ms\\012 '   ' < /tmp/.time$$)
      timeStart=$(HISTTIMEFORMAT="%s "  history 1 | awk '{print $2}')
      if [[ -n $_timeprev ]] ;then
         local now=$(date +%s)
         echo $_timeprev $timeNow | awk '{
            duration = now - timeStart
            usrPrev = $5*60 + $6
            sysPrev = $7*60 + $8
            usrCur = $13*60 + $14
            sysCur = $15*60 + $16
            total = (usrCur + sysCur)-(usrPrev + sysPrev)
            if (total >= timeRep) {
               printf("%.3fu %.3fs %d:%02d %.1f%%\n",
                      usrCur-usrPrev, sysCur-sysPrev,
                      duration / 60, duration % 60, total / (duration?duration:total) * 100.0)
            }
         }' timeRep=$timeRep now=$now timeStart=$timeStart
      fi
      _timeprev=$timeNow
      unset TIMESHOW
      rm -f /tmp/.time$$
   }
   TIMEREPORT=1
   TIMEFORMAT="%Uu %Ss %2R %P%%"
   function tim() { TIMESHOW=0 ; "$@"; }

   function exitrep() {
      #[[ "$HISTCMD" == "$LASTCMD" ]] && return
      #declare LASTCMD=$HISTCMD
      local -a ESTAT=( ${PIPESTATUS[@]} )
      local Last=$((${#ESTAT[*]} - 1))
      [[ ${ESTAT[$Last]} -ne 0 ]] && echo " E:${ESTAT[$Last]}"
   }

   function file_modtime() {
      [[ $(uname -s) = Darwin ]] && stat  -L -f %m "$@" || stat -L -c %Y "$@"
   }

   function profile_check() {
      local curtime=$(file_modtime $HOME/.bashrc)
      if [[ $_profile_time && $_profile_time != $curtime ]] ;then
         source $HOME/.bashrc
      fi
      _profile_time=$curtime
   }

   function tmux_update() {
      [[ "$TMUX" ]] && eval $(tmux show-environment -s -t 0)
   }

   PROMPT_COMMAND='history -a; stdir; hash -r; timerep; profile_check; tmux_update'

   tac() {
      awk '
         BEGIN {N=0; delete A}
         { A[N++]=$0 }
         END { while (N > 0) { print A[--N] } }
      ' "$@"
   }

   __idx() {
      case $1 in
         [0-9]) echo $1 ;;
         A) echo 10;; 10) echo A;; B) echo 11;; 11) echo B;; C) echo 12;;
         12) echo C;; D) echo 13;; 13) echo D;; E) echo 14;; 14) echo E;;
         F) echo 15;; 15) echo F;; G) echo 16;; 16) echo G;; H) echo 17;;
         17) echo H;; I) echo 18;; 18) echo I;; J) echo 19;; 19) echo J;;
         K) echo 20;; 20) echo K;; L) echo 21;; 21) echo L;; M) echo 22;;
         22) echo M;; N) echo 23;; 23) echo N;; O) echo 24;; 24) echo O;;
         P) echo 25;; 25) echo P;; Q) echo 26;; 26) echo Q;; S) echo 27;;
         27) echo S;; T) echo 28;; 28) echo T;; U) echo 29;; 29) echo U;;
         V) echo 30;; 30) echo V;; W) echo 31;; 31) echo W;; X) echo 32;;
         32) echo X;; Y) echo 33;; 33) echo Y;; Z) echo 34;; 34) echo Z;;
      esac
   }
   __h() {
      local -a C
      local -i I
      local N
      local RC=0
      eval $(command grep "$@" ~/.bash_history | uniq | command tail -35 | tac \
             | gawk '{print "C[" I++ "]=\047" gensub("\047", "\047\\\\\047\047", "g", $0) "\047"}')
      if [[ ${#C[@]} > 0 ]] ;then
         for ((I=0; I<${#C[@]}; I++ )) ;do echo "$(__idx $I): ${C[$I]}" > /dev/tty ;done
         read -n 1 -p "Select command: " N </dev/tty >/dev/tty
         if [[ $N = '!' ]]  ;then
            read -n 1 -p " : " N </dev/tty >/dev/tty
            RC=5
         fi
         if [[ $N = [0-9A-Z] && ${#C[$(__idx $N)]} > 0 ]] ;then
            echo -e "\b${C[$(__idx $N)]}" >/dev/tty
            echo -E "${C[$(__idx $N)]}"
            return $RC
         else
            echo '' >/dev/tty
         fi
      fi
      return 1
   }
   h() {
      set -o noglob
      local ___Very_UnL1leLy_7ar
      ___Very_UnL1leLy_7ar=$(__h "$@")
      local RC=$?
      [[ $RC -ne 1 ]] && history -s $___Very_UnL1leLy_7ar
      set +o noglob
      case $RC in
         0) eval $___Very_UnL1leLy_7ar ;;
         5) echo "Do <UP> or '!!' to use .." ;;
      esac
   }

   alias amp=amptree
   complete -C 'amptree --completions' amp
   complete -F _command -o filenames p pv pg
   complete -F _man vman
   complete -c vis env where 

   [ -z "$AMPROOT" ] && amptree --nocd epgit
fi

# vim: set sw=3 sts=3 et:
