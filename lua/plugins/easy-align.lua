return {
    "junegunn/vim-easy-align",
    keys = { { "ga", mode = { "n", "x" } }, },
    init = function()
        vim.g.easy_align_delimiters = {
        }
    end,
}
