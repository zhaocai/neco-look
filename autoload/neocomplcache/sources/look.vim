let s:source = {
      \ 'name': 'look',
      \ 'kind': 'plugin',
      \ }

if !exists('g:neocomplcache_source_look_dictionary_path')
  let g:neocomplcache_source_look_dictionary_path = ''
endif

function! s:source.initialize()
  call neocomplcache#set_completion_length('look', 3)
endfunction

function! s:source.finalize()
endfunction

function! s:source.get_keyword_list(cur_keyword_str)
  if !neocomplcache#is_text_mode()
        \ || a:cur_keyword_str !~ '^\w\+$' " always ignore multibyte characters
    return []
  endif

  let list = neocomplcache#is_win() ?
        \ split(neocomplcache#system(printf('grep "^%s" "%s"', a:cur_keyword_str,
        \       g:neocomplcache_source_look_dictionary_path)), "\n") :
        \ split(neocomplcache#system('look ' . a:cur_keyword_str), "\n")

  return map(list, "{'word': v:val, 'menu': 'look'}")
endfunction

function! neocomplcache#sources#look#define()
  return (neocomplcache#is_win() ? (executable('grep') && g:neocomplcache_source_look_dictionary_path != '') :
        \                           executable('look')) ? s:source : {}
endfunction
