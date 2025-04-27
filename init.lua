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
vim.cmd [[autocmd BufLeave * silent! update]]

-- for diagnostics
vim.api.nvim_create_autocmd("CursorHold", {
    callback = function()
        vim.diagnostic.open_float(nil, { focus = false })
    end,
})

vim.g.mapleader = ';'
vim.g.maplocalleader = '\''
vim.api.nvim_set_keymap('x', '<leader>y', '"+y<CR>', { noremap = true, silent = true })
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
            "nvim-neo-tree/neo-tree.nvim",
            branch = "v3.x",
            dependencies = {
                "nvim-lua/plenary.nvim",
                "nvim-tree/nvim-web-devicons", -- 注意：这里仍然使用 nvim-web-devicons
                "MunifTanjim/nui.nvim",
                {
                    "s1n7ax/nvim-window-picker", -- for open_with_window_picker keymaps
                    version = "2.*",
                    config = function()
                        require("window-picker").setup({
                            filter_rules = {
                                include_current_win = false,
                                autoselect_one = true,
                                -- filter using buffer options
                                bo = {
                                    -- if the file type is one of following, the window will be ignored
                                    filetype = { "neo-tree", "neo-tree-popup", "notify" },
                                    -- if the buffer type is one of following, the window will be ignored
                                    buftype = { "terminal", "quickfix" },
                                },
                            },
                        })
                    end,
                },
            },
            config = function()
                require("neo-tree").setup({
                    close_if_last_window = true,
                    popup_border_style = "rounded",
                    enable_git_status = true,
                    enable_diagnostics = true,
                    default_component_configs = {
                        indent = {
                            indent_size = 2,
                            padding = 1,
                        },
                        git_status = {
                            symbols = {
                                -- 更改 git 状态符号
                                added     = "✚",
                                deleted   = "✖",
                                modified  = "",
                                renamed   = "➜",
                                untracked = "?",
                                ignored   = "◌",
                                unstaged  = "",
                                staged    = "✓",
                                conflict  = "",
                            }
                        },
                    },
                    modified = {
                        symbol = "[+]",
                        highlight = "NeoTreeModified",
                    },
                    filesystem = {
                        filtered_items = {
                            visible = false, -- 默认不显示隐藏文件
                            hide_dotfiles = true,
                            hide_gitignored = true,
                            hide_by_name = {
                                "__pycache__",
                                ".DS_Store",
                            },
                            always_show_by_pattern = {
                                ".gitignore",
                                "*codebase*",
                                ".venv",
                            },
                        },
                        follow_current_file = {
                            enabled = true, -- 自动跟随当前文件
                        },
                        hijack_netrw_behavior = "open_current",
                        use_libuv_file_watcher = true,
                        window = {
                            width = 30,
                            mappings = {
                                ["sv"] = "open_vsplit",
                                ["sp"] = "open_split",
                                ["o"] = "open_with_window_picker",
                                ["<cr>"] = "open",
                            }
                        },

                    },
                })

                vim.g.neo_tree_window_picker_delay = 100 -- 毫秒
                vim.keymap.set('n', '<leader>n', ':Neotree toggle<CR>', { noremap = true, silent = true })
            end
        },
        {
            'akinsho/bufferline.nvim',
            version = "*",
            dependencies = 'nvim-tree/nvim-web-devicons',
            opts = {
                options = {
                    mode = "buffers",
                    numbers = "ordinal",
                    close_command = "Bdelete! %d",
                    offsets = {
                        {
                            filetype = "NvimTree",
                            text = "File Explorer",
                            highlight = "Directory",
                            text_align = "left",
                        },
                    },
                    color_icons = true,
                    show_buffer_icons = true,
                    show_buffer_close_icons = false,
                    separator_style = "thin",
                }
            },
            keys = {
                { "<Tab>",      "<Cmd>BufferLineCycleNext<CR>",            desc = "Next buffer" },
                { "<S-Tab>",    "<Cmd>BufferLineCyclePrev<CR>",            desc = "Previous buffer" },
                { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>",            desc = "Pin buffer" },
                { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete non-pinned buffers" },
            },
        },
        {
            "nvim-treesitter/nvim-treesitter",
            run = ":TSUpdate",
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
                            n = {
                                ["sv"] = actions.select_vertical,
                                ["sp"] = actions.select_horizontal,
                                ["<leader>w"] = telescope_open_with_picker,
                            }
                        },
                        file_ignore_patterns = {
                            "^.git/",
                            "^node_modules/",
                            "^__pycache__/",
                            "^venv/",
                            "^.venv/",
                            "undo",
                            "%.pyc$",
                            "%.DS_Store$",
                        },
                    },
                    pickers = {
                        find_files = {
                            hidden = true,
                            no_ignore = true,
                        },
                        live_grep = {
                            hidden = true,
                            no_ignore = true
                        },
                    },
                    extensions = {
                        projects = {

                        }
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
            "windwp/nvim-autopairs",
            event = "InsertEnter",
            config = function()
                local npairs = require("nvim-autopairs")
                npairs.setup({
                    check_ts = true,
                })


                local cmp = require("cmp")
                local cmp_autopairs = require("nvim-autopairs.completion.cmp")
                cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
            end,
        },
        {
            "folke/trouble.nvim",
            dependencies = { "nvim-tree/nvim-web-devicons" },
            cmd = "Trouble",
            config = function()
                require("trouble").setup()
            end
        },
        {
            'stevearc/conform.nvim',
            opts = {},
            event = { "BufWritePre" },
            config = function()
                require('conform').setup(
                    {
                        formatters_by_ft = {
                            python = { "black", "ruff_format", "ruff_fix" },
                            rust = { "rustfmt" },
                            go = { "goimports", "gofmt" },
                            lua = { "stylua" },
                            sh = { "shfmt" },
                            dart = { "dart_format" },
                        },
                        format_on_save = {
                            lsp_fallback = true,
                            timeout_ms = 1000,
                        },
                    }
                )
                -- vim.api.nvim_create_autocmd("BufWritePre", {
                --     pattern = "*",
                --     callback = function(args)
                --         require("conform").format({ bufnr = args.buf })
                --     end,
                -- })
            end
        },
        {
            "nvim-treesitter/nvim-treesitter-context",
            dependencies = { "nvim-treesitter/nvim-treesitter" },
            config = function()
                require("treesitter-context").setup(
                    {
                        enable = true,
                        max_lines = 5,
                        trim_scope = "outer",
                        min_window_height = 0,
                    }
                )
            end
        },
        {
            "neovim/nvim-lspconfig",
            event = { "BufReadPre", "BufNewFile", "BufEnter" },
            dependencies = {
                { "williamboman/mason.nvim", config = true },
                "williamboman/mason-lspconfig.nvim",


                {
                    "hrsh7th/nvim-cmp",
                    dependencies = {
                        "hrsh7th/cmp-nvim-lsp",
                        "hrsh7th/cmp-buffer",
                        "hrsh7th/cmp-path",
                        "hrsh7th/cmp-cmdline",
                        "L3MON4D3/LuaSnip",
                        "saadparwaiz1/cmp_luasnip"
                    },
                },
            },
            config = function()
                require("mason").setup()
                require("mason-lspconfig").setup({
                    ensure_installed = {
                        "jsonls",
                        "pyright",
                        "gopls",
                        "lua_ls",
                        "thriftls",
                    },
                })


                local capabilities = require("cmp_nvim_lsp").default_capabilities()


                local cmp = require("cmp")
                local luasnip = require("luasnip")

                require("luasnip.loaders.from_vscode").lazy_load()

                cmp.setup({
                    snippet = {
                        expand = function(args)
                            luasnip.lsp_expand(args.body)
                        end,
                    },
                    mapping = cmp.mapping.preset.insert({
                        ["<CR>"] = cmp.mapping.confirm({ select = true }),
                        ["<C-j>"] = cmp.mapping(function(fallback)
                            if cmp.visible() then
                                cmp.select_next_item()
                            elseif luasnip.expand_or_jumpable() then
                                luasnip.expand_or_jump()
                            else
                                fallback()
                            end
                        end, { "i", "s" }),
                        ["<C-k>"] = cmp.mapping(function(fallback)
                            if cmp.visible() then
                                cmp.select_prev_item()
                            elseif luasnip.jumpable(-1) then
                                luasnip.jump(-1)
                            else
                                fallback()
                            end
                        end, { "i", "s" }),
                    }),
                    sources = cmp.config.sources({
                        { name = "nvim_lsp" },
                        { name = "luasnip" },
                        { name = "buffer" },
                        { name = "path" },
                    }),
                })


                local lspconfig = require("lspconfig")
                local servers = {
                    jsonls = {},
                    dartls = {
                        cmd = { "dart", "language-server", "--protocol=lsp" },
                    },
                    thriftls = {},
                    pyright = {
                    },
                    gopls = {},
                    rust_analyzer = {},
                    lua_ls = {
                        settings = {
                            Lua = {
                                diagnostics = {
                                    globals = { "vim" },
                                },
                            },
                        },
                    },
                }

                local on_attach = function(_, bufnr)
                    local nmap = function(keys, func, desc)
                        vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
                    end

                    nmap("rn", vim.lsp.buf.rename, "[LSP] Rename")
                    nmap("gd", vim.lsp.buf.definition, "[LSP] Go to Definition")
                    nmap("gy", vim.lsp.buf.type_definition, "[LSP] Type Definition")
                    nmap("gi", vim.lsp.buf.implementation, "[LSP] Implementation")
                    nmap("gr", vim.lsp.buf.references, "[LSP] References")
                    nmap("gf", vim.lsp.buf.code_action, "[LSP] Code Action")
                    nmap("<leader>ca", vim.lsp.buf.code_action, "[LSP] Code Action")

                    vim.api.nvim_buf_create_user_command(bufnr, "Format", function()
                        vim.lsp.buf.format({ async = true })
                    end, { desc = "Format current buffer with LSP" })
                end

                for server, config in pairs(servers) do
                    config.capabilities = capabilities
                    config.on_attach = on_attach
                    lspconfig[server].setup(config)
                end
            end,
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
            "Exafunction/codeium.vim"
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
            tag = "v4.0.0",
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
            event = "BufReadPre",
            config = function()
                require 'nvim-lastplace'.setup {
                    lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
                    lastplace_ignore_filetype = { "gitcommit", "gitrebase", "svn", "hgcommit" },
                    lastplace_open_folds = true
                }
                require 'nvim-lastplace'.setup {}
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
        {
            "danymat/neogen",
            requires = "nvim-treesitter/nvim-treesitter",
            config = function()
                require("neogen").setup({
                    enabled = true,
                    languages = {
                        python = {
                            template = {
                                annotation_convention = "numpydoc"
                            }
                        }
                    }
                })

                vim.api.nvim_set_keymap('n', '<Leader>cc', ':lua require("neogen").generate()<CR>',
                    { noremap = true, silent = true })
            end,
        },
        {
            "folke/flash.nvim",
            event = "VeryLazy",
            opts = {
                modes = {
                    char = { enabled = false },
                    search = { enabled = true },
                    treesitter = { enabled = true },
                },
                label = {
                    uppercase = false,
                    rainbow = { enabled = true },
                },
            },
            keys = {
                {
                    "<leader>s",
                    mode = { "n", "x", "o" },
                    function()
                        require("flash").jump()
                    end,
                    desc = "Flash jump",
                },
                {
                    "<leader>S",
                    mode = { "n", "x", "o" },
                    function()
                        require("flash").treesitter()
                    end,
                    desc = "Flash treesitter",
                },
                {
                    "r",
                    mode = "o",
                    function() require("flash").remote() end,
                    desc = "Remote Flash"
                },
                {
                    "R",
                    mode = { "o", "x" },
                    function() require("flash").treesitter_search() end,
                    desc = "Treesitter Search"
                },
            },
        },
        {
            "lewis6991/gitsigns.nvim",
            config = function()
                require('gitsigns').setup({
                    signs                        = {
                        add          = { text = '┃' },
                        change       = { text = '┃' },
                        delete       = { text = '_' },
                        topdelete    = { text = '‾' },
                        changedelete = { text = '~' },
                        untracked    = { text = '┆' },
                    },
                    signcolumn                   = true,
                    numhl                        = false,
                    linehl                       = false,
                    word_diff                    = false,
                    watch_gitdir                 = {
                        interval = 100,
                        follow_files = true
                    },
                    attach_to_untracked          = true,
                    current_line_blame           = true,
                    current_line_blame_opts      = {
                        virt_text = true,
                        virt_text_pos = 'eol',
                        delay = 100,
                        ignore_whitespace = false,
                    },
                    current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
                    sign_priority                = 6,
                    update_debounce              = 100,
                    status_formatter             = nil,
                    max_file_length              = 40000,
                    preview_config               = {
                        border = 'single',
                        style = 'minimal',
                        relative = 'cursor',
                        row = 0,
                        col = 1
                    },
                    on_attach                    = function(bufnr)
                        local gitsigns = require('gitsigns')

                        local function map(mode, l, r, opts)
                            opts = opts or {}
                            opts.buffer = bufnr
                            vim.keymap.set(mode, l, r, opts)
                        end


                        map('n', ']c', function()
                            if vim.wo.diff then
                                vim.cmd.normal({ ']c', bang = true })
                            else
                                gitsigns.nav_hunk('next')
                            end
                        end)

                        map('n', '[c', function()
                            if vim.wo.diff then
                                vim.cmd.normal({ '[c', bang = true })
                            else
                                gitsigns.nav_hunk('prev')
                            end
                        end)
                    end
                })
            end
        },
        {
            "kevinhwang91/nvim-ufo",
            dependencies = "kevinhwang91/promise-async",
            event = "BufReadPost",
            opts = {
                provider_selector = function(_, filetype)
                    return filetype == "markdown" and "indent" or { "treesitter", "indent" }
                end
            },

        },
        {
            "simrat39/symbols-outline.nvim",
            cmd = { "SymbolsOutline", "SymbolsOutlineOpen" },
            keys = {
                { "<leader>so", "<cmd>SymbolsOutline<CR>", desc = "Toggle Symbols Outline" }
            },
            config = function()
                require("symbols-outline").setup({
                    show_symbol_details = true,
                })
            end,
        },
        {
            "solarnz/thrift.vim",
            ft = "thrift",
        },
    },
    install = { colorscheme = { "habamax" } },
    checker = { enabled = true },
})
