return {
    "andythigpen/nvim-coverage",
    version = "*",
    cmd = { "Coverage", "CoverageLoad", "CoverageShow", "CoverageToggle" },  -- 只在使用命令时加载
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
