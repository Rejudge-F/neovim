return {
    "coffebar/neovim-project",
    lazy = false,
    priority = 100,
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
        "Shatur/neovim-session-manager",
    },
    init = function()
        -- 让 session 保存全局变量（neovim-project 推荐设置）
        vim.opt.sessionoptions:append("globals")
    end,
    opts = {
        projects = {
            "~/go/src/code.byted.org/*",
            "~/.config/*",
        },
        last_session_on_startup = true,
        picker = {
            type = "telescope",
        },
    },
}
