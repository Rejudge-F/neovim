return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
        -- 为所有支持的文件类型启用 treesitter highlight
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "*",
            callback = function()
                pcall(vim.treesitter.start)
            end,
        })

        -- 禁用传统的 vim 语法高亮，避免冲突
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "*",
            callback = function()
                vim.opt_local.syntax = ""
            end,
        })
    end
}
