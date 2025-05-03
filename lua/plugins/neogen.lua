return {
    "danymat/neogen",
    requires = "nvim-treesitter/nvim-treesitter",
    config = function()
        require("neogen").setup({
            enabled = true,
            languages = {
                python = {
                    template = {
                        annotation_convention = "numpydoc"
                    }
                }
            }
        })

        vim.api.nvim_set_keymap('n', '<Leader>cc', ':lua require("neogen").generate()<CR>',
            { noremap = true, silent = true })
    end,
}
