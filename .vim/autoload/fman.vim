" (C) Copyright: Flemming Madsen https://github.com/themadsens
" vim: set ts=3 sw=3 et:

" BASH:
" export MANPAGER="nvim -c 'set ft=man' '+call fman#fmanize(1)' -"
" # OR, less intrusive
" fman() { nvim "+call fman#man_page(0, 1, '', '${1}')"; }
" complete -F _man fman

function! s:toggleLwin()
   if s:visibleLoc()
      lclose
   else
      lwindow
      ll
   end
endfunc

function! s:visibleLoc()
   return len(filter(getwininfo(), {i,v -> v.loclist}))
endfunc

function! s:followLine()
   let curLine = line(".")
   if (exists("b:lastLine") && b:lastLine == curLine) || 0 == s:visibleLoc()
      return
   endif
   let b:lastLine = line(".")
   let ent = len(filter(getloclist("."), {i,v -> v.lnum <= curLine}))
   if ent < 1 || (exists("b:lastEntry") && b:lastEntry == ent)
      return
   endif
   let b:lastEntry = ent
   let pos = [ 0, curLine, col("."), 0 ]
   exe "ll ".ent
   call setpos(".", pos)
endfunc

function! fman#fmanize(setQ)
   if &filetype != 'man'
      return
   end
   only
   nmap <buffer> <Space> <C-F>
   nmap <buffer> f <C-F>
   nmap <buffer> b <C-B>
   nmap <buffer> u <C-U>
   nmap <buffer> d <C-D>
   nmap <buffer> e <C-E>
   nmap <buffer> y <C-Y>
   nmap <buffer> j :lnext<CR>
   nmap <buffer> k :lprev<CR>
   nmap <buffer> q :call <SID>toggleLwin()<CR>
   if a:setQ
      nmap <buffer> Q :qall<CR>
   endif
   au CursorMoved <buffer> call <SID>followLine()
   call man#show_toc()
   ll
endfunc

function! fman#open_page(count, count1, mods, ...) 
   call call('man#open_page', [ a:count, a:count1, a:mods ] + a:000) 
   call fman#fmanize(0)
endfunc

function! fman#man_page(count, count1, mods, ...) 
   call call('fman#open_page', [ a:count, a:count1, a:mods ] + a:000) 
   call fman#fmanize(1)
endfunc

