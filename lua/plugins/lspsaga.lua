return {
    'nvimdev/lspsaga.nvim',
    event = "LspAttach",
    config = function()
        local lspsaga_config = {
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
        }

        require('lspsaga').setup(lspsaga_config)

        -- 彻底解决方案：自动清理 pending_request 状态
        -- 在每次调用 lspsaga 命令前，自动检查并清理卡住的状态
        local function safe_lspsaga_call(cmd)
            return function()
                -- 静默清理可能卡住的 pending_request 状态
                local modules_with_state = {
                    'lspsaga.codeaction',
                    'lspsaga.definition',
                    'lspsaga.finder',
                    'lspsaga.callhierarchy',
                    'lspsaga.typehierarchy',
                }
                for _, mod_name in ipairs(modules_with_state) do
                    local ok, mod = pcall(require, mod_name)
                    if ok and type(mod) == 'table' and mod.pending_request == true then
                        -- 只在真的卡住时重置（pending_request 为 true 但没有活动窗口）
                        local has_saga_window = false
                        for _, win in ipairs(vim.api.nvim_list_wins()) do
                            if vim.api.nvim_win_is_valid(win) then
                                local buf = vim.api.nvim_win_get_buf(win)
                                local bufname = vim.api.nvim_buf_get_name(buf)
                                if bufname:match("lspsaga://") then
                                    has_saga_window = true
                                    break
                                end
                            end
                        end
                        if not has_saga_window then
                            mod.pending_request = false
                        end
                    end
                end
                -- 执行实际命令
                vim.cmd(cmd)
            end
        end

        vim.keymap.set("n", "rn", safe_lspsaga_call("Lspsaga rename"), { noremap = true, silent = true })
        vim.keymap.set('n', 'K', safe_lspsaga_call("Lspsaga peek_definition"), { noremap = true, silent = true })
        vim.keymap.set('n', '<leader>so', safe_lspsaga_call("Lspsaga outline"), { noremap = true, silent = true })
        vim.keymap.set('n', '<leader>ca', safe_lspsaga_call("Lspsaga code_action"), { noremap = true, silent = true })
        vim.keymap.set('n', 'gr', safe_lspsaga_call("Lspsaga finder"), { noremap = true, silent = true })
        vim.keymap.set('n', 'gi', safe_lspsaga_call("Lspsaga finder imp"), { noremap = true, silent = true })
        vim.keymap.set('n', 'go', safe_lspsaga_call("Lspsaga outgoing_calls"), { noremap = true, silent = true })
        vim.keymap.set('n', 'gd', safe_lspsaga_call("Lspsaga goto_definition"), { noremap = true, silent = true })
        vim.keymap.set('n', 'gtd', safe_lspsaga_call("Lspsaga goto_type_definition"), { noremap = true, silent = true })
        vim.keymap.set('n', ']e', safe_lspsaga_call("Lspsaga diagnostic_jump_next"), { noremap = true, silent = true })
        vim.keymap.set('n', '[e', safe_lspsaga_call("Lspsaga diagnostic_jump_prev"), { noremap = true, silent = true })
        vim.keymap.set('n', '<leader>db', safe_lspsaga_call("Lspsaga show_buf_diagnostics"), { noremap = true, silent = true })
        vim.keymap.set('n', '<leader>dw', safe_lspsaga_call("Lspsaga show_workspace_diagnostics"), { noremap = true, silent = true })

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

        -- 完全热重启 lspsaga 的命令
        vim.api.nvim_create_user_command('LspsagaRestart', function()
            -- 1. 清理 lspsaga 模块的 pending_request 状态（核心修复）
            local modules_with_state = {
                'lspsaga.codeaction',
                'lspsaga.definition',
                'lspsaga.symbol',
                'lspsaga.callhierarchy',
                'lspsaga.typehierarchy',
            }
            for _, mod_name in ipairs(modules_with_state) do
                local ok, mod = pcall(require, mod_name)
                if ok and type(mod) == 'table' then
                    -- 重置 pending_request 标志
                    if mod.pending_request ~= nil then
                        mod.pending_request = false
                    end
                    -- 某些模块可能用的是实例方法
                    if type(mod) == 'table' and mod.__index then
                        for k, v in pairs(mod) do
                            if type(v) == 'table' and v.pending_request ~= nil then
                                v.pending_request = false
                            end
                        end
                    end
                end
            end

            -- 2. 关闭所有 lspsaga 相关的浮动窗口
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_is_valid(win) then
                    local config = vim.api.nvim_win_get_config(win)
                    if config.relative ~= "" then
                        pcall(vim.api.nvim_win_close, win, true)
                    end
                end
            end

            -- 3. 清理 lspsaga 相关的 buffer
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_valid(buf) then
                    local bufname = vim.api.nvim_buf_get_name(buf)
                    if bufname:match("lspsaga://") or bufname:match("sagaoutline") then
                        pcall(vim.api.nvim_buf_delete, buf, { force = true })
                    end
                end
            end

            -- 4. 清理 lspsaga 的自动命令组
            local augroups = vim.api.nvim_get_autocmds({})
            for _, au in ipairs(augroups) do
                if au.group_name and au.group_name:match("lspsaga") then
                    pcall(vim.api.nvim_del_augroup_by_name, au.group_name)
                end
            end

            -- 5. 卸载所有 lspsaga 模块
            for name, _ in pairs(package.loaded) do
                if name:match('^lspsaga') then
                    package.loaded[name] = nil
                end
            end

            -- 6. 重新 setup lspsaga
            require('lspsaga').setup(lspsaga_config)

            -- 7. 重新触发 winbar 更新
            vim.cmd('doautocmd BufEnter')

            vim.notify("Lspsaga restarted (pending states cleared)", vim.log.levels.INFO)
        end, { desc = "Completely restart lspsaga and clear pending request states" })

    end,
    dependencies = {
        'nvim-treesitter/nvim-treesitter', -- optional
        'nvim-tree/nvim-web-devicons',     -- optional
    }
}
