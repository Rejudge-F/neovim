return {
    'stevearc/conform.nvim',
    opts = {},
    event = { "BufWritePre" },
    config = function()
        require('conform').setup(
            {
                formatters_by_ft = {
                    python = { "black", "ruff_format", "ruff_fix" },
                    rust = { "rustfmt" },
                    go = { "goimports", "gofmt" },
                    lua = { "stylua" },
                    sh = { "shfmt" },
                    dart = { "dart_format" },
                },
                format_on_save = {
                    lsp_fallback = true,
                    timeout_ms = 1000,
                },
                async = true,
            }
        )
        -- vim.api.nvim_create_autocmd("BufWritePre", {
        --     pattern = "*",
        --     callback = function(args)
        --         require("conform").format({ bufnr = args.buf })
        --     end,
        -- })
    end
}
