""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-raven
"
" Maintainer: Michael Malick <malickmj@gmail.com>
"
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" linked to RavenSendSelection()
let g:source_send_selection = 'source("' . g:raven_tmp_file . '" , echo = TRUE)'
let s:filetype_lang = "R"
let s:quit_lang = 'q(save = "no")'
let s:source_current_file = 'source("' . expand('%:p') . '")'
let s:source_load_file = 'source("load.R")'

" SendFunction and RHelp still not lang agnostic



" -----------------------------------
" Mappings {{{
" -----------------------------------
if g:raven_map_keys

    nnoremap <silent> <leader>rf :call RavenOpenR()<CR>
    nnoremap <silent> <leader>rq :call RavenQuitR()<CR>
    nnoremap <silent> <leader>rs :call RavenSourceFileR()<CR>
    nnoremap <silent> <leader>rl :call RavenSourceLoadFileR()<CR>
    nnoremap <silent> <leader>f  :call RavenFunctionR()<CR>
    nnoremap <silent> <leader>rh :call RavenHelpWordR()<CR>
    nnoremap <silent> <leader>rH :call RavenHelpPromptR()<CR>

endif


" }}}



" -----------------------------------
" RavenHelpPromptR {{{
" -----------------------------------
function! RavenHelpPromptR()
    let save_cursor = getpos(".")
    call inputsave()
    let fun = input('Enter Function: ')
    call inputrestore()
    execute "!Rscript -e" . ' "help(' . fun . ')"'
    call setpos('.', save_cursor)
endfunction

function! RavenHelpWordR()
    let save_cursor = getpos(".")
    let fun = expand("<cword>")
    execute "!Rscript -e" . ' "help(' . fun . ')"'
    call setpos('.', save_cursor)
endfunction


" }}}



" -----------------------------------
" RavenOpenR {{{
" -----------------------------------
function! RavenOpenR()
    let save_cursor = getpos(".")
    call RavenOpenPane()
    call RavenSendText(s:filetype_lang)
    call setpos('.', save_cursor)
endfunction


" }}}


" -----------------------------------
" RavenQuitR {{{
" -----------------------------------
" TODO close pane also??
function! RavenQuitR()
    let save_cursor = getpos(".")
    call RavenSendText(s:quit_lang)
    call RavenKillPane()
    call setpos('.', save_cursor)
endfunction


" }}}


" -----------------------------------
" RavenFunctionR {{{
" -----------------------------------
function! RavenFunctionR()
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


" }}}


" -----------------------------------
" RavenSourceFileR {{{
" -----------------------------------
function! RavenSourceFileR()
    let save_cursor = getpos(".")
    call RavenSendText(s:source_current_file)
    call setpos('.', save_cursor)
endfunction


" }}}


" -----------------------------------
" RavenSourceLoadFileR {{{
" -----------------------------------
function! RavenSourceLoadFileR()
    let save_cursor = getpos(".")
    call RavenSendText(s:source_load_file)
    call setpos('.', save_cursor)
endfunction


" }}}




" vim:fdm=marker
