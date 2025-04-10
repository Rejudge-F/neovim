vim.opt.encoding       = 'utf-8'
vim.opt.guicursor      = 'n-v-c-i:block'
vim.opt.termguicolors  = true
vim.opt.sidescrolloff  = 15
vim.opt.showmatch      = true
vim.opt.undofile       = true
vim.opt.undodir        = vim.fn.expand('~/.config/nvim/undo/')
vim.opt.foldmethod     = 'expr'
vim.opt.foldexpr       = 'nvim_treesitter#foldexpr()'
vim.opt.foldlevelstart = 99
vim.opt.wildmenu       = true
vim.opt.wildmode       = { 'longest:list', 'full' }
vim.opt.vb             = true
vim.opt.number         = true
vim.opt.history        = 700
vim.opt.undolevels     = 700
vim.opt.tabstop        = 4
vim.opt.softtabstop    = 4
vim.opt.shiftwidth     = 4
vim.opt.shiftround     = true
vim.opt.expandtab      = true
vim.opt.hlsearch       = true
vim.opt.incsearch      = true
vim.opt.ignorecase     = true
vim.opt.smartcase      = true
vim.opt.backup         = false
vim.opt.writebackup    = false
vim.opt.swapfile       = false

vim.cmd [[filetype plugin indent on]]
vim.cmd [[syntax on]]
vim.cmd [[highlight ColorColumn ctermbg=233]]

vim.g.mapleader = ';'
vim.g.maplocalleader = '\''
vim.api.nvim_set_keymap('n', '<leader>q', ':q<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>h', '<C-w>h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>j', '<C-w>j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>k', '<C-w>k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>l', '<C-w>l', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<', '<gv', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '>', '>gv', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'Q', 'gq', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'Q', 'gqap', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'sp', ':split<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'sv', ':vsplit<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'sc', '<C-w>c', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'so', '<C-w>o', { noremap = true, silent = true })
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
    spec = {
        {
            "kyazdani42/nvim-tree.lua",
            dependencies = "kyazdani42/nvim-web-devicons",
            config = function()
                require("nvim-tree").setup {
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
                        side = "left",
                    },
                    git = {
                        enable = true,
                        ignore = false,
                    },
                    on_attach = function(bufnr)
                        local api = require("nvim-tree.api")
                        local opts = { noremap = true, silent = true, nowait = true, buffer = bufnr }
                        api.config.mappings.default_on_attach(bufnr)
                        vim.keymap.set('n', 'sv', api.node.open.vertical, opts)
                        vim.keymap.set('n', 'sp', api.node.open.horizontal, opts)
                    end,
                    hijack_cursor = true,
                    respect_buf_cwd = true,
                    sync_root_with_cwd = true,
                }
                vim.keymap.set('n', '<leader>n', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
            end
        },
        {
            "nvim-treesitter/nvim-treesitter",
            build = ":TSUpdate",
            config = function()
                require("nvim-treesitter.configs").setup({
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
                                ['@parameter.outer'] = 'v', ['@function.outer'] = 'V', ['@class.outer'] = '<c-v>', },
                        },
                    },
                })
            end
        },
        {
            "nvim-treesitter/nvim-treesitter-textobjects",
            dependencies = "nvim-treesitter/nvim-treesitter",
            after = "nvim-treesitter",
        },
        {
            "ahmedkhalf/project.nvim",
            config = function()
                require("project_nvim").setup {}
            end
        },
        {
            "nvim-telescope/telescope.nvim",
            tag = "0.1.8",
            dependencies = {
                "nvim-lua/plenary.nvim", "ahmedkhalf/project.nvim" },
            config = function()
                local actions = require("telescope.actions")
                local action_state = require("telescope.actions.state")
                local function telescope_open_with_picker(prompt_bufnr)
                    local picker = action_state.get_current_picker(prompt_bufnr)
                    local entry = action_state.get_selected_entry()
                    actions.close(prompt_bufnr)
                    local win = require("window-picker").pick_window({})
                    if not win or not entry then return end
                    vim.api.nvim_set_current_win(win)
                    if picker.prompt_title:match("Buffer") then
                        vim.cmd("buffer " .. entry.bufnr)
                    else
                        local path = entry.path or entry.filename
                        vim.cmd("edit " .. vim.fn.fnameescape(path))
                    end
                end
                require("telescope").setup({
                    defaults = {
                        layout_strategy = "bottom_pane",
                        layout_config = {
                            bottom_pane = {
                                height = 0.4,
                                prompt_position = "bottom",
                            },
                        },
                        mappings = {
                            i = {
                                ["<CR>"] = actions.select_vertical, },
                            n = {
                                ["sv"] = actions.select_vertical,
                                ["sp"] = actions.select_horizontal,
                                ["<leader>w"] = telescope_open_with_picker,
                            }
                        }
                    },
                    pickers = {
                        find_files = {
                            hidden = true,
                            no_ignore = true,
                        },
                        live_grep = {
                            no_ignore = true
                        },
                    },
                    extensions = {
                        projects = {}
                    }
                })
                require('telescope').load_extension('projects')
                vim.keymap.set("n", "<leader>f", ":Telescope find_files<CR>",
                    { noremap = true, silent = true })
                vim.keymap.set("n", "<leader>ss", ":Telescope live_grep<CR>",
                    { noremap = true, silent = true })
                vim.keymap.set("n", "<leader>p", ":Telescope projects<CR>",
                    { noremap = true, silent = true })
                require("telescope").load_extension("projects")
            end
        },
        {
            "s1n7ax/nvim-window-picker",
            name = 'window-picker',
            version = "2.*",
            event = 'VeryLazy',
            config = function()
                require("window-picker").setup({
                    autoselect_one = true,
                    include_current = true,
                    other_win_hl_color = "#087c9c",
                    selection_chars = "ABCDEFGHJKLMNOPQRSTUVWXYZ",
                    filter_rules = {
                        bo = {
                            filetype = { "neo-tree", "neo-tree-popup", "notify", "quickfix" },
                            buftype = { "terminal", "quickfix" },
                        },
                    },
                })
                _G.jump_to_window = function()
                    local picked_window_id = require("window-picker").pick_window()
                    if picked_window_id then
                        vim.api.nvim_set_current_win(picked_window_id)
                    end
                end
                vim.keymap.set("n", "<leader>w", ":lua jump_to_window()<CR>",
                    {
                        noremap = true,
                        silent = true,
                        desc = "Pick window"
                    })
            end
        },
        {
            "junegunn/seoul256.vim",
            lazy = false,
            priority = 1000,
            config = function()
                vim.g.seoul256_background = 236
                vim.cmd("colorscheme seoul256")
            end
        },
        {
            "sindrets/diffview.nvim",
            cmd = { "DiffviewOpen", "DiffviewClose" },
            keys = { { "dfo", "<cmd>DiffviewOpen<cr>", desc = "Open diff view" },
                { "dfc", "<cmd>DiffviewClose<cr>", desc = "Close diff view" },
                { "dfp", "<cmd>diffput<cr>",       desc = "Diff put" },
                { "dfg", "<cmd>diffget<cr>",       desc = "Diff get" },
            },
            config = function()
                require("diffview").setup({
                })
            end
        },
        {
            "junegunn/vim-easy-align",
            keys = { { "ga", mode = { "n", "x" } }, },
            init = function()
                vim.g.easy_align_delimiters = {
                }
            end,
        },
        {
            "neoclide/coc.nvim",
            branch = "release",
            build = "npm install",
            event = "VeryLazy",
            config = function()
                vim.g.coc_global_extensions = {
                    'coc-json',
                    'coc-tsserver',
                    'coc-pyright',
                    'coc-go',
                    'coc-rust-analyzer',
                    'coc-lua',
                }
                vim.keymap.set("n", "rn", "<Plug>(coc-rename)",
                    { desc = "Rename symbol" })
                vim.keymap.set("n", "gd", "<Plug>(coc-definition)",
                    { desc = "Go to definition" })
                vim.keymap.set("n", "gy", "<Plug>(coc-type-definition)",
                    { desc = "Go to type definition" })
                vim.keymap.set("n", "gi", "<Plug>(coc-implementation)",
                    { desc = "Go to implementation" })
                vim.keymap.set("n", "gr", "<Plug>(coc-references)",
                    { desc = "Show references" })
                vim.keymap.set("n", "gf", "<Plug>(coc-fix-current)",
                    { desc = "Auto-fix current" })
                vim.keymap.set("i", "<CR>",
                    [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]],
                    { expr = true, desc = "Confirm completion" })
                vim.api.nvim_create_user_command("Format", "call CocAction('format')",
                    {})
            end
        },
        {
            "tpope/vim-surround",
            keys = { { "cs", mode = "n" },
                { "ds", mode = "n" },
                { "ys", mode = { "n", "x" } },
                { "S",  mode = "x" },
            },
            init = function() end,
        },
        {
            "nvim-lualine/lualine.nvim",
            dependencies = { "nvim-tree/nvim-web-devicons" },
            event = "VeryLazy",
            config = function()
                require('lualine').setup({
                    theme = 'auto',
                })
            end
        },
        {
            'tveskag/nvim-blame-line',
            config = function()
                vim.api.nvim_create_autocmd("BufEnter",
                    {
                        pattern = "*",
                        command = "EnableBlameLine"
                    })
            end
        },
        {
            "Exafunction/codeium.vim",
        },
        {
            "akinsho/toggleterm.nvim",
            config = function()
                require("toggleterm").setup {
                    shade_terminals = true,
                    shading_factor = '1',
                    start_in_insert = true,
                    persist_size = true,
                    direction = 'horizontal',
                }
                vim.api.nvim_set_keymap('n', '<leader>t', ':ToggleTerm<CR>',
                    { noremap = true, silent = true })
                vim.api.nvim_set_keymap('t', '<Esc>', '<C-\\><C-n>',
                    { noremap = true, silent = true })
                vim.api.nvim_set_keymap('n', '<C-1>', ':1ToggleTerm<CR>',
                    { noremap = true, silent = true })
                vim.api.nvim_set_keymap('n', '<C-2>', ':2ToggleTerm<CR>',
                    { noremap = true, silent = true })
                vim.api.nvim_set_keymap('n', '<C-3>', ':3ToggleTerm<CR>',
                    { noremap = true, silent = true })
                vim.api.nvim_set_keymap('n', '<C-4>', ':4ToggleTerm<CR>',
                    { noremap = true, silent = true })
            end
        },
        {
            "mfussenegger/nvim-dap",
            dependencies = {
                "mfussenegger/nvim-dap-python",
                "leoluz/nvim-dap-go"
            }
        },
        {
            "rcarriga/nvim-dap-ui",
            dependencies = {
                "nvim-neotest/nvim-nio",
                "mfussenegger/nvim-dap"
            },
            config = function()
                local dap = require('dap')
                local dapui = require('dapui')
                local dap_python = require('dap-python')
                local dap_go = require('dap-go')
                local function get_python_path()
                    local cwd = vim.fn.getcwd()
                    if vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
                        return cwd .. '/.venv/bin/python'
                    elseif vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
                        return cwd .. '/venv/bin/python'
                    else
                        return 'python3'
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
                vim.api.nvim_set_keymap('n', '<F5>', ':lua require"dap".continue()<CR>',
                    { noremap = true, silent = true })
                vim.api.nvim_set_keymap('n', '<F10>', ':lua require"dap".step_over()<CR>',
                    { noremap = true, silent = true })
                vim.api.nvim_set_keymap('n', '<F11>', ':lua require"dap".step_into()<CR>',
                    { noremap = true, silent = true })
                vim.api.nvim_set_keymap('n', '<F12>', ':lua require"dap".step_out()<CR>',
                    { noremap = true, silent = true })
                vim.api.nvim_set_keymap('n', '<leader>b', ':lua require"dap".toggle_breakpoint()<CR>',
                    { noremap = true, silent = true })
                vim.api.nvim_set_keymap('n', '<leader>B',
                    ':lua require"dap".set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>',
                    { noremap = true, silent = true })
                vim.api.nvim_set_keymap('n', '<leader>dr', ':lua require"dap".repl.open()<CR>',
                    { noremap = true, silent = true })
            end
        },
        {
            "zbirenbaum/neodim",
            event = "LspAttach",
            config = function()
                require("neodim").setup()
            end
        },
        {
            'ethanholz/nvim-lastplace',
            config = function()
                require 'nvim-lastplace'.setup {
                    lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
                    lastplace_ignore_filetype = { "gitcommit", "gitrebase", "svn", "hgcommit" },
                    lastplace_open_folds = true
                }
            end
        },
        {
            'akinsho/git-conflict.nvim',
            config = function()
                require('git-conflict').setup()
            end
        },
        {
            "lukas-reineke/indent-blankline.nvim"
        },
    },
    install = { colorscheme = { "habamax" } },
    checker = { enabled = true },
})
