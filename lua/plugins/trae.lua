return {
    "https://code.byted.org/chenjiaqi.cposture/codeverse.vim.git",
    event = "VeryLazy",  -- 延迟加载
    dependencies = {
        "hrsh7th/nvim-cmp",
    },
    config = function()
        require("trae").setup({
        })
    end
}
