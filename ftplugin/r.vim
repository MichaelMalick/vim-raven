""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-raven
"
" Maintainer: Michael Malick <malickmj@gmail.com>
"
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" SendFunction and RHelp still not lang agnostic



" linked to RavenSendSelection()

if g:raven_source_send
    let g:source_send_selection = 'source("' . g:raven_tmp_file . '" , echo = TRUE)'
endif

let s:filetype_lang = "R"
let s:quit_lang = 'q(save = "no")'
let s:source_current_file = 'source("' . expand('%:p') . '")'
let s:source_load_file = 'source("load.R")'



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
    call RavenSendKeys(s:filetype_lang)
    call RavenSendKeys("Enter")
    call setpos('.', save_cursor)
endfunction


" }}}


" -----------------------------------
" RavenQuitR {{{
" -----------------------------------
function! RavenQuitR()
    let save_cursor = getpos(".")
    call RavenSendKeys('"' . RavenEscText(s:quit_lang) . '"')
    call RavenSendKeys("Enter")
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
    call RavenSendKeys('"' . RavenEscText(s:source_current_file) . '"')
    call RavenSendKeys("Enter")
    call setpos('.', save_cursor)
endfunction


" }}}


" -----------------------------------
" RavenSourceLoadFileR {{{
" -----------------------------------
function! RavenSourceLoadFileR()
    let save_cursor = getpos(".")
    call RavenSendKeys('"' . RavenEscText(s:source_load_file) . '"')
    call RavenSendKeys("Enter")
    call setpos('.', save_cursor)
endfunction


" }}}




" vim:fdm=marker
