" Neovim 配置文件: ~/.config/nvim/init.vim

" ------------------------------------------------
" 插件管理：使用 Neovim 原生 package 机制
" 插件目录：~/.local/share/nvim/site/pack/jinqiu/start/*
"            ~/.local/share/nvim/site/pack/jinqiu/opt/*
"
" cd ~/.local/share/nvim/site/pack/jinqiu/start
" git clone https://github.com/Raimondi/delimitMate.git
" git clone https://github.com/Yggdroot/indentLine.git
" git clone https://github.com/altercation/vim-colors-solarized.git
" git clone https://github.com/christoomey/vim-tmux-navigator.git
" git clone https://github.com/ctrlpvim/ctrlp.vim.git
" git clone https://github.com/airblade/vim-rooter.git
" git clone https://github.com/easymotion/vim-easymotion.git
" git clone https://github.com/godlygeek/tabular.git
" git clone https://github.com/majutsushi/tagbar.git
" git clone https://github.com/mhinz/vim-startify.git
" git clone https://github.com/ntpeters/vim-better-whitespace.git
" git clone https://github.com/preservim/nerdcommenter.git
" git clone https://github.com/preservim/nerdtree.git
" git clone https://github.com/sjl/vitality.vim.git      # 如果要延迟加载可放 opt/
" git clone https://github.com/lewis6991/gitsigns.nvim.git
" git clone https://github.com/vim-airline/vim-airline.git
" git clone https://github.com/vim-airline/vim-airline-themes.git
" git clone https://github.com/vim-syntastic/syntastic.git
" git clone https://github.com/xolox/vim-misc.git
" git clone https://github.com/kana/vim-arpeggio.git
" git clone https://github.com/elzr/vim-json.git
" git clone https://github.com/mbbill/undotree.git
" git clone https://github.com/ojroques/vim-oscyank.git
" ------------------------------------------------

" （如果有 opt 插件需要按需加载，写在这里）
" packadd vitality.vim

" ------------ gitsigns.nvim 配置 ------------
lua << EOF
require('gitsigns').setup {
  -- 默认图标，你可以按需调整
  signs = {
    add          = {hl = 'GitGutterAdd'   , text = '+'},
    change       = {hl = 'GitGutterChange', text = '~'},
    delete       = {hl = 'GitGutterDelete', text = '_'},
    topdelete    = {hl = 'GitGutterDelete', text = '‾'},
    changedelete = {hl = 'GitGutterChange', text = '~'},
  },
  -- 在行尾直接显示当前行的 Blame 信息
  current_line_blame = true,
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol',
    delay = 500,
  },
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    -- 跳到下一个/上一个 Hunk
    vim.keymap.set('n', ']h', gs.next_hunk,    {buffer=bufnr, desc="Next Git hunk"})
    vim.keymap.set('n', '[h', gs.prev_hunk,    {buffer=bufnr, desc="Prev Git hunk"})

    -- 预览当前 Hunk
    vim.keymap.set('n', '<leader>hp', gs.preview_hunk, {buffer=bufnr, desc="Preview Git hunk"})

    -- 切换行尾 Blame
    vim.keymap.set('n', '<leader>tb', '<cmd>Gitsigns toggle_current_line_blame<CR>', {buffer=bufnr, desc="Toggle current line blame"})

    -- 查看当前行的详细 Blame
    vim.keymap.set('n', '<leader>gb', '<cmd>Gitsigns blame_line<CR>', {buffer=bufnr, desc="Blame current line"})
  end,
}
EOF


" 每次 yank（y/yy/visual y）后自动调用 OSCYankReg +（使用 "+ 寄存器）
augroup YankToClipboard
  autocmd!
  autocmd TextYankPost * silent! OSCYankReg +
augroup END

" ----------------------------------------
" 基础设置
filetype plugin indent on
syntax enable
set encoding=utf-8
set number
set relativenumber
set cursorline
set cursorcolumn
set hlsearch
set incsearch
set colorcolumn=80
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set backspace=indent,eol,start
set wildmenu
set wildmode=longest,list,full
set whichwrap=h,l
set noswapfile
set nobackup
set autoread
set clipboard+=unnamed
set mouse=a

" 256 色或真彩支持
if has('termguicolors')
  set termguicolors
endif
let g:solarized_termcolors=256
set background=dark
colorscheme solarized
highlight clear SignColumn

" 窗格导航 (tmux + Neovim 窗格)
nmap <C-J> <C-W>j
nmap <C-K> <C-W>k
nmap <C-L> <C-W>l
nmap <C-H> <C-W>h

" CtrlP
let g:ctrlp_working_path_mode='ra'
let g:ctrlp_map='<C-P>'
let g:ctrlp_cmd='CtrlP'
let g:ctrlp_custom_ignore='node_modules\|DS_Store\|git\|\.class\|assembly\|\.pyc'
nnoremap <silent> <C-M> :CtrlPMRU<CR>

" NERDTree
nnoremap <silent> <C-I> :NERDTree %:p:h<CR>
nnoremap <silent> <C-N> :NERDTree<CR>
let g:NERDTreeIgnore=['\.pyc$']
let g:NERDTreeMapJumpPrevSibling='\<C-J>'
let g:NERDTreeMapJumpNextSibling='\<C-K>'

" vim-gitgutter
let g:gitgutter_max_signs=1000
nmap [s <Plug>(GitGutterNextHunk)
nmap [w <Plug>(GitGutterPrevHunk)

" easymotion
nmap <Leader>s <Plug>(easymotion-b)
nmap <Leader>f <Plug>(easymotion-w)
nmap <Leader>e <Plug>(easymotion-k)
nmap <Leader>d <Plug>(easymotion-j)

" syntastic 状态栏展示
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_mode_map={'mode':'passive'}
let g:syntastic_python_checker_args='--ignore=E501'
let g:syntastic_always_populate_loc_list=1
let g:syntastic_auto_loc_list=1
let g:syntastic_check_on_open=1
let g:syntastic_check_on_wq=0

" indentLine
let g:indentLine_color_term=239

" vim-rooter
let g:rooter_change_directory_for_non_project_files='home'
let g:rooter_silent_chdir=1

" nerdcommenter
let g:NERDSpaceDelims=1

" vim-json
let g:vim_json_syntax_conceal=0

" undotree & persistent undo
if has('persistent_undo')
  let s:undo_dir=expand('~/.local/share/nvim/undo')
  if !isdirectory(s:undo_dir)
    call mkdir(s:undo_dir, 'p', 0700)
  endif
  execute 'set undodir=' . fnameescape(s:undo_dir)
  set undofile
endif
nmap <Leader>u :UndotreeToggle<CR>

" startify 头部艺术字
let g:startify_custom_header=[
\ '',
\ '',
\ '',
\ '',
\ '                   $$\    $$\ $$$$$$\ $$\      $$\       $$\   $$\ $$$$$$$\\',
\ '                   $$ |   $$ |\_$$  _|$$$\    $$$ |      $$$\  $$ |$$  __$$\\',
\ '                   $$ |   $$ |  $$ |  $$$$\  $$$$ |      $$$$\ $$ |$$ |  $$ |',
\ '                   \$$\  $$  |  $$ |  $$\$$\$$ $$ |      $$ $$\$$ |$$$$$$$\ |',
\ '                    \$$\$$  /   $$ |  $$ \$$$  $$ |      $$ \$$$$ |$$  __$$\\',
\ '                     \$$$  /    $$ |  $$ |\$  /$$ |      $$ |\$$$ |$$ |  $$ |',
\ '                      \$  /   $$$$$$\ $$ | \_/ $$ |      $$ | \$$ |$$$$$$$  |',
\ '                       \_/    \______|\__|     \__|      \__|  \__|\_______/',
\ ''
\]
