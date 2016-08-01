" raven.vim - Send code to tmux pane
" Author:     Michael Malick <malickmj@gmail.com>
" Version:    0.0.2


if exists('g:loaded_raven') || &cp || v:version < 700 || !executable('tmux')
  finish
endif

let g:loaded_raven = 1

if !exists('g:raven_split_pane_percent')
    let g:raven_split_pane_percent = 30
endif

if !exists('g:raven_tmp_file')
    let g:raven_tmp_file = tempname()
endif

if !exists('g:raven_source_send')
    let g:raven_source_send = 0
endif

if !exists('g:raven_map_keys')
    let g:raven_map_keys = 1
endif


command! -range=0 -complete=shellcmd -nargs=+ Raven call raven#send_text(<q-args>)
command! RavenPanes call raven#pane_select()

" need <c-u> to clear selection brackets (i.e., '<,'>) before calls
nnoremap <silent> <Plug>RavenKillPane :<c-u> call raven#pane_kill()<CR>
nnoremap <silent> <Plug>RavenSendLine :<c-u> call raven#send_line()<CR>
vnoremap <silent> <Plug>RavenSendSelection :<c-u> call raven#send_selection()<CR>
nnoremap <silent> <Plug>RavenSendParagraph :<c-u> call raven#send_paragraph()<CR>
nnoremap <silent> <Plug>RavenSendFold :<c-u> call raven#send_fold()<CR>
nnoremap <silent> <Plug>RavenSelectPane :<c-u> call raven#pane_select()<CR>

if g:raven_map_keys
    nmap <localleader>rr  <Plug>RavenSelectPane
    nmap <localleader>rd  <Plug>RavenSendLine
    vmap <localleader>rs  <Plug>RavenSendSelection
    nmap <localleader>rs  <Plug>RavenSendParagraph
    nmap <localleader>rz  <Plug>RavenSendFold
    nmap <localleader>rq  <Plug>RavenKillPane
endif

