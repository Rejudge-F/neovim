return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = function()
        require("nvim-treesitter.install").update({ with_sync = true })()
    end,
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

        -- 立即启动当前 buffer 的 treesitter（解决延迟加载导致的高亮问题）
        local function start_treesitter_if_enabled()
            local ft = vim.bo.filetype
            for _, enabled_ft in ipairs(enabled_fts) do
                if ft == enabled_ft then
                    vim.treesitter.start()
                    vim.opt_local.syntax = ""
                    break
                end
            end
        end

        -- 对所有已存在的 buffer 启动 treesitter
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) then
                vim.api.nvim_buf_call(buf, start_treesitter_if_enabled)
            end
        end

        -- 为未来的文件类型启用 treesitter
        vim.api.nvim_create_autocmd("FileType", {
            pattern = enabled_fts,
            callback = function()
                vim.treesitter.start()
                vim.opt_local.syntax = ""  -- 禁用传统语法高亮
            end,
        })

        -- 设置折叠方法为 treesitter（与 nvim-ufo 配合使用）
        vim.opt.foldmethod = "expr"
        vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    end
}
