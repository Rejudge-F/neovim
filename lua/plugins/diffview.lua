return {
    "sindrets/diffview.nvim",
    enabled = false, -- Disabled: replaced by codediff.nvim
    cmd = { "DiffviewOpen", "DiffviewClose" },
    keys = { { "dfo", "<cmd>DiffviewOpen<cr>", desc = "Open diff view" },
        { "dfc", "<cmd>DiffviewClose<cr>", desc = "Close diff view" },
    },
    config = function()
        require("diffview").setup({
        })
    end
}
