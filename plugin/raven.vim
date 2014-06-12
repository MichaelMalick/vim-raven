""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-raven
"
" Maintainer: Michael Malick <malickmj@gmail.com>
"
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 
" TODO
"   - Julia support
"   - Pane number doesn't update if layout changes
"       - Tmux re-index pane number when new panes are created
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if exists('g:loaded_raven') || &cp || v:version < 700
  finish
endif
let g:loaded_raven = 1


" User defined variables
let g:raven_split_pane_percent = 30
let g:raven_split_pane_vertical = 1
let g:raven_tmp_file = "/tmp/vim-raven-tmp-file"
let g:raven_use_tmp_file = 0


" -----------------------------------
" Mappings {{{
" -----------------------------------
if !exists('g:raven_map_keys')
    let g:raven_map_keys = 1
endif

if g:raven_map_keys

    " need <c-u> to clear selection brackets (i.e., '<,'>) before calls
    vnoremap <silent> <leader>d   :<c-u> call RavenSendSelection()<CR>
    nnoremap <silent> <leader>d   :<c-u> call RavenSendLine()<CR>
    nnoremap <silent> <leader>s   :<c-u> call RavenSendParagraph()<CR>
    nnoremap <silent> <leader>rp  :call RavenOpenPane()<CR>

endif

" }}}





function! RavenTmuxInfo()
    let g:raven_pane_number = system('tmux display-message -p "#P"')
    let g:raven_pane_name = system('tmux display-message -p "#T"')
    let g:raven_window_number = system('tmux display-message -p "#I"')
    let g:raven_session_number = system('tmux display-message -p "#S"')
endfunction

function! RavenKillPane()
    call system("tmux kill-pane -t " . g:raven_pane_number)
endfunction




" -----------------------------------
" RavenOpenPane {{{
" -----------------------------------
function! RavenOpenPane()
    if !exists("g:raven_pane_number")
        if(g:raven_split_pane_vertical == 0)
            call system("tmux split-window -v -p " . g:raven_split_pane_percent)
        else
            call system("tmux split-window -h -p " . g:raven_split_pane_percent)
        endif
        call RavenTmuxInfo()
        call system("tmux last-pane")
    else
        echo "Raven Pane Is Already Open"
    endif
endfunction


" }}}


" -----------------------------------
" RavenSendKeys {{{
" -----------------------------------
function! RavenSendKeys(keys)
    if exists("g:raven_pane_number")
        call system("tmux send-keys -t " . "1" . " " . a:keys)
    else
        echo "No Raven Pane Started"
    endif
endfunction


" }}}


" -----------------------------------
" RavenSendText {{{
" -----------------------------------
function! RavenSendText(text)
    "let save_cursor = getpos(".")
    call RavenSendKeys('"'.escape(a:text, '"').'"')
    call RavenSendKeys("Enter")
    "call setpos('.', save_cursor)
endfunction


" }}}


" -----------------------------------
" RavenSendSelection {{{
" -----------------------------------
function! RavenSendSelection()
    call RavenSaveSelection()
    call RavenSendText(g:source_send_selection)
    call RavenSendKeys("Enter")
endfunction






" }}}


" -----------------------------------
" RavenSendLine {{{
" -----------------------------------
" TODO take count see:
" https://github.com/jpalardy/vim-slime/blob/master/plugin/slime.vim
" function! RavenSendLine()
"     let save_cursor = getpos(".")
"     let rv = getreg('"')
"     let rt = getregtype('"')
"     exe "normal! yy"
"     call RavenSendKeys('"'.escape(@", '"$').'"')
"     call setreg('"', rv, rt)
"     call setpos('.', save_cursor)
" endfunction

function! RavenSendLine()
    let save_cursor = getpos(".")
    let current_line = getline(".")
    call RavenSendKeys('"' . escape(current_line, '"$') . '"')
    call RavenSendKeys("Enter")
    call setpos('.', save_cursor)
endfunction




" }}}


" -----------------------------------
" RavenSendParagraph {{{
" -----------------------------------
function! RavenSendParagraph()
    let save_cursor = getpos(".")
    exe "normal! vip"
    call RavenSendSelection()
    exe "normal! \<Esc>"
    call setpos('.', save_cursor)
endfunction


" }}}


" -----------------------------------
" RavenSaveSelection {{{
" -----------------------------------
" https://stackoverflow.com/questions/1533565/how-to-get-visually-selected-text-in-vimscript
function! RavenSaveSelection()
  " '< '> marks are not set until after you leave the selection
  exe "normal! \<Esc>"
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][col1 - 1:]
  call writefile(lines, "/tmp/vim-raven-tmp-file")
endfunction


" }}}




" vim:fdm=marker
