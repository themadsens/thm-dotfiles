#!/bin/bash
mkdir -p plugins
cd plugins
(cat << EOF 
 	https://github.com/tmux-plugins/tpm
EOF
) | grep -v '^ *#'| \
while read rep ;do
    dir=${rep##*/}
    echo "* $dir - $rep"
    if [[ -d ${dir%.git} ]] ;then
        git -C ${dir%.git} pull
    else
        git clone --depth=5 $rep
    fi
done
