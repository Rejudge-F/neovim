return {
    "danymat/neogen",
    dependencies = "nvim-treesitter/nvim-treesitter",  -- 修复：requires → dependencies
    cmd = { "Neogen" },  -- 添加懒加载
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
