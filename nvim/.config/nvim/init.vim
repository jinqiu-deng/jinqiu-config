" ~/.config/nvim/init.vim
" ===============================================================
" 插件目录: ~/.local/share/nvim/site/pack/jinqiu/start/*
" ===============================================================

" ------------ gitsigns.nvim: Git 变更高亮/Blame ----------------
lua << EOF
require('gitsigns').setup {
  signs = {
    add          = {hl = 'GitGutterAdd'   , text = '+'},
    change       = {hl = 'GitGutterChange', text = '~'},
    delete       = {hl = 'GitGutterDelete', text = '_'},
    topdelete    = {hl = 'GitGutterDelete', text = '‾'},
    changedelete = {hl = 'GitGutterChange', text = '~'},
  },
  current_line_blame = true,
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol',
    delay = 500,
  },
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns
    vim.keymap.set('n', ']h', gs.next_hunk,    {buffer=bufnr, desc="Next Git hunk"})
    vim.keymap.set('n', '[h', gs.prev_hunk,    {buffer=bufnr, desc="Prev Git hunk"})
    vim.keymap.set('n', '<leader>hp', gs.preview_hunk, {buffer=bufnr, desc="Preview Git hunk"})
    vim.keymap.set('n', '<leader>tb', '<cmd>Gitsigns toggle_current_line_blame<CR>', {buffer=bufnr})
    vim.keymap.set('n', '<leader>gb', '<cmd>Gitsigns blame_line<CR>', {buffer=bufnr})
  end,
}
EOF

" ------------ vim-oscyank: OSC52 远程剪贴板 ---------------------
let g:clipboard = 'osc52'
augroup YankToClipboard
  autocmd!
  autocmd TextYankPost * silent! OSCYankReg 0
augroup END

" ------------ 基础设置 ----------------------------------------
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

" 256色/真彩配色
if has('termguicolors')
  set termguicolors
endif
let g:solarized_termcolors=256
set background=dark
colorscheme solarized
highlight clear SignColumn

" ------------ 窗口跳转（支持tmux） ----------------------------
nmap <C-J> <C-W>j
nmap <C-K> <C-W>k
nmap <C-L> <C-W>l
nmap <C-H> <C-W>h

" ------------ telescope.nvim: 模糊查找 -------------------------
" 建议用 telescope 代替 ctrlp，配置留给 lua

" ------------ vim-easymotion: 快速跳转 -------------------------
nmap <Leader>s <Plug>(easymotion-b)
nmap <Leader>f <Plug>(easymotion-w)
nmap <Leader>e <Plug>(easymotion-k)
nmap <Leader>d <Plug>(easymotion-j)

" ------------ tagbar: 代码结构树 ------------------------------
" <F8> 默认打开，可以自定义: nnoremap <F8> :TagbarToggle<CR>

" ------------ vim-airline: 状态栏美化 --------------------------
let g:airline_theme='solarized'
let g:airline_powerline_fonts = 1

" ------------ vim-startify: 启动页/书签 ------------------------
let g:startify_custom_header=[
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

" ------------ nerdcommenter: 注释增强 --------------------------
let g:NERDSpaceDelims=1

" ------------ indentLine: 缩进线 -------------------------------
let g:indentLine_color_term=239

" ------------ tabular: 对齐辅助 -------------------------------
" 直接 :Tabularize /pattern/

" ------------ vim-better-whitespace: 多余空白可视化 ----------
" 用 :StripWhitespace 清理

" ------------ undotree: 撤销树 + 持久化撤销 -------------------
if has('persistent_undo')
  let s:undo_dir=expand('~/.local/share/nvim/undo')
  if !isdirectory(s:undo_dir)
    call mkdir(s:undo_dir, 'p', 0700)
  endif
  execute 'set undodir=' . fnameescape(s:undo_dir)
  set undofile
endif
nmap <Leader>u :UndotreeToggle<CR>

" ------------ vim-rooter: 自动切换项目根目录 -----------------
let g:rooter_change_directory_for_non_project_files='home'
let g:rooter_silent_chdir=1

" ------------ vim-json: JSON 支持 -----------------------------
let g:vim_json_syntax_conceal=0

" ------------ delimitMate: 自动补全括号 ------------------------
" 插件无需特别配置
