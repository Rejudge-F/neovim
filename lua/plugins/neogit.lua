return {
    "NeogitOrg/neogit",
    dependencies = {
        "nvim-lua/plenary.nvim",  -- required
        "sindrets/diffview.nvim", -- optional - Diff integration

        -- Only one of these is needed.
        "nvim-telescope/telescope.nvim",
    },
    config = function()
        require("neogit").setup({
            kind = "floating",     -- 设置 popup 默认类型为 floating
            -- Floating window style
            floating = {
                relative = "editor",
                width = 0.8,
                height = 0.7,
                style = "minimal",
                border = "rounded",
            },
        })
    end
}
