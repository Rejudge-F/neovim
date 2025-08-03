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
                    -- I recommend these options. See :help conform.format for details.
                    lsp_format = "fallback",
                    timeout_ms = 500,
                },
                format_after_save = {
                    lsp_format = "fallback",
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
