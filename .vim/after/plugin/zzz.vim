
"echomsg "ZZZ Says after"
"command! -range=0 -complete=customlist,man#complete -nargs=* MaN call fman#open_page(v:count, v:count1, <q-mods>, <f-args>)

command! JIG call MyJavaImpGenerate()

call fmutil#InitBufMRU()

" vim: set sw=3 sts=3 et:
