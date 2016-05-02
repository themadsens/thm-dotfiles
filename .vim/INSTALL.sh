#!/bin/bash
mkdir -p bundle
cd bundle
(cat << EOF 
    https://github.com/vim-scripts/matchit.zip
    https://github.com/JalaiAmitahl/maven-compiler.vim
    https://github.com/junegunn/vim-easy-align
EOF
) | \
while read rep ;do
    dir=${rep##*/}
    echo "* $dir - $rep"
    if [[ -d $dir ]] ;then
        git -C $dir pull
    else
        git clone $rep
    fi
done
