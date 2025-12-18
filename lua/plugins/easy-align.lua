return {
    "junegunn/vim-easy-align",
    -- 延迟加载：只在需要时加载（通过 keys 触发）
    keys = { { "ga", mode = { "n", "x" } }, },
    event = "VeryLazy", -- 确保延迟加载
    init = function()
        vim.g.easy_align_delimiters = {
        }
    end,
}
