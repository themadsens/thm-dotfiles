
call plug#begin('~/.vim/plugged')

" Plug 'https://github.com/vim-scripts/matchit.zip'
  Plug 'https://github.com/JalaiAmitahl/maven-compiler.vim'
  Plug 'https://github.com/junegunn/vim-easy-align'
" Plug 'https://github.com/pangloss/vim-javascript'
" Plug 'https://github.com/othree/yajs.vim'
" Plug 'https://github.com/jelera/vim-javascript-syntax.git'
  Plug 'https://github.com/othree/javascript-libraries-syntax.vim'
  Plug 'https://github.com/mxw/vim-jsx.git'
" Plug 'https://github.com/udalov/kotlin-vim'
" Plug 'https://github.com/vim-scripts/dbext.vim'
" Plug 'https://github.com/cosminadrianpopescu/vim-sql-workbench'
  Plug 'https://github.com/preservim/tagbar.git'
  Plug 'https://github.com/xolox/vim-easytags'
  Plug 'https://github.com/xolox/vim-misc'
  Plug 'https://github.com/tpope/vim-fugitive.git'
  Plug 'https://github.com/tpope/vim-scriptease.git'
  Plug 'https://github.com/junegunn/gv.vim.git'
  Plug 'https://github.com/junegunn/fzf'
  Plug 'https://github.com/junegunn/fzf.vim'
" Plug 'https://github.com/scrooloose/syntastic'
  Plug 'https://github.com/cespare/vim-toml'
  Plug 'https://github.com/tmux-plugins/vim-tmux'
" Plug 'https://github.com/tomtom/brep_vim'
  Plug 'https://github.com/vim-scripts/GrepCommands.git'
  Plug 'https://github.com/vim-scripts/GrepHere.git'
  Plug 'https://github.com/vim-airline/vim-airline'
  Plug 'https://github.com/vim-airline/vim-airline-themes'
  Plug 'https://github.com/mildred/vim-bufmru.git'
  Plug 'https://github.com/edkolev/tmuxline.vim'
" Plug 'https://github.com/chrisbra/changesPlugin.git'
  Plug 'https://github.com/edkolev/promptline.vim'
  Plug 'https://github.com/vim-scripts/python_match.vim.git'
  Plug 'https://github.com/neomake/neomake'
  Plug 'https://github.com/vim-scripts/CmdlineComplete.git'
  Plug 'https://github.com/artur-shaik/vim-javacomplete2.git'
" Plug 'https://github.com/codeindulgence/vim-tig'
  Plug 'https://github.com/rhysd/devdocs.vim.git'
  Plug 'https://github.com/elzr/vim-json.git'
  Plug 'https://github.com/themadsens/jcall.vim.git'
  Plug 'https://github.com/tomtom/quickfixsigns_vim.git'
  Plug 'https://github.com/ctrlpvim/ctrlp.vim.git'
" Plug 'https://github.com/ternjs/tern_for_vim'
  Plug 'https://github.com/sjl/vitality.vim'
" Plug 'https://github.com/zerowidth/vim-copy-as-rtf'
" Plug 'https://github.com/natebosch/vim-lsc'
" Plug 'https://github.com/themadsens/VimPyServer'
  Plug 'https://github.com/rust-lang/rust.vim'
  Plug 'https://github.com/preservim/nerdtree.git'
  Plug 'https://github.com/ziglang/zig.vim'
  Plug 'https://github.com/simnalamburt/vim-mundo'
" Plug 'https://github.com/iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }
  Plug 'https://github.com/kdheepak/lazygit.nvim'
  Plug 'https://github.com/mhinz/vim-signify'
  Plug 'https://github.com/ryanoasis/vim-devicons'
" Plug 'kyazdani42/nvim-web-devicons'
<<<<<<< Updated upstream
  Plug 'https://github.com/kergoth/vim-bitbake'
  Plug 'https://github.com/Vimjas/vim-python-pep8-indent'
  Plug 'https://github.com/khaveesh/vim-fish-syntax'
  Plug 'https://github.com/neoclide/jsonc.vim'
  Plug 'https://github.com/dhruvasagar/vim-table-mode'
" Plug 'https://github.com/Rykka/riv.vim'
" Plug 'https://github.com/Rykka/InstantRst'
  Plug 'https://github.com/juneedahamed/vc.vim'
  Plug 'https://github.com/fcpg/vim-colddeck'

"if has('nvim')
  "Plug 'andymass/vim-matchup'
  "Plug 'nvim-treesitter/nvim-treesitter'
  Plug 'https://github.com/neoclide/coc.nvim', {'branch': 'release'}
  Plug 'https://github.com/Yggdroot/LeaderF'
  Plug 'https://github.com/sychen52/smart-term-esc.nvim'
  Plug 'https://github.com/rrethy/vim-hexokinase', { 'do': 'make hexokinase' }
"endif
=======
  Plug 'kergoth/vim-bitbake'
  Plug 'Vimjas/vim-python-pep8-indent'
  Plug 'khaveesh/vim-fish-syntax'
  Plug 'neoclide/jsonc.vim'
  Plug 'dhruvasagar/vim-table-mode'
" Plug 'Rykka/riv.vim'
" Plug 'Rykka/InstantRst'
  Plug 'juneedahamed/vc.vim'
  Plug 'elixir-editors/vim-elixir'

  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  Plug 'Yggdroot/LeaderF'
if has('nvim')
  "Plug 'andymass/vim-matchup'
  "Plug 'nvim-treesitter/nvim-treesitter'
  Plug 'rrethy/vim-hexokinase', { 'do': 'make hexokinase' }
endif
>>>>>>> Stashed changes


call plug#end()

