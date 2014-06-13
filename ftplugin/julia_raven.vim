" ftplugin/julia_raven.vim - Julia support for raven
" Author: Michael Malick <malickmj@gmail.com>



" if exists('g:loaded_raven') || &cp || v:version < 700
"   finish
" endif


if g:raven_source_send
    let g:source_send_selection = 'include("' . g:raven_tmp_file . '")'
endif

let s:filetype_lang = "julia"
let s:source_current_file = 'include("' . expand('%:p') . '")'
let s:clear_console = 'run(`clear`)'
let s:set_work_directory = 'cd("' . expand('%:p:h') . '")'


function! s:RavenOpenJulia()
    if !exists("g:raven_pane_id") 
        call RavenPromptPane()
    else
        let save_cursor = getpos(".")
        call RavenSendText(s:filetype_lang)
        call setpos('.', save_cursor)
    endif
endfunction


function! s:RavenSetWorkDirJulia()
    if !exists("g:raven_pane_id")
        echo "No Raven Pane Selected"
        return
    endif
    let save_cursor = getpos(".")
    call RavenSendText(s:set_work_directory)
    call setpos('.', save_cursor)
endfunction


function! s:RavenClearJulia()
    if !exists("g:raven_pane_id")
        echo "No Raven Pane Selected"
        return
    endif
    let save_cursor = getpos(".")
    call RavenSendText(s:clear_console)
    call setpos('.', save_cursor)
endfunction


function! s:RavenFunctionJulia()
    let save_cursor = getpos(".")
    call search('function', 'bc')
    normal! ^V
    normal! %
    call RavenSendSelection()
    execute "normal! \<Esc>"
    call setpos('.', save_cursor)
endfunction


function! s:RavenSourceFileJulia()
    if !exists("g:raven_pane_id")
        echo "No Raven Pane Selected"
        return
    endif
    let save_cursor = getpos(".")
    call RavenSendText(s:source_current_file)
    call setpos('.', save_cursor)
endfunction



nnoremap <silent> <Plug>RavenOpenJulia :call <SID>RavenOpenJulia()<CR>
nnoremap <silent> <Plug>RavenSourceFileJulia :call <SID>RavenSourceFileJulia()<CR>
nnoremap <silent> <Plug>RavenFunctionJulia :call <SID>RavenFunctionJulia()<CR>
nnoremap <silent> <Plug>RavenClearJulia :call <SID>RavenClearJulia()<CR>
nnoremap <silent> <Plug>RavenSetWorkDirJulia :call <SID>RavenSetWorkDirJulia()<CR>


if !exists('g:raven_map_keys') || g:raven_map_keys
    nmap <leader>ro <Plug>RavenOpenJulia
    nmap <leader>ri <Plug>RavenSourceFileJulia
    nmap <leader>rf <Plug>RavenFunctionJulia
    nmap <leader>rc <Plug>RavenClearJulia
    nmap <leader>rw <Plug>RavenSetWorkDirJulia
endif



" vim:fdm=marker

