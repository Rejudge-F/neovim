-- 使用 telescope 内置的项目管理功能
-- 或者选择其他替代方案：
-- 1. "coffebar/neovim-project" - 更现代，活跃维护
-- 2. 直接使用 vim 内置的 :cd 和会话管理

return {
    "coffebar/neovim-project",
    opts = {
        projects = {
            "~/go/src/*",
            "~/.config/nvim",
        },
        -- 自动检测 git 目录
        picker = {
            type = "telescope",  -- 使用 telescope
        },
    },
    init = function()
        vim.opt.sessionoptions:append("globals")
    end,
    dependencies = {
        { "nvim-lua/plenary.nvim" },
        { "nvim-telescope/telescope.nvim" },
        { "Shatur/neovim-session-manager" },
    },
    lazy = false,
    priority = 100,
}

-- 如果你想继续使用 ahmedkhalf/project.nvim，可以取消下面的注释
-- return {
--     "ahmedkhalf/project.nvim",
--     config = function()
--         require("project_nvim").setup {}
--     end
-- }
