#!/bin/bash
mkdir -p bundle
cd bundle
(cat << EOF 
    https://github.com/vim-scripts/matchit.zip
    https://github.com/JalaiAmitahl/maven-compiler.vim
    https://github.com/junegunn/vim-easy-align
#   https://github.com/pangloss/vim-javascript
    https://github.com/othree/yajs.vim
    https://github.com/othree/javascript-libraries-syntax.vim
	https://github.com/udalov/kotlin-vim
	https://github.com/vim-scripts/dbext.vim
	https://github.com/majutsushi/tagbar.git
#	https://github.com/scrooloose/syntastic
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
