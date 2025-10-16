return {
    "rcarriga/nvim-notify",
    config = function()
        local notify = require("notify")
        notify.setup({
            stages = "static",
            top_down = false,
            timeout = 1000,
            max_width = 50,  -- 添加：限制最大宽度
            max_height = 10, -- 添加：限制最大高度
            render = "compact", -- 添加：紧凑模式
        })
        -- 设置为全局通知处理器（已有）
        vim.notify = notify
    end,
}
