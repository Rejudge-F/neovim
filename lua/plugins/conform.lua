return {
    'stevearc/conform.nvim',
    opts = {},
    event = { "BufWritePre" },
    config = function()
        require('conform').setup({
            formatters_by_ft = {
                python = { "black", "ruff_format", "ruff_fix" },
                rust = { "rustfmt" },
                go = { "goimports", "gofmt" },
                lua = { "stylua" },
                sh = { "shfmt" },
                dart = { "dart_format" },
            },
            -- 保存时自动格式化（只需一次）
            format_on_save = {
                -- 如果 conform 没有配置 formatter，回退到 LSP 格式化
                lsp_format = "fallback",
                timeout_ms = 500,
            },
            -- 删除 format_after_save 以避免重复格式化
        })
    end
}
