-- 使用 packer.nvim 来管理插件
require('packer').startup(function(use)
    use 'wbthomason/packer.nvim' -- Packer 可以管理自身

    -- 插件列表,
    use 'nvim-tree/nvim-web-devicons'
    use { 'kyazdani42/nvim-tree.lua', requires = 'kyazdani42/nvim-web-devicons' }
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
    use({
        "nvim-treesitter/nvim-treesitter-textobjects",
        after = "nvim-treesitter",
        requires = "nvim-treesitter/nvim-treesitter",
    })
    use {
        "ahmedkhalf/project.nvim",
        config = function()
            require("project_nvim").setup {
                -- manual_mode = false,
                -- detection_methods = { "lsp", "pattern" },
                -- patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json", "pyproject.toml", "go.mod" },
            }
        end
    }
    use {
        's1n7ax/nvim-window-picker',
        tag = 'v2.*',
    }
    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.8',
        -- or                            , branch = '0.1.x',
        requires = { { 'nvim-lua/plenary.nvim' } }
    }
    use 'junegunn/seoul256.vim'
    use "sindrets/diffview.nvim"
    use 'junegunn/vim-easy-align'
    use { 'fatih/vim-go', run = ':GoUpdateBinaries' }
    use { 'neoclide/coc.nvim', branch = 'release' }
    use 'tpope/vim-surround'
    use 'vim-airline/vim-airline'
    use 'tveskag/nvim-blame-line'
    use {
        "Exafunction/codeium.vim",
    }
    use { "akinsho/toggleterm.nvim", tag = '*', config = function()
        require("toggleterm").setup {
            shade_terminals = true,
            shading_factor = '1',    -- 将颜色设置为多少度，默认1适用于深色背景
            start_in_insert = true,  -- 插入模式开始
            persist_size = true,     -- 记住终端大小
            direction = 'horizontal' -- 水平窗口
            -- 可选方向: 'vertical' | 'horizontal' | 'window' | 'tab'
        }
    end }
    use { "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" } }
    use 'mfussenegger/nvim-dap-python'
    use 'leoluz/nvim-dap-go'
    use {
        "zbirenbaum/neodim",
        event = "LspAttach",
        config = function()
            require("neodim").setup()
        end
    }
    use { 'ethanholz/nvim-lastplace', config = function()
        require 'nvim-lastplace'.setup {
            lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
            lastplace_ignore_filetype = { "gitcommit", "gitrebase", "svn", "hgcommit" },
            lastplace_open_folds = true
        }
    end }
    use { 'akinsho/git-conflict.nvim', tag = "*", config = function()
        require('git-conflict').setup()
    end }
    -- use {
    --     "windwp/nvim-autopairs",
    --     event = "InsertEnter",
    --     config = function()
    --         require("nvim-autopairs").setup {}
    --     end
    -- }
    use "lukas-reineke/indent-blankline.nvim"
    -- use "Vimjas/vim-python-pep8-indent"
end)

-- 设置基础选项
vim.opt.encoding      = 'utf-8'
vim.opt.guicursor     = 'n-v-c-i:block'
vim.opt.termguicolors = true
vim.opt.sidescrolloff = 15
vim.opt.showmatch     = true
vim.opt.undofile      = true
vim.opt.undodir       = vim.fn.expand('~/.config/nvim/undo/')

-- 设置 foldmethod 和 foldexpr
vim.o.foldmethod      = 'expr'
vim.o.foldexpr        = 'nvim_treesitter#foldexpr()'
vim.o.foldlevelstart  = 99

-- 自动补全命令
vim.opt.wildmenu      = true
vim.opt.wildmode      = { 'longest:list', 'full' }

vim.opt.vb            = true

-- 自动重新加载配置文件
vim.cmd [[autocmd! bufwritepost init.lua source <afile>]]

-- 设置 leader 键
vim.g.mapleader = ';'

-- 快速退出命令
vim.api.nvim_set_keymap('n', '<leader>q', ':q<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>Q', ':qa!<CR>', { noremap = true, silent = true })

-- 窗口的快捷移动
vim.api.nvim_set_keymap('n', '<leader>h', '<C-w>h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>j', '<C-w>j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>k', '<C-w>k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>l', '<C-w>l', { noremap = true, silent = true })

-- 代码块的便捷移动
vim.api.nvim_set_keymap('v', '<', '<gv', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '>', '>gv', { noremap = true, silent = true })

-- 启用语法高亮
vim.cmd [[filetype plugin indent on]]
vim.cmd [[syntax on]]

-- 显示行号
vim.opt.number = true
vim.cmd [[highlight ColorColumn ctermbg=233]]

-- 段落格式化配置
vim.api.nvim_set_keymap('v', 'Q', 'gq', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'Q', 'gqap', { noremap = true, silent = true })

-- 实用配置
vim.opt.history = 700
vim.opt.undolevels = 700

-- TAB 转空格
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.shiftround = true
vim.opt.expandtab = true

-- 搜索配置
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- 禁用备份和交换文件
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false

-- coc.nvim 插件的键映射
vim.api.nvim_set_keymap('n', 'rn', '<Plug>(coc-rename)', {})
vim.api.nvim_set_keymap('n', 'gd', '<Plug>(coc-definition)', {})
vim.api.nvim_set_keymap('n', 'gy', '<Plug>(coc-type-definition)', {})
vim.api.nvim_set_keymap('n', 'gi', '<Plug>(coc-implementation)', {})
vim.api.nvim_set_keymap('n', 'gr', '<Plug>(coc-references)', {})
vim.api.nvim_set_keymap('i', '<CR>', [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]],
    { expr = true, noremap = true, silent = true })
vim.api.nvim_set_keymap('n', "gf", "<Plug>(coc-fix-current)", { noremap = true, silent = false })

vim.api.nvim_create_user_command("Format", "call CocAction('format')", {})

-- 设置 easy align
vim.api.nvim_set_keymap('x', 'ga', '<Plug>(EasyAlign)', {})
vim.api.nvim_set_keymap('n', 'ga', '<Plug>(EasyAlign)', {})

-- 颜色主题配置
vim.g.seoul256_background = 236
vim.cmd [[colorscheme seoul256]]

-- 设置 go 开发相关插件的自动加载
vim.cmd [[autocmd BufWritePost *.go :GoImport | :GoLint]]

-- nvim-tree 配置
require 'nvim-tree'.setup {
    update_focused_file = {
        enable = true,
        update_cwd = true,
    },
    filters = {
        dotfiles = true,
        custom = { "__pycache__" },
        exclude = { ".codebase", ".venv" }
    },
    view = {
        width = 30,
        side = 'left',
    },
    git = {
        enable = true,
        ignore = false,
    },
    hijack_cursor = true,
    respect_buf_cwd = true,
    sync_root_with_cwd = true,
}
vim.api.nvim_set_keymap('n', '<leader>n', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
-- vim.api.nvim_create_autocmd("VimEnter", {
--     callback = function()
--         vim.cmd("NvimTreeOpen")
--
--         local win_count = vim.fn.len(vim.fn.getwininfo())
--         if win_count > 1 then
--             vim.cmd("wincmd w")
--         end
--     end
-- })

-- 设置 Airline
vim.g.airline_extensions_tabline = { enabled = 1, left_sep = ' ', left_alt_sep = '|', formatter = 'default' }

vim.api.nvim_set_keymap('n', '<leader>t', ':ToggleTerm<CR>', { noremap = true, silent = true })

-- 设置 git blame 的快捷键
-- 自动命令：在进入缓冲区时启用 EnableBlameLine
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    command = "EnableBlameLine"
})

-- 分割窗口
vim.api.nvim_set_keymap('n', 'sp', ':split<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'sv', ':vsplit<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'sc', '<C-w>c', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'so', '<C-w>o', { noremap = true, silent = true })

-- set terminal
vim.api.nvim_set_keymap('t', '<Esc>', '<C-\\><C-n>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-1>', ':1ToggleTerm<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-2>', ':2ToggleTerm<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-3>', ':3ToggleTerm<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-4>', ':4ToggleTerm<CR>', { noremap = true, silent = true })

-- set for dap
local dap        = require('dap')
local dapui      = require('dapui')
local dap_python = require('dap-python')
local dap_go     = require('dap-go')

-- 动态获取 Python 解析器路径
local function get_python_path()
    local cwd = vim.fn.getcwd()
    if vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
        return cwd .. '/.venv/bin/python'
    elseif vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
        return cwd .. '/venv/bin/python'
    else
        return 'python3' -- fallback to system python
    end
end
dap_python.setup(get_python_path())
dap_go.setup()
dapui.setup()

dap.listeners.after.event_initialized["dapui_config"] = function()
    require("dapui").open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    require("dapui").close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
    require("dapui").close()
end
vim.api.nvim_set_keymap('n', '<F5>', ':lua require"dap".continue()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<F10>', ':lua require"dap".step_over()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<F11>', ':lua require"dap".step_into()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<F12>', ':lua require"dap".step_out()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>b', ':lua require"dap".toggle_breakpoint()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>B', ':lua require"dap".set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>',
    { noremap = true, silent = true })
--vim.api.nvim_set_keymap('n', '<leader>lp', ':lua require"dap".set_breakpoint(nil, nil, vim.fn.input("Log point message: "))<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>dr', ':lua require"dap".repl.open()<CR>', { noremap = true, silent = true })

-- set for diffview
vim.api.nvim_set_keymap('n', 'dfo', ':DiffviewOpen<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'dfc', ':DiffviewClose<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'dfp', ':diffput<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'dfg', ':diffget<CR>', { noremap = true, silent = true })

-- set for telescope & project
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local function telescope_open_with_picker(prompt_bufnr)
    local picker = action_state.get_current_picker(prompt_bufnr)
    local entry = action_state.get_selected_entry()
    actions.close(prompt_bufnr)

    local win = require("window-picker").pick_window({})
    if not win or not entry then return end
    vim.api.nvim_set_current_win(win)

    -- buffer picker
    if picker.prompt_title:match("Buffer") then
        vim.cmd("buffer " .. entry.bufnr)
    else
        -- file picker
        local path = entry.path or entry.filename
        vim.cmd("edit " .. vim.fn.fnameescape(path))
    end
end
require('telescope').load_extension('projects')
require('telescope').setup {
    pickers = {
        find_files = {
            hidden = true,
            no_ignore = true,
        },
        live_grep = {
            -- hidden = true,
            no_ignore = true
        },
    },
    defaults = {
        layout_strategy = 'bottom_pane',
        layout_config = {
            bottom_pane = {
                height = 0.4,
                prompt_position = "bottom",
            },
        },
        -- sorting_strategy = 'ascending',
        prompt_prefix = "> ",
        selection_caret = "> ",
        -- path_display = { "smart" },
        mappings = {
            i = {
                ["<CR>"] = require('telescope.actions').select_vertical
            },
            n = {
                ["sv"] = require('telescope.actions').select_vertical,
                ["sp"] = require('telescope.actions').select_horizontal,
                ["<leader>w"] = telescope_open_with_picker
            }
        }
    }
}
vim.api.nvim_set_keymap('n', '<leader>p', ':Telescope projects<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>f', ':Telescope find_files<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>ss', ':Telescope live_grep<CR>', { noremap = true, silent = true })


-- set for window picker
require 'window-picker'.setup(
    {
        autoselect_one = true,
        include_current = true,
        other_win_hl_color = '#087c9c',
        selection_chars = 'ABCDEFGHJKLMNOPQRSTUVWXYZ',
        filter_rules = {
            bo = {
                filetype = { 'neo-tree', 'neo-tree-popup', 'notify', 'quickfix' },
                buftype = { 'terminal', 'quickfix' },
            },
        },
    }
)
_G.jump_to_window = function()
    local picked_window_id = require('window-picker').pick_window()
    if picked_window_id then
        vim.api.nvim_set_current_win(picked_window_id)
    end
end
vim.api.nvim_set_keymap('n', '<leader>w', ':lua jump_to_window()<CR>', { noremap = true, silent = true })




-- set for treesitter
require 'nvim-treesitter.configs'.setup {
    ensure_installed = { "c", "cpp", "lua", "python", "javascript", "typescript", "go", "rust" },
    highlight = {
        enable = true,
    },
    indent = {
        enable = true,
    },
    fold = {
        enable = true,
    },
    textobjects = {
        select = {
            enable = true,
            lookahead = true,
            keymaps = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
            },
            selection_modes = {
                ['@parameter.outer'] = 'v', -- charwise
                ['@function.outer'] = 'V',  -- linewise
                ['@class.outer'] = '<c-v>', -- blockwise
            },
        },
    },
    playground = {
        enable = true,
    },
}
