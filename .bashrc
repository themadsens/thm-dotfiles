#bash
SHELL=$BASH
export LC_CTYPE=en_US.UTF-8
umask 022

if [ -n "$PS1" ] ;then
   _PS1=$PS1
   #[[ $0 != -* && $- != *l* ]] && . /etc/profile 
   #PATH=/bin/:/usr/bin

   [[ $(uname -s) != Darwin ]] && source /etc/profile 
   HISTCONTROL=ignoredups
   IGNOREEOF=1
   HISTSIZE=999000
   HISTFILESIZE=999000

   unalias -a

   [[ $BASH_VERSINFO -gt 4 ]] && shopt -s direxpand
   WF=/opt/wildfly/standalone/
   WFL=/opt/wildfly/standalone/log/

   if [[ $TERM = screen || $TERM = xterm || $TERM = tmux ]] ;then
      export TERM=${TERM}-256color
   fi

   if [[ $PATH != *$HOME/bin3:* ]] ;then
       PATH=$HOME/bin3:$HOME/bin2:$HOME/bin:/usr/local/bin:/opt/local/bin:/sbin:/usr/sbin:$PATH
   fi
   if [[ ! "$GOPATH" && -d $HOME/go/bin ]] ;then
       GOPATH=~/go
   fi
   if [[ "$GOPATH" && -d $GOPATH && $PATH != *$GOPATH/bin:* ]] ;then
      PATH=$GOPATH/bin:$PATH
   fi
   for p in .cargo/bin .local/bin .bin ;do
      if [[ $PATH != *$HOME/$p:*  && -d $HOME/$p ]] ;then
         PATH=$HOME/$p:$PATH
      fi
   done

   export SVN_EDITOR=vi
   export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_102.jdk/Contents/Home
   [[ -d $JAVA_HOME ]] || export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_361.jdk/Contents/Home/
   [[ -d $JAVA_HOME ]] || export JAVA_HOME=/tmp/NONE
   export ANDROID_HOME=/usr/local/Cellar/android-sdk/24.4.1_1/
   export JBOSS_HOME=/opt/wildfly
   export AMPCOM_HOME=/opt/ampcom
   export MAVEN_OPTS="-Xmx1024m"
   export PGDATABASE=ampep
   #export MAVEN_OPTS="-Xmx1024m -XX:MaxPermSize=1024m" # Don't run out of memory while building
   export HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK=1

   [[ "$(type -p dircolors)" ]] && eval `dircolors`
   # eval `dircolors ~/.dircolors`

   sel() {
      local mode=paste
      if [[ $1 = copy ]] ;then
         mode=copy
         shift
      fi
      case $(uname -s)-$mode in
         Darwin-paste) pbpaste "$@" ;;
         Darwin-copy)  pbcopy "$@" ;;
         *-paste)      lemonade paste;;
         *-copy)       lemonade copy;;
      esac
   }
   findfile() { if [[ $(uname -s) = Darwin ]] ;then mdfind "kMDItemDisplayName == $1" ;else locate -b "$@" ;fi; }
   alias mark='   echo -e "\n\n\n\n      ${C_H2}---- `date` ----${C_CLEAR}\n\n\n\n"'
   alias l='      less -R'
   if type -p fdfind > /dev/null ;then
      alias fd='  fdfind --no-ignore-vcs --hidden'
      alias fdf=' fdfind --no-ignore-vcs --hidden -t f'
   else
      alias fd='  fd --no-ignore-vcs --hidden'
      alias fdf=' fd --no-ignore-vcs --hidden -t f'
   fi
   if type -p exa > /dev/null ;then
      _green_to_thousands() { luajit -e 'for l in io.stdin:lines() do
                                local p1,s,p2 = l:match("(.-\x1b%[1;32m)([%d,.]+)(\x1b.*)")
                                local x,n = (s or ""):gsub("(%d)[,.]","\x1b[4m%1\x1b[24m")
                                print(p2 and (p1..(" "):rep(n)..x..p2) or l)
                              end'; }
      ll() {      exa -laaB "$@" --group-directories-first --colour=always | _green_to_thousands; }
      alias ls='  exa --group-directories-first'
      tree()      { exa -laB --tree --color=always "$@" | _green_to_thousands; }
      lth()       { exa -laB -s modified -r --color=always "$@" | head -20 | _green_to_thousands; }
   else
      ll() { ls -la "$*"; }
      if [[ $(uname -s) = Darwin ]] ;then
         alias ls='ls -G'
      else
         alias ls='ls --color=auto'
      fi
      lth()       { ls -lat "$@" | head -20; }
   fi
   if type -p ag > /dev/null ;then
      alias ag='  ag --skip-vcs-ignores --hidden'
   fi
   if type -p rg > /dev/null ;then
      alias rg='  rg --no-ignore-vcs --hidden'
   fi
   alias where='  type -a'
   alias watch='  watch -d -p'
   alias grep='   grep --color=auto'
   alias svnhead="svnlog --limit=20"
   alias rehash=" hash -r"
   alias sort='   LC_ALL=C sort'
   alias reload=' exec env -u AMPROOT PATH=/usr/local/bin:/bin:/usr/bin bash -c "exec -l bash"'
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
   alias tigst="    tig status"
   alias gitcommit="git add \* ; git commit"
   gitdiff() {
      REV=''
      [[ $# > 0 && "$1" != -* ]] && REV=${1}^..${1}; shift;
      git diff -b $REV "$@";
   }
   gitup() {
      echo -e "Stashing .. \c"
      git stash save --include-untracked __GITGET__
      if git svn mkdirs >/dev/null ;then
         git svn rebase "$@"
      else
         git pull "$@"
      fi
      if git stash list | command grep -q __GITGET__ ;then
         echo -e "Unstash .. \c"
         git stash pop $(git stash list | awk  -F : '/__GITGET__/ {print $1; exit}')
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

   _GRC=`which grc`
   if [ "$TERM" != dumb ] && [ -n "$_GRC" ] ;then
      colorize() {
         if { test -t 1; } || [ "$COLORARG" = on ] ;then
            if [[ "$1" = *diff* || $2 = diff ]] ;then
               grc -es --colour=on "$@" | diff-highlight
            else
               grc -es --colour=${COLORARG:-auto} "$@"
            fi
         else
            command "$@"
         fi
      }
      for c in configure gcc as gas ld netstat ping traceroute head dig mount ps mtr df di \
               svn hg git ifconfig
      do
         eval "$c() { colorize '$c' \"\$@\"; }"
      done
   else
      colorize() { CMD=$1 ; shift; $CMD "$@"; }
   fi
   unset _GRC

   diff() { colorize diff -u "$@"; }
   df()   { colorize df -klP "$@"; }

   # Xubuntu: CapsLock -> CTRL-G + Control-R pressed -> DK layout
   fixkbd() { 
      #setxkbmap -option caps:none;
      xmodmap -e 'Caps_Lock=Control_L|G';
      xmodmap -e 'keysym Control_R = Mode_switch';
   }
   tpfan() {
      sudo ~/bin2/tp-fancontrol -s 5 -S 2 -l -d
   }

   export SVN=svn+ssh://ampsvn/srv/ampep
   vman()      { nvim "+call fman#man_page(0, 1, '', '${1}')"; }
   svnlast()   { if [[ $# -ge 1 ]] ;then svnlog -p -l 25 "$@" ;else svnlog -p -a $USER -l 25 ;fi; }
   gitlast()   { if [[ $# -ge 1 ]] ;then gitlog -p -l 25 "$@" ;else gitlog -p -a $USER -l 25 ;fi; }
   svnminfo()  { command svn mergeinfo $SVN/trunk/embedded \
                               --show-revs ${@:-eligible} | \
                 xargs -i svnlog '-{}' svn+ssh://ampsvn/srv/ampemb/trunk/embedded; }

   svnst()     { command svn st "$@" | command grep -v -e '^[X?]' -e '^    X'; }
   hgst()      { hg  st "$@" | command grep -v  '^[X?]'; }
   # alias open='kfmclient exec'
   url()       { kfmclient openURL "$*"; }
   vimless()   { nvim --cmd 'let no_plugin_maps = 1 | let load_less = 1' \
                     --cmd 'set readonly noswapfile' \
                      -c 'set mouse=a' \
                      -c 'runtime macros/less.vim' "${@:--}"; }
   jatt()      { curl -u fm:ccswe124 $1 | grcat conf.log | less -R; } # View jira attachment
   p()         { COLORARG="on" "$@" | less -R;}
   pg()        { $GRC -es "$@" | less -R;}
   vis()       { vi +set\ hlsearch $(which "$@"); }
   _txt()      { eval "file $*" | command grep -w text | cut -d: -f1; }
   vif()       { vi -c set\ hlsearch "+/$*/" $(ag --ignore .svn --ignore .git --ignore \*-pak -wl "$@"); }
   vdiff()     { vim -g -f -d --cmd 'set columns=220' -c 'normal <C-W>=' "$@"; }
   multitail() { XDG_CONFIG_HOME=$HOME/.config command multitail "$@"; }
   ToAURoot()  { tar zcf - $2 | command ssh $1 tar zxvf - -C /flash/root/; }
   Trace()     { amp-backtrace.lua "$@" | less +/'ERROR=>' --jump-target=.5; }
   psman()     { man -aW "$@" | xargs zcat | groff -man -Tps -P-pa4 \
                | psnup -pa4 -2 -d1 | less -R;}
   f()         { awk -v N="$*" 'BEGIN {split(N, Nr, / |,/)}
                 {for (n in Nr) {printf("%s%s", (n>1) ? " " : "", $Nr[n])}; print ""}'; }
   e()         { lua -e "print($*)";
                 lua -e "print(select(2, pcall(function() return string.format('0x%X', math.floor($*)) end)))"; }
   _utf8cat()  { iconv -f utf8 -t ascii  --byte-subst=" <0x%x> " --unicode-subst=" <U%04X> "; }
   utf8cat()   { if [[ $# -gt 0 ]] ;then _utf8cat <<< "$@" ;else _utf8cat ;fi; }
   utf8kill()  { if [[ $# -gt 0 ]] ;then iconv -f utf8 -t ascii -c <<< "$@" ;else iconv -f utf8 -t ascii -c ;fi; }
   utf8sel()   { sel | utf8kill; }
   pt()        { [[ $(tty) =~ /dev/ttys* ]] && ps -f -t $(printf "s%03d " $1) || ps -f -t $1; }
   # https://stackoverflow.com/a/8661395/3697584
   deflate()   { python3 -c 'import os,zlib; os.write(1, zlib.compress(open(0,"rb").read()))'; }
   inflate()   { python3 -c 'import os,zlib; os.write(1, zlib.decompress(open(0,"rb").read()))'; }
   #inflate()   { ruby -rzlib -e 'print Zlib::Inflate.new.inflate(STDIN.read)'; }
   #deflate()   { ruby -rzlib -e 'print Zlib::Deflate.new(6).deflate(STDIN.read, Zlib::FINISH)'; }
   waitsocks() { lsof -i TCP | awk 'NR==1 || (/WAIT/ && /^'"$1"'/) {print $0}'; }

   pv()        {
      if [[ $(type -t $1)  = alias ]] ;then
         local CMD=$1 ; shift
         COLORARG=on ${BASH_ALIASES[$CMD]} "$@" 2>&1 | less -R
      elif [[ $(type -t $1) ]] ;then
         COLORARG=on "$@" 2>&1 | less -R
      else
         command pv "$@"
      fi
   }

   del()       {
      [[ $# == 1 ]] && set ${1/:/ }
      echo -e "$2 d\nw\nq" | ed -s $1;
   }

   exit() {
      [[ "$SSH_CONNECTION" ]] && builtin exit "$@"
      [[ "$_" = */XMenu/* ]] && sleep 1 && builtin exit
      read -n 1 -t 10 -p "Really exit. Exits in 10 sec? [y/N] " ans
      [[ "$ans" = [yY]* || $? -gt 128 ]] && builtin exit "$@"
      echo "Phew!"
   }

   bindkeys() {
      echo -e "-- Readline (bind -P)"
      bind -P \
       | awk '/ can be found on / { split($0, W, / can be found on /); printf("%-40s %s\n", W[1], W[2]) }' \
       | sed 's/"\.$/"/'
      echo -e "\n-- Mappings (bind -s)"
      bind -s
      echo -e "\n-- Commands (bind -X)"
      bind -X
   }

   rmline() { sed -i '' "$1 d" "$2"; }

   tunnelstart() {
      tunnelblickctl status > /dev/null || tunnelblickctl launch
      tunnelblickctl connect "$(tunnelblickctl list | awk NR==1)"
      tunnelblickctl status
   }

   tmux-x-attach() {
      ps -f -u fm | grep -v grep | grep -q 'xpra start' || xpra start :9
      xpra attach :9 --opengl=no > /tmp/xpra-attach.log 2>&1 &
      DISPLAY=:9 tmux-attach "$@"
      xpra detach :9
   }

   tmux-attach() {
      # env | grep SSH
      if type -p ss && ss --tcp state CLOSE-WAIT | grep -q CLOSE_WAIT ;then
         # See https://stackoverflow.com/a/61139251/3697584
         sudo ss --tcp state CLOSE-WAIT --kill
      fi
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
   tmux-ssh() {
      tput smcup
      sshwrap ssh "$@" -A -X -t 'exec bash -i -c "PS1=tmux-ssh- ; . ~/.bashrc ; tmux-attach"'
      eof; printf '\e[?1000l'
   }
   alias tsel='tmux show-buffer'

   alias hist="builtin history | tail"
   alias histload="history -n"
   alias histgrep="history | grep"
   alias dhcp-assigned='ssh amplex@amplan0 "grep DHCPACK /var/log/syslog | tail "'

   case $TERM in
       sun-cmd) stln() { printf "\033]l %s \033" "$*"; } ; itit() { :; }
                ;;
       xterm*|linux*|screen*|tmux*)
                stln() { printf "\033]2;%s\007" "$*" ; }
                itit() { printf "\033]1;%s\007" "$*" ; }
                [ $WEZTERM_PANE ] &&
                   itit() { printf "\033]1337;SetUserVar=itit=%s\007" "$(echo -n "$*" | base64)"; }
                ;;
       *)       stln() { :; } ; itit() { :; }
       ;;
   esac
   if [[ "$TMUX" && -z "$NVIM_LISTEN_ADDRESS" ]] ;then
      itit() { printf "\ek%s\e\\" "$*" ; }
   fi
   if [[ "$NVIM_LISTEN_ADDRESS" ]] ;then
      itit() { :; }
   fi
   Tty=`tty | cut -c10- | sed 's/^\(0*\)\(..*\)/\2/'`
   HostnTty=`uname -n | cut -d. -f1 | tr a-z A-Z`:$Tty
   stdir() {
      local p=${PWD/$AMPROOT/@}
      if [[ $p = @/* ]] ;then Path=${p:2}; else Path=""; fi
      local p=${p/$HOME/\~}
      local V=''
      if [[ "$TMUX" ]] ;then
         itit "$Tty-$(cut -c1-3 <<< ${AMPROOT##*/})-${p##*/}"
      else
         itit "$Tty - $(cut -c1-3 <<< ${AMPROOT##*/}) - ${p##*/}"
      fi
      stln "-- $HostnTty $(ttprompt 2)- ${AMPROOT##*/} - $p --"
   }

   espmon ()
   {
      itit MON-${1##*/};
      python3 -m serial.tools.miniterm --rts 0 --dtr 0 --raw $1 ${2:-115200}
   }

   eof() {
      tput reset
      tput rmcup
      tput cup $(tput lines) 0
   }

   jsonui() { [[ $# -gt 0 ]] && command jsonui < $1 || command jsonui; }

   sshwrap() {
      local Cmd Host
      Cmd=$1 ; shift
      if test -t 1 ;then
         Host=$(command ssh -o 'ProxyCommand=sh -c "echo %h>/tmp/__H"' -o ControlPath=none "$@" 2>/dev/null;
                cat /tmp/__H; rm -f /tmp/__H)
         itit "$Tty => $(tr a-z A-Z <<< $Host)"
         if [[ $Host != fm* ]] ;then
            local Term=${TERM%-italic}
            env TERM=${Term/tmux/xterm} $Cmd "$@"
            return 0
         fi
      fi
      if ping -c 1 -t 1 "$Host"  |&  command grep -q 'Unknown host' ;then
         HostIP=$(host -4 -t A $Host | awk '/has address/ {print $4}')
         if [[ "$HostIP" ]] ;then
            command $Cmd "$@" -o "ProxyCommand=nc $HostIP %p"
         else
            command $Cmd "$@"
         fi
      else
         command $Cmd "$@"
      fi
      eof
   }
   function ssh()      { if [[ $# -eq 1 ]] ;then sshwrap ssh "$@" ;else command ssh "$@" ;fi; }
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
   wsHost() { # Resolve host from ~/.ssh/config
     cat ~/.ssh/config 2>/dev/null \
     | awk -v H="$1" '
        tolower($1) == "host" {
           found = 0;
           for (i = 1; i <= NF; i++) { if ($i == H) found = 1; }
        }
        tolower($1) == "hostname" && found { print $2; found = 2; exit; }
        END { if (found != 2) print H; }
     '
   }
   wsLogin() {
     local HOST=$(wsHost $2)
     local SCHM="https"
     if [[ $HOST = *://* ]] ;then
       SCHM=${HOST%://*}
       HOST=${HOST#*://}
     fi
     local LOGIN="--cookie /tmp/curl-cookie-jar.$1-$HOST --cookie-jar /tmp/curl-cookie-jar.$1-$HOST"
     local CODE=$(umask 077; curl -s -k -w '%{http_code}\n' $LOGIN $SCHM://$HOST/aasws/nodes -o /dev/null)
     if [[ $CODE = 403 ]] ;then
       CODE=$(umask 077; curl -s -k --user $1 -w '%{http_code}\n' $LOGIN $SCHM://$HOST/aasws/nodes -o /dev/null)
     fi
     if [[ $CODE != 200 ]] ;then
       LOGIN="--user $1"
     fi
     echo $LOGIN
   }
   function ws2 () {
     local OPER=$1
     local USER=$2
     local HOST=$3
     local PURL=$4
     shift 4
     local LOGIN=$(wsLogin $USER $HOST)
     local HOST=$(wsHost $HOST)
     local SCHM="https"
     if [[ $HOST = *://* ]] ;then
       SCHM=${HOST%://*}
       HOST=${HOST#*://}
     fi
     HEADERS=(-H "Content-type: application/json" -H "Accept: application/json")
     [[ $1 = '-H' ]] && HEADERS=()

     #echo "P: $P"
     curl -w '\n--- CURL STAT ---\n%{http_code}: %{size_header} + %{size_download}B TIME:%{time_total}-%{time_pretransfer}\n' \
        $LOGIN --anyauth --silent -k "${HEADERS[@]}" \
        -X$OPER $SCHM://$(wsHost $HOST)"$PURL" "$@" \
     | mawk '/^--- CURL STAT ---$/ {d=1} d==0 {print} d==1 {print > "/dev/stderr"}'
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

   function SvnUpRev () {
      if [[ $# = 0 ]] ;then
         echo "Usage: SvnUpRev <revision>"
         return 1
      fi
      REVISION=$1
      svn up -r$REVISION | egrep '^Fetching external' \
         | awk -F"'" '/^Fetching external item into/ {print $2}' \
         | xargs -I '{}' svn up -r$REVISION '{}'
   }

   if [[ -d ~/.keychain && "$UID" -ne 0 && -z "$SSH_AUTH_SOCK" ]] ;then
      #keychain --quiet ~/.ssh/id_dsa --timeout 1440  # 24 hours.
      HOSTNAME=$(uname -n) ; export HOSTNAME=${HOSTNAME%%.*}
      #keychain --quiet ~/.ssh/id_dsa
      eval `keychain --quiet --eval`
      #alias kcload='eval `keychain --quiet --eval`'
   fi

   if [[ -d /opt/toolchain/. ]] ;then
      . /opt/toolchain/utils/toolchain-utils-load
      . ~/.toolchainrc
   fi

   function amptree()  {
      if [ $# -eq 0 ] ;then echo $AMPROOT ; return ;fi
      if [ $1 == --completions ] ;then
         (cd ~/repos; for f in */arm9 */ampep */.git */.svn ;do [ -e $f ] && echo ${f%%/*} ;done) | sort -u | awk "/^$3/"
         return 
      fi
      local noCD=""
      if [[ $1 == --nocd ]] ;then noCD=1; shift; fi
      export AMPROOT=~/repos/$1
      CDPATH=""
      local D=""
      if [[ -d $AMPROOT/arm9 ]] ;then
         local DL="$AMPROOT/{,arm9,arm9/agentframework/{,agents,libs},arm9/apps/{,drivers},arm9/{utils,drivers,radiomodule}}"
         export SVN=svn+ssh://ampsvn/srv/ampemb
         D=arm9
      elif [[ -d $AMPROOT/ampep ]] ;then
         DL="$AMPROOT/{,ampep,greenwise,greenwise/common-ui/src/main/webapp/modules}"
         export SVN=svn+ssh://ampsvn/srv/ampep
         D=ampep
      else
         DL=$AMPROOT
      fi
      for d in ~ $(eval echo $DL) ~/{repos,repos/modules,releases,src,stuff} ;do
         CDPATH=$CDPATH:$d
      done
      export LUA_CPATH=";;/opt/toolchain/X86/usr/lib/lua/5.4/?.so;$AMPROOT/arm9/agentframework/lua/?.so"
      if [[ ! -n $noCD ]] ;then
         echo $AMPROOT/$D
         cd $AMPROOT/$D
      fi
   }

   # [[ $BASH_COMPLETION ]] || . /etc/bash_completion
   for f in bash_completion profile.d/bash_completion.sh ;do
      for d in /etc/ /usr/local/etc /usr/local/share/bash-completion ;do
         if [ -r $d/$f ] ;then
            source $d/$f
         fi
      done
   done
   for f in ~/.bash_completion.d/* ;do
      if [ -r $f ] ;then
         source $f
      fi
   done

   gitps1() {
      local branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
      if [[ $?=0 && "$branch" && $branch != "master" ]] ;then
         [[ $branch == "HEAD" ]] && branch='<detached>'
         echo ":${branch^^*}"
      fi
   }

   bgstatp() {
      if [[ $(jobs -s; jobs -r) ]] ;then
         printf ' BG:%d,%d' "$(jobs -s -p | wc -w)" "$(jobs -r -p | wc -w)"
      fi
   }

   ttprompt() {
      case "$1" in
         1) echo "${TOOLCHAIN_PS1_LABEL:+ }${TOOLCHAIN_PS1_LABEL}" ;;
         *) echo "${TOOLCHAIN_PS1_LABEL:+[}${TOOLCHAIN_PS1_LABEL}${TOOLCHAIN_PS1_LABEL:+]}" ;;
      esac
   }
   __col() {
      [[ $TERM == xterm*  || $TERM == screen* || $TERM == tmux* || $TERM == linux ]] && echo -n '\[\e[3'${1}'m\]'
   }

   PS1="[$(__col 1)\h $(__col 2)\W$(__col 6)\$(gitps1)\$(bgstatp)$(__col 3)\$(exitrep)\$(ttprompt 1)$(__col 9)]\\\$ "

   run() { local A=$1 ; shift ; open "/Applications/${A}.app" "$@"; }
   __run() {
      mapfile -t COMPREPLY < <(command ls -1d /Applications/{,*/}*.app | \
                               grep -i "/$2" | \
                               sed -e 's,^/Applications/,,' -e 's/.app$//' -e 's/ /\\ /g');
   }
   complete -F __run run

   [ -f /etc/rc.d/functions ] && USECOLOR=yes source /etc/rc.d/functions

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

   _prompt_command() {
      history -a
      stdir
      hash -r
      timerep
      profile_check
      tmux_update
   }
   PROMPT_COMMAND=_prompt_command

   =()         {
      #local i e
      #i="${@//p/+}"
      #i="${i//m/*}"
      #e="$(($i))"
      #printf "%d -- 0x%x\n" $e $e
      lua-5.3 -e "val = ${*//@/*}
                  print(string.format('%s -- 0x%x', val, val//1))"
   }

   _tac() {
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
      eval $(command grep "$@" ~/.bash_history | uniq | command tail -35 | _tac \
             | gawk '{print "C[" I++ "]=\047" gensub("\047", "\047\\\\\047\047", "g", $0) "\047"}')
      if [[ ${#C[@]} > 0 ]] ;then
         for ((I=0; I<${#C[@]}; I++ )) ;do echo "$(__idx $I): ${C[$I]}" > /dev/tty ;done
         read -n 1 -p "Select command: " N </dev/tty >/dev/tty
         if [[ $N = '!' ]]  ;then
            read -n 1 -p " : " N </dev/tty >/dev/tty
            RC=5
         fi
         if [[ $N != q && $N = [0-9A-Z] && ${#C[$(__idx $N)]} > 0 ]] ;then
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

   __vi() {
      COMPREPLY=()
      if [[ $3 = "-t"  || $1 = "vit" ]] ;then
         local D=.
         while [[ ! -f $D"/tags" && $(cd $D ; pwd) != "/" ]] ;do
            D=$D"/.."
         done
         if  [[ -f $D"/tags" ]] ;then
            mapfile -t COMPREPLY < <(readtags -p -t $D"/tags" $2 | cut -f 1 2>/dev/null)
         fi
      fi
   }
   vit() { vi "+T $1"; }

   alias amp=amptree
   complete -C 'amptree --completions' amp
   complete -F _command -o filenames p pv pg
   complete -F _man vman
   complete -c vis env where 
   complete -F __vi vit
   complete -o default -F __vi vi vim nvim

   if [[ $_PS1 != tmux-ssh- ]] ;then
      # See https://github.com/themadsens/qfc
      [[ -d ~/.qfc ]] && source ~/.qfc/bin/qfc.sh
      [[ -f ~/.fzf.bash ]] && source ~/.fzf.bash
      [[ -f ~/.fzf.bash ]] && source ~/thm-dotfiles/files/fzf.bash
      #qfc_quick_command 'vim' '\C-p' 'vim $0'
      #qfc_quick_command 'cd' '\C-b' 'cd $0'
   fi
   unset _PS1


   [ -z "$CDPATH" ] && amptree --nocd epgit
fi

# vim: set sw=3 sts=3 et:
