-- lspsaga: LSP 浮窗 UI
--
-- 2026-04-07 (2b3cb28) 曾整体移除, 改用原生 vim.lsp.buf.* + core/beacon.lua,
-- 现按需装回. 与当年那版的区别:
--   1. keymap 不在这里设置, 统一放在 nvim-lspconfig.lua 的 on_attach 里
--      (buffer-local, 和其余 LSP 键位在同一处, 不再散成全局映射)
--   2. pending_request 守卫抽到 core/saga.lua, 供 on_attach 复用
--   3. <C-o>/<C-i> 的 beacon 不再用 lspsaga.beacon —— core/keymaps.lua 已经
--      用 core/beacon.lua 包过一层了, 装两套会闪两次
--
-- 注意: lspsaga 历史上每次 Neovim 改 LSP 内部就容易炸 (0.5.1 时期整个跟
-- nightly 不兼容), 0.11/0.12 又重做了一轮 LSP 层. 真出问题时:
--   - gr 回退成 vim.lsp.buf.references 即可
--   - gR (core/ref_kinds.lua) 不依赖 lspsaga, 不受影响

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
        num_shortcut = false,    -- 禁用代码操作窗口的数字快捷键
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
        -- core/options.lua 已有全局 winborder='rounded', 这里仍显式写一遍:
        -- lspsaga 自建浮窗时读的是这个字段而不是 winborder, 留空会没边框
        border = 'rounded',
        title = true,
        winblend = 0,
        expand = '',
        collapse = '',
        code_action = '💡',
        actionfix = ' ',
        lines = { '┗', '┣', '┃', '━', '┏' },
    },
}

return {
    'nvimdev/lspsaga.nvim',
    event = "LspAttach",
    dependencies = {
        'nvim-treesitter/nvim-treesitter', -- optional
        'nvim-tree/nvim-web-devicons',     -- optional
    },
    config = function()
        require('lspsaga').setup(lspsaga_config)

        -- 完全热重启 lspsaga: 卡死到 core/saga.lua 的软清理也救不回来时用
        vim.api.nvim_create_user_command('LspsagaRestart', function()
            -- 1. 清理各模块的 pending_request 状态
            local modules_with_state = {
                'lspsaga.codeaction',
                'lspsaga.definition',
                'lspsaga.symbol',
                'lspsaga.finder',
                'lspsaga.callhierarchy',
                'lspsaga.typehierarchy',
            }
            for _, mod_name in ipairs(modules_with_state) do
                local ok, mod = pcall(require, mod_name)
                if ok and type(mod) == 'table' then
                    if mod.pending_request ~= nil then
                        mod.pending_request = false
                    end
                    -- 某些模块用的是实例方法, 状态挂在子表上
                    if mod.__index then
                        for _, v in pairs(mod) do
                            if type(v) == 'table' and v.pending_request ~= nil then
                                v.pending_request = false
                            end
                        end
                    end
                end
            end

            -- 2. 关掉所有浮动窗口
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_is_valid(win) then
                    local conf = vim.api.nvim_win_get_config(win)
                    if conf.relative ~= "" then
                        pcall(vim.api.nvim_win_close, win, true)
                    end
                end
            end

            -- 3. 清理 lspsaga 相关 buffer
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_valid(buf) then
                    local bufname = vim.api.nvim_buf_get_name(buf)
                    if bufname:match("lspsaga://") or bufname:match("sagaoutline") then
                        pcall(vim.api.nvim_buf_delete, buf, { force = true })
                    end
                end
            end

            -- 4. 清理 lspsaga 的 autocmd group
            for _, au in ipairs(vim.api.nvim_get_autocmds({})) do
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

            -- 6. 重新 setup + 重新触发 winbar
            require('lspsaga').setup(lspsaga_config)
            vim.cmd('doautocmd BufEnter')

            vim.notify("Lspsaga restarted (pending states cleared)", vim.log.levels.INFO)
        end, { desc = "Completely restart lspsaga and clear pending request states" })
    end,
}
