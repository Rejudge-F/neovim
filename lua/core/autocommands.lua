vim.cmd [[autocmd BufLeave * silent! update]]

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
