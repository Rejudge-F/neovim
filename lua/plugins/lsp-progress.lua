return {
    'linrongbin16/lsp-progress.nvim',
    event = "LspAttach",  -- LSP 连接时才加载
    config = function()
        require('lsp-progress').setup()
    end
}
