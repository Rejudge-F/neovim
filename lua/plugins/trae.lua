return {
    "https://code.byted.org/chenjiaqi.cposture/codeverse.vim.git",
    enabled = true,     -- 禁用 codeverse/trae
    event = "VeryLazy", -- 延迟加载
    dependencies = {
        "hrsh7th/nvim-cmp",
    },
    config = function()
        require("trae").setup({
        })

        -- trae 加载后重新触发主题高亮，确保补全颜色正确
        vim.schedule(function()
            vim.cmd("doautocmd ColorScheme")
        end)
    end
}
