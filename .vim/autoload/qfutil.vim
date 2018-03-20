function! qfutil#reformat(...) abort
  " echomsg 'reformat'

  let title = exists('a:1') ? a:1 : ''
  let height = exists('a:2') ? a:2 : 10

  let mywin = winnr()
  exe "copen ".height
  let qf = getqflist({'winid':1})
  if !has_key(qf, 'winid')
      return
  endif
  if len(title)
      let w:quickfix_title = title
  endif
  exe "normal! ".qf['winid']."\<C-W>w"

  let ul = &l:undolevels
  setlocal modifiable nonumber undolevels=-1
  silent % delete _

  let lnum_width = 0
  let col_width = 0
  let fname_width = 0

  let loclist = getqflist()
  for item in loclist
    let lnum_width = max([len(item.lnum), lnum_width])
    let col_width = max([len(item.col), col_width])
    let fname_width = max([len(fnamemodify(bufname(item.bufnr), ":t")), fname_width])
  endfor

  let lines = []
  for item in loclist
    let type = toupper(item.type)
    if empty(type)
      let type = ' '
    endif
    call add(lines, printf('%*s | %*s:%*s %s| %s', fname_width, fnamemodify(bufname(item.bufnr), ":t"),
                          \                        lnum_width, item.lnum, col_width, item.col, type, item.text))
  endfor

  call setline(1, lines)
  let &l:undolevels = ul
  setlocal modifiable nomodified
  exe "normal! ".mywin."\<C-W>w"
endfunction

