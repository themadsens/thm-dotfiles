#!/bin/bash
mkdir -p bundle
cd bundle
(cat << EOF 
    https://github.com/vim-scripts/matchit.zip
    https://github.com/JalaiAmitahl/maven-compiler.vim
    https://github.com/junegunn/vim-easy-align
#   https://github.com/pangloss/vim-javascript
#   https://github.com/othree/yajs.vim
    https://github.com/jelera/vim-javascript-syntax.git
    https://github.com/othree/javascript-libraries-syntax.vim
	https://github.com/udalov/kotlin-vim
	https://github.com/vim-scripts/dbext.vim
	https://github.com/majutsushi/tagbar.git
    https://github.com/xolox/vim-easytags
    https://github.com/xolox/vim-misc
    https://github.com/tpope/vim-fugitive.git
    https://github.com/junegunn/gv.vim.git
#	https://github.com/scrooloose/syntastic
 	https://github.com/cespare/vim-toml
 	https://github.com/tmux-plugins/vim-tmux
 	https://github.com/vim-scripts/Buffer-grep
 	https://github.com/vim-airline/vim-airline
 	https://github.com/vim-airline/vim-airline-themes
 	https://github.com/edkolev/tmuxline.vim
    https://github.com/chrisbra/changesPlugin.git
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
vi +'Helptags|quit'
