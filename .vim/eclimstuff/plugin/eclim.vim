" Eclim stuff for this subset of it

if !exists("g:EclimLogLevel")
  let g:EclimLogLevel = 4
endif

if !exists("g:EclimTraceHighlight")
  let g:EclimTraceHighlight = "Normal"
endif
if !exists("g:EclimDebugHighlight")
  let g:EclimDebugHighlight = "Normal"
endif
if !exists("g:EclimInfoHighlight")
  let g:EclimInfoHighlight = "Statement"
endif
if !exists("g:EclimWarningHighlight")
  let g:EclimWarningHighlight = "WarningMsg"
endif
if !exists("g:EclimErrorHighlight")
  let g:EclimErrorHighlight = "Error"
endif
if !exists("g:EclimFatalHighlight")
  let g:EclimFatalHighlight = "Error"
endif

if !exists("g:EclimShowCurrentError")
  let g:EclimShowCurrentError = 1
endif

if !exists("g:EclimShowCurrentErrorBalloon")
  let g:EclimShowCurrentErrorBalloon = 1
endif

if has("signs")
  if !exists("g:EclimSignLevel")
    let g:EclimSignLevel = 5
  endif
else
  let g:EclimSignLevel = 0
endif


if has('signs')
  if !exists(":Sign")
    command Sign :call eclim#display#signs#Toggle('user', line('.'))
  endif
  if !exists(":Signs")
    command Signs :call eclim#display#signs#ViewSigns('user')
  endif
  if !exists(":SignClearUser")
    command SignClearUser :call eclim#display#signs#UnplaceAll(
      \ eclim#display#signs#GetExisting('user'))
  endif
  if !exists(":SignClearAll")
    command SignClearAll :call eclim#display#signs#UnplaceAll(
      \ eclim#display#signs#GetExisting())
  endif
endif

if g:EclimSignLevel
  augroup eclim_qf
    autocmd WinEnter,BufWinEnter * call eclim#display#signs#Update()
    if has('gui_running')
      " delayed to keep the :make output on the screen for gvim
      autocmd QuickFixCmdPost * call eclim#util#DelayedCommand(
        \ 'call eclim#display#signs#QuickFixCmdPost()')
    else
      autocmd QuickFixCmdPost * call eclim#display#signs#QuickFixCmdPost()
    endif
  augroup END
endif


if g:EclimShowCurrentError
  " forcing load of util, otherwise a bug in vim is sometimes triggered when
  " searching for a pattern where the pattern is echoed twice.  Reproducable
  " by opening a new vim and searching for 't' (/t<cr>).
  runtime eclim/autoload/eclim/util.vim

  augroup eclim_show_error
    autocmd!
    autocmd CursorMoved * call eclim#util#ShowCurrentError()
  augroup END
endif

if g:EclimShowCurrentErrorBalloon && has('balloon_eval')
  set ballooneval
  set balloonexpr=eclim#util#Balloon(eclim#util#GetLineError(line('.')))
endif

