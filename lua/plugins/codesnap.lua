return {
    "mistricky/codesnap.nvim",
    build = "make build_generator",
    keys = {
        { "<leader>cs", ":CodeSnap<cr>", mode = "x", desc = "Save selected code snapshot into clipboard" },
    },
    opts = {
        save_path = "~/Pictures",
        has_breadcrumbs = true,
        bg_theme = "bamboo",
        watermark = "zhangfeng.z",
    },
}
