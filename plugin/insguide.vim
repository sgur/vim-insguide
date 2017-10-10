" insguide.vim
" Version: 0.0.1
" Author: sgur
" License: MIT License

if exists('g:loaded_insguide') && g:loaded_insguide
  finish
endif
let g:loaded_insguide = 1

let s:save_cpo = &cpo
set cpo&vim


" Internal functions {{{1

function! s:enable(...) "{{{
  if exists('s:insguide_enabled')
    call insguide#clear()
  endif
  let s:insguide_enabled = 1
  augroup plugin-insguide
    autocmd!
    autocmd InsertEnter,CursorMovedI *  call insguide#highlight()
    autocmd InsertLeave *  call insguide#clear()
  augroup END
endfunction "}}}

function! s:disable() "{{{
  let s:insguide_enabled = 0
  autocmd! plugin-insguide
  call insguide#clear()
endfunction "}}}

function! s:toggle() "{{{
  if get(s:, 'insguide_enabled', 0)
    call s:disable()
  else
    call s:enable()
  endif
endfunction "}}}

" Interfaces {{{1

" Enables insguide automatically
let g:insguide_default_enable = get(g:, 'insguide_default_enable', 1)
" Highlight group to use (Default: 'Underlined')
let g:insguide_highlight_group = get(g:, 'insguide_highlight_group', 'Question')
" Filetype blacklist (Default: ["help"])
let g:insguide_filetype_blacklist = get(g:, 'insguide_filetype_blacklist', ['help'])
" Syntax pattern to ignore highlighting
let g:insguide_ignore_syntax_pattern = get(g:, 'insguide_ignore_syntax_pattern', '')
" Highlight multiple windows with cursor word
let g:insguide_highlight_multiple_windows = get(g:, 'insguide_highlight_multiple_windows', 0)
" Minimum chars for highlight
let g:insguide_minimum_chars = get(g:, 'insguide_minimum_chars', 2)

" Enable
command! -nargs=0 InsGuideEnable  call s:enable()
" Disable
command! -nargs=0 InsGuideDisable  call s:disable()
" Toggle
command! -nargs=0 InsGuideToggle  call s:toggle()

" Initialization {{{1

if g:insguide_default_enable
  InsGuideEnable
endif

" 1}}}


let &cpo = s:save_cpo
unlet s:save_cpo
