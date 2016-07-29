" ftplugin/r_raven.vim - R support for raven
" Author: Michael Malick <malickmj@gmail.com>


if !g:loaded_raven || &cp || v:version < 700
  finish
endif

if g:raven_source_send
    let g:raven_source_command = 'source("' . g:raven_tmp_file . '" , echo = TRUE)'
endif

let s:filetype_lang = "R"
let s:clear_console = 'system("clear")'
let s:set_work_directory = 'setwd("' . expand('%:p:h') . '")'


function! s:RavenOpenR()
    if !exists("g:raven_pane_id")
        echohl WarningMsg | echo "No tmux pane selected" | echohl None
        return
    endif
    let save_cursor = getpos(".")
    call raven#send_text(s:filetype_lang)
    call setpos('.', save_cursor)
endfunction

function! s:RavenSetWorkDirR()
    if !exists("g:raven_pane_id")
        echohl WarningMsg | echo "No tmux pane selected" | echohl None
        return
    endif
    let save_cursor = getpos(".")
    call raven#send_text(s:set_work_directory)
    call setpos('.', save_cursor)
endfunction

function! s:RavenClearR()
    if !exists("g:raven_pane_id")
        echohl WarningMsg | echo "No tmux pane selected" | echohl None
        return
    endif
    let save_cursor = getpos(".")
    call raven#send_text(s:clear_console)
    call setpos('.', save_cursor)
endfunction

function! s:RavenSendFunctionR()
    if !exists("g:raven_pane_id")
        echohl WarningMsg | echo "No tmux pane selected" | echohl None
        return
    endif
    let save_cursor = getpos(".")
    call search('<-\s*function\s*(', 'bc')
    normal! V
    call search('{')
    normal! %
    call raven#send_selection()
    exe "normal! \<Esc>"
    call setpos('.', save_cursor)
endfunction

function! s:RavenSendChunkR()
    if !exists("g:raven_pane_id")
        echohl WarningMsg | echo "No tmux pane selected" | echohl None
        return
    endif
    let save_cursor = getpos(".")
    call search('```', 'bc')
    normal! j
    normal! V
    call search('```')
    normal! k
    call raven#send_selection()
    exe "normal! \<Esc>"
    call setpos('.', save_cursor)
endfunction

function! s:RavenSourceFileR()
    if !exists("g:raven_pane_id")
        echohl WarningMsg | echo "No tmux pane selected" | echohl None
        return
    endif
    let save_cursor = getpos(".")
    let source_current_file = 'source("' . expand('%:p') . '")'
    call raven#send_text(source_current_file)
    call setpos('.', save_cursor)
endfunction


nnoremap <silent> <Plug>RavenOpenR :call <SID>RavenOpenR()<CR>
nnoremap <silent> <Plug>RavenSourceFileR :call <SID>RavenSourceFileR()<CR>
nnoremap <silent> <Plug>RavenSendFunctionR :call <SID>RavenSendFunctionR()<CR>
nnoremap <silent> <Plug>RavenSendChunkR :call <SID>RavenSendChunkR()<CR>
nnoremap <silent> <Plug>RavenClearR :call <SID>RavenClearR()<CR>
nnoremap <silent> <Plug>RavenSetWorkDirR :call <SID>RavenSetWorkDirR()<CR>

if g:raven_map_keys
    nmap <localleader>ro <Plug>RavenOpenR
    nmap <localleader>ri <Plug>RavenSourceFileR
    nmap <localleader>rf <Plug>RavenSendFunctionR
    nmap <localleader>rc <Plug>RavenClearR
    nmap <localleader>rw <Plug>RavenSetWorkDirR
    nmap <localleader>rm <Plug>RavenSendChunkR
endif

