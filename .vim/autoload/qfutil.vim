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
  setlocal modifiable nonumber nowinfixheight undolevels=-1
  silent % delete _

  let lnum_width = 0
  let col_width = 0
  let fname_width = 0
  let fpath_width = 0

  let loclist = getqflist()
  for item in loclist
    let lnum_width = max([len(item.lnum), lnum_width])
    let col_width = max([len(item.col), col_width])
    let fname_width = max([len(fnamemodify(bufname(item.bufnr), ":t")), fname_width])
    let fpath_width = max([len(bufname(item.bufnr)), fpath_width])
  endfor
  let fname_width = min([40, max([fname_width, fpath_width])])

  let lines = []
  for item in loclist
    let type = toupper(item.type)
    if empty(type)
      let type = ' '
    endif
    let fname = bufname(item.bufnr)
    call add(lines, printf('%*s | %*s:%*s %s| %s', fname_width, strpart(fname, len(fname) - fname_width),
                          \                        lnum_width, item.lnum, col_width, item.col, type, item.text))
  endfor

  call setline(1, lines)
  let &l:undolevels = ul
  setlocal modifiable nomodified
  exe "normal! ".mywin."\<C-W>w"
endfunction


function! qfutil#visibleList(locList)
  if a:locList
    return len(filter(getwininfo(), {i,v -> v.loclist}))
  endif
  return len(filter(getwininfo(), {i,v -> v.quickfix}))
endfunc

function! qfutil#followLine(locList)
  let curLine = line(".")
  let curBuf = bufnr("%")
  if (exists("b:lastLine".a:locList) && b:lastLine{a:locList} == curLine) || 0 == qfutil#visibleList(a:locList)
    return 1
  endif
  let b:lastLine{a:locList} = line(".")
  let ent = filter(map(a:locList ? getloclist(".") : getqflist(), 
  \                    {i,v -> {"ix":i, "e":v} }), {i,v -> v.e.bufnr==curBuf && v.e.lnum <= curLine})
  if len(ent) < 1 || (exists("b:lastEntry".a:locList) && b:lastEntry{a:locList} == ent[-1].ix && ent[-1].e.lnum != curLine)
    if exists("b:lastEntryEcho")
      echo ""
      unlet b:lastEntryEcho
    endif
    return 2
  endif
  let b:lastEntry{a:locList} = ent[-1].ix
  let pos = [ 0, curLine, col("."), 0 ]
  exe (a:locList ? "ll " : "cc ").(ent[-1].ix+1)
  call setpos(".", pos)
  let ent = ent[-1].e
  if ent.lnum != curLine
    echo ""
    unlet! b:lastEntryEcho
  elseif len(ent.type)
    redraw
    exe "echohl "(ent.type=="E" ? "Error" : "Todo")
    echo ent.type.":" | echohl None | echon " ".ent.text
    let b:lastEntryEcho = 1
  endif
endfunc

" vim: set sw=2 sts=2 et:
