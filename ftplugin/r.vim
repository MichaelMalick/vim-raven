""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-raven
"
" Maintainer: Michael Malick <malickmj@gmail.com>
"
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" SendFunction and RHelp still not lang agnostic



if g:raven_source_send
    let g:source_send_selection = 'source("' . g:raven_tmp_file . '" , echo = TRUE)'
endif

let s:filetype_lang = "R"
let s:quit_lang = 'q(save = "no")'
let s:source_current_file = 'source("' . expand('%:p') . '")'
let s:source_load_file = 'source("load.R")'


function! s:RavenHelpPromptR()
    let save_cursor = getpos(".")
    call inputsave()
    let fun = input('Enter Function: ')
    call inputrestore()
    execute "!Rscript -e" . ' "help(' . fun . ')"'
    call setpos('.', save_cursor)
endfunction


function! s:RavenHelpWordR()
    let save_cursor = getpos(".")
    let fun = expand("<cword>")
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


function! s:RavenFunctionR()
    let save_cursor = getpos(".")
    execute 'normal! ?' . "<- function(" . "\<CR>"
    normal! ^
    normal! v
    execute 'normal! /' . "{" . "\<CR>"
    normal! %
    call RavenSendSelection()
    execute "normal! \<Esc>"
    call setpos('.', save_cursor)
endfunction


function! s:RavenSourceFileR()
    let save_cursor = getpos(".")
    call RavenSendText('"' . RavenEscText(s:source_current_file) . '"')
    call RavenSendKeys("Enter")
    call setpos('.', save_cursor)
endfunction


function! s:RavenSourceLoadFileR()
    let save_cursor = getpos(".")
    call RavenSendText('"' . RavenEscText(s:source_load_file) . '"')
    call RavenSendKeys("Enter")
    call setpos('.', save_cursor)
endfunction



nnoremap <silent> <Plug>RavenOpenR :call <SID>RavenOpenR()<CR>
nnoremap <silent> <Plug>RavenSourceFileR :call <SID>RavenSourceFileR()<CR>
nnoremap <silent> <Plug>RavenSourceLoadFileR :call <SID>RavenSourceLoadFileR()<CR>
nnoremap <silent> <Plug>RavenFunctionR :call <SID>RavenFunctionR()<CR>
nnoremap <silent> <Plug>RavenHelpWordR :call <SID>RavenHelpWordR()<CR>
nnoremap <silent> <Plug>RavenHelpPromptR :call <SID>RavenHelpPromptR()<CR>


if !exists('g:raven_map_keys') || g:raven_map_keys
    nmap <leader>ro <Plug>RavenOpenR
    nmap <leader>rs <Plug>RavenSourceFileR
    nmap <leader>rl <Plug>RavenLoadFileR
    nmap <leader>rf <Plug>RavenFunctionR
    nmap <leader>rh <Plug>RavenHelpWordR
    nmap <leader>rH <Plug>RavenHelpPrompR
endif



" vim:fdm=marker
