return {
    "mistricky/codesnap.nvim",
    build = "make build_generator",
    -- 延迟加载：只在需要时加载（通过 keys 触发）
    keys = {
        { "<leader>cs", ":CodeSnap<cr>", mode = "x", desc = "Save selected code snapshot into clipboard" },
    },
    event = "VeryLazy", -- 确保延迟加载
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
