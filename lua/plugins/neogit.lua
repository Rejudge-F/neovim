return {
    "NeogitOrg/neogit",
    dependencies = {
        "nvim-lua/plenary.nvim",  -- required
        "sindrets/diffview.nvim", -- optional - Diff integration

        -- Only one of these is needed.
        "nvim-telescope/telescope.nvim",
    },
    cmd = { "Neogit" },
    config = function()
        require("neogit").setup({
            kind = "floating", -- 设置 popup 默认类型为 floating
            -- Floating window style
            floating = {
                relative = "editor",
                width = 0.8,
                height = 0.7,
                style = "minimal",
                border = "rounded",
            },
            -- 配置 commit view 使用 tab，避免被主 floating 窗口遮挡
            commit_view = {
                kind = "tab", -- 使用新标签页显示 commit 内容
            },
        })
    end
}
