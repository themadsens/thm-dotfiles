

" Automatically open the taglist window on Vim startup
"   let Tlist_Auto_Open = 0

" When the taglist window is toggle opened, move the cursor to the
" taglist window
"   let Tlist_GainFocus_On_ToggleOpen = 0

" Process files even when the taglist window is not open
"   let Tlist_Process_File_Always = 0

let Tlist_Show_Menu = 1

" Tag listing sort type - 'name' or 'order'
"   let Tlist_Sort_Type = 'order'

" Tag listing window split (horizontal/vertical) control
"   let Tlist_Use_Horiz_Window = 0

" Open the vertically split taglist window on the left or on the right
" side.  This setting is relevant only if Tlist_Use_Horiz_Window is set to
" zero (i.e.  only for vertically split windows)
let Tlist_Use_Right_Window = 1

" Increase Vim window width to display vertically split taglist window.
" For MS-Windows version of Vim running in a MS-DOS window, this must be
" set to 0 otherwise the system may hang due to a Vim limitation.
"       let Tlist_Inc_Winwidth = 1

" Vertically split taglist window width setting
let Tlist_WinWidth = 50

" Horizontally split taglist window height setting
"   let Tlist_WinHeight = 10

" Display tag prototypes or tag names in the taglist window
"   let Tlist_Display_Prototype = 0

" Display tag scopes in the taglist window
"   let Tlist_Display_Tag_Scope = 1

" Use single left mouse click to jump to a tag. By default this is disabled.
" Only double click using the mouse will be processed.
"   let Tlist_Use_SingleClick = 0

" Control whether additional help is displayed as part of the taglist or
" not.  Also, controls whether empty lines are used to separate the tag
" tree.
"   let Tlist_Compact_Format = 0

" Exit Vim if only the taglist window is currently open. By default, this is
" set to zero.
"   let Tlist_Exit_OnlyWindow = 0

" Automatically close the folds for the non-active files in the taglist
" window
"   let Tlist_File_Fold_Auto_Close = 0

" Close the taglist window when a tag is selected
"   let Tlist_Close_On_Select = 0

" Automatically update the taglist window to display tags for newly
" edited files
"   let Tlist_Auto_Update = 1

" Automatically highlight the current tag
let Tlist_Auto_Highlight_Tag = 0

" Automatically highlight the current tag on entering a buffer
"   let Tlist_Highlight_Tag_On_BufEnter = 1

" Enable fold column to display the folding for the tag tree
"   let Tlist_Enable_Fold_Column = 1

" Display the tags for only one file in the taglist window
"   let Tlist_Show_One_File = 0
"   let Tlist_Max_Submenu_Items = 20
"   let Tlist_Max_Tag_Length = 10
