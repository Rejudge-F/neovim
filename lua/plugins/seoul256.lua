return {
    "junegunn/seoul256.vim",
    lazy = false,
    priority = 1000,
    config = function()
        vim.g.seoul256_background = 236
        vim.cmd("colorscheme seoul256")
    end
}
