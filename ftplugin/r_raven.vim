" ftplugin/r_raven.vim - R support for raven
" Author: Michael Malick <malickmj@gmail.com>



" if !g:loaded_raven || &cp || v:version < 700
"   finish
" endif


if g:raven_source_send
    let g:source_send_selection = 'source("' . g:raven_tmp_file . '" , echo = TRUE)'
endif

let s:filetype_lang = "R"
let s:source_current_file = 'source("' . expand('%:p') . '")'
let s:clear_console = 'system("clear")'
let s:set_work_directory = 'setwd("' . expand('%:p:h') . '")'
" SendFunction and RHelp are not lang agnostic


function! s:RavenHelpPromptR()
    let save_cursor = getpos(".")
    call inputsave()
    let fun = input('Enter Function: ')
    call inputrestore()
    execute "!Rscript -e" . ' "help(' . fun . ')"'
    call setpos('.', save_cursor)
endfunction


function! s:RavenOpenR()
    if !exists("g:raven_pane_id")
        echo "No Raven Pane Selected"
        return
    endif
    let save_cursor = getpos(".")
    call RavenSendText(s:filetype_lang)
    call setpos('.', save_cursor)
endfunction


function! s:RavenSetWorkDirR()
    if !exists("g:raven_pane_id")
        echo "No Raven Pane Selected"
        return
    endif
    let save_cursor = getpos(".")
    call RavenSendText(s:set_work_directory)
    call setpos('.', save_cursor)
endfunction


function! s:RavenClearR()
    if !exists("g:raven_pane_id")
        echo "No Raven Pane Selected"
        return
    endif
    let save_cursor = getpos(".")
    call RavenSendText(s:clear_console)
    call setpos('.', save_cursor)
endfunction


function! s:RavenFunctionR()
    if !exists("g:raven_pane_id")
        echo "No Raven Pane Selected"
        return
    endif
    let save_cursor = getpos(".")
    call search('function(', 'bc')
    normal! V
    call search('{')
    normal! %
    call RavenSendSelection()
    execute "normal! \<Esc>"
    call setpos('.', save_cursor)
endfunction


function! s:RavenSourceFileR()
    if !exists("g:raven_pane_id")
        echo "No Raven Pane Selected"
        return
    endif
    let save_cursor = getpos(".")
    call RavenSendText(s:source_current_file)
    call setpos('.', save_cursor)
endfunction



nnoremap <silent> <Plug>RavenOpenR :call <SID>RavenOpenR()<CR>
nnoremap <silent> <Plug>RavenSourceFileR :call <SID>RavenSourceFileR()<CR>
nnoremap <silent> <Plug>RavenFunctionR :call <SID>RavenFunctionR()<CR>
nnoremap <silent> <Plug>RavenHelpPromptR :call <SID>RavenHelpPromptR()<CR>
nnoremap <silent> <Plug>RavenClearR :call <SID>RavenClearR()<CR>
nnoremap <silent> <Plug>RavenSetWorkDirR :call <SID>RavenSetWorkDirR()<CR>


if !exists('g:raven_map_keys') || g:raven_map_keys
    nmap <leader>rr <Plug>RavenOpenR
    nmap <leader>ri <Plug>RavenSourceFileR
    nmap <leader>rf <Plug>RavenFunctionR
    nmap <leader>rh <Plug>RavenHelpPromptR
    nmap <leader>rc <Plug>RavenClearR
    nmap <leader>rw <Plug>RavenSetWorkDirR
endif



" vim:fdm=marker
