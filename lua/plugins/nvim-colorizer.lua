return {
    "catgoose/nvim-colorizer.lua",
    -- 只在需要颜色高亮的文件类型中加载
    ft = { "css", "scss", "sass", "html", "javascript", "typescript", "jsx", "tsx", "vue", "svelte", "lua", "vim" },
    opts = {
        user_default_options = {
            mode = "background",  -- 使用背景色模式
            debounce = 300,       -- 优化：增加防抖延迟到 300ms
        },
    },
}
