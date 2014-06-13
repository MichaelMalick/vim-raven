if g:raven_source_send
    let g:source_send_selection = 'include("' . g:raven_tmp_file . '")'
endif

let s:filetype_lang = "julia"
