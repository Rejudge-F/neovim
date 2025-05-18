vim.cmd [[autocmd BufLeave * silent! update]]

-- for diagnostics
vim.o.updatetime = 300 -- 300 毫秒
vim.api.nvim_create_autocmd("CursorHold", {
    callback = function()
        vim.diagnostic.open_float(nil, { focus = false })
    end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = { "go.mod", "go.sum" },
    callback = function()
        for _, client in pairs(vim.lsp.get_active_clients()) do
            if client.name == "gopls" then
                client.notify("workspace/didChangeConfiguration", { settings = {} })
            end
        end
    end,
})

vim.cmd [[filetype plugin indent on]]
vim.cmd [[syntax on]]
vim.cmd [[highlight ColorColumn ctermbg=233]]
