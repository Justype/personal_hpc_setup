"" Custom keymap
nnoremap ; :
vnoremap ; :
nnoremap <silent> <Leader>w <c-w><c-w>
nnoremap <silent> <M-w> <c-w><c-w>
tnoremap <silent> <M-w> <c-\><c-n><c-w><c-w>
tnoremap <silent> <Esc> <c-\><c-n>
nnoremap <silent> <M-v> <c-v>
nnoremap - $
vnoremap - $
nnoremap d- d$
nnoremap y- y$
nnoremap <silent> <C-j> <c-d>
nnoremap <silent> <C-k> <c-u>
nnoremap <silent> <Leader>d <c-d>
nnoremap <silent> <Leader>f <c-u>

"" set fold to marker
set foldlevelstart=99 " Unfold by default

"" set enable syntax
set linebreak
syntax on
set shiftwidth=4
set tabstop=4
set expandtab
