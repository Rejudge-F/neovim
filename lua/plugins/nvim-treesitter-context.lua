return {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
        require("treesitter-context").setup(
            {
                enable = true,
                max_lines = 5,
                trim_scope = "outer",
                min_window_height = 0,
            }
        )
    end
}
