vim.cmd [[autocmd BufLeave * silent! update]]

-- for diagnostics - 优化性能
vim.o.updatetime = 500 -- 500ms，平衡性能和响应速度

-- 光标停留时自动显示诊断信息
vim.api.nvim_create_autocmd("CursorHold", {
    callback = function()
        -- 只在有诊断信息时才显示
        local opts = {
            focusable = false,
            close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
            border = 'rounded',
            source = 'always',
            prefix = ' ',
            scope = 'cursor',
        }
        vim.diagnostic.open_float(nil, opts)
    end,
})

-- 当焦点回到 Neovim 时检查文件变化
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
    callback = function()
        if vim.fn.mode() ~= 'c' then
            vim.cmd('checktime')
        end
    end,
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
