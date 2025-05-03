return {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
        modes = {
            char = { enabled = false },
            search = { enabled = true },
            treesitter = { enabled = true },
        },
        label = {
            uppercase = false,
            rainbow = { enabled = true },
        },
    },
    keys = {
        {
            "<leader>s",
            mode = { "n", "x", "o" },
            function()
                require("flash").jump()
            end,
            desc = "Flash jump",
        },
        {
            "<leader>S",
            mode = { "n", "x", "o" },
            function()
                require("flash").treesitter()
            end,
            desc = "Flash treesitter",
        },
        {
            "r",
            mode = "o",
            function() require("flash").remote() end,
            desc = "Remote Flash"
        },
        {
            "R",
            mode = { "o", "x" },
            function() require("flash").treesitter_search() end,
            desc = "Treesitter Search"
        },
    },
}
