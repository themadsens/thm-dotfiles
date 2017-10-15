
command! -range=0 -complete=customlist,man#complete -nargs=* FMan call fman#open_page(v:count, v:count1, <q-mods>, <f-args>)
command! -range=0 -complete=customlist,man#complete -nargs=* Man call fman#open_page(v:count, v:count1, <q-mods>, <f-args>)
command! -range=0 -complete=customlist,man#complete -nargs=* MAN call fman#open_page(v:count, v:count1, <q-mods>, <f-args>)
