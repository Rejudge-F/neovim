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
        -- 排除第三方插件源码目录，避免误格式化 lazy 管理的插件
        local function should_skip_format(bufnr)
            local bufname = vim.api.nvim_buf_get_name(bufnr)
            local lazy_path = vim.fn.stdpath("data") .. "/lazy/"
            local site_path = vim.fn.stdpath("data") .. "/site/"
            return bufname:find(lazy_path, 1, true) ~= nil
                or bufname:find(site_path, 1, true) ~= nil
        end

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
            format_after_save = function(bufnr)
                if should_skip_format(bufnr) then return end
                return {
                    lsp_format = "fallback",
                    async = true,
                }
            end,
            -- 性能优化：禁用不必要的通知
            notify_on_error = false,
        })
    end
}
