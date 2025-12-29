return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    config = function()
        -- 延迟注册 autocmd，避免在加载时创建
        vim.defer_fn(function()
            vim.api.nvim_create_augroup("lualine_augroup", { clear = true })
            vim.api.nvim_create_autocmd("User", {
                group = "lualine_augroup",
                pattern = "LspProgressStatusUpdated",
                callback = require("lualine").refresh,
            })
        end, 100)
        require('lualine').setup({
            theme = 'auto',
            -- 减少 extensions，只保留常用的（减少加载时间）
            extensions = { "neo-tree", "lazy", "quickfix" },
            sections = {
                lualine_a = { 'mode' },
                lualine_b = {
                    'branch',
                    'diff',
                    'diagnostics',
                },
                lualine_c = {
                    { 'filename', path = 1, symbols = { modified = ' ●', readonly = ' ', unnamed = '[No Name]' } },
                },
                lualine_x = {
                    {
                        -- 显示 git blame 信息
                        function()
                            local blame = vim.b.gitsigns_blame_line
                            if blame then
                                return string.format(" %s", blame)
                            end
                            return ""
                        end,
                        cond = function()
                            return vim.b.gitsigns_blame_line ~= nil
                        end,
                        color = { fg = '#7c7d83', gui = 'italic' },
                    },
                    require('lsp-progress').progress,
                    'encoding',
                    'fileformat',
                    'filetype'
                },
                lualine_y = { 'progress' },
                lualine_z = { 'location' }
            },
        })
    end
}
