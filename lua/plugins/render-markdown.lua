-- lua/plugins/render-markdown.lua
return {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { "markdown" }, -- 添加懒加载：只在 markdown 文件中加载
    dependencies = { 'nvim-treesitter/nvim-treesitter', },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
        max_file_size = 1.5, -- 限制 1.5MB 以上文件不渲染，避免大文件卡顿
        debounce = 100,      -- 添加防抖，减少渲染频率
    },
}
