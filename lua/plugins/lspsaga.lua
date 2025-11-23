return {
    'nvimdev/lspsaga.nvim',
    event = "LspAttach",
    config = function()
        require('lspsaga').setup({
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

        -- 一键修复所有可自动修复的 diagnostics
        local function fix_all_diagnostics()
            local bufnr = vim.api.nvim_get_current_buf()
            local diagnostics = vim.diagnostic.get(bufnr)

            if #diagnostics == 0 then
                vim.notify("没有发现任何 diagnostics", vim.log.levels.INFO)
                return
            end

            -- 按行号从大到小排序，从文件末尾开始修复，避免行号变化
            table.sort(diagnostics, function(a, b)
                if a.lnum == b.lnum then
                    return a.col > b.col
                end
                return a.lnum > b.lnum
            end)

            local total_count = #diagnostics
            local processed = 0

            vim.notify(string.format("开始修复 %d 个 diagnostics...", total_count), vim.log.levels.INFO)

            -- 处理每个 diagnostic
            for _, diag in ipairs(diagnostics) do
                local line = diag.lnum
                local col = diag.col

                -- 移动光标到 diagnostic 位置
                vim.api.nvim_win_set_cursor(0, { line + 1, col })

                -- 请求该位置的 code actions
                local params = vim.lsp.util.make_range_params()
                params.context = {
                    diagnostics = { diag },
                    only = { "quickfix", "source.fixAll" },
                }

                -- 同步请求 code actions
                local results = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 1000)

                if results then
                    for _, result in pairs(results) do
                        if result.result and #result.result > 0 then
                            -- 应用第一个可用的 code action
                            local action = result.result[1]
                            if action.edit then
                                vim.lsp.util.apply_workspace_edit(action.edit, "utf-8")
                                processed = processed + 1
                            elseif action.command then
                                vim.lsp.buf.execute_command(action.command)
                                processed = processed + 1
                            end
                            break
                        end
                    end
                end
            end

            if processed > 0 then
                vim.notify(string.format("成功修复 %d/%d 个问题", processed, total_count), vim.log.levels.INFO)
            else
                vim.notify("没有找到可自动修复的问题", vim.log.levels.WARN)
            end
        end

        vim.keymap.set('n', '<leader>fx', fix_all_diagnostics, {
            noremap = true,
            silent = true,
            desc = "Fix all diagnostics in current buffer"
        })
    end,
    dependencies = {
        'nvim-treesitter/nvim-treesitter', -- optional
        'nvim-tree/nvim-web-devicons',     -- optional
    }
}
