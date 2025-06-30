-- ~/.config/nvim/init.lua
-- ==============================================================
-- 插件目录: ~/.local/share/nvim/site/pack/jinqiu/*
-- ==============================================================

-- ---- 开子窗口 --------------------------------
require("toggleterm").setup{}

-- 根据 SSH 连接状态，切换本地/远程剪贴板配置
if vim.env.SSH_CONNECTION == nil then
  -- 本地环境：所有复制/粘贴走系统剪贴板
  vim.keymap.set({'n', 'v'}, 'y', '"+y', { noremap = true, silent = true })
  vim.keymap.set({'n', 'v'}, 'd', '"+d', { noremap = true, silent = true })
  vim.keymap.set({'n', 'v'}, 'c', '"+c', { noremap = true, silent = true })
  vim.keymap.set({'n', 'v'}, 'p', '"+p', { noremap = true, silent = true })
  vim.keymap.set({'n', 'v'}, 'P', '"+P', { noremap = true, silent = true })
else
  -- 远程 SSH：使用 OSC52 推送到本地剪贴板
  vim.g.clipboard = 'osc52'
  vim.api.nvim_create_augroup('YankToClipboard', { clear = true })
  vim.api.nvim_create_autocmd('TextYankPost', {
    group   = 'YankToClipboard',
    pattern = '*',
    command = 'silent! OSCYankReg +'
  })
end

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
vim.g.mapleader = '\\'

-- 开启真彩（如果终端支持）
vim.opt.termguicolors = true

-- 先载入 nonicons
local nonicons = require("nvim-nonicons")
nonicons.setup()

-- 载入 lualine 的 nonicons 扩展
local nonicons_ext = require("nvim-nonicons.extentions.lualine")

-- 设置背景
vim.opt.background = "dark"

 -- 可选：night / storm / moon / day
vim.g.tokyonight_style = "night"

-- 可选：透明背景
vim.g.tokyonight_transparent_background = 1

vim.cmd("colorscheme tokyonight")

-- 不自动加注释前缀，确保在 filetype plugin indent on 之后
vim.api.nvim_create_augroup('NoCommentContinuation', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  group = 'NoCommentContinuation',
  pattern = '*',
  callback = function()
    -- 按 <Enter> 或 o/O 时都不要自动延续注释前缀
    vim.opt_local.formatoptions:remove('r')
    vim.opt_local.formatoptions:remove('o')
  end,
})

-- --------------- lualine 基本配置 -------------------
require('lualine').setup{
  options = {
    icons_enabled = true,
    theme = 'auto',  -- 会自动匹配 tokyonight 主题
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = {},
    always_divide_middle = false,
    globalstatus = true,
  },
  sections = {
    lualine_a = { nonicons_ext.mode },  -- 模式图标
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding','fileformat','filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  }
}

-- ------------ 全文搜索选中的文字 ---------------------------
vim.keymap.set('v', '//', '"zy/\\V<C-R>z<CR>', { noremap = true, silent = true })

-- ------------ 窗口跳转（支持tmux） ----------------------------
vim.keymap.set('n', '<C-J>', '<C-W>j')
vim.keymap.set('n', '<C-K>', '<C-W>k')
vim.keymap.set('n', '<C-L>', '<C-W>l')
vim.keymap.set('n', '<C-H>', '<C-W>h')

-- ------------ vim-easymotion: 快速跳转 ------------------------
vim.cmd([[
  nmap <Leader>s <Plug>(easymotion-b)
  nmap <Leader>f <Plug>(easymotion-w)
  nmap <Leader>e <Plug>(easymotion-k)
  nmap <Leader>d <Plug>(easymotion-j)
]])


-- ------------ notebook: 编辑ipynb --------------------------
require('notebook').setup{
  -- 默认为 true，你可以按需开启/关闭
  insert_blank_line = true,
  show_index        = true,
  show_cell_type    = true,
  virtual_text_style= { fg = "lightblue", italic = true },
}

-- ------------ tagbar: 代码结构树 ------------------------------
vim.keymap.set('n', '<F8>', ':TagbarToggle<CR>', {desc = "Toggle Tagbar"})

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

-- ------------ iron -----------------------------
local iron = require("iron.core")
local common = require("iron.fts.common")

-- Send the "cell" delimited by #%% markers
local function send_current_cell()
  local bufnr  = vim.api.nvim_get_current_buf()
  -- 查找 cell 起止行
  local start  = vim.fn.search('^#%%', 'bnW'); if start==0 then start=1 else start=start+1 end
  local finish = vim.fn.search('^#%%', 'nW'); if finish==0 then finish=vim.api.nvim_buf_line_count(bufnr) else finish=finish-1 end

  -- 获取行列表并在尾部加一个空行
  local lines = vim.api.nvim_buf_get_lines(bufnr, start-1, finish, false)
  table.insert(lines, "")

  -- 直接把行列表扔给 REPL；common.bracketed_paste_python 会自动包裹
  iron.send(nil, lines)
end

-- 普通模式下 \gc 发送当前 #%% cell
vim.keymap.set("n", "<leader>gc", send_current_cell, {
  silent = true,
  desc   = "Send current #%% cell to REPL",
})

-- 用 gd 发送 IPython 的 %clear 魔法命令
vim.keymap.set('n', 'gd', function()
  iron.send(nil, {"%clear"})
end, { noremap = true, silent = true, desc = "Clear IPython Console" })

-- 在 terminal 模式下，用单次 <Esc> 退回普通模式
vim.api.nvim_set_keymap('t', '<Esc>', '<C-\\><C-n>', { noremap = true, silent = true })

iron.setup {
  config = {
    -- 不把 REPL 当作 scratch buffer，退出时保留 buffer
    scratch_repl = false,
    -- REPL 进程退出后不自动关闭窗口
    close_window_on_exit = false,

    repl_definition = {
      python = {
        -- 连接到已经跑在后台的 kernel
        command = {
          "bash", "-lc",
          "jupyter console --existing /Users/dengjinqiu/.local/share/jupyter/runtime/kernel-jinqiu-ea.json"
        },
        format = common.bracketed_paste,
      },
    },

    -- 打开 REPL 时在当前窗口右侧竖直分屏，并让所有窗口等宽
    repl_open_cmd = "vertical rightbelow vsplit | wincmd =",
  },

  -- 常用按键映射；<leader> 默认是 “\”
  keymaps = {
    toggle_repl       = "gt",  -- g + t 打开/关闭 REPL (t = toggle)
    restart_repl      = "gr",  -- g + r 重启 REPL (r = restart)
    send_line         = "gs",  -- g + s 发送当前行 (s = send)
    visual_send       = "gv",  -- g + v 发送可视选区 (v = visual)
    send_file         = "gp",  -- g + f 发送全文件 (p = pager)
    send_until_cursor = "gu",  -- g + u 发送到光标 (u = until)
    interrupt         = "gi",  -- g + i 中断内核 (i = interrupt)
    exit              = "gq",  -- g + q 退出 REPL (q = quit)
  },
}

-- 确保已加载 Iron
local uv   = vim.loop

-- 配置（可在 init.lua 中覆盖）
vim.g.visidata_tmp_dir_remote    = vim.g.visidata_tmp_dir_remote or "/home/dengjinqiu/tmp/"
vim.g.visidata_tmp_dir_local     = vim.g.visidata_tmp_dir_local or "~/tmp/"
vim.g.visidata_wait_timeout_secs = vim.g.visidata_wait_timeout_secs or 30

-- 异步等待 CSV 文件生成
local function wait_for_file(path, callback)
  local start = uv.now()
  local function check()
    uv.fs_stat(path, function(err, stat)
      if stat then
        vim.schedule(function() callback(true) end)
      else
        if (uv.now() - start) / 1000 > vim.g.visidata_wait_timeout_secs then
          vim.schedule(function()
            vim.notify("❌ 等待 CSV 生成超时（" .. vim.g.visidata_wait_timeout_secs .. "s）", vim.log.levels.ERROR)
          end)
        else
          vim.defer_fn(check, 200)
        end
      end
    end)
  end
  check()
end

-- 主函数：远程导出 DataFrame 为 CSV，完成后通过 tmux 下方窗口打开
local function show_visidata_tmux(var)
  if var == "" then
    return vim.notify("⚠️ 没有选中变量名", vim.log.levels.WARN)
  end

  -- 生成唯一文件名
  local filename = tostring(os.time()) .. ".csv"
  local remote_fp = vim.g.visidata_tmp_dir_remote .. filename
  local local_fp  = vim.fn.expand(vim.g.visidata_tmp_dir_local .. filename)

  -- 发送导出命令到远端 Python
  local cmd = string.format("%s.to_csv('%s', index=False)", var, remote_fp)
  iron.send(nil, {cmd})
  vim.notify("🔍 已发送导出命令: " .. cmd, vim.log.levels.INFO)

  -- 文件生成后，使用 tmux split-window 在 vim 下方打开 VisiData
  wait_for_file(local_fp, function()
    local tmux_cmd = string.format(
      "tmux split-window -v -p 20 'vd -f csv %s'",
      local_fp
    )
    vim.fn.system(tmux_cmd)
    vim.notify("✅ CSV 已生成，已在 tmux 下方新窗打开 VisiData", vim.log.levels.INFO)
  end)
end

-- 自动命令：在 Python 编辑面板，为普通模式映射 <leader>vd
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"python"},
  callback = function(args)
    -- 仅在 Python 缓冲区生效
    if vim.bo[args.buf].filetype ~= "python" then return end

    -- 删除已有映射
    pcall(vim.api.nvim_buf_del_keymap, args.buf, 'n', '<leader>vd')

    -- 普通模式：光标所在单词直接执行
    vim.keymap.set('n', '<leader>vd', function()
      local var = vim.fn.expand('<cword>')
      show_visidata_tmux(var)
    end, { buffer=true, silent=true, desc="导出光标单词对应 DF 并查看" })
  end,
})

-- ------------------------- Neo-tree 核心配置 -------------------
local neo_ext = require("nvim-nonicons.extentions.nvim-tree")
require("neo-tree").setup({
  renderer = {
    icons = {
      glyphs = neo_ext.glyphs,
    },
  },
  close_if_last_window = true,       -- 关闭最后一个窗口时一起退出 Neo-tree
  enable_git_status = true,          -- 显示 Git 状态
  enable_diagnostics = true,         -- 显示 Diagnostics（LSP 报错）
  popup_border_style = "rounded",    -- 浮动窗口的边框样式

  filesystem = {
    hijack_netrw_behavior = "open_default",  -- 劫持 netrw，打开目录用 Neo-tree
    follow_current_file = true,              -- 光标文件变化时自动展开到对应节点
    use_libuv_file_watcher = true,           -- 用更高效的文件监听刷新树

    filtered_items = {
      hide_dotfiles = false,     -- 隐藏 ·开头 文件
      hide_gitignored = true,    -- 隐藏被 .gitignore 的文件
      never_show = { ".DS_Store" },
    },
  },

  window = {
    position = "left",
    width    = 30,
    mappings = {
      ["<cr>"] = "open",
      ["o"]    = "open",
      ["a"]    = "add",
      ["d"]    = "delete",
      ["r"]    = "rename",
      ["<space>"] = "toggle_node",
    },
  },

  -- 打开文件时自动关闭 Neo-tree
  commands = {
    open = function(state)
      require("neo-tree.commands").open(state)
      vim.cmd("wincmd p")  -- 切回上一个窗口
    end,
  },
})

-- VimEnter 时，如果参数是一个目录，则自动启动 Neo-tree
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function(data)
    if vim.fn.isdirectory(data.file) == 1 then
      require("neo-tree.command").execute({ source = "filesystem" })
    end
  end,
})

-- 全局快捷键，手动切换 Neo-tree
vim.keymap.set("n", "<C-n>", "<cmd>Neotree toggle<cr>", { desc = "Toggle Neo-tree" })

-- helper：是不是本地会话
local function is_local()
  return vim.env.SSH_CONNECTION == nil
end

if is_local() then
  -- 你放到 opt 下的插件名称
  local opt_plugins = {
    "gitsigns.nvim",
    "telescope.nvim",
    "telescope-fzf-native.nvim",
    "telescope-file-browser.nvim",
  }
  for _, name in ipairs(opt_plugins) do
    vim.cmd("packadd " .. name)
  end

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

  -- ---------------telescope.nvim: 模糊查找 + 扩展 --------------
  local icons = require('nvim-nonicons')
  require('telescope').setup {
    defaults = {
      prompt_prefix = "  " .. icons.get("telescope") .. "  ",
      selection_caret = "  " .. icons.get("arrow_right") .. "  ",
      entry_prefix = "   ",
      mappings = {
        i = { ["<C-n>"] = "move_selection_next", ["<C-p>"] = "move_selection_previous" },
        n = { ["q"] = "close" },
      },
    },
    extensions = {
      fzf = {
        fuzzy                   = true,
        override_generic_sorter = true,
        override_file_sorter    = true,
      },
      file_browser = {
        theme            = "ivy",
        hijack_netrw     = true,
        hidden           = true,
        respect_gitignore= false,
        previewer        = false,   -- ← 在扩展里关预览
      },
    },
  }

  -- 然后再 load 扩展
  require('telescope').load_extension('fzf')
  require('telescope').load_extension('file_browser')

  -- 你的快捷键映射
  vim.keymap.set('n', '<leader>ae', function()
    require('telescope').extensions.file_browser.file_browser({
      cwd = vim.loop.cwd(),
      -- （这里也可以再 override previewer = false）
    })
  end, { desc = '文件浏览器' })

  -- 在这里加入到你其它 <leader> 映射的附近
  vim.keymap.set('n', '<leader>ar',
    function()
      require('telescope.builtin').oldfiles({
        prompt_title = " Recent Files",
        cwd_only     = false,         -- 只看当前工作目录就设为 true
      })
    end,
    { desc = "Open Recent Files" }
  )


  -- 加载扩展
  require('telescope').load_extension('fzf')
  require('telescope').load_extension('file_browser')

  vim.keymap.set('n', '<leader>gf',
    require('telescope.builtin').git_files,
    { desc = 'Git 跟踪文件' })

  -- 快捷键映射
  local builtin = require('telescope.builtin')
  vim.keymap.set('n', '<leader>af', builtin.find_files,    { desc = '查找文件' })
  vim.keymap.set('n', '<leader>ag', builtin.live_grep,     { desc = '全局 grep' })
  vim.keymap.set('n', '<leader>ab', builtin.buffers,       { desc = '列出 Buffer' })
  vim.keymap.set('n', '<leader>ah', builtin.help_tags,     { desc = '帮助文档' })
  -- 新增：telescope-file-browser
  vim.keymap.set('n', '<leader>ae', function()
    require('telescope').extensions.file_browser.file_browser({
      cwd = vim.loop.cwd(),
    })
  end, { desc = '文件浏览器' })


end
