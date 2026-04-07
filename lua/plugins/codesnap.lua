return {
    "mistricky/codesnap.nvim",
    build = "make build_generator",
    tag = "v2.0.0-beta.17",
    cmd = { "CodeSnap", "CodeSnapSave", "CodeSnapHighlight", "CodeSnapHighlightSave", "CodeSnapASCII" },
    init = function()
        -- 直接在 init 注册 keymap, 不走 lazy 的 keys 懒加载机制
        -- (lazy 的 keys handler 在转发按键时会退出 visual mode, 导致
        --  '<'>' 标记尚未设置, :'<,'>CodeSnap 拿不到选区)
        -- :CodeSnap 命令本身仍然由 lazy cmd handler 触发懒加载, 所以
        -- 第一次按 <leader>cs 时插件才真正加载
        vim.keymap.set("x", "<leader>cs", ":CodeSnap<CR>",
            { silent = true, desc = "Save selected code snapshot into clipboard" })
    end,
    opts = {
        save_path = "/tmp",
        snapshot_config = {
            code_config = {
                breadcrumbs = {
                    enable = true,
                },
            },
            watermark = {
                content = "zhangfeng.z",
                font_family = "Pacifico",
                color = "#ffffff",
            },
            background = {
                start = { x = 0, y = 0 },
                ["end"] = { x = "max", y = 0 },
                stops = {
                    { position = 0, color = "#6bcba5" },
                    { position = 1, color = "#caf4c2" },
                },
            },
        },
    },
}
