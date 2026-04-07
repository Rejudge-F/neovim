return {
    {
        "nvim-neotest/neotest",
        -- 按需加载：只在使用测试功能时加载
        cmd = "Neotest",
        keys = {
            { "<C-t>", desc = "Toggle test summary" },
            { "<leader>tr", desc = "Run nearest test" },
            { "<leader>tf", desc = "Run test file" },
            { "<leader>to", desc = "Open test output" },
        },
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-neotest/neotest-python",
            { "fredrikaverpil/neotest-golang" }, -- Installation
        },
        config = function()
            local neotest_golang_opts = { -- Specify configuration
                runner = "go",
                go_test_args = {
                    "-v",
                    "-race",
                    "-count=1",
                    "-parallel=10",
                },
                testify_enabled = false, -- 禁用 testify，因为项目不使用它
                dap_go_enabled = true,   -- 启用 DAP 调试，可以直接调试测试用例
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
                },
                log_level = vim.log.levels.DEBUG,                   -- 启用调试日志
            })
            vim.keymap.set("n", "<C-t>", function() require("neotest").summary.toggle() end,
                { desc = "Toggle test summary" })
            -- 添加更多有用的快捷键
            vim.keymap.set("n", "<leader>tr", function() require("neotest").run.run() end,
                { desc = "Run nearest test" })
            vim.keymap.set("n", "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end,
                { desc = "Run test file" })
            vim.keymap.set("n", "<leader>to", function() require("neotest").output.open({ enter = true }) end,
                { desc = "Open test output" })
        end,
    }
}
