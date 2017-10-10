scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim


" Internal Functions {{{1

function! s:cword() abort "{{{
  return matchstr(getline('.'), printf('\k*\%%%sc\k*', col('.')))
endfunction "}}}

function! s:highlight(src_winnr, src_pos, term) abort "{{{
  let winnr = winnr()
  if has_key(s:highlighted, winnr) && s:highlighted[winnr].term is# a:term
    return
  endif
  if empty(a:term) || s:is_blacklisted(&filetype)
        \ || s:is_ignored_syntax(a:src_pos) || s:is_multibyte(a:term)
    return
  endif
  call s:clear(winnr)
  let pattern = s:pattern(escape(a:term, '/\'), &cursorline || a:src_winnr == winnr)
  let id = matchadd(g:insguide_highlight_group, pattern, 15)
  let s:highlighted[winnr] = {'id': id, 'term': a:term}
endfunction "}}}

function! s:clear(winnr) abort "{{{
  if !has_key(s:highlighted, a:winnr)
    return
  endif
  if index(map(getmatches(), 'v:val.id'), s:highlighted[a:winnr].id) > -1
    call matchdelete(s:highlighted[a:winnr].id)
    call remove(s:highlighted, a:winnr)
  endif
  " ASSERT
  if has_key(s:highlighted, a:winnr)
    echohl WarningMsg | echomsg "ASSERT: has_key(s:highlighted, a:winnr)" a:winnr | echohl NONE
  endif
endfunction "}}}

function! s:pattern(term, avoid_cursor) abort "{{{
  return a:avoid_cursor
        \ ? printf('\V\%%%dl\@!%s', line('.'), a:term)
        \ : printf('\V%s', a:term)
endfunction "}}}

function! s:is_multibyte(expr) abort "{{{
  return strlen(a:expr) != strchars(a:expr)
endfunction "}}}

function! s:is_blacklisted(filetype) abort "{{{
  return index(g:insguide_filetype_blacklist, a:filetype) > -1
endfunction "}}}

function! s:is_ignored_syntax(pos) abort "{{{
  if empty(g:insguide_ignore_syntax_pattern)
    return 0
  endif
  let syn = synIDattr(synID(a:pos[0], a:pos[1], 1), "name")
  return syn =~? g:insguide_ignore_syntax_pattern
endfunction "}}}

" Internal Variables {{{1

let s:highlighted = {}

" Interfaces {{{1

function! insguide#highlight() abort
  let term = s:cword()
  if len(term) < g:insguide_minimum_chars
    call insguide#clear()
    return
  endif
  let pos = getpos('.')[1 : 2]
  let winnr = winnr()
  if g:insguide_highlight_multiple_windows && empty(getcmdwintype())
    windo call s:highlight(winnr, pos, term)
    execute winnr . "wincmd w"
  else
    call s:highlight(winnr, pos, term)
  endif
endfunction

function! insguide#clear() abort
  let winnr = winnr()
  if g:insguide_highlight_multiple_windows && empty(getcmdwintype())
    windo call s:clear(winnr())
    execute winnr . "wincmd w"
  else
    call s:clear(winnr())
  endif
endfunction

" 1}}}


let &cpo = s:save_cpo
unlet s:save_cpo
