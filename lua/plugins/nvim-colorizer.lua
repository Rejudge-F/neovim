return {
    "catgoose/nvim-colorizer.lua",
    event = "BufReadPre",
    opts = {
        user_default_options = {
            mode = "background",  -- 使用背景色模式
            debounce = 300,       -- 优化：增加防抖延迟到 300ms
        },
    },
}
