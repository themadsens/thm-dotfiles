" vim: set ts=3 sw=3 et:

function! s:toggleLwin()
   if getbufvar(winbufnr(winnr('$')), 'current_syntax') == 'qf'
      lclose
   else
      lwindow
      ll
   end
endfunc

function! s:open_page(count, count1, mods, ...) 
   call call('man#open_page', [ a:count, a:count1, a:mods ] + a:000) 
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
   call man#show_toc()
   ll
endfunc

function! s:cmd_page(count, count1, mods, ...) 
   call call('s:open_page', [ a:count, a:count1, a:mods ] + a:000) 
   nmap <buffer> Q :qall<CR>
endfunc

command! -range=0 -complete=customlist,man#complete -nargs=* FMan call s:open_page(v:count, v:count1, <q-mods>, <f-args>)
command! -range=0 -complete=customlist,man#complete -nargs=* CMan call s:cmd_page(v:count, v:count1, <q-mods>, <f-args>)
command! -range=0 -complete=customlist,man#complete -nargs=* Man call s:open_page(v:count, v:count1, <q-mods>, <f-args>)
