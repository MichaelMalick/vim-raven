" ftplugin/julia_raven.vim - Julia support for raven
" Author: Michael Malick <malickmj@gmail.com>


if !g:loaded_raven || &cp || v:version < 700
  finish
endif

if g:raven_source_send
    let g:raven_source_command = 'include("' . g:raven_tmp_file . '")'
endif

let s:filetype_lang = "julia"
let s:clear_console = 'run(`clear`)'
let s:set_work_directory = 'cd("' . expand('%:p:h') . '")'


function! s:RavenOpenJulia()
    if !exists("g:raven_pane_id")
        echohl WarningMsg | echo "No tmux pane selected" | echohl None
        return
    endif
    let save_cursor = getpos(".")
    call raven#send_text(s:filetype_lang)
    call setpos('.', save_cursor)
endfunction

function! s:RavenSetWorkDirJulia()
    if !exists("g:raven_pane_id")
        echohl WarningMsg | echo "No tmux pane selected" | echohl None
        return
    endif
    let save_cursor = getpos(".")
    call raven#send_text(s:set_work_directory)
    call setpos('.', save_cursor)
endfunction

function! s:RavenClearJulia()
    if !exists("g:raven_pane_id")
        echohl WarningMsg | echo "No tmux pane selected" | echohl None
        return
    endif
    let save_cursor = getpos(".")
    call raven#send_text(s:clear_console)
    call setpos('.', save_cursor)
endfunction

function! s:RavenSendFunctionJulia()
    if !exists("g:raven_pane_id")
        echohl WarningMsg | echo "No tmux pane selected" | echohl None
        return
    endif
    let save_cursor = getpos(".")
    call search('function', 'bc')
    normal! ^V
    normal! %
    call raven#send_selection()
    exe "normal! \<Esc>"
    call setpos('.', save_cursor)
endfunction

function! s:RavenSourceFileJulia()
    if !exists("g:raven_pane_id")
        echohl WarningMsg | echo "No tmux pane selected" | echohl None
        return
    endif
    let save_cursor = getpos(".")
    call raven#send_text('include("' . expand('%:p') . '")')
    call setpos('.', save_cursor)
endfunction

function! s:RavenReloadFileJulia()
    if !exists("g:raven_pane_id")
        echohl WarningMsg | echo "No tmux pane selected" | echohl None
        return
    endif
    let save_cursor = getpos(".")
    call raven#send_text('reload("' . expand('%:p') . '")')
    call setpos('.', save_cursor)
endfunction


nnoremap <silent> <Plug>RavenOpenJulia :call <SID>RavenOpenJulia()<CR>
nnoremap <silent> <Plug>RavenSourceFileJulia :call <SID>RavenSourceFileJulia()<CR>
nnoremap <silent> <Plug>RavenReloadFileJulia :call <SID>RavenReloadFileJulia()<CR>
nnoremap <silent> <Plug>RavenSendFunctionJulia :call <SID>RavenSendFunctionJulia()<CR>
nnoremap <silent> <Plug>RavenClearJulia :call <SID>RavenClearJulia()<CR>
nnoremap <silent> <Plug>RavenSetWorkDirJulia :call <SID>RavenSetWorkDirJulia()<CR>

if g:raven_map_keys
    nmap <localleader>ro <Plug>RavenOpenJulia
    nmap <localleader>ri <Plug>RavenSourceFileJulia
    nmap <localleader>rf <Plug>RavenSendFunctionJulia
    nmap <localleader>rc <Plug>RavenClearJulia
    nmap <localleader>rw <Plug>RavenSetWorkDirJulia
    nmap <localleader>rj <Plug>RavenReloadFileJulia
endif

