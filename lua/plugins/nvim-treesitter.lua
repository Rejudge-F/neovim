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
        -- 使用新的 Neovim 0.10+ API
        local enabled_fts = {
            "c", "cpp", "lua", "python", "javascript", "typescript",
            "go", "rust", "java", "bash", "json", "yaml", "toml",
            "markdown", "vim"
        }

        vim.api.nvim_create_autocmd("FileType", {
            pattern = enabled_fts,
            callback = function()
                vim.treesitter.start()
                vim.opt_local.syntax = ""  -- 禁用传统语法高亮
            end,
        })

        -- 设置折叠方法为 treesitter（与 nvim-ufo 配合使用）
        vim.opt.foldmethod = "expr"
        vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
    end
}
