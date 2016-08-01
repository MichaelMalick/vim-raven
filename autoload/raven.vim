" raven.vim - autoload
" Author:     Michael Malick <malickmj@gmail.com>


"" Send functions ------------------------------------------
function! raven#send_line()
    if !exists("g:raven_pane_id")
        echohl WarningMsg | echo "No tmux pane selected" | echohl None
        return
    endif
    let save_cursor = getpos(".")
    let current_line = getline(".")
    call raven#send_text(current_line)
    call setpos('.', save_cursor)
endfunction

function! raven#send_paragraph()
    if !exists("g:raven_pane_id")
        echohl WarningMsg | echo "No tmux pane selected" | echohl None
        return
    endif
    let l:win_view = winsaveview()
    exe "normal! vip"
    call raven#send_selection()
    exe "normal! \<Esc>"
    call winrestview(l:win_view)
endfunction

function! raven#send_fold()
    if !exists("g:raven_pane_id")
        echohl WarningMsg | echo "No tmux pane selected" | echohl None
        return
    endif
    let l:startpos = getpos('.')
    let l:win_view = winsaveview()
    let l:found = search('{{{', 'nbcW', 1)
    if !l:found
        echo "Not inside a fold"
        return
    else
        call search('{{{', 'bc')
        let l:foldstart = getpos('.')
        normal! %
        let l:foldend = getpos('.')
        if l:startpos[1] < l:foldstart[1] || l:startpos[1] > l:foldend[1]
            echo "Not inside a fold"
            call setpos('.', l:startpos)
            call winrestview(l:win_view)
            return
        else
            call setpos('.', l:foldstart)
            normal! V
            call setpos('.', l:foldend)
            call raven#send_selection()
            exe "normal! \<Esc>"
        endif
    endif
    call winrestview(l:win_view)
endfunction

function! raven#send_selection()
    if !exists("g:raven_pane_id")
        echohl WarningMsg | echo "No tmux pane selected" | echohl None
        return
    endif
    call raven#save_selection()
    let start_line = line("'<")
    let end_line = line("'>")
    if exists("g:raven_source_command") && start_line != end_line
        call raven#send_text(g:raven_source_command)
        call raven#send_keys("Enter")
    else
        let select_text = readfile(g:raven_tmp_file)
        for i in select_text
            call raven#send_text(i)
        endfor
    endif
endfunction

function! raven#send_text(text)
    if !exists("g:raven_pane_id")
        echohl WarningMsg | echo "No tmux pane selected" | echohl None
        return
    endif
    let send_text = shellescape(a:text)
    " include the literal flag so Tmux keywords are not looked up
    call system("tmux send-keys -l -t " . g:raven_pane_id . " " . send_text)
    call raven#send_keys("Enter")
endfunction

function! raven#send_keys(keys)
    call system("tmux send-keys -t " . g:raven_pane_id . " " . a:keys)
endfunction

function! raven#save_selection()
    " '< '> marks are not set until after you leave the selection
    exe "normal! \<Esc>"
    let [lnum1, col1] = getpos("'<")[1:2]
    let [lnum2, col2] = getpos("'>")[1:2]
    let lines = getline(lnum1, lnum2)
    let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][col1 - 1:]
    call writefile(lines, g:raven_tmp_file)
endfunction


"" Tmux functions ------------------------------------------
function! raven#pane_select()
    let session_number = system('tmux display-message -p "#S"')
    if len(session_number) > 5
        echohl WarningMsg | echo "Tmux is not currently running" | echohl None
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
    nnoremap <buffer> <silent> <Enter> :call raven#pane_pick()<CR>
    nnoremap <buffer> <silent> v :call system("tmux display-panes")<CR>
    nnoremap <buffer> <silent> r :call raven#reload_prompt()<CR>
    nnoremap <buffer> <silent> 1 :call raven#pane_open('v')<CR>
    nnoremap <buffer> <silent> 2 :call raven#pane_open('h')<CR>
endfunction

function! raven#pane_kill()
    if !exists("g:raven_pane_id")
        echohl WarningMsg | echo "No raven pane to kill" | echohl None
        return
    endif
    call system("tmux kill-pane -t " . g:raven_pane_id)
    unlet g:raven_pane_id
endfunction

function! raven#pane_pick()
    call raven#pane_match()
    if len(s:pane_match) == 0
        echo "Please select a pane with enter or exit with 'q'"
        return
    endif
    let g:raven_pane_id = s:pane_match[1]
    hide
endfunction

function! raven#reload_prompt()
    hide
    call raven#pane_select()
endfunction

function! raven#pane_match()
    let line = getline(".")
    let s:pane_match = matchlist(line, '\(^[^ ]\+\)\: ')
endfunction

function! raven#pane_open(dir)
    call system("tmux split-window -" . a:dir . " -p " . g:raven_split_pane_percent)
    let g:raven_pane_id = substitute(system('tmux display-message -p "#D"'), '\n$', '','')
    call system("tmux last-pane")
    hide
endfunction

