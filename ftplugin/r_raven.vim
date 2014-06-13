" ftplugin/r_raven.vim - R support for raven
" Author: Michael Malick <malickmj@gmail.com>



if g:raven_source_send
    let g:source_send_selection = 'source("' . g:raven_tmp_file . '" , echo = TRUE)'
endif

let s:filetype_lang = "R"
let s:quit_lang = 'q(save = "no")'
let s:source_current_file = 'source("' . expand('%:p') . '")'
let s:source_load_file = 'source("load.R")'
let s:clear_console = 'system("clear")'
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
    let save_cursor = getpos(".")
    call RavenOpenPane()
    call RavenSendText(s:filetype_lang)
    call RavenSendKeys("Enter")
    call setpos('.', save_cursor)
endfunction


function! s:RavenClearR()
    let save_cursor = getpos(".")
    call RavenSend(s:clear_console)
    call setpos('.', save_cursor)
endfunction


function! s:RavenFunctionR()
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
    let save_cursor = getpos(".")
    call RavenSend(s:source_current_file)
    call setpos('.', save_cursor)
endfunction



nnoremap <silent> <Plug>RavenOpenR :call <SID>RavenOpenR()<CR>
nnoremap <silent> <Plug>RavenSourceFileR :call <SID>RavenSourceFileR()<CR>
nnoremap <silent> <Plug>RavenFunctionR :call <SID>RavenFunctionR()<CR>
nnoremap <silent> <Plug>RavenHelpPromptR :call <SID>RavenHelpPromptR()<CR>
nnoremap <silent> <Plug>RavenClearR :call <SID>RavenClearR()<CR>


if !exists('g:raven_map_keys') || g:raven_map_keys
    nmap <leader>ro <Plug>RavenOpenR
    nmap <leader>rs <Plug>RavenSourceFileR
    nmap <leader>rf <Plug>RavenFunctionR
    nmap <leader>rh <Plug>RavenHelpPromptR
    nmap <leader>rc <Plug>RavenClearR
endif



" vim:fdm=marker
