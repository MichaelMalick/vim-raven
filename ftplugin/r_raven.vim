" ftplugin/r_raven.vim - R support for raven
" Author: Michael Malick <malickmj@gmail.com>



if !g:loaded_raven || &cp || v:version < 700
  finish
endif


if g:raven_source_send
    let g:source_send_selection = 'source("' . g:raven_tmp_file . '" , echo = TRUE)'
endif

let s:filetype_lang = "R"
let s:clear_console = 'system("clear")'
let s:set_work_directory = 'setwd("' . expand('%:p:h') . '")'
" SendFunction and RHelp are not lang agnostic


if !exists("*s:RavenHelpPromptR") 
    function! s:RavenHelpPromptR()
        let save_cursor = getpos(".")
        call inputsave()
        let fun = input('Enter Function: ')
        call inputrestore()
        belowright new
        execute "read !Rscript -e" . ' "help(' . fun . ')"'
        setlocal filetype=r
        setlocal bufhidden=wipe buftype=nofile
        setlocal nobuflisted nomodifiable noswapfile nowrap
        nnoremap <buffer> <silent> q :hide<CR>
        call setpos('.', save_cursor)
    endfunction
endif

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


function! s:RavenSendFunctionR()
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
    let source_current_file = 'source("' . expand('%:p') . '")'
    call RavenSendText(source_current_file)
    call setpos('.', save_cursor)
endfunction



nnoremap <silent> <Plug>RavenOpenR :call <SID>RavenOpenR()<CR>
nnoremap <silent> <Plug>RavenSourceFileR :call <SID>RavenSourceFileR()<CR>
nnoremap <silent> <Plug>RavenSendFunctionR :call <SID>RavenSendFunctionR()<CR>
nnoremap <silent> <Plug>RavenHelpPromptR :call <SID>RavenHelpPromptR()<CR>
nnoremap <silent> <Plug>RavenClearR :call <SID>RavenClearR()<CR>
nnoremap <silent> <Plug>RavenSetWorkDirR :call <SID>RavenSetWorkDirR()<CR>


if !exists('g:raven_map_keys') || g:raven_map_keys
    nmap <localleader>ro <Plug>RavenOpenR
    nmap <localleader>ri <Plug>RavenSourceFileR
    nmap <localleader>rf <Plug>RavenSendFunctionR
    nmap <localleader>rh <Plug>RavenHelpPromptR
    nmap <localleader>rc <Plug>RavenClearR
    nmap <localleader>rw <Plug>RavenSetWorkDirR
endif



" vim:fdm=marker
