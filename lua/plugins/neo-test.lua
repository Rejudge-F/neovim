return {
    {
        "nvim-neotest/neotest",
        event = "VeryLazy",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-neotest/neotest-python",
            { "fredrikaverpil/neotest-golang", version = "*" }, -- Installation
        },
        config = function()
            local neotest_golang_opts = { -- Specify configuration
                runner = "go",
                go_test_args = {
                    "-v",
                    "-race",
                    "-count=1",
                    "-parallel=10",
                    "-coverprofile=" .. vim.fn.getcwd() .. "/coverage.out",
                },
            }
            require("neotest").setup({
                adapters = {
                    require("neotest-python")({
                        dap = { justMyCode = false },
                        runner = "pytest",
                        args = { "--log-level", "DEBUG" },
                        python = ".venv/bin/python",
                    }),
                    require("neotest-golang")(neotest_golang_opts), -- Registration
                }
            })
            vim.keymap.set("n", "<C-t>", function() require("neotest").summary.toggle() end,
                { desc = "Toggle test summary" })
        end,
    }
}
