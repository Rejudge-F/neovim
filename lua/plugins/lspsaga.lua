return {
    'nvimdev/lspsaga.nvim',
    event = "LspAttach",
    config = function()
        require('lspsaga').setup({
            -- 请求超时设置,防止 lspsaga 卡住
            request_timeout = 3000, -- 3秒超时
            beacon = {
                enable = true
            },
            lightbulb = {
                enable = false,
            },
            diagnostic = {
                jump_num_shortcut = false, -- 禁用诊断窗口的数字快捷键
            },
            code_action = {
                num_shortcut = false, -- 禁用代码操作窗口的数字快捷键
                extend_gitsigns = false, -- 禁用 gitsigns 集成,可能导致延迟
            },
            definition = {
                width = 0.6,
                height = 0.5,
                keys = {
                    edit = 'o',
                    vsplit = 'sv',
                    split = 'sp',
                    tabe = 't',
                    quit = 'q',
                    close = '<Esc>',
                }
            },
            finder = {
                max_height = 0.6,
                default = 'ref+imp', -- 默认显示引用和实现
                layout = 'float',    -- 使用浮动布局
                silent = false,
                keys = {
                    shuttle = '[w',       -- 在结果间切换
                    toggle_or_open = 'o', -- 打开或切换
                    vsplit = 'sv',
                    split = 'sp',
                    tabe = 't',
                    tabnew = 'r',
                    quit = 'q',
                    close = '<Esc>',
                }
            },
            symbol_in_winbar = {
                enable = true,
            },
            ui = {
                border = 'rounded', -- 使用圆角边框
                title = true,
                winblend = 0,
                expand = '',
                collapse = '',
                code_action = '💡',
                actionfix = ' ',
                lines = { '┗', '┣', '┃', '━', '┏' },
            },
        })
        vim.keymap.set("n", "rn", ":Lspsaga rename<CR>", { noremap = true, silent = true })
        vim.keymap.set('n', 'K', ':Lspsaga peek_definition<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', '<leader>so', ':Lspsaga outline<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', '<leader>ca', ':Lspsaga code_action<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', 'gr', ':Lspsaga finder<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', 'gi', ':Lspsaga finder imp<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', 'go', ':Lspsaga outgoing_calls<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', 'gd', ':Lspsaga goto_definition<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', 'gtd', ':Lspsaga goto_type_definition<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', ']e', ':Lspsaga diagnostic_jump_next<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', '[e', ':Lspsaga diagnostic_jump_prev<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', '<leader>db', ':Lspsaga show_buf_diagnostics<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', '<leader>dw', ':Lspsaga show_workspace_diagnostics<CR>', { noremap = true, silent = true })

        local function with_beacon(fn)
            return function()
                vim.schedule(function()
                    local row = vim.fn.line('.') - 1
                    local col = vim.fn.col('.')
                    local line = vim.fn.getline('.')
                    local len = #line
                    local s = col
                    while s > 1 and line:sub(s - 1, s - 1):match("%w") do
                        s = s - 1
                    end
                    local e = col
                    while e <= len and line:sub(e, e):match("%w") do
                        e = e + 1
                    end
                    e = e - 1
                    local width = e - s + 1
                    require('lspsaga.beacon').jump_beacon({ row, s - 1 }, width)
                end)
                return fn()
            end
        end

        vim.keymap.set("n", "<C-o>", with_beacon(function() return "<C-o>" end), { expr = true })
        vim.keymap.set("n", "<C-i>", with_beacon(function() return "<C-i>" end), { expr = true })

    end,
    dependencies = {
        'nvim-treesitter/nvim-treesitter', -- optional
        'nvim-tree/nvim-web-devicons',     -- optional
    }
}
