" Vim color file
" Maintainer: David Ne\v{c}as (Yeti) <yeti@physics.muni.cz>
" Last Change: 2003-04-23
" URL: http://trific.ath.cx/Ftp/vim/colors/peachpuff.vim

" This color scheme uses a peachpuff background (what you've expected when it's
" called peachpuff?).
"
" Note: Only GUI colors differ from default, on terminal it's just `light'.

" First remove all existing highlighting.
set background=light
hi clear
if exists("syntax_on")
  syntax reset
endif

let colors_name = "flemming"

"hi Normal guibg=CornSilk guifg=Black
hi Normal guibg=#ddd9c3 guifg=Black

hi SpecialKey term=bold ctermfg=4 guifg=#0220B2
"hi NonText term=bold cterm=bold ctermfg=7 gui=bold guifg=Blue
hi NonText term=bold cterm=bold ctermfg=252 gui=bold guifg=#d0d0d0
"hi Directory term=bold ctermfg=4 guifg=#0220B2
hi Directory term=bold ctermfg=4 guifg=#0220B2
"hi ErrorMsg term=standout cterm=bold ctermfg=8 ctermbg=9 gui=bold guifg=White guibg=Red
hi ErrorMsg term=standout cterm=bold ctermfg=8 ctermbg=9 gui=bold guifg=#555753 guibg=#EF2929
hi IncSearch term=reverse cterm=reverse gui=reverse
hi Search term=reverse ctermbg=227 guibg=#ffff5f
hi MoreMsg term=bold ctermfg=2 gui=bold guifg=#107A02
hi ModeMsg term=bold cterm=bold gui=bold
"hi LineNr term=underline ctermfg=3 guifg=Red3
hi Question term=standout ctermfg=2 gui=bold guifg=#107A02
"hi StatusLine term=bold,reverse cterm=bold,reverse gui=bold guifg=White guibg=Black
"hi StatusLineNC term=reverse cterm=reverse gui=bold guifg=PeachPuff guibg=Gray45
hi VertSplit term=reverse cterm=reverse gui=bold guifg=White guibg=Gray45
hi Title term=bold ctermfg=5 gui=bold guifg=#CA30C7
hi Visual term=reverse ctermbg=249 gui=reverse guifg=#b2b2b2 guibg=fg
hi WarningMsg term=standout ctermfg=1 gui=bold guifg=#8A252C
hi WildMenu term=standout ctermfg=0 ctermbg=227 guifg=Black guibg=#ffff5f
hi Folded term=standout ctermfg=4 ctermbg=7 guifg=#0220B2 guibg=#e3c1a5
hi FoldColumn term=standout ctermfg=4 ctermbg=7 guifg=#0220B2 guibg=#9c9c9c
hi DiffAdd term=bold ctermbg=36 guibg=#00af87
hi DiffChange term=bold ctermbg=172 guibg=#d78700
hi DiffDelete term=bold cterm=bold ctermbg=204 gui=bold guifg=Black guibg=#ff5f87
hi DiffText term=reverse cterm=bold ctermbg=202 gui=bold guibg=#ff5f00
hi Cursor guifg=bg guibg=fg
hi lCursor guifg=bg guibg=fg
hi SpellBad ctermbg=168 gui=undercurl guisp=Red

highlight LineNr cterm=NONE ctermbg=187 ctermfg=3 guifg=#706F00 guibg=#d7d7af
highlight CursorLine cterm=NONE ctermbg=186 guibg=#d7d787
highlight CursorLineNr term=bold cterm=bold ctermbg=186 ctermfg=130 guibg=#d7d787 guifg=#af5f00
highlight CursorColumn cterm=NONE ctermbg=186 guibg=#d7d787
highlight SignColumn cterm=NONE ctermbg=187 guibg=#d7d7af

hi StatusLineNC   term=reverse      cterm=NONE ctermbg=darkgrey  ctermfg=white gui=NONE guibg=grey
hi StatusLine     term=reverse      cterm=NONE ctermbg=grey  ctermfg=black    gui=NONE guibg=darkgrey
hi User1          term=reverse,bold cterm=NONE,bold ctermfg=red  ctermbg=grey gui=bold guifg=red guibg=gray
hi User2          term=reverse      cterm=NONE      ctermfg=blue ctermbg=grey guifg=darkblue guibg=gray

" Changes
hi ChangesSignTextAdd ctermbg=150 ctermfg=238 guibg=#afd787 guifg=#444444
hi ChangesSignTextDel ctermbg=210 ctermfg=238 guibg=#ff8787 guifg=#444444
hi ChangesSignTextCh  ctermbg=109 ctermfg=238 guibg=#87afaf guifg=#444444

" Colors for syntax highlighting
hi Comment term=bold ctermfg=4 cterm=italic gui=italic guifg=#0220B2
hi Constant term=underline ctermfg=1 guifg=#8a252c
hi Special term=bold ctermfg=5 guifg=#CA30C7
hi Identifier term=underline ctermfg=6 guifg=#008383
hi Statement term=bold ctermfg=3 cterm=bold gui=bold guifg=#706F00
hi PreProc term=underline ctermfg=5 guifg=#CA30C7
hi Type term=underline ctermfg=2 gui=NONE guifg=#107A02
hi Ignore cterm=bold ctermfg=7 guifg=#9c9c9c
hi Error term=reverse ctermbg=9 ctermfg=15 guifg=White guibg=#EF2929
hi Todo term=standout ctermfg=0 ctermbg=11 guifg=Black guibg=#FDEB61

