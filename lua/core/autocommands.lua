-- 离开 buffer 时静默保存——但跳过第三方插件/runtime 路径，避免误改源码
local lazy_path = vim.fn.stdpath("data") .. "/lazy/"
local site_path = vim.fn.stdpath("data") .. "/site/"
vim.api.nvim_create_autocmd("BufLeave", {
    callback = function(args)
        local name = vim.api.nvim_buf_get_name(args.buf)
        if name == "" then return end
        if name:find(lazy_path, 1, true) or name:find(site_path, 1, true) then return end
        if not vim.bo[args.buf].modifiable or vim.bo[args.buf].readonly then return end
        pcall(vim.cmd, "silent! update")
    end,
    desc = "Auto-save buffer on leave (skip third-party plugin sources)",
})

-- 恢复光标到上次离开文件时的位置（替代 nvim-lastplace）
local lastplace_ignore_buftype = { quickfix = true, nofile = true, help = true }
local lastplace_ignore_filetype = { gitcommit = true, gitrebase = true, svn = true, hgcommit = true }
vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function(args)
        if lastplace_ignore_buftype[vim.bo[args.buf].buftype] then return end
        if lastplace_ignore_filetype[vim.bo[args.buf].filetype] then return end
        local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
        local line_count = vim.api.nvim_buf_line_count(args.buf)
        if mark[1] > 0 and mark[1] <= line_count then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
            -- 展开折叠以确保光标可见
            vim.cmd("normal! zv")
        end
    end,
    desc = "Restore cursor to last position",
})

-- 诊断显示已统一使用 lspsaga:
--   ]e / [e  - 跳转到下一个/上一个诊断
--   <leader>db - 显示当前 buffer 诊断列表
--   <leader>dw - 显示 workspace 诊断列表

-- 当焦点回到 Neovim 时检查文件变化
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
    callback = function()
        if vim.fn.mode() ~= 'c' then
            vim.cmd('checktime')
        end
    end,
})

-- LSP $/progress -> Nvim 0.12 progress-message 桥接
-- 让 vim.ui.progress_status() 能拿到 LSP 进度，供 lualine 等显示
-- 参考: :help LspProgress
vim.api.nvim_create_autocmd("LspProgress", {
    callback = function(ev)
        local value = ev.data and ev.data.params and ev.data.params.value
        if type(value) ~= "table" then return end
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        vim.api.nvim_echo({ { value.message or (value.kind == "end" and "done" or "") } }, false, {
            id = "lsp." .. ev.data.client_id,
            kind = "progress",
            source = client and client.name or "vim.lsp",
            title = value.title,
            status = value.kind ~= "end" and "running" or "success",
            percent = value.percentage,
        })
    end,
    desc = "Bridge LSP $/progress to Nvim progress messages",
})

-- 已移除旧的 BufWritePost autocommand，因为在 lspconfig.lua 中有更完善的实现

-- vim.api.nvim_create_autocmd("LspDetach", {
--     callback = function(args)
--         local client_id = args.data.client_id
--         local client = vim.lsp.get_client_by_id(client_id)
--         if client then
--             vim.defer_fn(function()
--                 vim.cmd("LspStart " .. client.name)
--             end, 1000)
--         end
--     end,
-- })

-- vim.api.nvim_create_autocmd("CursorMoved", {
--     callback = function()
--         for _, win in ipairs(vim.api.nvim_list_wins()) do
--             local config = vim.api.nvim_win_get_config(win)
--             if config.relative ~= "" then
--                 vim.api.nvim_win_close(win, true)
--             end
--         end
--     end,
-- })


vim.cmd [[filetype plugin indent on]]
-- vim.cmd [[syntax on]]  -- 已由 treesitter 替代，不需要
vim.cmd [[highlight ColorColumn ctermbg=233]]

-- ============================================================================
-- 预加载常用插件（在启动完成后的空闲时间）
-- ============================================================================
-- 策略：启动时按需加载（keys/cmd），启动后后台预加载，使用时零延迟
vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
        -- 延迟 200ms，确保启动完全完成，然后在后台预加载常用插件
        vim.defer_fn(function()
            -- 使用 lazy.nvim 的 API 来加载插件
            local lazy = require("lazy")

            -- 预加载插件列表（使用 lazy.nvim 的插件名）
            local preload_plugins = {
                "telescope.nvim",  -- Telescope
                "neo-tree.nvim",   -- Neo-tree
                "toggleterm.nvim", -- ToggleTerm
                "trouble.nvim",    -- Trouble
                "diffview.nvim",   -- Diffview
            }

            for _, plugin_name in ipairs(preload_plugins) do
                -- 使用 lazy.load 加载插件，这会触发插件的完整加载流程
                pcall(lazy.load, { plugins = { plugin_name } })
            end

            -- 可选：预加载后输出调试信息
            -- vim.notify("常用插件预加载完成", vim.log.levels.DEBUG)
        end, 200) -- 启动后 200ms 开始预加载
    end,
})
