-- ~/.config/nvim/init.lua
-- ==============================================================
-- 插件目录: ~/.local/share/nvim/site/pack/jinqiu/start/*
-- ==============================================================

-- ------------ gitsigns.nvim: Git 变更高亮/Blame ---------------
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

-- 让 Vim 所有复制/粘贴都用系统剪贴板
vim.keymap.set({'n', 'v'}, 'y', '"+y', { noremap = true })
vim.keymap.set({'n', 'v'}, 'd', '"+d', { noremap = true })
vim.keymap.set({'n', 'v'}, 'c', '"+c', { noremap = true })
vim.keymap.set({'n', 'v'}, 'p', '"+p', { noremap = true })
vim.keymap.set({'n', 'v'}, 'P', '"+P', { noremap = true })

-- ------------ vim-oscyank: OSC52 远程剪贴板 -------------------
-- vim.g.clipboard = 'osc52'
-- vim.api.nvim_create_augroup('YankToClipboard', {clear=true})
-- vim.api.nvim_create_autocmd('TextYankPost', {
--   group = 'YankToClipboard',
--   pattern = '*',
--   command = 'silent! OSCYankReg 0'
-- })

-- ------------ 基础设置 ----------------------------------------
vim.opt.filetype = 'on'
vim.cmd('filetype plugin indent on')
vim.cmd('syntax enable')
vim.opt.encoding = 'utf-8'
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.cursorcolumn = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.colorcolumn = '80'
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.backspace = {'indent', 'eol', 'start'}
vim.opt.wildmenu = true
vim.opt.wildmode = {'longest','list','full'}
vim.opt.whichwrap:append('h,l')
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.autoread = true
vim.opt.clipboard:append('unnamed')
vim.opt.mouse = 'a'

-- 256色/真彩配色
if vim.fn.has('termguicolors') == 1 then
  vim.opt.termguicolors = true
end
vim.g.solarized_termcolors = 256
vim.opt.background = 'dark'
vim.cmd('colorscheme solarized')
vim.cmd('highlight clear SignColumn')

-- ------------ 窗口跳转（支持tmux） ----------------------------
vim.keymap.set('n', '<C-J>', '<C-W>j')
vim.keymap.set('n', '<C-K>', '<C-W>k')
vim.keymap.set('n', '<C-L>', '<C-W>l')
vim.keymap.set('n', '<C-H>', '<C-W>h')

-- ------------ telescope.nvim: 模糊查找 ------------------------
require('telescope').setup{
  defaults = {
    prompt_prefix = "🔍 ",
    selection_caret = "➤ ",
    mappings = {
      i = {
        ["<C-n>"] = "move_selection_next",
        ["<C-p>"] = "move_selection_previous",
        ["<C-c>"] = "close",
      },
      n = {
        ["q"] = "close",
      },
    },
  },
}

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {desc = '查找文件'})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {desc = '全局 grep'})
vim.keymap.set('n', '<leader>fb', builtin.buffers,   {desc = '列出 Buffer'})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {desc = '帮助文档查找'})

-- ------------ vim-easymotion: 快速跳转 ------------------------
vim.cmd([[
  nmap <Leader>s <Plug>(easymotion-b)
  nmap <Leader>f <Plug>(easymotion-w)
  nmap <Leader>e <Plug>(easymotion-k)
  nmap <Leader>d <Plug>(easymotion-j)
]])

-- ------------ tagbar: 代码结构树 ------------------------------
vim.keymap.set('n', '<F8>', ':TagbarToggle<CR>', {desc = "Toggle Tagbar"})

-- ------------ vim-airline: 状态栏美化 -------------------------
vim.g.airline_theme = 'solarized'
vim.g.airline_powerline_fonts = 1

-- ------------ vim-startify: 启动页/书签 -----------------------
vim.g.startify_custom_header = {
  '',
  '',
  '                   $$\\    $$\\ $$$$$$\\ $$\\      $$\\       $$\\   $$\\ $$$$$$$\\',
  '                   $$ |   $$ |\\_$$  _|$$$\\    $$$ |      $$$\\  $$ |$$  __$$\\',
  '                   $$ |   $$ |  $$ |  $$$$\\  $$$$ |      $$$$\\ $$ |$$ |  $$ |',
  '                   \\$$\\  $$  |  $$ |  $$\\$$\\$$ $$ |      $$ $$\\$$ |$$$$$$$\\ |',
  '                    \\$$\\$$  /   $$ |  $$ \\$$$  $$ |      $$ \\$$$$ |$$  __$$\\',
  '                     \\$$$  /    $$ |  $$ |\\$  /$$ |      $$ |\\$$$ |$$ |  $$ |',
  '                      \\$  /   $$$$$$\\ $$ | \\_/ $$ |      $$ | \\$$ |$$$$$$$  |',
  '                       \\_/    \\______|\\__|     \\__|      \\__|  \\__|\\_______/',
  ''
}

-- ------------ nerdcommenter: 注释增强 -------------------------
vim.g.NERDSpaceDelims = 1

-- ------------ indentLine: 缩进线 ------------------------------
vim.g.indentLine_color_term = 239

-- ------------ tabular: 对齐辅助 -------------------------------
-- 直接 :Tabularize /pattern/

-- ------------ vim-better-whitespace: 多余空白可视化 ----------
-- 用 :StripWhitespace 清理

-- ------------ undotree: 撤销树 + 持久化撤销 -------------------
if vim.fn.has('persistent_undo') == 1 then
  local undo_dir = vim.fn.expand('~/.local/share/nvim/undo')
  if vim.fn.isdirectory(undo_dir) == 0 then
    vim.fn.mkdir(undo_dir, 'p', 0700)
  end
  vim.opt.undodir = undo_dir
  vim.opt.undofile = true
end
vim.keymap.set('n', '<Leader>u', ':UndotreeToggle<CR>')

-- ------------ vim-rooter: 自动切换项目根目录 -----------------
vim.g.rooter_change_directory_for_non_project_files = 'home'
vim.g.rooter_silent_chdir = 1

-- ------------ vim-json: JSON 支持 -----------------------------
vim.g.vim_json_syntax_conceal = 0

-- ------------ delimitMate: 自动补全括号 -----------------------
-- 插件无需特别配置
