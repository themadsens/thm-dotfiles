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
autocmd BufReadPost,StdinReadPost * call SetFileTypeOnLoad()
augroup END

set tags=/opt/toolchain/include/tags,/usr/include/tags
set path=.,,include,../include,/opt/toolchain/include,/usr/include

if has("win32")
   behave xterm
   set directory=C:/temp/preserve//   " Home of the swap files_
   if filereadable('C:\Programs\NT_SFU\Shell\grep.EXE')
      set grepprg=grep\ -n            " Use POSIX grep if available
   endif

   " Let VIM know about VisualC++ include files
   if exists("$include")
      let more = substitute($include, ';', ',', 'g')
      let more = substitute(more, ' ', '\\\\\\ ', 'g')
      execute "set path+=" . more
      let g:incdirs = g:incdirs.",".more

      let more = substitute($include, ';', '\\\\\\tags,', 'g')
      execute "set tags+=" . substitute(more, ' ', '\\\\\\ ', 'g') . '\\tags'
      unlet more
   endif

   if exists("$SCCSHOME")
      " Can not handle '/' to '\' conversion otherwise
      let $SCCSHOME = $SCCSHOME . "/"
   endif

   if has("gui_running")
      set guifont=Courier_New:h9
      " System menu and quick minimize
      map <M-Space> :simalt ~<CR>
      map <M-n> :simalt ~n<CR>
      " Size the GUI window. Delay positioning until window is created
      set lines=50
      set columns=82
      augroup AutoPos
      autocmd BufEnter * winp 200 50 | autocmd! AutoPos
      augroup END
   endif
else
   if (&term == "cygwin") " This seem to have some quirks, work around some
      set directory=/var/preserve/
      " Make <End> work
      exe "set t_@7=\e[4~"
      " Make <Home> work
      exe "set t_kh=\e[1~"
   else
      set directory=/var/preserve//
      if has("gui_running")
         let &guifont="Bitstream Vera Sans Mono 8"
      else
         " Uncomment line below to use :emenu. Adds ~1 second to startup time
         " source $VIMRUNTIME/menu.vim

         " Make <End> work - Some options cannot be assigned to with 'let'
         "exe "set t_@7=\<Esc>OF"

         " Must be _very_ slow to handle triple cl"icks
         set mousetime=1500
         "if &ttymouse == "xterm2"
         "   " The xterm2 mode will flood us with messages
         "   set ttymouse=xterm
         "endif
         if (&term == "screen")
            set ttymouse=xterm2
         endif

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

         " Make <Del> mappings work
         " exe 'set t_kb=\x08'
         " exe 'set t_kD=\x7f'

         exe "set t_Co=16"

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
    set title icon
    set titlestring=%F%(\ --\ %a%)
    set iconstring=%f
else
    set notitle noicon         " Do _not_ mess with title string of my xterm
endif

set showcmd                    " Show chars for command in progress on ruler
set exrc                       " Allow .vimrc in current dir
set hidden                     " Dont unload buffers BEWARE OF :q! and :qa! !!!
set backspace=indent,eol       " Can ^H/^W/^U across lines in insert
set sidescroll=5
set scrolloff=4
set textwidth=100
set whichwrap=h,l,<,>,[,]      " Do not backspace/space across line boundaries
set autoindent
set winheight=10               " Make new windows this high
set cmdheight=2                " status line area height - higher for quickfix
set laststatus=2               " always with statusline
set showmatch
set autowrite                  " write files back at ^Z, :make etc.
set mouse=nv                   " Use xterm mouse mode in insert/cmdline/prompt
set clipboard=autoselect       " Visual to/from clipboard
set fileformats=unix,dos,mac
set showbreak=________         " Show me where long lines break
set showfulltag                " Insert function prototype in ^X^]
set incsearch nohlsearch       " Search while typing, 'zx' toggles highlighting
set helpheight=100             " Maximize help windows
set shortmess=ato              " Brief messages to avoid 'Hit Return' prompts
set formatoptions=crqlo        " Comment handling / Dont break while typing
set history=100
set viminfo='20,\"500          " Keep history listings across sessions
set wildmenu                   " Show completion matches on statusline
set wildmode=list:longest,full
set complete=.,w,b,u,d         " The ,t,i from the default was too much, now ,d
set isfname-==                 " No = allows 'gf' in File=<Path> Constructs
set shiftwidth=4
set softtabstop=4
set number
set expandtab
set spelllang=en_us
set equalprg=csb
set visualbell
set printfont=:h7.5
set printoptions=number:y,duplex:off,left:5mm,top:5mm,bottom:5mm,right:5mm
set virtualedit=block
set noignorecase
set smartcase
set nofoldenable

let c_gnu = 1
let c_no_curly_error = 1
"let &errorformat = 

" For running edit-compile-edit (quickfix)
nmap <Esc>n :cnext<CR>
nmap <Esc>l :clist<CR>
nmap <Esc>c :cc<CR>
nmap <Esc>p :cprevious<CR>
nmap <Esc>m :Make<CR>

" Various utility keys
nmap (     :bprev<CR>
nmap )     :bnext<CR>
nmap F     :files<CR>
"nmap Q     :bdelete<CR>
nmap !Q    :bdelete!<CR>
nmap Q     :call PrevBuf(1)<CR>
nmap ZQ    :call PrevBuf(0)<CR>
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
set timeoutlen=500
set ttimeoutlen=50

" Make cursor keys jump out of insert. Your preference may differ
imap <Left>     <Esc>
imap <Right>    <Esc>
imap <Up>       <Esc>
imap <Down>     <Esc>
imap <S-Left>   <Esc>
imap <S-Right>  <Esc>
imap <S-Up>     <Esc>
imap <S-Down>   <Esc>

" Movement with "2x3" block navigation keys. Customize to your liking
nnoremap <PageUp>   <C-U>
nnoremap <PageDown> <C-D>
nnoremap <Home>     <C-Y>
nnoremap <xHome>    <C-Y>
nnoremap <End>      <C-E>
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
   set background=dark
   hi statusLine ctermfg=black
   hi statusLineNC ctermfg=black ctermbg=yellow
endif

" Use :T instead of :ta to see file names in ^D complete-lists
command! -complete=tag_listfiles -nargs=1 T tjump <args>|
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
augroup end

function! BufEnterGlobalOpts()
   " Avoid '#-in-1.-column' problem with cindent & smartindent
   if &filetype == 'c' || &filetype == 'cpp'
      inoremap # #
      " Dont highligh this as an error
      hi link cCommentStartError Comment
   else
      inoremap # X<BS>#
   endif
   if &filetype == 'java'
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

function! SetFileTypeOpts()
   let ft = &filetype
   if index(["tcl","poststr"], ft) >= 0
      setlocal nocindent smartindent
      inoremap # X<BS>#
   else
      inoremap # #
   endif
   if index(["c","cpp","java","jsp"], ft) >= 0
      setlocal cindent
      " Match open brace above )
      setlocal cinoptions=(0,w1,u0,:1,=2
   endif
   if index(["tcl","postscr","c","cpp","java","jsp"], ft) >= 0
      " NO autowrap while typing in source code files
      setlocal formatoptions-=t
   endif
   if index(["java","jsp"], ft) >= 0
      " Ampep java settings
      setlocal sw=2 ts=2
      compiler mvn
      setlocal includeexpr=JspPath(v:fname)
      setlocal cinkeys-=:
   endif
   if ft == "sh"
      call TextEnableCodeSnip('lua', '--LUA--', '--EOF--') 
      call TextEnableCodeSnip('awk', '#AWK#', '#EOF#')
   elseif ft == "java"
      call TextEnableCodeSnip('sql', '--UA--', '--EOF--') |
   elseif ft == "lua"
      call TextEnableCodeSnip('c', 'cdef\[\[', '\]\]') |
   elseif ft == "jsp"
      call TextEnableCodeSnip('javascript', '<script type=.text/javascript.>', '</script>') |
   elseif ft == "xml"
      call TextEnableCodeSnip('sql', '<sql>', '</sql>') |
   elseif ft == "javascript"
     compiler jshint
     setlocal sw=2 ts=2
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
      endif
      if strlen(glob(fpath."/include"))
         exe "setlocal path+=".fpath."/include"
      endif
      if strlen(glob(fpath."/*.h"))
         exe "setlocal path+=".fpath
      endif
      if !exists("b:GlimpsePath") && filereadable(fpath."/.glimpse_index")
         let b:GlimpsePath = fpath
         if filereadable(fpath."/amplex-trees")
            let b:ampdirs = join(readfile(fpath."/amplex-trees"), ",")
         endif
         exe "setlocal path+=".fpath
      endif
      let fpath = fnamemodify(fpath, ":h")
   endwhile
   if ! exists("tagset")
       setlocal tags+=tags,../tags
   endif
endfunc

" Testing
"set title titlestring=%<%F%=%l/%L-%P titlelen=70
"set rulerformat=%l,%c%_%t-%P

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
   if makeArgs == 'jshint' and &ft == 'javascript' 
      setlocal makeprg=jshint
   elseif &makeprg == "mmvn" || &makeprg == "mvn" || current_compiler == "mvn"
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
   echomsg "make ".makeArgs." in: ".getcwd()
   exe "make ".makeArgs
   if exists("oldwd")
      exe "cd ".fnameescape(oldwd)
  endif
endfunc
command! -nargs=* Make call MakePrg("<args>")
command! -nargs=* Mvn compiler mvn | call MakePrg("<args>")

" Ensure --remote loads adds to the jumplist
autocmd Private BufReadPost * 1

function! PrevBuf(closeThis, ...)

   if a:closeThis && &buftype != ""
      exe "bdelete" . (a:0 > 0 ? a:1 : "")
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

function! SvnDiff(f)
   let f = a:f
   if f == ""
      let f = bufname("%")
   endif
   let bufname = "DIFF::".f
  
   let curbuf = bufnr("%")
   exe "edit ".bufname
   let tmpbuf = bufnr("%")
   setlocal buftype=nofile
   setlocal bufhidden=hide
   setlocal noswapfile
   set filetype=diff
  
   if bufexists(f)
      exe "buffer ".bufnr(f) 
      if &modified
         let tmp = tempname()
         exe "write ".fnameescape(tmp)
         call system("svn cat ".shellescape(fnamemodify(f, ":p"))." > ".shellescape(tmp.".orig"))
         let cmd = "diff -u ".shellescape(tmp.".orig")." ".shellescape(tmp)." ; rm ".shellescape(tmp)."{,.orig}"
      endif
      exe "buffer ".curbuf
   endif
   if !exists("cmd")
      let cmd = "svn diff ".shellescape(fnamemodify(f, ":p"))
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
   let bufname = "AUTH::".f
  
   let curbuf = bufnr("%")
   exe "edit ".bufname
   let tmpbuf = bufnr("%")
   setlocal buftype=nofile
   setlocal bufhidden=hide
   setlocal noswapfile
   set filetype=diff
  
   let cmd = "svn blame ".shellescape(fnamemodify(f, ":p"))
   " echom "F: '".f."' CMD: '".cmd."'"
   exe "buffer ".tmpbuf
   exe "normal S-- AUTH: ".f
   exe "read !".cmd 
   exe "1"
endfunc
command! -nargs=? -complete=buffer SvnBlame call SvnBlame(<q-args>)
nmap gkb :SvnBlame<CR>


"
" Extra vim stuff
" 

map `h <Plug>jdocConvertHere
map `c <Plug>jdocConvertCompact

nmap <F2> :call SetCHdr()<CR>

map gy "*y
map gp "*p
map g]p "*]p
map g[P "*[P

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
vmap              gG      :call VisualOpenSpec("GLM::")<CR>
command! -nargs=1 Glimpse  call OpenSpec("GLM::<args>")
command! -nargs=1 GlimpseW call OpenSpec("GLW::<args>")

func! OpenSpec(str)
	let Str = a:str
   let g:GlimpsePath = b:GlimpsePath
	exe "edit ".Str
   call histadd("cmd", "edit ".Str)
endfunction

func! VisualOpenSpec(Pre)
  let Col1 = col("'<")  
  let Col2 = col("'>")  
  if line("'<") != line("'>") | return | endif
  let Str = strpart(getline(line("'<")), Col1 - 1, Col2 - Col1 + 1)
  let Str = substitute(Str, " ", ".", "g")
  call OpenSpec(a:Pre.Str)
endfunc

command! -nargs=? SvnWeb let _ = system("svnbrowse " . expand((len("<args>")?"<args>":"%").":p") )
command! -nargs=? RemoteSend let _ = system("vim -g --remote " . expand((len("<args>")?"<args>":"%").":p") )

" Find amplex java imports
set suffixesadd=.java
nmap gf :call GoFile()<CR>
function! GoFile()
    if !exists("b:ampdirs") 
        normal! gf
        return
    endif
    let savePath = &path
    let &l:path = &path.",".b:ampdirs
    normal! gf
    let &l:path = savePath
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

set statusline=%<%f%=\ %{ShowSyn()}%2*%{VimBuddy()}%*\ %([%1*%M\%*%n%R\%Y
              \%{VarExists(',GZ','b:zipflag')},%1*%{CaseStat()}%*]%)\ %02c%V(%02B)C\ %3l/%LL\ %P
hi User1          term=reverse,bold cterm=NONE,bold ctermfg=red  ctermbg=grey gui=bold guifg=red guibg=gray
hi User2          term=reverse      cterm=NONE      ctermfg=blue ctermbg=grey guifg=darkblue guibg=gray
hi StatusLineNC   term=reverse      cterm=NONE ctermbg=darkgrey  ctermfg=white gui=NONE guibg=grey
hi StatusLine     term=reverse      cterm=NONE ctermbg=grey  ctermfg=black    gui=NONE guibg=darkgrey
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


if exists("load_less")
   set directory=
   set statusline=%3l/%LL\ %P\ %o/%{line2byte(line(\"$\")+1)-1}\ %=%<%f%a
   set cmdheight=1
endif

call SetBufferOpts() " Why is this needed ?? it is mapped to BufNewFile!!
let loaded_explorer=1 " Don't want plugin/explorer.vim
" echo "DONE sourcing"

