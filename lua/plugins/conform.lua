return {
    'stevearc/conform.nvim',
    opts = {},
    -- 只在需要格式化的文件类型时加载
    ft = { "python", "rust", "go", "lua", "sh", "dart", "javascript", "typescript", "thrift" },
    cmd = { "ConformInfo", "Format" },
    keys = {
        {
            "<leader>cf",
            function()
                require("conform").format({ async = true, lsp_fallback = true })
            end,
            mode = "",
            desc = "Format buffer",
        },
    },
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
            -- 禁用 format_on_save，改用 format_after_save 异步格式化
            format_on_save = nil,
            -- 保存后异步格式化（不阻塞保存操作）
            format_after_save = {
                lsp_format = "fallback",
                async = true, -- 异步执行，不阻塞
            },
            -- 性能优化：禁用不必要的通知
            notify_on_error = false,
        })
    end
}
