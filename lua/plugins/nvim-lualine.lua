return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    config = function()
        vim.api.nvim_create_augroup("lualine_augroup", { clear = true })
        vim.api.nvim_create_autocmd("User", {
            group = "lualine_augroup",
            pattern = "LspProgressStatusUpdated",
            callback = require("lualine").refresh,
        })
        require('lualine').setup({
            theme = 'auto',
            extensions = { "neo-tree", "mason", "toggleterm", "trouble", "nvim-dap-ui", "quickfix", "lazy", "trouble", },
            sections = {
                lualine_a = { 'mode' },
                lualine_b = {
                    'branch',
                    'diff',
                    'diagnostics',
                },
                lualine_c = {
                    { 'filename', path = 1, symbols = { modified = ' ●', readonly = ' ', unnamed = '[No Name]' } },
                },
                lualine_x = { require('lsp-progress').progress, 'encoding', 'fileformat', 'filetype' },
                lualine_y = { 'progress' },
                lualine_z = { 'location' }
            },
        })
    end
}
