"
" My .vimrc file
" vint: -ProhibitImplicitScopeVariable -ProhibitAbbreviationOption
"
scriptencoding utf-8
if has('win32')
   " Use CCI standard setup. This happens automatically on UNIX
   if filereadable($VIM . '/vimrc')
      source $VIM/vimrc
   endif
endif

" execute pathogen#infect() " Using https://github.com/junegunn/vim-plug these days
source $HOME/.vim/plugins.vim

syntax on
filetype plugin indent on

augroup Private
  autocmd!
  autocmd BufReadPost,StdinReadPost * call SetFileTypeOnLoad()
  autocmd BufReadPre *.nfo,*.NFO :setlocal fileencodings=cp437,utf-8
  autocmd CursorHold  * :exe "normal \<c-g>\<c-g>"
augroup END

let g:tagbar_ctags_bin = "ctags"
let g:tagbar_autoclose = 1
let g:tagbar_autofocus = 1
let g:tagbar_sort = 0
let g:tagbar_zoomwidth = 0
let g:tagbar_type_lua = { 'replace': 1, 'ctagstype': 'MYLUA', 'kinds': [ 'f:functions', 'c:constants', ] }
let g:tagbar_type_javascript = { 'replace': 1,
    \ 'kinds' : [
        \ 'v:globals',
        \ 'c:classes',
        \ 'p:properties',
        \ 'm:methods',
        \ 'f:functions',
    \ ],
\ }
nmap <F3> :TagbarToggle<CR>

setglobal tags=/opt/toolchain/include/tags,/usr/include/tags
setglobal path=.,,include,../include,/opt/toolchain/include,/usr/include

if has('win32')
   behave xterm
   setglobal directory=C:/temp/preserve//   " Home of the swap files_
   if filereadable('C:\Programs\NT_SFU\Shell\grep.EXE')
      setglobal grepprg=grep\ -n            " Use POSIX grep if available
   endif

   " Let VIM know about VisualC++ include files
   if exists('$include')
      let more = substitute($include, ';', ',', 'g')
      let more = substitute(more, ' ', '\\\\\\ ', 'g')
      execute 'setglobal path+=' . more
      let g:incdirs = g:incdirs.','.more

      let more = substitute($include, ';', '\\\\\\tags,', 'g')
      execute 'setglobal tags+=' . substitute(more, ' ', '\\\\\\ ', 'g') . '\\tags'
      unlet more
   endif

   if exists('$SCCSHOME')
      " Can not handle '/' to '\' conversion otherwise
      let $SCCSHOME = $SCCSHOME . '/'
   endif

   if has('gui_running')
      setglobal guifont=Courier_New:h9
      " System menu and quick minimize
      map <M-Space> :simalt ~<CR>
      "map <M-n> :simalt ~n<CR>
      " Size the GUI window. Delay positioning until window is created
      setglobal lines=50
      setglobal columns=82
      augroup AutoPos
      autocmd BufEnter * winp 200 50 | autocmd! AutoPos
      augroup END
   endif
else
   if (&term ==# 'cygwin') " This seem to have some quirks, work around some
      setglobal directory=/var/preserve/
      " Make <End> work
      exe "setglobal t_@7=\e[4~"
      " Make <Home> work
      exe "setglobal t_kh=\e[1~"
   else
      setglobal directory=/var/preserve//
      setglobal grepprg=ag\ --vimgrep\ --follow\ $*
      set grepformat=%f:%l:%c:%m
      if has('gui_running')
         let &guifont='Monaco for Powerline:h10'
         "let &guifont='Bitstream Vera Sans Mono 8'
      else
         " Uncomment line below to use :emenu. Adds ~1 second to startup time
         " source $VIMRUNTIME/menu.vim

         " Make <End> work - Some options cannot be assigned to with 'let'
         "exe 'setglobal t_@7=\<Esc>OF'

         " Must be _very_ slow to handle triple clicks
         setglobal mousetime=1500
         "if &ttymouse ==# 'xterm2'
         "   " The xterm2 mode will flood us with messages
         "   setglobal ttymouse=xterm
         "endif
         if &term =~# '\v^(screen|tmux|xterm-)'
           "setglobal ttymouse=xterm2
            if &term =~# '\v^(screen|tmux)'
               execute "set <xUp>=\e[1;*A"
               execute "set <xDown>=\e[1;*B"
               execute "set <xRight>=\e[1;*C"
               execute "set <xLeft>=\e[1;*D"
            endif
         endif

         if has('nvim')
            set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20
         else
            " Save and restore the 'shell' screen on enter and exit
            let &t_te = "\<Esc>[2J\<Esc>[?47l\<Esc>8"
            let &t_ti = "\<Esc>7\<Esc>[?47h"

            " tmux will only forward escape sequences to the terminal if surrounded by a DCS sequence
            " Bar cursor on insert. Assumes iterm2
            if exists('$TMUX')
              let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
              let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
            else
              let &t_SI = "\<Esc>]50;CursorShape=1\x7"
              let &t_EI = "\<Esc>]50;CursorShape=0\x7"
            endif
         endif

         " Make <Del> mappings work
         " exe 'setglobal t_kb=\x08'
         " exe 'setglobal t_kD=\x7f'

         exe 'setglobal t_Co=16'
         " highlight LineNr cterm=NONE ctermbg=187
         " highlight CursorLine cterm=NONE ctermbg=186
         setglobal cursorline
         set cursorline

         " Make shifted cursor keys work.
         " For the necessary xmodmap commands, see :help hpterm
         map  <t_F3>   <S-Up>
         map! <t_F3>   <S-Up>
         map  <t_F6>   <S-Down>
         map! <t_F6>   <S-Down>
         map  <t_F8>   <S-Left>
         map! <t_F8>   <S-Left>
         map  <t_F9>   <S-Right>
         map! <t_F9>   <S-Right>
         " To make the shift-Tab <S-Tab> key work, also see :help suffixes
         cmap <Esc>[1~ <C-P>
         cmap <Esc>[1;2~ <C-P>
      endif
   endif
endif

if has('gui_running')
    setglobal title icon
    setglobal titlestring=%F%(\ --\ %a%)
    setglobal iconstring=%f
else
    setglobal notitle noicon         " Do _not_ mess with title string of my xterm
endif

setglobal showcmd                    " Show chars for command in progress on ruler
setglobal exrc                       " Allow .vimrc in current dir
setglobal hidden                     " Dont unload buffers BEWARE OF :q! and :qa! !!!
setglobal backspace=indent,eol       " Can ^H/^W/^U across lines in insert
setglobal sidescroll=5
setglobal scrolloff=4
setglobal textwidth=100
setglobal whichwrap=h,l,<,>,[,]      " Do not backspace/space across line boundaries
setglobal autoindent
setglobal winheight=10               " Make new windows this high
setglobal cmdheight=2                " status line area height - higher for quickfix
setglobal laststatus=2               " always with statusline
setglobal showmatch
setglobal autowrite                  " write files back at ^Z, :make etc.
setglobal mouse=nv                   " Use xterm mouse mode in insert/cmdline/prompt
setglobal clipboard=                 " Too intrusive with: unnamed,unnamedplus
setglobal fileformats=unix,dos,mac
setglobal showbreak=________         " Show me where long lines break
setglobal showfulltag                " Insert function prototype in ^X^]
setglobal incsearch nohlsearch       " Search while typing, 'zx' toggles highlighting
setglobal helpheight=100             " Maximize help windows
setglobal shortmess=ato              " Brief messages to avoid 'Hit Return' prompts
setglobal formatoptions=crqlo        " Comment handling / Dont break while typing
setglobal history=100
setglobal viminfo='20,\"500          " Keep history listings across sessions
"setglobal wildmenu                   " Show completion matches on statusline
"setglobal wildmode=list:longest,full " Default 'full' in neovim -> wildoptions=pum (popupmenu)
setglobal complete=.,w,b,u,d         " The ,t,i from the default was too much, now ,d
setglobal isfname-==                 " No = allows 'gf' in File=<Path> Constructs
setglobal shiftwidth=4
setglobal softtabstop=4
setglobal number
setlocal  number
setglobal expandtab
setglobal spelllang=en_us
setglobal visualbell
setglobal printfont=:h7.5
setglobal printoptions=number:y,duplex:off,left:5mm,top:5mm,bottom:5mm,right:5mm
setglobal virtualedit=block
setglobal noignorecase
setglobal smartcase
setglobal nofoldenable
"setglobal undofile
if has('nvim')
   setglobal list
   setlocal  list
end

let c_gnu = 1
let c_no_curly_error = 1
"let &errorformat =

" Disaster prevention
vmap u <Esc>
vmap U <Esc>
vnoremap gu u
vnoremap gU U

function! WithQfInfo(cmd)
    let exception = ""
    try
        exe a:cmd
    catch
        echohl WarningMsg | echo v:exception[3:] | echohl None
        let exception = v:exception
    endtry
    let info = getqflist({'nr': 0, 'size': 1, 'idx':1, 'winid':1})
    if exception == '' && info.winid > 0
        let err = getqflist()[info.idx-1]
        echo "("..info.idx.." of "..info.size.."): "..err.text
    endif
endfunction

" For running edit-compile-edit (quickfix)
nmap <silent> gn    :call WithQfInfo("cnext")<CR>
nmap <silent> <M-n> :call WithQfInfo("cnext")<CR>
nmap <silent> gp    :call WithQfInfo("cprevious")<CR>
nmap <silent> <M-p> :call WithQfInfo("cprevious")<CR>
nmap <silent> gl    :call WithQfInfo("cwindow")<CR>
nmap <silent> gc    :call WithQfInfo("cc")<CR>
nmap <silent> gz    :call qfutil#followLine(0)<CR>
nmap gm :Make<CR>

" Various utility keys
nmap (     :bprev<CR>
nmap )     :bnext<CR>
nmap F     :files<CR>
"nmap Q     :bdelete<CR>
nmap !Q    :bwipeout!<CR>
nmap Q     :call PrevBuf(1)<CR>
"nmap gQ    :call PrevBuf(0)<CR>
"nmap !Q    :call PrevBuf(1,"!")<CR>
nmap [f    :bunload<CR>
nmap zx    :call ToggleOpt("hlsearch")<CR>
nmap zs    :call ToggleOpt("spell")<CR>
nmap zn    :call ToggleOpt("number")<CR>
nmap zm    :call ToggleOpt("cursorcolumn")<CR>
nmap zf    :call ToggleOpt("foldenable")<CR>
nmap zz    :call ToggleOpt("ignorecase")<CR>
nmap zp    :call ToggleOpt("paste")<CR>
nmap [s    :exe "g/".@/."/p"<CR>

" Bashify command line
cnoremap <C-A> <Home>
cnoremap <C-E> <End>
cnoremap <C-F> <Right>
cnoremap <C-B> <Left>
cnoremap <Esc>b <S-Left>
cnoremap <Esc>f <S-Right>

map <MiddleMouse> <Nop>
imap <MiddleMouse> <Nop>

command! Q qall

function! ToggleOpt(opt)
    exe 'set inv'.a:opt
    echo "Option '".a:opt."' : ".eval('&'.a:opt)
endfunction

" Make cursor keys jump out of insert. Your preference may differ
imap <Left>     <Esc>
imap <Right>    <Esc>
imap <Up>       <Esc>
imap <Down>     <Esc>
imap <S-Left>   <Esc>
imap <S-Right>  <Esc>
imap <S-Up>     <Esc>
imap <S-Down>   <Esc>
let g:ftplugin_sql_omni_key_right = '<C-C><Right>'
let g:ftplugin_sql_omni_key_left  = '<C-C><Left>'
map <F12> <Cmd>set nopaste<CR>
lnoremap <F12> <C-O><Cmd>set nopaste<CR>

" Movement with "2x3" block navigation keys. Customize to your liking
nnoremap <PageUp>   <C-U>
nnoremap <PageDown> <C-D>
nnoremap <Home>     <C-Y>
nnoremap <xHome>    <C-Y>
nnoremap <End>      <C-E>
nnoremap <M-Up>     <C-Y>
nnoremap <M-Down>   <C-E>
nmap <Insert>   [[zz
nmap <Del>      ]]zz
nmap <kDel>     ]]zz
nmap <S-Up>     {
nmap <S-Down>   }
nnoremap <Esc><PageUp>   gT
nnoremap <Esc><PageDown> gt
inoremap <Esc><PageUp>   gT
inoremap <Esc><PageDown> gt

" Insert some standard blobs
map <F2> :r $SCCSHOME/SccsHeaders/static.hdr<CR>

" Always delete to left of cursor
inoremap <Del> <C-H>
cnoremap <Del> <C-H>

" EasyAlign
nmap ga <Plug>(EasyAlign)
vmap ga <Plug>(EasyAlign)
let g:easy_align_delimiters = {
\ '>': { 'pattern': '>>\|=>\|>' },
\ '/': {
\     'pattern':         '//\+<\?\|/\*\|\*/',
\     'delimiter_align': 'l',
\     'ignore_groups':   ['!Comment'] },
\ ']': {
\     'pattern':       '[[\]]',
\     'left_margin':   0,
\     'right_margin':  0,
\     'stick_to_left': 0
\   },
\ ')': {
\     'pattern':       '[()]',
\     'left_margin':   0,
\     'right_margin':  0,
\     'stick_to_left': 0
\   },
\ }


" List multiple matches at CTRL-]
nmap <C-]>      :T <C-R><C-W><CR>
" Tag "preview" window
nmap <C-X><C-]>     :ptag <C-R><C-W><CR>
nmap <C-X><Right>   :ptnext<CR>
nmap <C-X><C-Right> :ptnext<CR>
nmap <C-X><Left>    :ptprevious<CR>
nmap <C-X><C-Left>  :ptprevious<CR>
nmap <C-X><Down>    :ppop<CR>
nmap <C-X><C-Down>  :ppop<CR>
nmap <C-X><Up>      :ptag<CR>
nmap <C-X><C-Up>    :ptag<CR>
nmap <C-X>x         :pclose<CR>

" ins-completion
inoremap <C-]> <C-X><C-]>
inoremap <C-O> <C-X><C-O>
"inoremap <C-F> <C-X><C-F>

" Some coloring. These are _my_ preferences
hi NonText                                    ctermfg=lightgray
hi Visual                           cterm=Inverse ctermfg=grey ctermbg=black

if &term ==# 'ansi' || &term ==# 'console' || &term ==# 'linux'
    setglobal background=dark
    hi statusLine ctermfg=black
    hi statusLineNC ctermfg=black ctermbg=yellow
endif

function! Tjump(tag)
    let tagnm = split(a:tag, '[^:]:[^:]')
    if len(tagnm) > 1
        exe '1 tag '.split(a:tag, ':')[0]
        exe split(a:tag, ':')[1]
    else " Jump to tag directly if they all point to same kind in same file. Prefer search cmd
        let fn = ""
        let all = 1
        let cnt = 1
        for t in taglist(a:tag)
            let all = all + 1
            "let cur = t.name.':'.t.filename.':'.t.kind
            let cur = t.filename.':'.t.kind
            if fn != "" && fn != cur
                let all = 0
                break
            elseif t.cmd[0] == '/'
                let cnt = all
            end
            let fn = cur
        endfor
        if all > 0
            exe cnt.' tag '.a:tag
        else
            exe 'tjump '.a:tag
        end
    end
endfunction

function! Tag(tag)
    let tagnm = split(a:tag, ':')
    exe 'tag '.tagnm[0]
    if len(tagnm) > 1
        exe tagnm[1]
    end
    let _=foreground()
endfunction

function! LoadFileAtLine(f)
    let [fname, lineno] = split(a:f, ":")
    exe "edit +"..lineno.." "..fnameescape(fname)
    autocmd CursorHold <buffer=abuf> edit
endfunction

" Use :T instead of :ta to see file names in ^D complete-lists
command! -complete=tag_listfiles -nargs=1 T call Tjump("<args>")|
                                           \call histadd("cmd", "T <args>")

" File type dependent settings
augroup Private
   autocmd BufReadPost * call SetBufferOpts()
   autocmd BufNewFile  * call SetBufferOpts()
   autocmd BufNewFile  * call SetBufferOpts()
   autocmd DirChanged  * call SetBufferOpts()
   autocmd FileType    * call SetFileTypeOpts()
   " autocmd CursorMoved * call qfutil#followLine(0)

   " Handle global (non bufferspecific) options
   autocmd BufEnter * call BufEnterGlobalOpts()

   autocmd BufReadCmd *:[0-9]\\\{1,5\} call LoadFileAtLine(expand("<amatch>"))

   autocmd InsertEnter * call system("tmux set mouse off")
   autocmd InsertLeave * call system("tmux set mouse on")

   function! YankToClip(event)
      let text = a:event.regcontents[:]
      if text[-1] ==# ''
	 let text = text[:-2]
      end
      if a:event.operator ==# 'y' && len(text) > 0
	 call system(has('mac') ? 'pbcopy' : 'lemonade copy', text)
      end
   endfunc

   autocmd FocusGained  * let @" = system(has('mac') ? "pbpaste" : "lemonade paste")
   autocmd TextYankPost * call YankToClip(v:event)
augroup end

function! BufEnterGlobalOpts()
   " Avoid '#-in-1.-column' problem with cindent & smartindent
   let ft = &filetype
   if ft==#'c' || ft==#'cpp' || ft==#'arduino'
      inoremap # #
      " Dont highligh this as an error
      hi link cCommentStartError Comment
   else
      inoremap # X<BS>#
   endif
   if ft ==# 'java'
      nmap [[ [m
      nmap ]] ]m
      nmap gd "zyiw[m/\<<C-R>z\><CR>
      nmap <Insert>   [mzz
      nmap <Del>      ]mzz
   else
      nnoremap gd gd
      nnoremap [[ [[
      nnoremap ]] ]]
      nmap <Insert>   [[zz
      nmap <Del>      ]]zz
   endif
   syntax sync minlines=1000
endfunc

function! SetFileTypeOnLoad()
   if (!did_filetype() || tolower(&ft) ==# 'conf') && expand('<amatch>') !~ g:ft_ignore_pat
      let line1 = tolower(getline(1))
      if line1 =~# 'lua'
         setlocal filetype=lua
      elseif line1 =~# 'node'
         setlocal filetype=javascript
      elseif expand('<amatch>') =~ '\.r$'
         setlocal filetype=xdefaults
      elseif expand('<amatch>') =~ '\.gitignore$'
         setlocal filetype=config
      endif
  endif
endfunc
let g:used_javascript_libs = 'underscore,angularjs,jquery'

function! SetFileTypeOpts()
   let ft = &filetype
   " echomsg 'FILETYPE: '.ft
   if index(['c','cpp','arduino','java','jsp','javascript'], ft) >= 0
      setlocal cindent
      " Match open brace above )
      setlocal cinoptions=(0,w1,u0,:1,=2
   endif
   if index(['tcl','postscr','c','cpp','arduino','java','jsp'], ft) >= 0
      " NO autowrap while typing in source code files
      setlocal formatoptions-=t
      setlocal sw=4 ts=4
   endif
   if index(['java','jsp'], ft) >= 0
      " Ampep java settings
      setlocal sw=2 sts=2 et
      compiler mvn
      setlocal includeexpr=JspPath(v:fname)
      setlocal cinkeys-=:
   endif
   if ft ==# 'sh'
      call TextEnableCodeSnip('lua', '--LUA--', '--EOF--')
      call TextEnableCodeSnip('awk', '#AWK#', '#EOF#')
      call TextEnableCodeSnip('javascript', '/\*JS\*/', '/\*EOF\*/')
      call TextEnableCodeSnip('javascript', '#JS#', '#EOF#')
      setlocal sw=4 sts=4 et
      set iskeyword-=$
   elseif ft ==# 'vim'
      call TextEnableCodeSnip('lua', '--LUA--', '--EOF--')
   elseif ft ==# 'java'
      setlocal omnifunc=javacomplete#Complete
   elseif ft ==# 'lua'
      call TextEnableCodeSnip('c', 'cdef\[\[', '\]\]') |
      call TextEnableCodeSnip('xml', 'xml *= *\[\[', '\]\]') |
      call TextEnableCodeSnip('sh', '#SH#', '#EOF#')
      setlocal sw=3 sts=3 et
      syn match   luaFunc /\<seq\.map\>/
      syn match   luaFunc /\<seq\.filter\>/
      syn match   luaFunc /\<seq\.sort\>/
      syn match   luaFunc /\<seq\.copy\>/
      syn match   luaFunc /\<seq\.tpairs\>/
      syn match   luaFunc /\<seq\.tipairs\>/
      syn match   luaFunc /\<seq\.splice\>/
      syn match   luaFunc /\<seq\.reduce\>/
   elseif ft ==# 'jsp'
      call TextEnableCodeSnip('javascript', '<script type=.text/javascript.>', '</script>') |
   elseif ft ==# 'xml'
      call TextEnableCodeSnip('sql', '<sql>', '</sql>') |
      setlocal sw=2 ts=2 et
   elseif ft ==# 'javascript'
     compiler jshint
     setlocal formatoptions-=t
     setlocal sw=2 ts=2 et
     "setlocal cindent
     "setlocal indentexpr& " The provided indent file is hopeless
   elseif ft ==# 'python'
     setlocal sw=2 ts=2 noet
   elseif ft ==# 'css' || ft ==# 'html'
     setlocal sw=2 ts=2 et
   end
   if filereadable(findfile('_vimrc', '.;'))
      exe 'source '.fnameescape(findfile('_vimrc', '.;'))
   end
   syntax sync minlines=1000
endfunc

function! SetBufferOpts()

   call SetStl()

   let fpath = expand('<afile>:p')
   if fpath =~# '\f\/src-repo/\f'
      setlocal patchmode=.orig            " Always save original file
   else
      setlocal patchmode&
   endif

   setlocal path<
   setlocal tags<
   let fpath = expand('<afile>:p:h')
   let b:fpath = fpath
   if fpath ==# ''
      let fpath = getcwd()
   endif
   while strlen(fpath) > 3
      if ! exists('tagset') && filereadable(fpath.'/tags')
         exe 'setlocal tags^='.fpath.'/tags'
         let tagset = fpath
         if filereadable(fpath.'/amplex-trees')
            let b:ampdirs = join(readfile(fpath.'/amplex-trees'), ',')
         endif
         if filereadable(fpath.'/.gitignore')
            let b:searchroot = fpath
         endif
         if 0 && filereadable(fpath.'/cscope.out')
            if match(execute('cscope show'), fpath.'/cscope.out') < 0
               execute 'cscope add '.fpath.'/cscope.out'
            endif
         endif
         exe 'setlocal path+='.fpath
      endif
      if strlen(glob(fpath.'/include'))
         exe 'setlocal path+='.fpath.'/include'
      endif
      if strlen(glob(fpath.'/*.h'))
         exe 'setlocal path+='.fpath
      endif
      if !exists('b:GlimpsePath') && filereadable(fpath.'/.glimpse_index')
         let b:GlimpsePath = fpath
      endif
      let fpath = fnamemodify(fpath, ':h')
   endwhile
   if ! exists('tagset')
       setlocal tags^=tags,../tags
   endif
   if &omnifunc ==# ''
      setlocal omnifunc=syntaxcomplete#Complete
   endif
endfunc

" Testing
"setglobal title titlestring=%<%F%=%l/%L-%P titlelen=70
"setglobal rulerformat=%l,%c%_%t-%P

function! VarExists(s,v)
   if exists(a:v)
      return a:s
   else
      return ''
   endif
endfunction

function! Show_g_CTRLG()
   let col   = col('.')
   let vcol  = virtcol('.')
   let line  = line('.')
   let lline = line('$')
   exe 'normal $'
   let cole  = col('.')
   let vcole = virtcol('.')
   exe 'normal ' vcol . '|'

   let out_str = 'Col ' . col
   if col !=# vcol
      let out_str = out_str . '-' . vcol
   endif
   let out_str = out_str . ' of ' . cole
   if cole !=# vcole
      let out_str = out_str . '-' . vcole
   endif
   let out_str = out_str . '; Line ' . line . ' of ' . lline
   let out_str = out_str . ' (' . (line * 100 / lline) . '%)'
   let byte = line2byte(line) + col - 1
   let out_str = out_str . '; Char ' . byte
   let lbyte = line2byte(lline) + strlen(getline(lline))
   let out_str = out_str . ' of ' . lbyte . ' (' . (byte * 100 / lbyte) . '%)'
   echo out_str
endfunction
" This is _much_ faster than g<C-G> on large files. And it is more verbose
map gK :call Show_g_CTRLG()<CR>

function! Incr()
   if ! exists('g:Incr')
      let g:Incr = 0
   else
      let g:Incr = g:Incr + 1
   endif
   return g:Incr
endfunc

function! FindDir(f, d)
   let d = findfile(a:f, a:d)
   if d !=# ''
      return strpart(d, 0, len(d)-len(a:f)-1)
   endif
   return ''
endfunc

function! s:QfWinPost()
   if len(getqflist()) > 0
      cwindow | cnext | cprevious | redraw
   else
      cclose
   endif
endfunc

function! MakePrg(mkArg)
   let makeArgs=a:mkArg
   if makeArgs ==# 'jshint' || makeArgs ==# 'jslint'
      setlocal makeprg=makeArgs
      let makeArgs = '%'
   elseif makeArgs ==# 'luacheck' || (&ft ==# 'lua' && !filereadable('Makefile'))
      setlocal makeprg=luacheck\ --no-color
      let makeArgs = '%'
   elseif findfile('pom.xml', '.;') ==# '' && findfile('gulpfile.js', '.;') !=# '' && &ft ==# 'javascript'
      setlocal makeprg=gulp\ --no-color
      if makeArgs ==# ''
         let makeArgs = 'lint'
         compiler jshint
      endif
   elseif &ft ==# 'javascript'
      setlocal makeprg=jslint
      compiler jshint
      let makeArgs = '%'
   elseif &makeprg ==# 'mmvn' || &makeprg ==# 'mvn' || (exists('current_compiler') && g:current_compiler ==# 'mvn')
      setlocal makeprg=mmvn
      if makeArgs =~# '\<here\>'
         let makeArgs = substitute(makeArgs, '\<here\>', '', 'g')
         let here = 1
      endif
      if makeArgs =~# '^ *$'
         let makeArgs = 'compile'
      endif
      if ! filereadable('pom.xml') || ! exists('here')
         let pom = FindDir('pom.xml', './;')
         if pom !=# ''
             "echomsg 'makeArgs:'.makeArgs.' Pom:'.pom.' :'.split(pom, '/')[-1]
             let makeArgs = makeArgs.' -pl :'.fnameescape(split(pom, '/')[-1])
         endif
      endif
   endif
   echomsg 'make '.makeArgs.' in: '.getcwd()." with: '".&makeprg."'"
   exe 'silent make '.makeArgs
   redraw!
   call qfutil#reformat('MAKE')
   call s:QfWinPost()
   if exists('oldwd')
      exe 'cd '.fnameescape(oldwd)
   endif
endfunc
command! -nargs=* Make call MakePrg("<args>")
command! -nargs=* Mvn compiler mvn | call MakePrg("<args>")

" Ensure --remote loads adds to the jumplist
autocmd Private BufReadPost * 1

function! PrevBuf(closeThis, ...)
   if a:closeThis
      if exists('s:transientHls')
         set nohlsearch
         unlet s:transientHls
      endif
      if &buftype !=# ''
         exe 'bdelete' . (a:0 > 0 ? a:1 : '')
         return
      endif
      for win in getwininfo()
         if getwinvar(win.winnr, '&previewwindow')
            pclose
            return
         endif
      endfor
      for win in getwininfo()
         if win.quickfix
            exe 'bdelete '.win.bufnr
            return
        endif
      endfor
      for win in getwininfo()
         if win.loclist
            exe 'bdelete '.win.bufnr
            return
         endif
      endfor
   endif

   let l:curBuf = bufnr('%')
   let l:curPos = getpos('%')
   let l:ok = 0
   while curBuf > 0
      let l:lastPos = getpos('.')
      let l:lastBuf = bufnr('%')
      exe "normal \<c-o>"
      if bufnr('%') !=# l:curBuf && bufname('%') !~# '^__\|^NERD_' && &buftype ==# ''
         let l:ok = 1
         break
      endif
      let l:pos = getpos('.')
      if l:pos[1] ==# l:lastPos[1] && l:pos[2] ==# l:lastPos[2] &&
       \ l:lastBuf ==# bufnr('%')
         " We did not move, stop looping
         break
      endif
   endw
   if a:closeThis && l:ok
      exe 'bdelete' . (a:0 > 0 ? a:1 : '') l:curBuf
   endif
   if l:ok ==# 0
      " Failed, Restore old pos
      call setpos('', l:curPos)
   endif
endf

function! s:PrivBuf(name, ft)
   exe 'edit '.a:name
   setlocal buftype=nofile
   setlocal bufhidden=hide
   setlocal noswapfile
   exe 'set filetype='.a:ft
endfunc

function! SvnDiff(f)
   let f = a:f
   if f ==# ''
      let f = bufname('%')
   endif
   let f = resolve(fnamemodify(f, ':p'))
   let cd = 'cd '.shellescape(fnamemodify(f, ':h')).';'
   let fn = fnamemodify(f, ':t')

   let curbuf = bufnr('%')
   call s:PrivBuf('DIFF::'.f, 'diff')
   let tmpbuf = bufnr('%')

   let diff='svn diff -x -w '
   let git=0
   call system(cd.'git log -1')
   if v:shell_error ==# 0
      let diff='git diff -w HEAD '
      let git=1
   endif

   if bufexists(f)
      exe 'buffer '.bufnr(f)
      if &modified
         let tmp = tempname()
         exe 'write '.fnameescape(tmp)
         if git
            call system(cd.'git show HEAD:'.fn.' > '.shellescape(tmp.'.orig'))
         else
            call system(cd.'svn cat '.shellescape(fn).' > '.shellescape(tmp.'.orig'))
         endif
         let cmd = 'diff -u -w '.shellescape(tmp.'.orig').' '.shellescape(tmp).' ; echo '.shellescape(tmp).'{,.orig}'
      endif
      exe 'buffer '.curbuf
   endif
   if !exists('cmd')
      let cmd = cd.diff.shellescape(fn)
   endif
   echom "F: '".f."' CMD: '".cmd."'"
   exe 'buffer '.tmpbuf
   exe 'normal S-- DIFF: '.f
   exe 'read !'.cmd
   exe '1'
endfunc
command! -nargs=? -complete=buffer SvnDiff call SvnDiff(<q-args>)
nmap gkd :SvnDiff<CR>
nmap  ld :SvnDiff<CR>

function! SvnBlame(f)
   let f = a:f
   if f ==# ''
      let f = bufname('%')
   endif
   let f = resolve(fnamemodify(f, ':p'))
   let cd = 'cd '.shellescape(fnamemodify(f, ':h')).';'
   let fn = fnamemodify(f, ':t')
   call s:PrivBuf('BLAME::'.f, ''.&ft)

   let cmd=cd.'sh -c '.shellescape('git blame -w ''.fn.''|cut -c1-9,11-14,28,31-38,60-')
   let svninf = system(cd.'git svn info')
   if v:shell_error ==# 0
      " FIXME: Actually we should seach upward for '.git' and subtract *that* dir's URL:
      let m = matchlist(svninf, '[^\p]URL:\s*\(\p\+\).*[^\p]Repository Root:\s*\(\p\+\)')
      let fp = (len(m[2]) > 5 && 0 ==# stridx(m[1], m[2].'/trunk/')) ? strpart(m[1], len(m[2])+7).'/'.fn : fn
      let cmd=cd.'git svn blame -w '.shellescape(fp)
   else
      call system(cd.'svn info')
      if v:shell_error ==# 0
         let cmd=cd.'svn blame -x -w '.shellescape(fn)
      endif
   endif

   echom "F: '".f."' CMD: '".cmd."'"
   exe 'normal S-- BLAME: '.f
   exe 'read !'.cmd
   exe '1'
endfunc
command! -nargs=? -complete=buffer SvnBlame call SvnBlame(<q-args>)
nmap gkb :SvnBlame<CR>
nmap  lb :SvnBlame<CR>

function! SvnCommitInfo(id, ...)
   let f = a:1
   if f ==# ''
      let f = bufname('%')
   endif
   call s:PrivBuf('COMMIT::'.f, 'diff')

   let cmd='sh -c '.shellescape('git blame $0 | cut -c1-9,10-14,28-43,53-').' '
   call system('git svn info')
   if v:shell_error ==# 0
      let cmd='git svn blame '
   else
      call system('svn info')
      if v:shell_error ==# 0
         let cmd='svn blame '
      endif
   endif

   let cmd .= shellescape(fnamemodify(f, ':p'))
   echom "F: '".f."' CMD: '".cmd."'"
   exe 'normal S-- AUTH: '.f
   exe 'read !'.cmd
   exe '1'

endfunc
command! -nargs=? -complete=buffer SvnCommitInfo call SvnCommitInfo(<q-args>)
nmap gkc :SvnCommitInfo <C-R><C-W><CR>
nmap  lc :SvnCommitInfo <C-R><C-W><CR>


"
" Extra vim stuff
"
map gjh <Plug>jdocConvertHere
map gjc <Plug>jdocConvertCompact

nmap <F2> :call SetCHdr()<CR>

function! SetCHdr()
   call append(0, ['/**',
         \ ' * @file '.strpart(bufname('%'), strridx(bufname('%'), '/')+1),
         \ ' * ABSTRACT HERE << ',
         \ ' *',
         \ ' * $Id$',
         \ ' *',
         \ ' * (C) Copyright '.strftime('%Y').' Amplex, '.$USER.'@amplex.dk',
         \ ' */'])
   call append(line('$'), ['', '// vim: set sw=2 sts=2 et:'])
   normal! 5G$
   set sw=2 sts=2 et
endfunction

" From http://vim.wikia.com/wiki/VimTip857
function! TextEnableCodeSnip(filetype,start,end) abort
  let ft=toupper(a:filetype)
  let group='textGroup'.ft
  if exists('b:current_syntax')
    let s:current_syntax=b:current_syntax
    " Remove current syntax definition, as some syntax files (e.g. cpp.vim)
    " do nothing if b:current_syntax is defined.
    unlet b:current_syntax
  endif
  execute 'syntax include @'.group.' syntax/'.a:filetype.'.vim'
  try
    execute 'syntax include @'.group.' after/syntax/'.a:filetype.'.vim'
  catch
  endtry
  if exists('s:current_syntax')
    let b:current_syntax=s:current_syntax
  else
    unlet b:current_syntax
  endif
  exe  'syntax region textSnip'.ft.
  \ ' matchgroup=textSnip '.
  \ ' start="'.a:start.'" end="'.a:end.'" '.
  \ ' contains=@'.group.' containedin=ALL'
  hi link textSnip SpecialComment
endfunction

nmap gmd :Glimpse NodeType.<C-R><C-W><CR>

let vimrcdir = expand('<sfile>:h').'/.vim/macros'
func! CciPostLoad(Pattern, File)
   augroup CciAutoLoad
   exe 'autocmd BufNewFile '.a:Pattern 'source '.g:vimrcdir.'/'.a:File
       \ .' |let b:isNew = 1 |  autocmd! CciAutoLoad BufNewFile '.a:Pattern
   augroup CCIstart
   exe 'autocmd BufNewFile '.a:Pattern 'let b:autohdr = 1'
   augroup END
endfunc
call CciPostLoad('GLM::*', 'srcmgr.vim')
call CciPostLoad('GLW::*', 'srcmgr.vim')
delfunction CciPostLoad
"exe "source  '.expand('<sfile>:h').'/dot/usr/vim/'.'utils.vim'
"exe 'source  '.expand('<sfile>:h').'/dot/usr/vim/'.'newfmgr.vim'

nmap              gG      :call OpenSpec("GLW::<C-R><C-W>")<CR>
vmap              gG      :call OpenSpec("GLM::".VisVal())<CR>
command! -nargs=1 Glimpse  call OpenSpec("GLM::<args>")
command! -nargs=1 GlimpseW call OpenSpec("GLW::<args>")

func! s:TransientHls(pattern)
   if !&hlsearch
      let @/ = a:pattern
      set hlsearch
      let s:transientHls = 1
   endif
endfunc

func! s:AgSearch(pattern, wordwise)
   let sgSave = &grepprg
   let pwd = getcwd()
   if exists('b:searchroot')
      exe 'cd '.fnameescape(b:searchroot)
   endif
   let ign = filereadable('.agignore') ? ' -p .agignore --skip-vcs-ignores' : ''
   let &grepprg = 'ag'.ign.' --ignore tags --vimgrep --follow '.(a:wordwise ? '-w ' : '').(&ignorecase ? '-i ' : '')
   exe 'silent grep! '.shellescape(a:pattern, 1)
   let &grepprg = sgSave
   call histadd('cmd', 'Search'.(a:wordwise ? 'W ' : ' ').fnameescape(a:pattern))
   call s:TransientHls(a:pattern)
   call qfutil#reformat('Global: '.a:pattern, 15)
   exe 'cd '.fnameescape(pwd)
   redraw!
endfunc

func! s:GrepHereHL(term)
   call GrepHere#List(a:term)
   call s:TransientHls(len(a:term) ? a:term : @/)
   call qfutil#reformat('Grep: '.(len(a:term) ? a:term : @/), 15)
endfunc

nmap              gs      :call <SID>AgSearch("<C-R><C-W>", 1)<CR>
vmap              gs      :call <SID>AgSearch(VisVal(), 0)<CR>
command! -nargs=1 Search   call <SID>AgSearch("<args>", 0)
command! -nargs=1 SearchW  call <SID>AgSearch("<args>", 1)
nmap              qr      :call qfutil#reformat()<CR>
nnoremap <silent> qn      :<C-u>call <SID>GrepHereHL('')<CR>
nnoremap <silent> qm      :<C-u>call <SID>GrepHereHL(GrepHere#SetCword(0))<CR>
command! -count -nargs=?  Grep  call GrepHere#Grep(<count>, 'vimgrep', <q-args>)|call qfutil#reformat('Grep: '.<q-args>)
command! -bang -count -nargs=? -complete=expression BGrep 
               \ call GrepCommands#Grep(<count>, 'vimgrep<bang>', GrepCommands#Buffers(), <q-args>)|
               \ call qfutil#reformat('BufGrep: '.<q-args>)

func! CsSearch(pattern)
   execute 'cscope find c '.a:pattern
   call s:TransientHls(a:pattern)
   call qfutil#reformat('CScope: '.a:pattern, 15)
   cwindow 20
   redraw!
endfunc
nmap              lr      :call CsSearch("<C-R><C-W>")<CR>
vmap              lr      :call CsSearch(VisVal())<CR>
command! -nargs=1 Cscope   call CsSearch("<args>")
set cscopequickfix=c-

func! OpenSpec(str)
   let Str = a:str
   exe 'edit '.Str
   call histadd('cmd', 'edit '.Str)
endfunction

func! VisVal()
  let Col1 = col("'<")
  let Col2 = col("'>")
  if line("'<") !=# line("'>") | return | endif
  let Str = strpart(getline(line("'<")), Col1 - 1, Col2 - Col1 + 1)
  return substitute(Str, ' ', '.', 'g')
endfunc

func! Search(pat, wordwise)
   if a:wordwise
      let @/ = "\\<".a:pat."\\>"
   else
      let @/ = a:pat
   endif
   call feedkeys('n')
endfunc
vmap gv <Esc>:call Search(VisVal(), 0)<CR>
vmap gw <Esc>:call Search(VisVal(), 1)<CR>

command! -nargs=? SvnWeb let _ = system("svnbrowse " . expand((len("<args>")?"<args>":"%").":p") )
command! -nargs=? RemoteSend let _ = system("vim -g --remote " . expand((len("<args>")?"<args>":"%").":p") )

" Find amplex java imports
nmap gf :call GoFile("gf")<CR>
nmap gF :call GoFile("gF")<CR>
function! GoFile(cmd)
    let saveSfx = &suffixesadd
    setlocal suffixesadd=.java,.js,.jsp
    if !exists('b:ampdirs')
        exe 'normal! '.a:cmd
        let &l:suffixesadd = saveSfx
        return
    endif
    let savePath = &path
    let &l:path = &path.','.b:ampdirs
    exe 'normal! '.a:cmd
    let &l:path = savePath
    let &l:suffixesadd = saveSfx
endfunc

" For use as includeexpr in ftplugin/*.vim
function! JspPath(s)
    echomsg 'JspPath:'.a:s
    if a:s =~# '^/.*\.jsp$'
        return substitute(a:s,'^/*', '', '')
    endif
    return substitute(a:s,'\.','/','g')
endfunc

function! CaseStat()
    return &ignorecase > 0 ? 'I' : 'C'
endfunc

function! Modified()
    return &modified > 0 ? '✚ ' : ''
endfunc

function! ShowSyn()
   return 0 ==# &spell ? '' : synIDattr(synID(line('.'), col('.'), 1), 'name').' '
endfunc

function! JumpBuffers()
   let byName = {}
   let byIndex = []
   for ent in reverse(getjumplist()[0])
      let name = bufname(ent.bufnr)
      if !has_key(byName, name)
         let byIndex += [{'name': name, 'bufno': ent.bufnr, 'ix': len(byIndex)+1}]
         let byName[name] = len(byIndex)
      endif
   endfor

   if &runtimepath =~ 'fzfx'
       fzf#run({'source': map(byIndex,  {k,val -> printf('%2d %6d %s', ent.ix, ent.bufno, ent.name)}),
            \   'sink':xx})
       return
   endif

   if v:count > 0
      if len(byIndex) >= v:count
         echomsg 'Count '.v:count.' Jumps to '.byIndex[v:count-1].bufno
         execute 'buffer '.byIndex[v:count-1].bufno
      endif
      return
   endif
   echohl Special
   echo 'No Buffer Name'
   echohl None
   for ent in byIndex
      echo printf('%2d %6d %s', ent.ix, ent.bufno, ent.name)
   endfor
   let ix = input('Type number and <Enter> (empty cancels): ') + 0
   if ix > 0 && ix <= len(byIndex)
      execute 'keepjumps buffer '.byIndex[ix-1].bufno
   endif
endfunc
" Note this overrides :goto
nmap go :<C-U>call JumpBuffers()<CR>
nmap <C-G><C-O> 2go
" Remap builtin 'go'
nnoremap g<C-O> go

function! TmuxReload()
   for line in systemlist('tmux show-environment')
      if line[0] ==# '-'
         execute 'let $'.strpart(line, 1)."=''"
      else
         let prt = matchlist(line, '\([^=]\+\)=\(.*\)')
         if len(prt) > 2 && len(prt[1]) > 0
            execute 'let $'.prt[1].'="'.escape(prt[2], '\"').'"'
         endif
      endif
   endfor
endfunc
command! TmuxReload call TmuxReload()

function! MyJavaImpGenerate()
   if !filereadable($HOME.'/vim/JavaImp/amplex-trees')
      echoerr 'Error (no amplex-trees file)'
      return
   end
   let g:JavaImpPaths = join(readfile($HOME.'/vim/JavaImp/amplex-trees'), ',').','.$HOME.'/vim/JavaImp/jmplst'
   "let g:JavaImpDataDir = '/tmp/JavaImp'
   call execute('JavaImpGenerate')
endfunc

function! Menu(i)
   source $VIMRUNTIME/menu.vim
   set wildmenu
   set cpo-=<
   set wildcharm=<C-Z>
   " Shift-F4
   nmap <F16> :emenu <C-Z>
   if a:i
      echom 'You can now use shift <F4> to bring up the menu'
      "call feedkeys("\<F4>")
   end
endfunc
call Menu(0)
command! Menu call Menu(1)

setglobal statusline=%<%f%=\ %{ShowSyn()}%2*%{VimBuddy()}%*\ %([%1*%M\%*%n%R\%Y
              \%{VarExists(',GZ','b:zipflag')},%1*%{CaseStat()}%*]%)\ %02c%V(%02B)C\ %3l/%LL\ %P

colorscheme flemming
hi User1          term=reverse,bold cterm=NONE,bold ctermfg=red  ctermbg=grey gui=bold guifg=red guibg=gray
hi User2          term=reverse      cterm=NONE      ctermfg=blue ctermbg=grey guifg=darkblue guibg=gray
"hi StatusLineNC   term=reverse      cterm=NONE ctermbg=darkgrey  ctermfg=white gui=NONE guibg=grey
"hi StatusLine     term=reverse      cterm=NONE ctermbg=grey  ctermfg=black    gui=NONE guibg=darkgrey
let s:statusline = &statusline
function! SetStl()
   let &l:statusline = s:statusline
endfunc
command! Stl call SetStl()
Stl

" OK. So here is the infamous VimBuddy. You can delete it, if it is not
" referenced from your 'statusline'
function! VimBuddy()
    " Take a copy for others to see the messages
    if ! exists('g:actual_curbuf')
       return ':-)'
    endif
    if ! exists('s:vimbuddy_msg')
        let s:vimbuddy_msg = v:statusmsg
    endif
    if ! exists('s:vimbuddy_warn')
        let s:vimbuddy_warn = v:warningmsg
    endif
    if ! exists('s:vimbuddy_err')
        let s:vimbuddy_err = v:errmsg
    endif
    if ! exists('s:vimbuddy_onemore')
        let s:vimbuddy_onemore = ''
    endif

    if g:actual_curbuf !=# bufnr('%')
        " Not my buffer, sleeping
        return '|-o'
    elseif s:vimbuddy_err !=# v:errmsg
        let v:errmsg = v:errmsg . ' '
        let s:vimbuddy_err = v:errmsg
        return ':-('
    elseif s:vimbuddy_warn !=# v:warningmsg
        let v:warningmsg = v:warningmsg . ' '
        let s:vimbuddy_warn = v:warningmsg
        return '(-:'
    elseif s:vimbuddy_msg !=# v:statusmsg
        let v:statusmsg = v:statusmsg . ' '
        let s:vimbuddy_msg = v:statusmsg
        let test = matchstr(v:statusmsg, 'lines *$')
        let num = substitute(v:statusmsg, '^\([0-9]*\).*', '\1', '') + 0
        " How impressed should we be
        if test !=# '' && num > 20
            let str = ':-O'
        elseif test !=# '' && num
            let str = ':-o'
        else
            let str = ':-/'
        endif
        let s:vimbuddy_onemore = str
        return str
    elseif s:vimbuddy_onemore !=# ''
      let str = s:vimbuddy_onemore
      let s:vimbuddy_onemore = ''
      return str
    endif

    if ! exists('b:lastcol')
        let b:lastcol = col('.')
        let b:linechange = 0
        let b:lastlineno = line('.')
    endif
    let num = b:lastcol - col('.')
    let b:lastcol = col('.')
    if num !=# 0 && b:lastlineno ==# line('.')
        " Let VimBuddy rotate his nose
        let b:linechange += 1
        return ':' . ['/', '-', '\', '|'][b:linechange % 4] . ')'
    endif
    let b:lastlineno = line('.')
    let b:linechange = 0

    " Happiness is my favourite mood
    return ':-)'
endfunction

" au! CursorHold * redraw!

if exists('load_less')
   setglobal directory=
   setglobal statusline=%3l/%LL\ %P\ %o/%{line2byte(line(\"$\")+1)-1}\ %=%<%f%a
   setglobal cmdheight=1
endif

call SetBufferOpts() " Why is this needed ?? it is mapped to BufNewFile!!
let loaded_explorer=1 " Don't want plugin/explorer.vim

let g:jsx_ext_required = 1

"let g:changes_vcs_check = 1
"let g:changes_linehi_diff = 0 " Experimental!
"let g:changes_sign_text_utf8 = 0
"nmap zv :ToggleChangeView<CR>
let g:quickfixsigns_classes = ['qfl', 'vcsdiff', 'vcsmerge']
nmap zv :QuickfixsignsToggle<CR>
nmap qd :Quickfixsignsecho<CR>
highlight SignColumn cterm=NONE ctermbg=187
let g:quickfixsigns#vcsdiff#extra_args_git = '-w'
let g:quickfixsigns#vcsdiff#extra_args_svn = '-x -w'

let g:airline_powerline_fonts = 1
let g:airline_theme = 'dark' " 'flemming', 'distinguished'
let g:airline_mode_map = {'__':'-','n':'N','i':'I','R':'R','c':'C','v':'V','V':'V','':'V','s':'S','S':'S','':'S',}
let g:airline_section_y = '%{ShowSyn()}%{VimBuddy()} '.
         \                '[%#__accent_red#%{Modified()}%#airline_y#%n,%#airline_y_bold#%{CaseStat()}%#airline_y#,%02B]'
let g:airline#extensions#whitespace#enabled = 0
function! AirlineInit()
  let g:airline_section_c = substitute(g:airline_section_c, '%m','','')
endfunction
augroup Private
    autocmd User AirlineAfterInit call AirlineInit()
augroup END
nmap zl :AirlineToggle<CR>
nmap z; :AirlineToggleWhitespace<CR>
let g:airline_theme_patch_func = 'AirlineThemePatch'
function! AirlineThemePatch(palette)
 if g:airline_theme ==# 'dark'
   for colors in values(a:palette.inactive)
     let colors[2] = 245
   endfor
 endif
endfunction

if &wildoptions =~# 'pum'
    cnoremap <expr> <Right> wildmenumode() ? "\<Down>"  : "\<Right>"
    cnoremap <expr> <Left>  wildmenumode() ? "\<Up>"    : "\<Left>"
    cnoremap <expr> <Up>    wildmenumode() ? "\<Left>"  : "\<Up>"
    cnoremap <expr> <Down>  wildmenumode() ? "\<Right>" : "\<Down>"
endif

function! s:get_visual_selection()
    " Why is this not a built-in Vim script function?!
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    return join(lines, "\n")
endfunction

function! s:formatForSQL()
    let text = s:get_visual_selection()
    let text = substitute(text, '\v(^|\n)[^"]*\"', '\n', 'g')    " Start
    let text = substitute(text, '\v\"[^"]*(\n|$)', '\n', 'g')    " End
    let text = substitute(text, '\v\"\+(\i+)\+\"', ' :\1 ', 'g') " :Param
    let @* = text
endfunc
command! -bar -range SqlCopy call <SID>formatForSQL()
vmap lsq :call <SID>formatForSQL()<CR>

function! s:ShowHTML() range
    execute "'<,'> TOhtml"
    silent !open %:p
    sleep 2
    silent !del %:p
    q!
endfunction
command! -bar -range ShowHTML call <SID>ShowHTML()

let g:airline#extensions#tmuxline#enabled = 0
let g:tmuxline_theme = 'powerline'
let g:tmuxline_preset = {
      \'a'       : '[#(uname -n | cut -d. -f1 | tr a-z A-Z)]',
      \'win'     : ['#F', '#W'],
      \'cwin'    : ['#F', '#W'],
      \'x'       : '#S',
      \'y'       : '#{?mouse,MSE,}',
      \'z'       : '#{cpu_percentage}'}

let g:easytags_async = 1
let g:easytags_auto_highlight = 0
let g:easytags_on_cursorhold = 0
let g:easytags_resolve_links = 0
let g:easytags_dynamic_files = 0
let g:easytags_events = ['BufWritePost']
call xolox#easytags#filetypes#add_mapping('lua', 'MYLUA')

let g:brep#use_bufdo = 1   " Force searching unloaded buffers
nmap              gb      :call brep#Grep("<C-R><C-W>", 1)<CR>
vmap              gb      :call brep#Grep(VisVal(), 0)<CR>

let g:neomake_open_list = 2
let g:neomake_javascript_enabled_makers = [ 'jslint' ]
let g:neomake_lua_enabled_makers        = [ 'luacheck' ]
nmap ln :lnext<CR>
nmap <M-C-N> :lnext<CR>
nmap lp :lprev<CR>
nmap <M-C-P> :lprev<CR>
nmap lc :ll<CR>
nmap ll :lwindow<CR>
nmap lm :write\|Neomake<CR>
augroup Private
    autocmd User NeomakeJobFinished silent! lrewind
augroup END

let g:html_number_lines = 0

let s:SRC = $HOME.'/amplex'
let g:javacall_locations = [ ['/ampcom/', {'prefix':'dk.amplex'}],
                           \ ['pom.xml',  {'prefix':'dk.amplex', 'ignore':'/ampcom/'}] ]
nmap <leader>j] <Plug>JCallerJump
nmap <leader>jh <Plug>JCallerOpen
nmap <leader>jc <Plug>JCallerClear
let g:JavaComplete_ImportSortType = 'packageName'
nmap <Leader>jS <Plug>(JavaComplete-Imports-RemoveUnused)<Plug>(JavaComplete-Imports-SortImports)

" Ctrl-P

" vim-lsc
" let g:lsc_server_commands = {'java': $HOME.'/stuff/java-language-server/dist/lang_server_mac.sh'}

" Workaround for https://github.com/neovim/neovim/issues/12023
inoremap <C-C> <C-V>
inoremap <C-V> <C-R>*
inoremap <M-v> <C-R>*
inoremap <M-c> <C-R>*

" Fugitive
nmap gy :Git log --pretty=oneline %<CR>
nmap gG :Git<CR>

" NerdTree
function! NerdTreeFocusToggle()
    if g:NERDTree.IsOpen()
        call g:NERDTree.Close()
    else
        let buf = expand("%")
        let path = expand("%:h")
        exe "NERDTreeToggleVCS" fnameescape(path)
        exe "NERDTreeFind" fnameescape(buf)
    endif
endfunction
nmap <F4> :call NerdTreeFocusToggle()<CR>

" Mundo
nmap <F5> :MundoToggle<CR>
let g:mundo_preview_bottom=1
let g:mundo_preview_Height=20

" fzf
nmap g/ :History/<CR>
nmap g: :History:<CR>
"nmap F  :Buffers<CR>
nmap F  :files<CR>
let $BAT_THEME = "ansi-light"
let g:fzf_preview_window = ['up', 'ctrl-/']
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.8 } }


" echo "DONE sourcing"

" vim: set sw=4 sts=4 et:
