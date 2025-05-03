return {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    config = function()
        require("nvim-treesitter.configs").setup({
            ensure_installed = { "c", "cpp", "lua", "python", "javascript", "typescript", "go", "rust" },
            highlight = {
                enable = true,
            },
            indent = {
                enable = true,
            },
            fold = {
                enable = true,
            },
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true,
                    keymaps = {
                        ["af"] = "@function.outer",
                        ["if"] = "@function.inner",
                        ["ac"] = "@class.outer",
                        ["ic"] = "@class.inner",
                    },
                    selection_modes = {
                        ['@parameter.outer'] = 'v', ['@function.outer'] = 'V', ['@class.outer'] = '<c-v>', },
                },
            },
        })
    end
}
