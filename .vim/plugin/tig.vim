if has('nvim')
  if !exists('g:tig_executable')
    let g:tig_executable = 'tig'
  endif

  if !exists('g:tig_default_command')
    let g:tig_default_command = 'status'
  endif

  if !exists('g:tig_on_exit')
    let g:tig_on_exit = 'bw!'
  endif

  if !exists('g:tig_open_command')
    let g:tig_open_command = 'enew | setlocal nonumber'
  endif

  function! s:tig(bang, ...)
    let s:callback = {}
    if a:0 > 0
      let file = resolve(fnamemodify(expand(a:1), ":p"))
    else
      let file = resolve(expand('%:p'))
    end
    let dir = shellescape(fnamemodify(file, ":h"))
    let file = shellescape(fnamemodify(file, ":t"))

    function! s:callback.on_exit(id, status, event)
      exec g:tig_on_exit
    endfunction

    function! s:tigopen(arg)
      call termopen(g:tig_executable.' '.a:arg, s:callback)
    endfunction

    function! s:diropen(arg, dir)
      "echomsg g:tig_executable . ' ' . a:arg
      call termopen('cd '.a:dir.'; '.g:tig_executable.' '.a:arg, s:callback)
    endfunction

    exec g:tig_open_command
    if a:bang > 0
      call s:diropen("blame -w --follow -- ".file, dir)
    elseif a:0 > 0
      call s:diropen("-w --follow -- ".file, dir)
    else
      call s:tigopen(g:tig_default_command)
    endif
    startinsert
  endfunction

  command! -bang -nargs=? Tig call s:tig(<bang>0, <f-args>)
  map gt :Tig %<CR>
endif
