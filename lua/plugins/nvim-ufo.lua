return {
    "kevinhwang91/nvim-ufo",
    dependencies = "kevinhwang91/promise-async",
    event = "BufReadPost",
    config = function()
        -- 配置 ufo
        require('ufo').setup({
            provider_selector = function(_, filetype)
                -- markdown 使用 indent 折叠，其他文件使用 treesitter
                return filetype == "markdown" and "indent" or { "treesitter", "indent" }
            end,
            -- 折叠预览配置
            preview = {
                win_config = {
                    border = { '', '─', '', '', '', '─', '', '' },
                    winhighlight = 'Normal:Folded',
                    winblend = 0
                },
                mappings = {
                    scrollU = '<C-u>',
                    scrollD = '<C-d>',
                    jumpTop = '[',
                    jumpBot = ']'
                }
            },
        })

        -- 设置折叠快捷键
        vim.keymap.set('n', 'zR', require('ufo').openAllFolds, { desc = "Open all folds" })
        vim.keymap.set('n', 'zM', require('ufo').closeAllFolds, { desc = "Close all folds" })
        vim.keymap.set('n', 'zr', require('ufo').openFoldsExceptKinds, { desc = "Open folds except kinds" })
        vim.keymap.set('n', 'zm', require('ufo').closeFoldsWith, { desc = "Close folds with" })
        vim.keymap.set('n', 'zp', require('ufo').peekFoldedLinesUnderCursor, { desc = "Peek fold" })

        -- 配置折叠列显示
        -- vim.o.foldcolumn = '1'
        vim.o.foldlevel = 99
        vim.o.foldlevelstart = 99
        vim.o.foldenable = true
    end
}
