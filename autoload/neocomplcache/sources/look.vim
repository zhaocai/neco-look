let s:source = {
            \ 'name': 'look',
            \ 'kind': 'plugin',
            \ }

if !exists('g:neocomplcache_source_look_dictionary_path')
    let g:neocomplcache_source_look_dictionary_path = ''
endif

if !exists('g:neocomplcache_source_look_only_in_textmode')
    let g:neocomplcache_source_look_only_in_textmode = 1
endif

function! s:source.initialize()
    call neocomplcache#set_completion_length('look', 3)
endfunction

function! s:source.finalize()
endfunction

function! s:source.get_keyword_list(cur_keyword_str)
    if a:cur_keyword_str !~ '^\w\+$' " always ignore multibyte characters
        return []
    endif

    if g:neocomplcache_source_look_only_in_textmode && !neocomplcache#is_text_mode()
	return []
    endif

    let list = neocomplcache#is_win()
                \ ? split(neocomplcache#system( printf('grep "^%s" "%s"', a:cur_keyword_str,
                \       g:neocomplcache_source_look_dictionary_path)), "\n")
                \ : split(neocomplcache#system('look ' . a:cur_keyword_str), "\n")

    let keyword_list = []
    " ~ UPPERCASE match ~
    if a:cur_keyword_str ==# toupper(a:cur_keyword_str)
        let keyword_list = map( map(list,'toupper(v:val)'),
                    \ "{'word': v:val, 'menu': 'look'}"
                \ )
    " ~ Camelcase match ~
    elseif strpart(a:cur_keyword_str, 0, 1) =~# '\u'
        let keyword_list = map( map(list,'substitute(v:val,''\(\<\w\+\>\)'', ''\u\1'', ''g'')'),
                    \ "{'word': v:val, 'menu': 'look'}"
                \ )
    " ~ match as it is ~
    else
        let keyword_list = map(list, "{'word': v:val, 'menu': 'look'}")
    endif

    return neocomplcache#keyword_filter(keyword_list, a:cur_keyword_str)
endfunction

function! neocomplcache#sources#look#define()
    return (neocomplcache#is_win()
                \ ? (executable('grep') && g:neocomplcache_source_look_dictionary_path != '')
                \ : executable('look')) ? s:source : {}
endfunction

