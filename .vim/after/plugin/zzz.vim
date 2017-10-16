
"echomsg "ZZZ Says after"
command! -range=0 -complete=customlist,man#complete -nargs=* Man call fman#open_page(v:count, v:count1, <q-mods>, <f-args>)
