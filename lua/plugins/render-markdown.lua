-- lua/plugins/render-markdown.lua
return {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { "markdown", "Avante" }, -- 添加懒加载：markdown + avante 侧栏
    dependencies = { 'nvim-treesitter/nvim-treesitter', },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
        max_file_size = 1.5, -- 限制 1.5MB 以上文件不渲染，避免大文件卡顿
        debounce = 100,      -- 添加防抖，减少渲染频率
        anti_conceal = { enabled = false },      -- 始终渲染, 光标行也不还原成源码
        file_types = { 'markdown', 'Avante' },   -- 让 avante 聊天输出也渲染
    },
}
