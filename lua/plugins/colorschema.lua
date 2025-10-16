-- 推荐主题（按色彩丰富度排序）：
-- 1. tokyonight - 色彩非常丰富，对比度高
-- 2. catppuccin - 柔和但色彩丰富
-- 3. kanagawa - 传统日式配色，色彩适中
-- 4. gruvbox - 经典暖色调，色彩丰富
-- 5. seoul256 - 低对比度灰色调（你原来的主题）

-- return {
--     "folke/tokyonight.nvim",
--     lazy = false,
--     priority = 1000,
--     config = function()
--         require("tokyonight").setup({
--             style = "night", -- night, storm, day, moon
--             styles = {
--                 comments = { italic = true },
--                 keywords = { italic = true },
--             },
--         })
--         vim.cmd("colorscheme tokyonight")
--     end
-- }
--
-- return {
--     "catppuccin/nvim",
--     name = "catppuccin",
--     lazy = false,
--     priority = 1000,
--     config = function()
--         vim.cmd("colorscheme catppuccin-mocha")
--     end
-- }

return {
    "junegunn/seoul256.vim",
    lazy = false,
    priority = 1000,
    config = function()
        vim.g.seoul256_background = 236
        vim.cmd("colorscheme seoul256")
    end
}
