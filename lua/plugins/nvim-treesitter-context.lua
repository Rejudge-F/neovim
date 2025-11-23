return {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPost",  -- 读取文件后才加载
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
        require("treesitter-context").setup(
            {
                enable = false,  -- 优化：暂时禁用以提升光标移动速度
                max_lines = 5,
                trim_scope = "outer",
                min_window_height = 0,
                throttle = true,  -- 启用节流
                max_lines = 3,    -- 减少最大行数
            }
        )
    end
}
