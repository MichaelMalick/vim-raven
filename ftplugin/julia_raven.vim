" ftplugin/julia_raven.vim - Julia support for raven
" Author: Michael Malick <malickmj@gmail.com>




if g:raven_source_send
    let g:source_send_selection = 'include("' . g:raven_tmp_file . '")'
endif

let s:filetype_lang = "julia"
let s:source_current_file = 'include("' . expand('%:p') . '")'
let s:clear_console = 'run(`clear`)'



function! s:RavenOpenJulia()
    let save_cursor = getpos(".")
    call RavenOpenPane()
    call RavenSendText(s:filetype_lang)
    call RavenSendKeys("Enter")
    call setpos('.', save_cursor)
endfunction


function! s:RavenClearJulia()
    let save_cursor = getpos(".")
    call RavenSend(s:clear_console)
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
    let save_cursor = getpos(".")
    call RavenSend(s:source_current_file)
    call setpos('.', save_cursor)
endfunction



nnoremap <silent> <Plug>RavenOpenJulia :call <SID>RavenOpenJulia()<CR>
nnoremap <silent> <Plug>RavenFunctionJulia :call <SID>RavenFunctionJulia()<CR>
nnoremap <silent> <Plug>RavenSourceFileJulia :call <SID>RavenSourceFileJulia()<CR>
nnoremap <silent> <Plug>RavenClearJulia :call <SID>RavenClearJulia()<CR>


if !exists('g:raven_map_keys') || g:raven_map_keys
    nmap <leader>ro <Plug>RavenOpenJulia
    nmap <leader>rs <Plug>RavenSourceFileJulia
    nmap <leader>rf <Plug>RavenFunctionJulia
    nmap <leader>rc <Plug>RavenClearJulia
endif





" vim:fdm=marker
