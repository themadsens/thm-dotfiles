" vim: set ts=3 sw=3 et:

function! s:FindAsh()
   if getline(1) =~ '\<ash$'
      let b:is_bash = 1
      set filetype=sh
   end
endfunc

au BufRead,BufNewFile * call <SID>FindAsh()
