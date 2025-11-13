return {
    "theHamsta/nvim-dap-virtual-text",
    lazy = true,  -- DAP 启动时才加载
    dependencies = {
        "mfussenegger/nvim-dap",
        "nvim-treesitter/nvim-treesitter",
    },
    config = function()
        require("nvim-dap-virtual-text").setup({
            enabled = true,
            highlight_changed_variables = true,
            highlight_new_as_changed = true,
        })
    end
}
