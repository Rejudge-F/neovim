return {
    "tpope/vim-surround",
    -- 延迟加载：只在需要时加载（通过 keys 触发）
    keys = {
        { "cs", mode = "n" },
        { "ds", mode = "n" },
        { "ys", mode = { "n", "x" } },
        { "S",  mode = "x" },
    },
    -- 确保延迟加载
    event = "VeryLazy",
}
