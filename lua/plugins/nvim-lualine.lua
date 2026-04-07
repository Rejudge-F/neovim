return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false, -- 取消延迟加载，避免颜色闪烁
    priority = 900, -- 在配色方案之后加载
    config = function()
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
                    -- 0.12 原生 LSP progress (替代 lsp-progress.nvim)
                    {
                        function()
                            if vim.ui and vim.ui.progress_status then
                                return vim.ui.progress_status() or ""
                            end
                            return ""
                        end,
                    },
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
