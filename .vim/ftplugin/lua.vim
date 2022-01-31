" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif

" Wrap official file
source $VIMRUNTIME/ftplugin/lua.vim

" Don't load another plugin for this buffer
let b:did_ftplugin = 1

if !exists('*LuaFtpluginUnmap')
    func LuaFtpluginUnmap()
        silent! nunmap <buffer> [[
        silent! vunmap <buffer> [[
        silent! nunmap <buffer> ]]
        silent! vunmap <buffer> ]]
    endfunc
endif

let b:undo_ftplugin .= " | call LuaFtpluginUnmap()"

" Move around functions.
nnoremap <silent><buffer> [[ m':call search('^\s*\(local\s\)\=\s*function\>', "bW")<CR>
vnoremap <silent><buffer> [[ m':<C-U>exe "normal! gv"<Bar>call search('^\s*\(local\s\)\=\s*function\>', "bW")<CR>
nnoremap <silent><buffer> ]] m':call search('^\s*\(local\s\)\=\s*function\>', "W")<CR>
vnoremap <silent><buffer> ]] m':<C-U>exe "normal! gv"<Bar>call search('^\s*\(local\s\)\=\s*function\>', "W")<CR>
