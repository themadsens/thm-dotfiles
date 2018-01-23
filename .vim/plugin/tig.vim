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
    let g:tig_open_command = 'enew | set nonumber'
  endif

  function! s:tig(bang, ...)
    let s:callback = {}
    if a:0 > 0
      let file = expand(a:1)
    else
      let file = expand('%')
    end

    function! s:callback.on_exit(id, status, event)
      exec g:tig_on_exit
    endfunction

    function! s:tigopen(arg)
      echomsg g:tig_executable . ' ' . a:arg
      call termopen(g:tig_executable . ' ' . a:arg, s:callback)
    endfunction

    exec g:tig_open_command
    if a:bang > 0
      call s:tigopen("blame -w -- ".file)
    elseif filereadable(file)
      call s:tigopen("-- ".file)
    elseif a:0 > 0
      call s:tigopen(file)
    else
      call s:tigopen(g:tig_default_command)
    endif
    startinsert
  endfunction

  command! -bang -nargs=? Tig call s:tig(<bang>0, <f-args>)
  map gt :Tig %<CR>
endif
