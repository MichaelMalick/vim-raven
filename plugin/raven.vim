" raven.vim - Send code to tmux pane
" Author:     Michael Malick <malickmj@gmail.com>
" Version:    0.0.2



if exists('g:loaded_raven') || &cp || v:version < 700
  finish
endif

let g:loaded_raven = 1
let g:raven_split_pane_percent = 30
let g:raven_tmp_file = "/tmp/vim-raven-tmp-file"
let g:raven_source_send = 1

" -----------------------------------
" Mapped Function {{{
" -----------------------------------
function! RavenSelectPane()
    let session_number = system('tmux display-message -p "#S"')
    if len(session_number) > 5
        echo "Tmux Is Not Currently Running"
        return
    endif
    belowright new
    call setline(1, '# Enter: select pane | Esc/q: cancel | v: view pane numbers')
    call setline(2, '# Press 1 for a new horizontal pane')
    call setline(3, '# Press 2 for a new vertical pane')
    call setline(4, "")
    normal! G
    read !tmux list-panes -F '\#{pane_id}: \#{session_name}:\#{window_index}.\#{pane_index}: \#{window_name}: \#{pane_title} [\#{pane_width}x\#{pane_height}] \#{?pane_active,(active) ,}' -a | cat

    if exists("g:raven_pane_id")
        call search(g:raven_pane_id)
        exe 'normal! A(current)'
        exe 'normal! ^'
    else
        call setpos(".", [0, 5, 0, 0])
    endif

    setlocal bufhidden=wipe buftype=nofile
    setlocal nobuflisted nomodifiable noswapfile nowrap
    setlocal cursorline nocursorcolumn
    nnoremap <buffer> <silent> q :hide<CR>
    nnoremap <buffer> <silent> <Esc> :hide<CR>
    nnoremap <buffer> <silent> <Enter> :call RavenPickPane()<CR>
    nnoremap <buffer> <silent> v :call system("tmux display-panes")<CR>
    nnoremap <buffer> <silent> r :call RavenReloadPrompt()<CR>
    nnoremap <buffer> <silent> 1 :call RavenOpenPane('v')<CR>
    nnoremap <buffer> <silent> 2 :call RavenOpenPane('h')<CR>
endfunction


function! RavenSendSelection()
    if !exists("g:raven_pane_id")
        echo "No Raven Pane Selected"
        return
    endif
    call s:RavenSaveSelection()
    if exists("g:source_send_selection")
        call RavenSendText(g:source_send_selection)
        call s:RavenSendKeys("Enter")
    else
        let g:select_text = readfile(g:raven_tmp_file)
        for i in g:select_text
            call RavenSendText(i)
        endfor
    endif
endfunction


function! RavenSendLine()
    if !exists("g:raven_pane_id")
        echo "No Raven Pane Selected"
        return
    endif
    let save_cursor = getpos(".")
    let current_line = getline(".")
    call RavenSendText(current_line)
    call setpos('.', save_cursor)
endfunction


function! RavenSendParagraph()
    let save_cursor = getpos(".")
    exe "normal! vip"
    call RavenSendSelection()
    exe "normal! \<Esc>"
    call setpos('.', save_cursor)
endfunction


function! RavenKillPane()
    if !exists("g:raven_pane_id")
        echo "No Raven Pane To Kill"
        return
    endif
    call system("tmux kill-pane -t " . g:raven_pane_id)
    unlet g:raven_pane_id
endfunction

" }}}



" -----------------------------------
" Utility Function {{{
" -----------------------------------
function! RavenSendText(text)
    if !exists("g:raven_pane_id")
        echo "No Raven Pane Selected"
        return
    endif
    let send_text = '"' . s:RavenEscText(a:text) . '"'
    " include the literal flag so Tmux keywords are not looked up
    call system("tmux send-keys -l -t " . g:raven_pane_id . " " . send_text)
    call s:RavenSendKeys("Enter")
endfunction


function! RavenPickPane()
    call RavenPaneMatch() 
    if len(s:pane_match) == 0
        echo "Please select a pane with enter or exit with 'q'"
        return
    endif
    let g:raven_pane_id = s:pane_match[1]
    hide
endfunction


function! RavenReloadPrompt()
    hide
    call RavenSelectPane()
endfunction


function! RavenPaneMatch()
    let line = getline(".")
    let s:pane_match = matchlist(line, '\(^[^ ]\+\)\: ')
endfunction


function! RavenOpenPane(dir)
    call system("tmux split-window -" . a:dir . " -p " . g:raven_split_pane_percent)
    let g:raven_pane_id = substitute(system('tmux display-message -p "#D"'), '\n$', '','')
    call system("tmux last-pane")
    hide
endfunction


function! s:RavenSendKeys(keys)
    call system("tmux send-keys -t " . g:raven_pane_id . " " . a:keys)
endfunction


function! s:RavenEscText(text)
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

" }}}


command! -range=0 -complete=shellcmd -nargs=+ Raven call RavenSendText(<q-args>)


" need <c-u> to clear selection brackets (i.e., '<,'>) before calls
nnoremap <silent> <Plug>RavenSend :<c-u> call RavenSend()<CR>
nnoremap <silent> <Plug>RavenKillPane :<c-u> call RavenKillPane()<CR>
nnoremap <silent> <Plug>RavenSendLine :<c-u> call RavenSendLine()<CR>
vnoremap <silent> <Plug>RavenSendSelection :<c-u> call RavenSendSelection()<CR>
nnoremap <silent> <Plug>RavenSendParagraph :<c-u> call RavenSendParagraph()<CR>
nnoremap <silent> <Plug>RavenSelectPane :<c-u> call RavenSelectPane()<CR>


if !exists('g:raven_map_keys') || g:raven_map_keys
    nmap <leader>rr  <Plug>RavenSelectPane
    nmap <leader>rq  <Plug>RavenKillPane
    nmap <leader>rd  <Plug>RavenSendLine
    vmap <leader>rs  <Plug>RavenSendSelection
    nmap <leader>rs  <Plug>RavenSendParagraph
endif



" vim:fdm=marker
