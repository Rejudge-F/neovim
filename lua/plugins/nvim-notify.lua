return {
    "rcarriga/nvim-notify",
    lazy = true,  -- 延迟加载
    init = function()
        -- 延迟设置 vim.notify，避免启动时加载
        vim.defer_fn(function()
            local notify = require("notify")
            notify.setup({
                stages = "static",
                top_down = false,
                timeout = 1000,
                max_width = 50,
                max_height = 10,
                render = "compact",
            })
            vim.notify = notify
        end, 100)  -- 启动后 100ms 再加载
    end,
}
