return {
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-neotest/neotest-python",
            "nvim-neotest/neotest-go",
        },
        config = function()
            require("neotest").setup({
                adapters = {
                    require("neotest-python")({
                        dap = { justMyCode = false },
                        runner = "pytest",
                        args = { "--log-level", "DEBUG" },
                        python = ".venv/bin/python",
                    }),
                    require("neotest-go")({
                    }),
                }
            })
            vim.keymap.set("n", "<C-t>", function() require("neotest").summary.toggle() end,
                { desc = "Toggle test summary" })
        end,
    }
}
