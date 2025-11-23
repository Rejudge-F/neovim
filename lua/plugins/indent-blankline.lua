return {
    "lukas-reineke/indent-blankline.nvim",
    enabled = false,
    event = "BufReadPost", -- 读取文件后才加载
    config = function()
        require("ibl").setup({
            debounce = 200, -- 优化：增加防抖延迟,减少重绘频率
            viewport_buffer = {
                min = 30,   -- 减少视口缓冲区
                max = 500,
            },
        })
    end,
}
