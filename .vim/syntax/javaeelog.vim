" Vim syntax file

" quit when a syntax file was already loaded.
if exists("b:XXcurrent_syntax")
  finish
endif
syn clear

for colnm in ['black', 'red', 'green', 'blue', 'cyan', 'magenta', 'yellow', 'white']
  for prefix in ((colnm=='white' || colnm=='black') ? [''] : ['', 'light', 'dark'])
    let color=prefix.colnm
    exec 'hi '.color.' ctermfg='.color.' guifg='.color
    for [col1,col2] in [[color,'gray'],['white',color],[color,'lightred'],['black',color]]
      exec 'hi '.col1.'_on_'.col2.' ctermfg='.col1.' guifg='.col1.' ctermbg='.col2.' guibg='.col2
    endfor
  endfor
endfor

syn match LogLead             "^[^ ]* *[^,]*,[^ ]* *[0-9]* *[A-Z]\+ *\[[^]]\+] *(\S\+)"
syn match FileAndLine         "([a-zA-Z_-]\+\.java:[0-9]\+)"
syn match JavaPart    contained containedin=FileAndLine "[a-zA-Z_-]\+.java:"he=e-1
syn match ClassPart   contained containedin=LogLead "[a-zA-Z_-]\+:"he=e-1
syn match NumberPart  contained containedin=FileAndLine,LogLead "[0-9]\+)"he=e-1
syn match TimeStamp   contained containedin=LogLead "^[0-9]*-[0-9]*-[0-9]* [0-9]*:[0-9]*:[0-9]*,[0-9]*"
syn keyword LogDebug  contained containedin=LogLead DEBUG TRACE
syn keyword LogInfo   contained containedin=LogLead INFO
syn keyword LogWarn   contained containedin=LogLead WARN WARNING
syn keyword LogError  contained containedin=LogLead ERROR SEVERE FATAL
syn match ExceptError         "An error occurred at line: *[0-9]*[^:]*:.*"
syn match ExceptCausedBy      "^Caused by:.*"
syn match ExceptAmplex        "amplex"
syn match WildflyStartStop    /^ .\+WildFly \S\+ "Tweek".\+/hs=s+1
syn match WildflyErrors contained containedin=WildflyStartStop "(with errors)"

hi def link JavaPart           darkmagenta
hi def link ClassPart          darkmagenta
hi def link NumberPart         darkgreen
hi def link TimeStamp          darkblue
hi def link LogDebug           darkblue
hi def link LogInfo            darkgreen
hi def link LogWarn            darkyellow
hi def link LogError           darkred
hi def link ExceptError        darkred
hi def link ExceptCausedBy     darkred_on_gray
hi def link ExceptAmplex       darkred
hi def link WildflyStartStop   black_on_green
hi def link WildflyErrors      black_on_lightred

" Synchronization.
syn sync clear
let b:current_syntax = "javaeelog"

