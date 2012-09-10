let s:source = {
            \ 'name': 'look',
            \ 'kind': 'plugin',
            \ }

call zlib#rc#set_default({
            \ 'g:neocomplcache_source_look_enable_rules'    : {
            \     'text_mode'   : 1 ,
            \     'syntax_mode' : {
            \         'Comment'        : 1 ,
            \         'SpecialComment' : 1 ,
            \     },
            \ },
            \
            \ 'g:neocomplcache_source_look_max_candidates'  : 5  ,
            \ 'g:neocomplcache_source_look_dictionary_path' : '' ,
        \ })


function! s:source.initialize()
    call neocomplcache#set_completion_length('look', 4)
    " Set rank.
    call neocomplcache#set_dictionary_helper(g:neocomplcache_source_rank,
                \ 'look', 3)
endfunction

function! s:source.finalize()
endfunction

function! s:check_enable_rules(erules)
    let r = a:erules
    let hlgroup = zlib#syntax#cursor_trans_hlgroup({'col' : col('.') - 1})

    if !empty(hlgroup) && has_key(r['syntax_mode'], hlgroup)
                \ && r.syntax_mode[hlgroup] == 1
        return 1
    endif

    if r['text_mode'] && !neocomplcache#is_text_mode()
	return 0
    endif

    return 1
endfunction

function! s:source.get_keyword_list(cur_keyword_str)
    if a:cur_keyword_str !~ '^\w\+$' " always ignore multibyte characters
        return []
    endif

    if ! <SID>check_enable_rules(g:neocomplcache_source_look_enable_rules)
	return []
    endif

    let list = neocomplcache#is_win()
                \ ? split(neocomplcache#system(
                \   printf('grep "^%s" "%s"', a:cur_keyword_str,
                \   g:neocomplcache_source_look_dictionary_path)), "\n")
                \ : split(neocomplcache#system('look '.a:cur_keyword_str), "\n")

    let keyword_list = []
    " ~ UPPERCASE match ~
    if a:cur_keyword_str ==# toupper(a:cur_keyword_str)
        let keyword_list = map( map(list,'toupper(v:val)'),
                    \ "{'word': v:val, 'menu': '[look]'}"
                \ )
    " ~ TitleCase match ~
    elseif strpart(a:cur_keyword_str, 0, 1) =~# '\u'
        let keyword_list = map( map(list,
                    \ 'substitute(v:val,''\(\<\w\+\>\)'', ''\u\1'', ''g'')'),
                    \ "{'word': v:val, 'menu': '[look]'}"
                \ )
    " ~ match as it is ~
    else
        let keyword_list = map(list, "{'word': v:val, 'menu': '[look]'}")
    endif

    return neocomplcache#keyword_filter(
                \ keyword_list[0:g:neocomplcache_source_look_max_candidates],
                \ a:cur_keyword_str)
endfunction

function! neocomplcache#sources#look#define()
    return (neocomplcache#is_win()
                \ ? (executable('grep')
                \ && g:neocomplcache_source_look_dictionary_path != '')
                \ : executable('look')) ? s:source : {}
endfunction

