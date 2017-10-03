" vim: set ts=3 sw=3 et:
"""
""" %Z%%E% %U%, %I% %P%
""" (C) Copyright 2000 CCI-Europe. Author : fma
"""
""" Revision History """
""" End of Revisions """
"
" My .vimrc file
"
set nocompatible " TODO: Why did the default change for 7.3 vs 7.2
if has("win32")
   " Use CCI standard setup. This happens automatically on UNIX
   if filereadable($VIM . "/vimrc")
      source $VIM/vimrc
   endif
endif

let g:loaded_quickfixsigns = 99 " Disable for now
execute pathogen#infect()

syntax on
filetype plugin indent on
augroup filetypedetect
autocmd BufEnter *.r set ft=xdefaults
autocmd BufEnter .gitignore set ft=config
autocmd BufReadPost,StdinReadPost * call SetFileTypeOnLoad()
augroup END

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

if has("win32")
   behave xterm
   setglobal directory=C:/temp/preserve//   " Home of the swap files_
   if filereadable('C:\Programs\NT_SFU\Shell\grep.EXE')
      setglobal grepprg=grep\ -n            " Use POSIX grep if available
   endif

   " Let VIM know about VisualC++ include files
   if exists("$include")
      let more = substitute($include, ';', ',', 'g')
      let more = substitute(more, ' ', '\\\\\\ ', 'g')
      execute "setglobal path+=" . more
      let g:incdirs = g:incdirs.",".more

      let more = substitute($include, ';', '\\\\\\tags,', 'g')
      execute "setglobal tags+=" . substitute(more, ' ', '\\\\\\ ', 'g') . '\\tags'
      unlet more
   endif

   if exists("$SCCSHOME")
      " Can not handle '/' to '\' conversion otherwise
      let $SCCSHOME = $SCCSHOME . "/"
   endif

   if has("gui_running")
      setglobal guifont=Courier_New:h9
      " System menu and quick minimize
      map <M-Space> :simalt ~<CR>
      map <M-n> :simalt ~n<CR>
      " Size the GUI window. Delay positioning until window is created
      setglobal lines=50
      setglobal columns=82
      augroup AutoPos
      autocmd BufEnter * winp 200 50 | autocmd! AutoPos
      augroup END
   endif
else
   if (&term == "cygwin") " This seem to have some quirks, work around some
      setglobal directory=/var/preserve/
      " Make <End> work
      exe "setglobal t_@7=\e[4~"
      " Make <Home> work
      exe "setglobal t_kh=\e[1~"
   else
      setglobal directory=/var/preserve//
      setglobal grepprg=ag\ --vimgrep\ --follow\ $*
      set grepformat=%f:%l:%c:%m
      if has("gui_running")
         let &guifont="Bitstream Vera Sans Mono 8"
      else
         " Uncomment line below to use :emenu. Adds ~1 second to startup time
         " source $VIMRUNTIME/menu.vim

         " Make <End> work - Some options cannot be assigned to with 'let'
         "exe 'setglobal t_@7=\<Esc>OF'

         " Must be _very_ slow to handle triple clicks
         setglobal mousetime=1500
         "if &ttymouse == "xterm2"
         "   " The xterm2 mode will flood us with messages
         "   setglobal ttymouse=xterm
         "endif
         if &term =~ '\v^(screen|tmux|xterm-)'
           setglobal ttymouse=xterm2
            if &term =~ '\v^(screen|tmux)'
               execute "set <xUp>=\e[1;*A"
               execute "set <xDown>=\e[1;*B"
               execute "set <xRight>=\e[1;*C"
               execute "set <xLeft>=\e[1;*D"
            endif
         endif

         if has('nvim')
            set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20
         else
            " Save and restore the "shell" screen on enter and exit
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

         exe "setglobal t_Co=16"
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

if has("gui_running")
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
setglobal wildmenu                   " Show completion matches on statusline
setglobal wildmode=list:longest,full
setglobal complete=.,w,b,u,d         " The ,t,i from the default was too much, now ,d
setglobal isfname-==                 " No = allows 'gf' in File=<Path> Constructs
setglobal shiftwidth=4
setglobal softtabstop=4
setglobal number
setlocal  number
setglobal expandtab
setglobal spelllang=en_us
setglobal equalprg=csb
setglobal visualbell
setglobal printfont=:h7.5
setglobal printoptions=number:y,duplex:off,left:5mm,top:5mm,bottom:5mm,right:5mm
setglobal virtualedit=block
setglobal noignorecase
setglobal smartcase
setglobal nofoldenable

let c_gnu = 1
let c_no_curly_error = 1
"let &errorformat = 

" Disaster prevention
vmap u <Esc>
vmap U <Esc>
vnoremap gu u
vnoremap gU U

" For running edit-compile-edit (quickfix)
nmap gn :cnext<CR>
nmap gl :clist<CR>
nmap gc :cc<CR>
nmap gp :cprevious<CR>
nmap gm :Make<CR>

" Various utility keys
nmap (     :bprev<CR>
nmap )     :bnext<CR>
nmap F     :files<CR>
"nmap Q     :bdelete<CR>
nmap !Q    :bwipeout!<CR>
nmap Q     :call PrevBuf(1)<CR>
nmap gQ    :call PrevBuf(0)<CR>
"nmap !Q    :call PrevBuf(1,"!")<CR>
nmap [f    :bunload<CR>
nmap zx    :call ToggleOpt("hlsearch")<CR>
nmap zs    :call ToggleOpt("spell")<CR>
nmap zn    :call ToggleOpt("number")<CR>
nmap zf    :call ToggleOpt("foldenable")<CR>
nmap zc    :call ToggleOpt("ignorecase")<CR>
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

function! ToggleOpt(opt)
    exe "set inv".a:opt
    echo "Option '".a:opt."' : ".eval("&".a:opt)
endfunction

" These seem to be suitable for hitting all keys in mapping within timeout
setglobal timeoutlen=500
setglobal ttimeoutlen=50

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
nmap <C-X><C-]>   :ptag <C-R><C-W><CR>
nmap <C-X><Right> :ptnext<CR>
nmap <C-X><Left>  :ptprevious<CR>
nmap <C-X><Down>  :ppop<CR>
nmap <C-X><Up>    :ptag<CR>
nmap <C-X>x       :pclose<CR>

" Some coloring. These are _my_ preferences
hi NonText                                     ctermfg=lightgray
hi Visual                           cterm=Inverse ctermfg=grey ctermbg=black

if &term == "ansi" || &term == "console" || &term == "linux"
   setglobal background=dark
   hi statusLine ctermfg=black
   hi statusLineNC ctermfg=black ctermbg=yellow
endif

function! Tjump(tag)
   let tagnm = split(a:tag, ':')
   exe 'tjump '.tagnm[0]
   if len(tagnm) > 1
      exe tagnm[1]
   end
endfunction

" Use :T instead of :ta to see file names in ^D complete-lists
command! -complete=tag_listfiles -nargs=1 T call Tjump("<args>")|
                                           \call histadd("cmd", "T <args>")

" File type dependent settings
augroup Private
   autocmd BufReadPost * call SetBufferOpts()
   autocmd BufNewFile  * call SetBufferOpts()
   autocmd BufNewFile  * call SetBufferOpts()
   autocmd FileType    * call SetFileTypeOpts()

   " Handle global (non bufferspecific) options
   autocmd BufEnter * call BufEnterGlobalOpts()      

   autocmd InsertEnter * call system("tmux set mouse off")
   autocmd InsertLeave * call system("tmux set mouse on")
   if has('nvim')
      function! YankToClip(event)
         let text = a:event.regcontents[:]
         if text[-1] == ''
            let text = text[:-2]
         end
         if a:event.operator == 'y' && len(text) > 0 
            call system(has('mac') ? "pbcopy" : "lemonade copy", text)
         end
      endfunc

      autocmd FocusGained  * let @" = system(has('mac') ? "pbpaste" : "lemonade paste") 
      autocmd TextYankPost * call YankToClip(v:event)
   end
augroup end

function! BufEnterGlobalOpts()
   " Avoid '#-in-1.-column' problem with cindent & smartindent
   let ft = &filetype
   if ft=='c' || ft=='cpp' || ft=='arduino'
      inoremap # #
      " Dont highligh this as an error
      hi link cCommentStartError Comment
   else
      inoremap # X<BS>#
   endif
   if ft == 'java'
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

endfunc

function! SetFileTypeOnLoad()
   if (!did_filetype() || tolower(&ft) == "conf") && expand("<amatch>") !~ g:ft_ignore_pat
      let line1 = tolower(getline(1))
      if line1 =~ "lua"
         setlocal filetype=lua
      elseif line1 =~ "node"
         setlocal filetype=javascript
      endif
  endif
endfunc
let g:used_javascript_libs = 'underscore,angularjs,jquery'

function! SetFileTypeOpts()
   let ft = &filetype
   " echomsg 'FILETYPE: '.ft
   if index(["tcl","poststr"], ft) >= 0
      setlocal nocindent smartindent
      inoremap # X<BS>#
   else
      inoremap # #
   endif
   if index(["c","cpp","arduino","java","jsp"], ft) >= 0
      setlocal cindent
      " Match open brace above )
      setlocal cinoptions=(0,w1,u0,:1,=2
   endif
   if index(["tcl","postscr","c","cpp","arduino","java","jsp"], ft) >= 0
      " NO autowrap while typing in source code files
      setlocal formatoptions-=t
      setlocal sw=4 ts=4
   endif
   if index(["java","jsp"], ft) >= 0
      " Ampep java settings
      setlocal sw=2 ts=2 et
      compiler mvn
      setlocal includeexpr=JspPath(v:fname)
      setlocal cinkeys-=:
   endif
   if ft == "sh"
      call TextEnableCodeSnip('lua', '--LUA--', '--EOF--') 
      call TextEnableCodeSnip('awk', '#AWK#', '#EOF#')
      call TextEnableCodeSnip('javascript', '/\*JS\*/', '/\*EOF\*/') 
      call TextEnableCodeSnip('javascript', '#JS#', '#EOF#') 
      setlocal sw=4 ts=4 et
   elseif ft == "java"
      call TextEnableCodeSnip('sql', '--UA--', '--EOF--') |
   elseif ft == "lua"
      call TextEnableCodeSnip('c', 'cdef\[\[', '\]\]') |
      call TextEnableCodeSnip('xml', 'xml *= *\[\[', '\]\]') |
      setlocal sw=3 ts=3 et
      syn match   luaFunc /\<seq\.map\>/
      syn match   luaFunc /\<seq\.filter\>/
      syn match   luaFunc /\<seq\.sort\>/
      syn match   luaFunc /\<seq\.copy\>/
      syn match   luaFunc /\<seq\.tpairs\>/
      syn match   luaFunc /\<seq\.tipairs\>/
      syn match   luaFunc /\<seq\.splice\>/
      syn match   luaFunc /\<seq\.reduce\>/
   elseif ft == "jsp"
      call TextEnableCodeSnip('javascript', '<script type=.text/javascript.>', '</script>') |
   elseif ft == "xml"
      call TextEnableCodeSnip('sql', '<sql>', '</sql>') |
      setlocal sw=2 ts=2 et
   elseif ft == "javascript"
     compiler jshint
     setlocal formatoptions-=t
     setlocal sw=2 ts=2 et
   elseif ft == "python"
     setlocal sw=2 ts=2 noet
   end
   if filereadable(findfile("_vimrc", ".;"))
      exe "source ".fnameescape(findfile("_vimrc", ".;"))
   end
endfunc

function! SetBufferOpts()

   call SetStl()

   let fpath = expand("<afile>:p")
   if fpath =~ '\f\/src-repo/\f'
      setlocal patchmode=.orig            " Always save original file
   else
      setlocal patchmode&
   endif

   setlocal path<
   setlocal tags<
   let fpath = expand("<afile>:p:h")
   let b:fpath = fpath
   if fpath == ""
      let fpath = getcwd()
   endif
   while strlen(fpath) > 3
      if ! exists("tagset") && filereadable(fpath."/tags")
         exe "setlocal tags+=".fpath."/tags"
         let tagset = 1
         if filereadable(fpath."/amplex-trees")
            let b:ampdirs = join(readfile(fpath."/amplex-trees"), ",")
         endif
         if filereadable(fpath."/.gitignore")
            let b:searchroot = fpath
         endif
         exe "setlocal path+=".fpath
      endif
      if strlen(glob(fpath."/include"))
         exe "setlocal path+=".fpath."/include"
      endif
      if strlen(glob(fpath."/*.h"))
         exe "setlocal path+=".fpath
      endif
      if !exists("b:GlimpsePath") && filereadable(fpath."/.glimpse_index")
         let b:GlimpsePath = fpath
      endif
      let fpath = fnamemodify(fpath, ":h")
   endwhile
   if ! exists("tagset")
       setlocal tags+=tags,../tags
   endif
endfunc

" Testing
"setglobal title titlestring=%<%F%=%l/%L-%P titlelen=70
"setglobal rulerformat=%l,%c%_%t-%P

function! VarExists(s,v)
   if exists(a:v)
      return a:s
   else
      return ""
   endif
endfunction

function! Show_g_CTRLG()
   let col   = col(".")
   let vcol  = virtcol(".")
   let line  = line(".")
   let lline = line("$")
   exe "normal $"
   let cole  = col(".")
   let vcole = virtcol(".")
   exe "normal " vcol . "|"

   let out_str = "Col " . col
   if col != vcol
      let out_str = out_str . "-" . vcol
   endif
   let out_str = out_str . " of " . cole
   if cole != vcole
      let out_str = out_str . "-" . vcole
   endif
   let out_str = out_str . "; Line " . line . " of " . lline
   let out_str = out_str . " (" . (line * 100 / lline) . "%)"
   let byte = line2byte(line) + col - 1
   let out_str = out_str . "; Char " . byte
   let lbyte = line2byte(lline) + strlen(getline(lline))
   let out_str = out_str . " of " . lbyte . " (" . (byte * 100 / lbyte) . "%)"
   echo out_str
endfunction
" This is _much_ faster than g<C-G> on large files. And it is more verbose
map gK :call Show_g_CTRLG()<CR>

function! Incr()
   if ! exists("g:Incr")
      let g:Incr = 0
   else 
      let g:Incr = g:Incr + 1
   endif
   return g:Incr
endfunc

function! FindDir(f, d)
   let d = findfile(a:f, a:d)
   if d != ""
      return strpart(d, 0, len(d)-len(a:f)-1)
   endif
   return ""
endfunc

function! MakePrg(mkArg)
   let makeArgs=a:mkArg
   if makeArgs == 'jshint'
      setlocal makeprg=jshint
      let makeArgs = '%'
   elseif makeArgs == 'lualint' || (&ft == 'lua' && !filereadable('Makefile'))
      setlocal makeprg=lualint
      let makeArgs = '%'
   elseif findfile("gulpfile.js", ".;") != "" && &ft == 'javascript' 
      setlocal makeprg="gulp"
      if makeArgs == ""
         let makeArgs = 'lint'
      endif
   elseif &ft == 'javascript' 
      setlocal makeprg=jshint
      let makeArgs = '%'
   elseif &makeprg == "mmvn" || &makeprg == "mvn" || (exists("current_compiler") && current_compiler == "mvn")
      setlocal makeprg=mmvn
      if makeArgs =~ '\<here\>' 
         let makeArgs = substitute(makeArgs, '\<here\>', '', 'g')
         let here = 1
      endif
      if makeArgs =~ ' *'
         let makeArgs = "compile"
      endif
      if ! filereadable("pom.xml") || ! exists("here")
         let pom = FindDir("pom.xml", "./;")
         if pom != ""
            let oldwd = getcwd()
            exe "cd ".fnameescape(pom)
         endif
      endif
   endif
   echomsg "make ".makeArgs." in: ".getcwd()." with: '".&makeprg."'"
   exe "silent make ".makeArgs
   redraw!
   if exists("oldwd")
      exe "cd ".fnameescape(oldwd)
   endif
endfunc
command! -nargs=* Make call MakePrg("<args>")
command! -nargs=* Mvn compiler mvn | call MakePrg("<args>")
function! MakePrgPost()
   if len(getqflist()) > 0
      cwindow | cnext | cprevious | redraw
   else
      cclose
   endif
endfunc
au! QuickfixCmdPost make call MakePrgPost()

" Ensure --remote loads adds to the jumplist
autocmd Private BufReadPost * 1

function! PrevBuf(closeThis, ...)


   if a:closeThis && &buftype != ""
      exe "bdelete" . (a:0 > 0 ? a:1 : "")
      return
   elseif a:closeThis && getbufvar(winbufnr(winnr('$')), 'current_syntax') == 'qf'
      exe "bdelete " . winbufnr(winnr('$'))
      return
   endif

   let l:curBuf = bufnr("%")
   let l:curPos = getpos("%")
   let l:ok = 0
   while curBuf > 0
      let l:lastPos = getpos(".")
      let l:lastBuf = bufnr("%")
      exe "normal \<c-o>"
      if bufnr("%") != l:curBuf && bufname("%") !~ "^__" && &buftype == ""
         let l:ok = 1
         break
      endif
      let l:pos = getpos(".")
      if l:pos[1] == l:lastPos[1] && l:pos[2] == l:lastPos[2] && 
       \ l:lastBuf == bufnr("%")
         " We did not move, stop looping
         break
      endif
   endw
   if a:closeThis && l:ok
      exe "bdelete" . (a:0 > 0 ? a:1 : "") l:curBuf
   endif
   if l:ok == 0
      " Failed, Restore old pos
      let l:curPos[0] = l:curBuf
      call setpos("", l:curPos)
   endif
endf

function! s:PrivBuf(name, ft)
   exe "edit ".a:name
   setlocal buftype=nofile
   setlocal bufhidden=hide
   setlocal noswapfile
   exe "set filetype=".a:ft
endfunc

function! SvnDiff(f)
   let f = a:f
   if f == ""
      let f = bufname("%")
   endif
   let f = resolve(fnamemodify(f, ":p"))
   let cd = "cd ".shellescape(fnamemodify(f, ":h")).";"
   let fn = fnamemodify(f, ":t")

   let curbuf = bufnr("%")
   call s:PrivBuf("DIFF::".f, "diff")
   let tmpbuf = bufnr("%")

   let diff="svn diff "
   let git=0
   call system(cd."git log -1")
   if v:shell_error == 0
      let diff="git diff HEAD "
      let git=1
   endif
  
   if bufexists(f)
      exe "buffer ".bufnr(f) 
      if &modified
         let tmp = tempname()
         exe "write ".fnameescape(tmp)
         if git
            call system(cd."git show HEAD:".fn." > ".shellescape(tmp.".orig"))
         else
            call system(cd."svn cat ".shellescape(fn)." > ".shellescape(tmp.".orig"))
         endif
         let cmd = "diff -u ".shellescape(tmp.".orig")." ".shellescape(tmp)." ; rm ".shellescape(tmp)."{,.orig}"
      endif
      exe "buffer ".curbuf
   endif
   if !exists("cmd")
      let cmd = cd.diff.shellescape(fn)
   endif
   " echom "F: '".f."' CMD: '".cmd."'"
   exe "buffer ".tmpbuf
   exe "normal S-- DIFF: ".f
   exe "read !".cmd 
   exe "1"
endfunc
command! -nargs=? -complete=buffer SvnDiff call SvnDiff(<q-args>)
nmap gkd :SvnDiff<CR>

function! SvnBlame(f)
   let f = a:f
   if f == ""
      let f = bufname("%")
   endif
   let f = resolve(fnamemodify(f, ":p"))
   let cd = "cd ".shellescape(fnamemodify(f, ":h")).";"
   let fn = fnamemodify(f, ":t")
   call s:PrivBuf("BLAME::".f, "".&ft)
  
   let cmd=cd."sh -c ".shellescape("git annotate '".fn."'|cut -c3-9,11-14,26-42,52-|expand -1|sed 's/[0-9]*)//'")
   call system("git svn info")
   if v:shell_error == 0
      let cmd="git svn blame ".shellescape(f)
   else
      call system("svn info")
      if v:shell_error == 0
         let cmd=cd."svn blame ".shellescape(fn)
      endif
   endif
  
   echom "F: '".f."' CMD: '".cmd."'"
   exe "normal S-- BLAME: ".f
   exe "read !".cmd 
   exe "1"
endfunc
command! -nargs=? -complete=buffer SvnBlame call SvnBlame(<q-args>)
nmap gkb :SvnBlame<CR>

function! SvnCommitInfo(id, ...)
   let f = a:1
   if f == ""
      let f = bufname("%")
   endif
   call s:PrivBuf("COMMIT::".f, "diff")

   let cmd="sh -c ".shellescape('git blame $0 | cut -c1-9,10-14,28-43,53-')." "
   call system("git svn info")
   if v:shell_error == 0
      let cmd="git svn blame "
   else
      call system("svn info")
      if v:shell_error == 0
         let cmd="svn blame "
      endif
   endif
  
   let cmd .= shellescape(fnamemodify(f, ":p"))
   echom "F: '".f."' CMD: '".cmd."'"
   exe "normal S-- AUTH: ".f
   exe "read !".cmd 
   exe "1"

endfunc
command! -nargs=? -complete=buffer SvnCommitInfo call SvnCommitInfo(<q-args>)
nmap gkc :SvnCommitInfo <C-R><C-W><CR>


"
" Extra vim stuff
" 
map gjh <Plug>jdocConvertHere
map gjc <Plug>jdocConvertCompact

nmap <F2> :call SetCHdr()<CR>

function! SetCHdr()
   call append(0, ["/**",
         \ " * @file ".strpart(bufname("%"), strridx(bufname("%"), "/")+1), 
         \ " * ABSTRACT HERE << ",
         \ " *",
         \ " * $Id$",
         \ " *",
         \ " * (C) Copyright ".strftime("%Y")." Amplex, ".$USER."@amplex.dk",
         \ " */"])
   call append(line('$'), ["", "// vim: set sw=3 sts=3 et:"])
   normal 5G$ 
   if &filetype == "c"
       set sw=3 sts=3 et
   endif
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

let vimrcdir = expand("<sfile>:h")."/.vim/macros"
func! CciPostLoad(Pattern, File)
   augroup CciAutoLoad
   exe "autocmd BufNewFile ".a:Pattern "source ".g:vimrcdir."/".a:File
       \ ." |let b:isNew = 1 |  autocmd! CciAutoLoad BufNewFile ".a:Pattern
   augroup CCIstart
   exe "autocmd BufNewFile ".a:Pattern "let b:autohdr = 1"
   augroup END
endfunc
call CciPostLoad("GLM::*", "srcmgr.vim")
call CciPostLoad("GLW::*", "srcmgr.vim")
delfunction CciPostLoad
"exe "source  ".expand("<sfile>:h")."/dot/usr/vim/"."utils.vim"
"exe "source  ".expand("<sfile>:h")."/dot/usr/vim/"."newfmgr.vim"

nmap              gG      :call OpenSpec("GLW::<C-R><C-W>")<CR>
vmap              gG      :call OpenSpec("GLM::".VisVal())<CR>
command! -nargs=1 Glimpse  call OpenSpec("GLM::<args>")
command! -nargs=1 GlimpseW call OpenSpec("GLW::<args>")

func! AgSearch(pattern, wordwise)
   let sgSave = &grepprg
   let pwd = getcwd()
   if exists("b:searchroot")
      exe "cd ".fnameescape(b:searchroot)
   endif
   let ign = filereadable(".agignore") ? " -U -p .agignore" : ""
   let &grepprg = 'ag'.ign.' --vimgrep --follow '.(a:wordwise ? '-w ' : '').(&ignorecase ? '-i ' : '')
   exe "silent grep! ".shellescape(a:pattern, 1)
   cwindow 30
   let &grepprg = sgSave
   call histadd("cmd", "Search".(a:wordwise ? 'W ' : ' ').fnameescape(a:pattern))
   exe "cd ".fnameescape(pwd)
   redraw!
endfunc
nmap              gs      :call AgSearch("<C-R><C-W>", 1)<CR>
vmap              gs      :call AgSearch(VisVal(), 0)<CR>
command! -nargs=1 Search   call AgSearch("<args>", 0)
command! -nargs=1 SearchW  call AgSearch("<args>", 1)
nmap              gb      :Bgrep <C-R><C-W><CR>
vmap              gb      <Esc>:exe  "Bgrep ".fnameescape(VisVal())<CR>

func! OpenSpec(str)
   let Str = a:str
   exe "edit ".Str
   call histadd("cmd", "edit ".Str)
endfunction

func! VisVal()
  let Col1 = col("'<")  
  let Col2 = col("'>")  
  if line("'<") != line("'>") | return | endif
  let Str = strpart(getline(line("'<")), Col1 - 1, Col2 - Col1 + 1)
  return substitute(Str, " ", ".", "g")
endfunc

func! Search(pat, wordwise)
   if a:wordwise
      let @/ = "\\<".a:pat."\\>"
   else
      let @/ = a:pat
   endif
   call feedkeys("n")
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
    if !exists("b:ampdirs") 
        exe "normal! ".a:cmd
        let &l:suffixesadd = saveSfx
        return
    endif
    let savePath = &path
    let &l:path = &path.",".b:ampdirs
    exe "normal! ".a:cmd
    let &l:path = savePath
    let &l:suffixesadd = saveSfx
endfunc

" For use as includeexpr in ftplugin/*.vim
function! JspPath(s)
    echomsg "JspPath:".a:s
    if a:s =~ '^/.*\.jsp$'
        return substitute(a:s,'^/*', '', '')
    endif
    return substitute(a:s,'\.','/','g')
endfunc

function! CaseStat()
    return &ignorecase > 0 ? "I" : "C"
endfunc

function! ShowSyn()
   if 0 == &spell
      return ""
   endif
   return synIDattr(synID(line("."), col("."), 1), "name")." "
endfunc

function! JumpBuffers()
   let jumptxt = ""
   redir! => jumptxt
   silent jumps
   redir END
   let byName = {}
   let byIndex = []
   for line in reverse(split(jumptxt, '\n'))
      let name = strpart(line, 16)
      let bufno = bufnr(name)
      if len(name) > 0 && bufno >= 0 && !has_key(byName, name)
         let byIndex += [{'name': name, 'bufno': bufno, 'ix': len(byIndex)+1}]
         let byName[name] = len(byIndex)
      endif
   endfor
   if v:count > 0
      if len(byIndex) >= v:count
         echomsg "Count ".v:count." Jumps to ".byIndex[v:count-1].bufno
         execute "buffer ".byIndex[v:count-1].bufno
      endif
      return
   endif
   echohl Special
   echo "No Buffer Name"
   echohl None
   for ent in byIndex
      echo printf("%2d %6d %s", ent.ix, ent.bufno, ent.name)
   endfor
   let ix = input("Type number and <Enter> (empty cancels): ") + 0
   if ix > 0 && ix <= len(byIndex)
      execute "keepjumps buffer ".byIndex[ix-1].bufno
   endif
endfunc
" Note this overrides :goto
nmap go :<C-U>call JumpBuffers()<CR>
nmap <C-G><C-O> 2go
" Remap builtin 'go'
nnoremap g<C-O> go

function! TmuxReload()
   for line in systemlist("tmux show-environment")
      if line[0] == "-"
         execute "let $".strpart(line, 1)."=''"
      else
         let prt = matchlist(line, '\([^=]\+\)=\(.*\)')
         if len(prt) > 2 && len(prt[1]) > 0
            execute 'let $'.prt[1].'="'.escape(prt[2], '\"').'"'
         endif
      endif
   endfor
endfunc
command! TmuxReload call TmuxReload()

function! Menu(i)
   source $VIMRUNTIME/menu.vim
   set wildmenu
   set cpo-=<
   set wcm=<C-Z>
   map <F4> :emenu <C-Z>
   if a:i
      echom "You can now use <F4> to bring up the menu"
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
    if ! exists("s:actual_curbuf")
       return ":-)"
    endif
    if ! exists("s:vimbuddy_msg")
        let s:vimbuddy_msg = v:statusmsg
    endif
    if ! exists("s:vimbuddy_warn")
        let s:vimbuddy_warn = v:warningmsg
    endif
    if ! exists("s:vimbuddy_err")
        let s:vimbuddy_err = v:errmsg
    endif
    if ! exists("s:vimbuddy_onemore")
        let s:vimbuddy_onemore = ""
    endif

    if g:actual_curbuf != bufnr("%")
        " Not my buffer, sleeping
        return "|-o"
    elseif s:vimbuddy_err != v:errmsg
        let v:errmsg = v:errmsg . " "
        let s:vimbuddy_err = v:errmsg
        return ":-("
    elseif s:vimbuddy_warn != v:warningmsg
        let v:warningmsg = v:warningmsg . " "
        let s:vimbuddy_warn = v:warningmsg
        return "(-:"
    elseif s:vimbuddy_msg != v:statusmsg
        let v:statusmsg = v:statusmsg . " "
        let s:vimbuddy_msg = v:statusmsg
        let test = matchstr(v:statusmsg, 'lines *$')
        let num = substitute(v:statusmsg, '^\([0-9]*\).*', '\1', '') + 0
        " How impressed should we be
        if test != "" && num > 20
            let str = ":-O"
        elseif test != "" && num
            let str = ":-o"
        else
            let str = ":-/"
        endif
        let s:vimbuddy_onemore = str
        return str
    elseif s:vimbuddy_onemore != ""
      let str = s:vimbuddy_onemore
      let s:vimbuddy_onemore = ""
      return str
    endif

    if ! exists("b:lastcol")
        let b:lastcol = col(".")
    endif
    if ! exists("b:lastlineno")
        let b:lastlineno = line(".")
    endif
    let num = b:lastcol - col(".")
    let b:lastcol = col(".")
    if (num == 1 || num == -1) && b:lastlineno == line(".")
        " Let VimBuddy rotate his nose
        let num = b:lastcol % 4
        if num == 0
            let ch = '/'
         elseif num == 1
            let ch = '-'
        elseif num == 2
            let ch = '\'
        else
            let ch = '|'
        endif
        return ":" . ch . ")"
    endif
    let b:lastlineno = line(".")

    " Happiness is my favourite mood
    return ":-)"
endfunction

au! CursorHold * redraw!

if exists("load_less")
   setglobal directory=
   setglobal statusline=%3l/%LL\ %P\ %o/%{line2byte(line(\"$\")+1)-1}\ %=%<%f%a
   setglobal cmdheight=1
endif

call SetBufferOpts() " Why is this needed ?? it is mapped to BufNewFile!!
let loaded_explorer=1 " Don't want plugin/explorer.vim
let g:airline_powerline_fonts = 1
" echo "DONE sourcing"

