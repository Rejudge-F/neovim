return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    config = function()
        require('lualine').setup({
            theme = 'auto',
            extensions = { "neo-tree", "mason", "toggleterm", "trouble", "nvim-dap-ui", "quickfix", }
        })
    end
}
