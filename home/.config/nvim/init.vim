" Change COC location
" let g:coc_data_home = "/ext3/.local/share/coc/extensions"

" Plugins will be downloaded under the specified directory.
" call plug#begin("/ext3/.local/share/nvim/plugged")
call plug#begin() " Install in default directory
Plug 'neoclide/coc.nvim', {'branch': 'release'} " autocomplete
Plug 'nvim-tree/nvim-tree.lua' " Explorer
Plug 'romgrk/barbar.nvim' "Tabline
Plug 'nvim-lualine/lualine.nvim' " Lualine
Plug 'nvim-tree/nvim-web-devicons' " icons
Plug 'ojroques/vim-oscyank', {'branch': 'main'} " copy text to local machine
Plug 'akinsho/toggleterm.nvim', {'tag' : '*'} " terminal in neovim
Plug 'windwp/nvim-autopairs' " for autopairs
Plug 'joshdick/onedark.vim' " color theme
Plug 'jpalardy/vim-slime' " nvim to tmux
call plug#end()

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

"" set relativenumber and enable syntax
set number
set relativenumber
set linebreak
syntax on
colorscheme onedark
set shiftwidth=4
set tabstop=4
set expandtab
" set noexpandtab in .bed files
autocmd BufRead,BufNewFile *.bed setlocal noexpandtab
let g:markdown_fenced_languages = ['python', 'bash', 'sql', 'cpp', 'c', 'rust', 'dart']

"" Keyremap for certain file
" autocmd FileType dart inoremap <buffer> <C-;> <Esc>$a;
inoremap <C-;> <Esc>A;<Esc>
nnoremap <C-;> A;<Esc>

"" onedark
if (empty($TMUX))
  if (has("nvim"))
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  if (has("termguicolors"))
    set termguicolors
  endif
endif

"" COC
" use <tab> for trigger completion and navigate to the next complete item
"function! CheckBackspace() abort
"  let col = col('.') - 1
"  return !col || getline('.')[col - 1]  =~# '\s'
"endfunction
"inoremap <silent><expr> <Tab>
"      \ coc#pum#visible() ? coc#pum#next(1) :
"      \ CheckBackspace() ? "\<Tab>" :
"      \ coc#refresh()
"inoremap <silent><expr> <S-Tab> pumvisible() ? "\<C-P>" : "\<S-Tab>"
nnoremap <silent> gd <Plug>(coc-definition)
nnoremap <silent> gy <Plug>(coc-type-definition)
nnoremap <silent> gi <Plug>(coc-implementation)
nnoremap <silent> gr <Plug>(coc-references)
nnoremap <silent> <leader>rn <Plug>(coc-rename)
nnoremap <silent> <F2> <Plug>(coc-rename)
"" GitHub Copilot accept
"imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")
"let g:copilot_no_tab_map = v:true


" copy text to local machine
vnoremap <silent> <c-c> :OSCYankVisual<CR>

"" barbar
" Move to previous/next
nnoremap <silent> <M-,> <Cmd>BufferPrevious<CR>
nnoremap <silent> <Leader>z <Cmd>BufferPrevious<CR>
nnoremap <silent> <M-.> <Cmd>BufferNext<CR>
nnoremap <silent> <Leader>x <Cmd>BufferPrevious<CR>

" Re-order to previous/next
nnoremap <silent> <M-<> <Cmd>BufferMovePrevious<CR>
nnoremap <silent> <M->> <Cmd>BufferMoveNext<CR>

" Close buffer
nnoremap <silent> <M-q> <Cmd>BufferClose<CR>

"" nvim-tree
nnoremap <silent> <Leader>b <Cmd>NvimTreeFindFileToggle<CR>
nnoremap <silent> <M-b> <Cmd>NvimTreeFindFileToggle<CR>
tnoremap <silent> <M-b> <c-\><c-n><Cmd>NvimTreeFindFileToggle<CR>i
cnoreabbrev <expr> b ((getcmdtype() is# ':' && getcmdline() is# 'b')?('NvimTreeFindFileToggle'):('b'))

"" toggle terminal
nnoremap <silent> <Leader>t <Cmd>ToggleTerm<CR>
nnoremap <silent> <M-t> <Cmd>ToggleTerm<CR>
inoremap <silent> <M-t> <Esc><Cmd>ToggleTerm<CR>
tnoremap <silent> <M-t> <c-\><c-n><Cmd>ToggleTerm<CR>

"" vim-slime
let g:slime_target = "tmux"
let g:slime_default_config = {"socket_name": "default", "target_pane": "{last}"}
let g:slime_dont_ask_default = 1
let g:slime_bracketed_paste = 1  " Optional, for better pasting

"disables default bindings
let g:slime_no_mappings = 1
"send visual selection
xmap <leader>r <Plug>SlimeRegionSend
"send based on motion or text object
nmap <leader>r <Plug>SlimeParagraphSend
"send line
nmap <leader>rr <Plug>SlimeLineSend
xmap <M-r> <Plug>SlimeRegionSend
nmap <M-r> <Plug>SlimeParagraphSend

" command alias tutorial
" https://stackoverflow.com/questions/3878692/how-to-create-an-alias-for-a-command-in-vim/3879737#3879737

lua << END
-- lualine
require('lualine').setup()

-- nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
require("nvim-tree").setup()

-- ToggleTerm
require'toggleterm'.setup{
  persist_size = false
}

-- nvim-autopairs
require("nvim-autopairs").setup {}
END
