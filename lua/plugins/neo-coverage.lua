return {
    "andythigpen/nvim-coverage",
    version = "*",
    config = function()
        require("coverage").setup({
            auto_reload = true,
            highlights = {
                covered = { fg = "#C3E88D" },   -- 被覆盖的行
                uncovered = { fg = "#F07178" }, -- 未覆盖的行
            },
        })
    end,
}
