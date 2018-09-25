
function! fmutil#InitBufMRU()
   if !exists("g:did_bufmru")
      return
   end

   call bufmru#init()
   call bufmru#noautocmd()
   let jumptxt = ""
   let lz = &lazyredraw
   set lazyredraw
   redir! => jumptxt
   silent jumps
   redir END
   let byName = {}
   let byMru = []
   for line in reverse(split(jumptxt, '\n'))
      let name = strpart(line, 16)
      let bufno = bufnr(name)
      if len(name) > 0 && bufno >= 0 && !has_key(byName, name)
         let byMru += [{'name': name, 'bufno': bufno, 'ix': len(byMru)+1}]
         let byName[name] = len(byMru)
      endif
   endfor
   for mru in byMru
      execute "buffer! ".mru.bufno
      let listed = &buflisted
      setlocal buflisted
      call bufmru#save("leave()")
      let &buflisted = listed
   endfor
   call bufmru#autocmd()
   let &lazyredraw = lz
endfunc

" vim: set sw=3 sts=3 et:
