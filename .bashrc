# [ -n "$DISPLAY" ] && export TERM=xterm-color
SHELL=$BASH
export LC_CTYPE=en_US.UTF-8
umask 022

if [ -n "$PS1" ] ;then
   #[[ $0 != -* && $- != *l* ]] && . /etc/profile 
   unalias -a
   source /etc/profile 

   if [[ $TERM != *color* && "$COLORTERM" ]] ;then
      export TERM=xterm-256color
   fi

   if [[ $PATH != $HOME/bin3:* ]] ;then
       PATH=$HOME/bin3:$HOME/bin2:$HOME/bin:/usr/local/bin:/opt/local/bin:$PATH
   fi

   for f in bash_completion ;do
      for d in /etc/ /usr/local/etc ;do
         [ -f $d/$f ] && source $d/$f
      done
   done
   for f in ~/.bash_completion.d/* ;do
      [ -r $f ] && source $f
   done

   # [[ $BASH_COMPLETION ]] || . /etc/bash_completion
   #. /etc/profile

   export SVN_EDITOR=vi
   HISTCONTROL=ignoredups
   IGNOREEOF=3
   HISTSIZE=999000
   HISTFILESIZE=999000
   export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.7.0_75.jdk/Contents/Home
   export ANDROID_HOME=/usr/local/Cellar/android-sdk/24.4.1_1/
   export JBOSS_HOME=/opt/wildfly
   export AMPCOM_HOME=/opt/ampcom
   export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.7.0_75.jdk/Contents/Home
   export MAVEN_OPTS="-Xmx1024m -XX:MaxPermSize=1024m" # Don't run out of memory while building

   ttprompt() {
      case "$1" in
         1) echo "${TOOLCHAIN_PS1_LABEL/#tt/ tt${TARGET_PLATFORM/#V26/26}}" ;;
         *) echo "${TOOLCHAIN_PS1_LABEL/#tt/[tt${TARGET_PLATFORM/#V26/26}] }" ;;
      esac
   }
   __col() {
      [[ $TERM == xterm*  || $TERM == screen || $TERM == linux ]] && echo -n '\[\e[3'${1}'m\]'
   }
   PS1="[$(__col 1)\h $(__col 2)\W$(__col 3)\$(exitrep)\$(ttprompt 1)$(__col 9)]\\\$ "
   NOTTPS1=$PS1
   [[ "$(type -p dircolors)" ]] && eval `dircolors`
   # eval `dircolors ~/.dircolors`

   [ -f /etc/rc.d/functions ] && USECOLOR=yes source /etc/rc.d/functions

   sel() { if [[ $(uname -s) = Darwin ]] ;then pbpaste "$@" ;else xclip -o "$@" ;fi; }
   alias mark='echo -e "\n\n\n\n      ${C_H2}---- `date` ----${C_CLEAR}\n\n\n\n"'
   alias l='      less -R'
   alias v='      vimless'
   alias m='      mark'
   alias ll='     ls -la'
   alias tree='   tree -uph'
   if [[ $(uname -s) = Darwin ]] ;then
      alias ls='  ls -G'
   else
      alias ls='  ls --color=auto'
   fi
   alias where='  type -a'
   alias watch='  watch -d -p'
   alias grep='   grep --color=auto'
   alias svnhead="svnlog --limit=20"
   alias rehash=" hash -r"
   alias sort='   LC_ALL=C sort'
   alias reload=' exec env PATH=/bin:/usr/bin bash'
   alias tsel='   tmux show-buffer'
   alias luai='   with-readline luajit'
   alias se='     vim -g --remote'
   alias unquot=' sel | cut -d\" -f2'
   alias jslint=' jshint --reporter=/usr/local/lib/node_modules/jshint-stylish'
   alias gitll=" git log --graph --pretty=format:'%C(bold)%h%Creset%C(magenta)%d%Creset %s %C(yellow)<%an> %C(cyan)(%cr)%Creset' --abbrev-commit --date=relative"
   # From http://blogs.atlassian.com/2014/10/advanced-git-aliases/ # Show commits since last pull
   alias gitnew=" git log HEAD@{1}..HEAD@{0}"
   # Add uncommitted and unstaged changes to the last commit
   alias gitappend="git commit -a --amend -C HEAD"
   alias gitst="    git status"
   alias gitcommit="git add \* ; git commit"
   gitdiff() {
      REV=''
      [[ $# > 0 && "$1" != -* ]] && REV=${1}^..${1}; shift;
      git diff -b $REV "$@";
   }
   gitup() {
      echo -e "Stashing .. \c"
      git stash save --include-untracked __GITGET__
      git svn mkdirs > /dev/null
      git svn rebase
      if git stash list | grep -q __GITGET__ ;then
         echo -e "Unstash .. \c"
         git stash pop
      fi
   }
   gitdcommit() {
      echo -e "Stashing .. \c"
      git stash save --include-untracked __GITSDC__
      git svn dcommit
      if git stash list | grep -q __GITSDC__ ;then
         echo -e "Unstash .. \c"
         git stash pop
      fi
   }

   GRC=`which grc`
   if [ "$TERM" != dumb ] && [ -n "$GRC" ] ;then
      colorize() { $GRC -es ${COLORARG:-"--colour=auto"} "$@"; }
      for c in configure make gcc as gas ld netstat ping traceroute head dig mount ps mtr df \
               svn hg git cat ifconfig
      do
         eval "$c() { colorize '$c' \"\$@\"; }"
      done
   else
      colorize() { "$@"; }
   fi

   diff() { colorize diff -u "$@"; }
   df()   { colorize df -k "$@"; }

   # Xubuntu: CapsLock -> CTRL-G + Control-R pressed -> DK layout
   fixkbd() { 
      #setxkbmap -option caps:none;
      xcape -e 'Caps_Lock=Control_L|G';
      xmodmap -e 'keysym Control_R = Mode_switch';
   }
   tpfan() {
      sudo ~/bin2/tp-fancontrol -s 5 -S 2 -l -d
   }

   export SVN=svn+ssh://ampsvn/srv/ampep
   svnlast()   { if [[ $# -ge 1 ]] ;then svnlog -p -l 25 "$@" ;else svnlog -p -a $USER -l 25 ;fi; }
   gitlast()   { if [[ $# -ge 1 ]] ;then gitlog -p -l 25 "$@" ;else gitlog -p -a $USER -l 25 ;fi; }
   svnminfo()  { svn mergeinfo $SVN/trunk/embedded \
                               --show-revs ${@:-eligible} | \
                 xargs -i svnlog '-{}' svn+ssh://ampsvn/srv/ampemb/trunk/embedded; }

   svnst()     { svn st "$@" | command grep -v  '^[X?]'; }
   hgst()      { hg  st "$@" | command grep -v  '^[X?]'; }
   lth()       { ls -lat "$@" | head -20; }
   # alias open='kfmclient exec'
   url()       { kfmclient openURL "$*"; }
   vimless()   { vim --cmd 'let no_plugin_maps = 1 | let load_less = 1' \
                     --cmd 'set readonly noswapfile' \
                      -c 'set mouse=a' \
                      -c 'runtime macros/less.vim' "${@:--}"; }
   jatt()      { curl -u fm:ccswe124 $1 | grcat conf.log | less -R; } # View jira attachment
   p()         { COLORARG=" " "$@" | less -R;}
   pg()        { $GRC -es "$@" | less -R;}
   pv()        { if [[ $# -eq 1 && -e $1 ]] ;then vimless $1 ;else "$@" | vimless ;fi }
   vis()       { vi +set\ hlsearch $(which "$@"); }
   _txt()      { eval "file $*" | command grep -w text | cut -d: -f1; }
   vif()       { vi -c set\ hlsearch "+/$*/" $(egrep -l "$*" $(_txt \*)); }
   vdiff()     { vi -g -f -d --cmd 'set columns=164' -c 'normal <C-W>=' "$@"; }
   mt()        { xterm +tb -e sh -c "while multitail $@; do : ;done"; }
   ToAURoot()  { tar zcf - $2 | command ssh $1 tar zxvf - -C /flash/root/; }
   Trace()     { amp-backtrace.lua "$@" | less +/'ERROR=>' --jump-target=.5; }
   psman()     { man -aW "$@" | xargs zcat | groff -man -Tps -P-pa4 \
                | psnup -pa4 -2 -d1 | less -R;}
   f()         { awk -v N="$*" 'BEGIN {split(N, Nr, / |,/)}
                 {for (n in Nr) {printf("%s%s", (n>1) ? " " : "", $Nr[n])}; print ""}'; }
   e()         { lua -e "print($*)"; }
   del()       { echo -e "$2 d\nw\nq" | ed -s $1; }
   utf8kill()  { if [[ $# -gt 0 ]] ;then iconv -f utf8 -t ascii -c <<< "$@" ;else iconv -f utf8 -t ascii -c ;fi; }
   utf8sel()   { sel | utf8kill; }

   exit() {
      [[ "$SSH_CONNECTION" ]] && builtin exit "$@"
      [[ "$_" = */XMenu/* ]] && sleep 1 && builtin exit
      read -n 1 -t 10 -p "Really exit. Exits in 10 sec? [y/N] " ans
      [[ "$ans" = [yY]* || $? -gt 128 ]] && builtin exit "$@"
      echo "Phew!"
   }

   =()         {
      #local i e
      #i="${@//p/+}"
      #i="${i//m/*}"
      #e="$(($i))"
      #printf "%d -- 0x%x\n" $e $e
      lua-5.3 -e "val = ${*//@/*}
                  print(string.format('%s -- 0x%x', val, val//1))"
   }

   rmline() { sed -i '' "$1 d" "$2"; }

   tmux-x-attach() {
      ps -f -u fm | grep -v grep | grep -q 'xpra start' || xpra start :9
      xpra attach :9 --opengl=no > /tmp/xpra-attach.log 2>&1 &
      DISPLAY=:9 tmux-attach "$@"
      xpra detach :9
   }

   tmux-attach() {
      # env | grep SSH
      case $(tmux list-sessions 2>/dev/null | wc -l) in
         0) tmux ;;
         1) tmux attach ;;
         *)
            tmux list-sessions | awk '{print NR-1 ": " $0}'
            read -n 1 -p "Select session: " N < /dev/tty > /dev/tty;
            SES=`tmux list-sessions | awk -F: -v N=$N 'NR==N+1 {print $1}'`
            echo "Session: $SES"
            tmux attach -t "$SES"
            ;;
      esac
   }
   tmux-ssh() { ssh "$@" -A -X -t 'PS1=tmux-ssh- ; . ~/.bashrc ; tmux-x-attach'; tput init; }
   alias tsel='tmux show-buffer'

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
   alias hi="history|tail"
   alias hist="history"
   alias hgrep="history|grep"
   run() { local A=$1 ; shift ; open "/Applications/${A}.app" "$@"; }
   __run() {
      mapfile -t COMPREPLY < <(ls -1d /Applications/{,*/}*.app | \
                               grep -i "/$2" | \
                               sed -e 's,^/Applications/,,' -e 's/.app$//' -e 's/ /\\ /g');
   }
   complete -F __run run

   case $TERM in
       sun-cmd) stln() { printf "\033]l %s \033" "$*"; } ; itit() { :; }
                ;;
       xterm*|linux*|screen*)
                stln() { printf "\033]2;%s\007" "$*" ; }
                itit() { printf "\033]1;%s\007" "$*" ; }
                ;;
       *)       stln() { :; } ; itit() { :; }
       ;;
   esac
   if [[ "$TMUX" ]] ;then
      itit() { printf "\ek%s\e\\" "$*" ; }
   fi
   HostnTty=`uname -n | cut -d. -f1 | tr a-z A-Z`:`tty | cut -c10-`
   Tty=`tty | cut -c10-`
   stdir() {
      local p=${PWD/$AMPROOT/@}
      if [[ $p = @/* ]] ;then Path=${p:2}; else Path=""; fi
      local p=${p/$HOME/\~}
      local V=''
      stln "-- $HostnTty $(ttprompt 2)- ${AMPROOT##*/} - $p --"
      if [[ "$TMUX" ]] ;then
         itit "$Tty-$(cut -c1-3 <<< ${AMPROOT##*/})-${p##*/}"
      else
         itit "$Tty - $(cut -c1-3 <<< ${AMPROOT##*/}) - ${p##*/}"
      fi
   }

   sshwrap() {
      local Cmd Host
      Cmd=$1 ; shift
      if test -t 1 ;then
         Host=$(command ssh -o 'ProxyCommand=sh -c "echo %h>/tmp/__H"' -o ControlPath=none "$@" 2>/dev/null;
                cat /tmp/__H; rm -f /tmp/__H)
         itit "$Tty => $(tr a-z A-Z <<< $Host)"
      fi
      command $Cmd "$@"
   }
   function ssh()      { sshwrap ssh "$@"; }
   function aussh()    { sshwrap aussh "$@"; }
   function au-sshgw() { sshwrap au-sshgw "$@"; }
   function tail()     { itit "$Tty - TAIL $@" ; colorize tail "$@"; }
   function cu()       { itit "$Tty - CU $@"   ; command cu "$@"; }
   function locate()
   {
      if [[ $# == 1 ]] ;then
         command locate -b "$@"
      else
         command locate "$@"
      fi
   }
   function ws2 () {
      local O=$1
      local U=$2
      local H=$3
      local P=$4
      shift ; shift
      shift ; shift
      #echo "P: $P"
      curl -w '\n---- CURL STAT ----\n%{http_code}: %{size_header} + %{size_download}B %{time_total}sTOT %{time_pretransfer}sPRE\n' \
         -u$U -k -H 'content-type: application/json' \
         -X$O https://${H}$P "$@" \
         | mawk '/^---- CURL STAT ----$/ {d=1} d==0 {print} d==1 {print > "/dev/stderr"}'
   }
   function ws () {
      local O=$1
      local P=$2
      local R=${P%%/*}
      shift ; shift
      case $R in
         (ws|lightWs|glams|aasweb|startgrid|aasws|gis) ;; 
         #(*)  P=aasws/$P ;;
      esac
      #echo "P: $P"
      curl -w '\n-----------\n%{http_code}: %{size_header} + %{size_download} B\n' \
         -uampfm3:ccswe124 -k -H 'content-type: application/json' \
         -X$O http://localhost:8000/$P "$@"
   }
   function findTests() { find . -name surefire-reports | xargs -I % open %/index.html; }

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
   if [[ -d ~/.keychain && "$UID" -ne 0 && -z "$SSH_AUTH_SOCK" ]] ;then
      #keychain --quiet ~/.ssh/id_dsa --timeout 1440  # 24 hours.
      HOSTNAME=$(uname -n) ; export HOSTNAME=${HOSTNAME%%.*}
      #keychain --quiet ~/.ssh/id_dsa
      eval `keychain --quiet --eval`
      #alias kcload='eval `keychain --quiet --eval`'
   fi

   if [[ -d /opt/toolchain/. ]] ;then
      . /opt/toolchain/utils/toolchain-utils-load
   fi

   function amptree()  {
      if [ $# -eq 0 ] ;then echo $AMPROOT ; return ;fi
      if [ $1 == --completions ] ;then
         ( cd ~/amplex ; command ls -1d */arm9 */ampep) | cut -d/ -f1 | command grep "^$3"
         return 
      fi
      local noCD=""
      if [[ $1 == --nocd ]] ;then noCD=1; shift; fi
      AMPROOT=~/amplex/$1
      CDPATH=""
      if [[ -d $AMPROOT/arm9 ]] ;then
          local DL="$AMPROOT/{,arm9,arm9/agentframework/{,agents,libs},arm9/apps/{,drivers},arm9/utils,arm9/drivers}"
          local D=arm9
          export SVN=svn+ssh://ampsvn/srv/ampemb
      else
          DL="$AMPROOT/{,ampep,greenwise,ampep/startgrid-ws/src/main/java/dk/amplex/aas/ws/"
          DL="$DL,ampep/startgrid-ws/src/main/java/dk/amplex/aas/ws/"
          DL="$DL,greenwise/greenwise-web/src/main/java/dk/amplex/greenwise/}"
          local D=ampep
          export SVN=svn+ssh://ampsvn/srv/ampep
      fi
      for d in ~ $(eval echo $DL) ~/{amplex,releases,src,abs,abs2} ;do
         CDPATH=$CDPATH:$d
      done
      export LUA_CPATH=";;$AMPROOT/arm9/agentframework/lua/?.so"
      if [[ ! -n $noCD ]] ;then
         echo $AMPROOT/$D
         cd $AMPROOT/$D
      fi
   }
   alias amp=amptree
   complete -C 'amptree --completions' amp
   [ -z "$AMPROOT" ] && amptree --nocd epgit
   complete -F _command -o filenames p pv pg
   complete -c vis env where 
fi
# vim: set sw=3 sts=3 et:
