return {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = "nvim-treesitter/nvim-treesitter",
    branch = "main",
    event = { "BufReadPost", "BufNewFile" }, -- 移除 BufReadPre，避免过早加载
    config = function()
        require("nvim-treesitter-textobjects").setup({
            select = {
                lookahead = true,
                selection_modes = {
                    ['@parameter.outer'] = 'v',
                    ['@function.outer'] = 'V',
                    ['@class.outer'] = 'V',
                },
                include_surrounding_whitespace = false,
            },
            move = {
                set_jumps = true,
            },
        })

        -- 配置 select 快捷键
        local select = require("nvim-treesitter-textobjects.select")
        local modes = { "x", "o" }

        vim.keymap.set(modes, "af", function()
            select.select_textobject("@function.outer", "textobjects")
        end, { desc = "Select outer function" })

        vim.keymap.set(modes, "if", function()
            select.select_textobject("@function.inner", "textobjects")
        end, { desc = "Select inner function" })

        vim.keymap.set(modes, "ac", function()
            select.select_textobject("@class.outer", "textobjects")
        end, { desc = "Select outer class" })

        vim.keymap.set(modes, "ic", function()
            select.select_textobject("@class.inner", "textobjects")
        end, { desc = "Select inner class" })

        -- 配置 move 快捷键
        local move = require("nvim-treesitter-textobjects.move")

        vim.keymap.set("n", "]m", function()
            move.goto_next_start("@function.outer", "textobjects")
        end, { desc = "Next function start" })

        vim.keymap.set("n", "]M", function()
            move.goto_next_end("@function.outer", "textobjects")
        end, { desc = "Next function end" })

        vim.keymap.set("n", "[m", function()
            move.goto_previous_start("@function.outer", "textobjects")
        end, { desc = "Previous function start" })

        vim.keymap.set("n", "[M", function()
            move.goto_previous_end("@function.outer", "textobjects")
        end, { desc = "Previous function end" })

        vim.keymap.set("n", "]c", function()
            move.goto_next_start("@class.outer", "textobjects")
        end, { desc = "Next class start" })

        vim.keymap.set("n", "[c", function()
            move.goto_previous_start("@class.outer", "textobjects")
        end, { desc = "Previous class start" })
    end,
}
