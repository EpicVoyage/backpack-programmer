set nu!
set backspace=indent,eol,start
set autoindent
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

behave mswin
vnoremap <C-X> "+x
vnoremap <C-C> "+y
imap <C-V> <Esc>"+gPa
