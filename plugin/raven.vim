" raven.vim - Send code to tmux pane
" Author:     Michael Malick <malickmj@gmail.com>
" Version:    0.0.1



if exists('g:loaded_raven') || &cp || v:version < 700
  finish
endif

let g:loaded_raven = 1
let g:raven_split_pane_percent = 30
let g:raven_split_pane_vertical = 1
let g:raven_tmp_file = "/tmp/vim-raven-tmp-file"
let g:raven_source_send = 0




" -----------------------------------
" Mapped Function {{{
" -----------------------------------
function! RavenOpenPane()
    if !exists("s:raven_pane_number")
        if(g:raven_split_pane_vertical == 0)
            call system("tmux split-window -v -p " . g:raven_split_pane_percent)
        else
            call system("tmux split-window -h -p " . g:raven_split_pane_percent)
        endif
        call s:RavenTmuxInfo()
        call system("tmux last-pane")
    else
        echo "Raven Pane Is Already Open"
    endif
endfunction


function! RavenSendSelection()
    if exists("s:raven_pane_number")
        call s:RavenSaveSelection()
        if exists("g:source_send_selection")
            call RavenSendText('"' . RavenEscText(g:source_send_selection) . '"')
            call RavenSendKeys("Enter")
        else
            let g:select_text = readfile(g:raven_tmp_file)
            for i in g:select_text
                call RavenSendText('"' . RavenEscText(i) . '"')
                call RavenSendKeys("Enter")
            endfor
        endif
    else
        echo "No Raven Pane Started"
    endif
endfunction


function! RavenSendLine()
    if exists("s:raven_pane_number")
        let save_cursor = getpos(".")
        let current_line = getline(".")
        call RavenSendText('"' . RavenEscText(current_line) . '"')
        call RavenSendKeys("Enter")
        call setpos('.', save_cursor)
    else
        echo "No Raven Pane Started"
    endif
endfunction


function! RavenSendParagraph()
    let save_cursor = getpos(".")
    exe "normal! vip"
    call RavenSendSelection()
    exe "normal! \<Esc>"
    call setpos('.', save_cursor)
endfunction


function! RavenKillPane()
    if exists("s:raven_pane_number") 
        call system("tmux kill-pane -t " . s:raven_pane_number)
        unlet s:raven_pane_number
        unlet s:raven_window_number
        unlet s:raven_session_number
    else
        echo "No Raven Pane To Kill"
    endif
endfunction

" }}}



" -----------------------------------
" Utility Function {{{
" -----------------------------------
function! RavenSendText(text)
    " include the literal flag so Tmux keywords are not looked up
    call system("tmux send-keys -l -t " . s:raven_target . " " . a:text)
endfunction


function! RavenSendKeys(keys)
    call system("tmux send-keys -t " . "1" . " " . a:keys)
endfunction


function! RavenEscText(text)
    let esc_text = escape(a:text, '"$;')
    return(esc_text)
endfunction


function! s:RavenSaveSelection()
    " '< '> marks are not set until after you leave the selection
    exe "normal! \<Esc>"
    let [lnum1, col1] = getpos("'<")[1:2]
    let [lnum2, col2] = getpos("'>")[1:2]
    let lines = getline(lnum1, lnum2)
    let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][col1 - 1:]
    call writefile(lines, g:raven_tmp_file)
endfunction


function! s:RavenTmuxInfo()
    " Pane number doesn't update if layout changes
    " Tmux re-indexes pane number when new panes are created
    let s:raven_pane_number = substitute(system('tmux display-message -p "#P"'), '\n$', '','')
    let s:raven_window_number = substitute(system('tmux display-message -p "#I"'), '\n$', '','')
    let s:raven_session_number = substitute(system('tmux display-message -p "#S"'), '\n$', '','')
    let s:raven_target = s:raven_session_number . ":" . s:raven_window_number . "." . s:raven_pane_number
endfunction

" }}}



" need <c-u> to clear selection brackets (i.e., '<,'>) before calls
nnoremap <silent> <Plug>RavenOpenPane :<c-u> call RavenOpenPane()<CR>
nnoremap <silent> <Plug>RavenKillPane :<c-u> call RavenKillPane()<CR>
nnoremap <silent> <Plug>RavenSendLine :<c-u> call RavenSendLine()<CR>
vnoremap <silent> <Plug>RavenSendSelection :<c-u> call RavenSendSelection()<CR>
nnoremap <silent> <Plug>RavenSendParagraph :<c-u> call RavenSendParagraph()<CR>


if !exists('g:raven_map_keys') || g:raven_map_keys
    nmap <leader>ro  <Plug>RavenOpenPane
    nmap <leader>rq  <Plug>RavenKillPane
    nmap <leader>rd  <Plug>RavenSendLine
    vmap <leader>rs  <Plug>RavenSendSelection
    nmap <leader>rs  <Plug>RavenSendParagraph
endif



" vim:fdm=marker
