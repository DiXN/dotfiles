function! TrimWhiteSpace()
  %s/\s\+$//e
endfunction

function! bootstrap#after() abort
  nnoremap <silent> <F5> :call SpaceVim#plugins#runner#open('make')
  highlight ExtraWhitespace ctermbg=red guibg=red
  match ExtraWhitespace /\s\+$/
  autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
  autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
  autocmd InsertLeave * match ExtraWhitespace /\s\+$/
  autocmd BufWinLeave * call clearmatches()
  autocmd BufWritePre * call TrimWhiteSpace()
  g:spacevim_lint_on_save = 0
endfunction

function! bootstrap#before() abort
  let g:mapleader = ','
  let g:suda_smart_edit = 1
  let g:spacevim_enable_ycm = 1
  let g:ycm_autoclose_preview_window_after_insertion = 1
endfunction

