vim.cmd [[autocmd BufLeave * silent! update]]

-- for diagnostics
vim.o.updatetime = 300 -- 300 毫秒
vim.api.nvim_create_autocmd("CursorHold", {
    callback = function()
        vim.diagnostic.open_float(nil, { focus = false })
    end,
})

vim.cmd [[filetype plugin indent on]]
vim.cmd [[syntax on]]
vim.cmd [[highlight ColorColumn ctermbg=233]]
