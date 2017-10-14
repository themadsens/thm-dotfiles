
SHELL=$BASH
export LC_CTYPE=en_US.UTF-8
umask 022

if [ -n "$PS1" ] ;then
    source ~/thm-dotfiles/.sh-common
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
fi

# vim: set sw=3 sts=3 et:
