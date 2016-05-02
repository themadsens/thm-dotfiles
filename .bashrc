# [ -n "$DISPLAY" ] && export TERM=xterm-color
SHELL=$BASH
umask 022

if [ -n "$PS1" ] ;then
   #[[ $0 != -* && $- != *l* ]] && . /etc/profile 
   unalias -a
   source /etc/profile 

   if [[ $PATH != $HOME/bin:* ]] ;then
       PATH=$HOME/bin:/usr/local/bin:/opt/local/bin:$PATH
   fi

   for f in bash_completion ;do
      if [ -f /usr/local/etc/$f ]; then
         source /usr/local/etc/$f
      fi
   done

   # [[ $BASH_COMPLETION ]] || . /etc/bash_completion
   #. /etc/profile

   export SVN_EDITOR=vi
   HISTCONTROL=ignoredups
   IGNOREEOF=3
   HISTSIZE=50000
   HISTFILESIZE=50000
   export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.7.0_75.jdk/Contents/Home
   export ANDROID_HOME=/usr/local/Cellar/android-sdk/24.2
   export JBOSS_HOME=/opt/wildfly
   export AMPCOM_HOME=/opt/ampcom
   export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.7.0_75.jdk/Contents/Home
   export MAVEN_OPTS="-Xmx1024m -XX:MaxPermSize=1024m" # Don't run out of memory while building

   __col() {
      [[ $TERM == xterm*  || $TERM == screen || $TERM == linux ]] && echo -n '\[\e[3'${1}'m\]'
   }
   PS1="[$(__col 1)\h $(__col 2)\W$(__col 3)\$(exitrep)$(__col 9)]\\\$ "
   # eval `dircolors ~/.dircolors`

   [ -f /etc/rc.d/functions ] && USECOLOR=yes source /etc/rc.d/functions

   alias mark='echo -e "\n\n\n\n      ${C_H2}---- `date` ----${C_CLEAR}\n\n\n\n"'
   alias l='      less -R'
   alias v='      vimless'
   alias m='      mark'
   alias ll='     ls -la'
   alias ls='     ls -G'
   alias where='  type -a'
   alias watch='  watch -d -p'
   alias grep='   grep --color=auto'
   alias svnhead="svnlog --limit=20"
   alias rehash=" hash -r"
   alias sort='   LC_ALL=C sort'
   alias reload=' exec env PATH=/bin:/usr/bin bash'
   alias xsel='   xclip -o'
   alias sel='    pbpaste'
   alias luai='   with-readline luajit'
   alias se='     vim -g --remote'
   alias unquot=' sel | cut -d\" -f2'
   alias jslint=' jshint --reporter=/usr/local/lib/node_modules/jshint-stylish'

   GRC=`which grc`
   if [ "$TERM" != dumb ] && [ -n "$GRC" ] ;then
      colorize() { $GRC -es ${COLORARG:-"--colour=auto"} "$@"; }
      for c in configure make gcc as gas ld netstat ping traceroute head dig mount ps mtr df \
               svn hg git cat
      do
         eval "$c() { colorize '$c' \"\$@\"; }"
      done
   else
      colorize() { "$@"; }
   fi

   diff() { colorize diff -u "$@"; }
   df()   { colorize df -k "$@"; }

   export SVN=svn+ssh://ampsvn/srv/ampep
   svnlast()   { if [[ $# -ge 1 ]] ;then svnlog -p -l 25 "$@" ;else svnlog -p -a $USER -l 25 ;fi; }
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

   tac() {
      awk '
         BEGIN {N=0; delete A}
         { A[N++]=$0 }
         END { while (N > 0) { print A[--N] } }
      ' "$@"
   }

   __h()
   {
      local -a C
      local -i I
      local N
      eval $(command grep "$@" ~/.bash_history | uniq | command tail -10 | tac \
             | gawk '{print "C[" I++ "]=\047" gensub("\047", "\047\\\\\047\047", "g", $0) "\047"}')
      if [[ ${#C[@]} > 0 ]] ;then
         for ((I=0; I<${#C[@]}; I++ )) ;do echo "$I: ${C[$I]}" > /dev/tty ;done
         read -n 1 -p "Select command: " N </dev/tty >/dev/tty
         if [[ $N = [0-9] && ${#C[$N]} > 0 ]] ;then
            echo "  ...  Running [$N]" >/dev/tty
            echo "${C[$N]}"
         else
            echo '' >/dev/tty
         fi
      fi
   }
   h() {
      local ___Very_UnL1leLy_7ar=$(__h "$@")
      history -s $___Very_UnL1leLy_7ar
      eval $___Very_UnL1leLy_7ar
   }
   alias hi="history|tail"
   alias hist="history"

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
   HostnTty=`uname -n | cut -d. -f1 | tr '[a-z]' '[A-Z]'`:`tty | cut -c10-`
   Tty=`tty | cut -c10-`
   stdir() {
      local p=${PWD/$AMPROOT/@}
      if [[ $p = @/* ]] ;then Path=${p:2}; else Path=""; fi
      local p=${p/$HOME/\~}
      local V=''
      stln "-- $HostnTty ${TOOLCHAIN_PS1_LABEL/#tt/[tt${TARGET_PLATFORM/#V26/26}] }- $p --"
      itit "$Tty - $(cut -c1-3 <<< ${AMPROOT##*/}) - ${p##*/}"
   }

   sshwrap() {
      local Cmd Host CmdU
      Cmd=$1 ; shift
      Host=$(command ssh -o 'ProxyCommand=echo %h >/dev/fd/9' -o ControlPath=none "$@" 9>&1 2>&-)
      CmdU=$(tr a-z A-Z <<<$Cmd)
      itit "$Tty - $CmdU $Host"
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
      timeNow=$(< /tmp/.time$$)
      HISTTIMEFORMAT="%s "  history 1 > /tmp/.time$$
      read no timeStart cmd < /tmp/.time$$
      if [[ -n $_timeprev ]] ;then
         echo $_timeprev $timeNow | tr ms '  ' | awk '
         {
            usrPrev = $5*60 + $6
            sysPrev = $7*60 + $8
            usrCur = $13*60 + $14
            sysCur = $15*60 + $16
            total = (usrCur + sysCur) - (usrPrev + sysPrev)
            if (total >= timeRep) {
               printf("%.3fu %.3fs %d:%02d %.1f%%\n",
                      usrCur - usrPrev, sysCur - sysPrev,
                      duration / 60, duration % 60, total / (duration?duration:total) * 100.0)
            }
         }' timeRep=$timeRep duration=$(( $(date +%s) - $timeStart ))
      fi
      _timeprev=$timeNow
      unset TIMESHOW
      rm -f /tmp/.time$$
   }
   TIMEREPORT=1
   function tim() { TIMESHOW=0 ; "$@"; }

   function exitrep() {
      #[[ "$HISTCMD" == "$LASTCMD" ]] && return
      #declare LASTCMD=$HISTCMD
      local -a ESTAT=( ${PIPESTATUS[@]} )
      local Last=$((${#ESTAT[*]} - 1))
      [[ ${ESTAT[$Last]} -ne 0 ]] && echo " E:${ESTAT[$Last]}"
   }

   function file_modtime() {
      [[ $(uname -s) = Darwin ]] && stat -s %m "$@" || stat -c %Y "$@"
   }

   function profile_check() {
      local curtime=$(file_modtime $HOME/.bashrc)
      if [[ $_profile_time && $_profile_time != $curtime ]] ;then
         source $HOME/.bashrc
      fi
      _profile_time=$curtime
   }

   PROMPT_COMMAND='history -a; stdir; hash -r; timerep; profile_check'
   if [[ -d ~/.keychain && "$UID" -ne 0 ]] ;then
      #keychain --quiet ~/.ssh/id_dsa --timeout 1440  # 24 hours.
      HOSTNAME=$(uname -n) ; export HOSTNAME=${HOSTNAME%%.*}
      #keychain --quiet ~/.ssh/id_dsa
      eval `keychain --quiet --eval`
      #alias kcload='eval `keychain --quiet --eval`'
      alias squid-ssh-keys='ssh-add ~/.ssh/nopf/*'
   fi

   if [[ -d /opt/toolchain/. ]] ;then
      . /opt/toolchain/utils/toolchain-utils-load
   fi

   function amptree()  {
      if [ $# -eq 0 ] ;then echo $AMPROOT ; return ;fi
      if [ $1 == --completions ] ;then
         ( cd ~/amplex ; ls -1d */arm9 */ampep) | cut -d/ -f1 | command grep "^$3"
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
   [ -z "$AMPROOT" ] || amptree --nocd ep
   test $AMPROOT || amptree --nocd ep
   complete -F _command -o filenames p pv pg
   complete -c vis env where 
fi
# vim: set sw=3 sts=3 et:
