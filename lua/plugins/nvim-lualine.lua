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
                    -- LSP client 状态: 列出当前 buffer 上 attached 的 client
                    -- 没有 client 时显示警告标识 (LSP 异常退出时一眼可见)
                    {
                        function()
                            local bufnr = vim.api.nvim_get_current_buf()
                            -- 跳过没意义的 buftype (terminal/nofile 等)
                            local bt = vim.bo[bufnr].buftype
                            if bt ~= "" and bt ~= "acwrite" then return "" end
                            -- 跳过没有真实文件名的 buffer
                            if vim.api.nvim_buf_get_name(bufnr) == "" then return "" end
                            local clients = vim.lsp.get_clients({ bufnr = bufnr })
                            if #clients == 0 then
                                return " no LSP"
                            end
                            local names = {}
                            for _, c in ipairs(clients) do
                                table.insert(names, c.name)
                            end
                            return " " .. table.concat(names, ",")
                        end,
                        padding = { left = 0, right = 1 },
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

        -- LSP attach/detach 时立即刷新 lualine, 让 LSP 状态变化第一时间可见
        vim.api.nvim_create_autocmd({ "LspAttach", "LspDetach" }, {
            callback = function() require("lualine").refresh() end,
            desc = "Refresh lualine on LSP attach/detach",
        })
    end
}
