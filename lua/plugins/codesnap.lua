return {
    "mistricky/codesnap.nvim",
    build = "make build_generator",
    keys = {
        { "<leader>cs", ":CodeSnap<cr>", mode = "x", desc = "Save selected code snapshot into clipboard" },
    },
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
