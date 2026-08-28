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
        heading = {
            -- 默认会给每级标题铺一条通栏底色 (RenderMarkdownH1Bg..H6Bg), 在 avante
            -- 侧栏里非常刺眼. 清空这个列表只去底色, 标题图标和前景色还在
            backgrounds = {},
        },
        quote = {
            -- 引用块的竖线默认只画在缓冲区行的开头, 一段长文本折行后剩下的显示行
            -- 就没有竖线了 (avante 的 thinking 一整段是一行). 这个开关走
            -- extmark 的 virt_text_repeat_linebreak, 让竖线跟着折行一直延伸
            repeat_linebreak = true,
        },
        -- repeat_linebreak 要求这三个选项配合, 否则竖线会盖住正文.
        -- 只在 render-markdown 渲染的窗口里设, 不污染全局
        win_options = {
            showbreak = { default = vim.o.showbreak, rendered = '  ' },
            breakindent = { default = vim.o.breakindent, rendered = true },
            breakindentopt = { default = vim.o.breakindentopt, rendered = '' },
        },
        code = {
            -- 不要边框也不要底色: 代码块靠语法高亮 + 下面自己加的行号来区分,
            -- 比 render-markdown 那套(只能画上下横线, 没有左右竖线)干净
            style = 'language',        -- 只渲染语言标签, 不铺背景
            border = 'none',
            conceal_delimiters = true, -- ``` 那两行照样藏起来
        },
    },
    config = function(_, opts)
        require('render-markdown').setup(opts)

        -- 全部只给前景色, 不设 bg, 这样代码块是透明的, 跟正文同底.
        -- RenderMarkdownCodeBorder 默认链到 ColorColumn, 语言标签会顶着一块灰底,
        -- 清掉 bg 才干净.
        local function set_code_colors()
            vim.api.nvim_set_hl(0, 'RenderMarkdownCode', {})
            vim.api.nvim_set_hl(0, 'RenderMarkdownCodeBorder', {})
            vim.api.nvim_set_hl(0, 'RenderMarkdownCodeLineNr', { fg = '#6b6b6b' })
            -- 派生组(把 bg 当 fg 用)有缓存, 让 render-markdown 重算一遍
            pcall(function() require('render-markdown.core.colors').reload() end)
        end

        set_code_colors()
        vim.api.nvim_create_autocmd('ColorScheme', {
            group = vim.api.nvim_create_augroup('RenderMarkdownCodeColors', { clear = true }),
            callback = vim.schedule_wrap(set_code_colors),
        })

        -- 代码块行号. render-markdown 不提供 (源码里搜 line_number 零命中),
        -- 所以自己扫一遍 treesitter 的 fenced_code_block, 给每个内容行插一个
        -- inline virt_text. 用 inline 而不是 overlay, 否则会盖住代码.
        local ns = vim.api.nvim_create_namespace('render_markdown_code_lineno')
        local function number_code_blocks(buf)
            if not vim.api.nvim_buf_is_valid(buf) then return end
            vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
            local ok, parser = pcall(vim.treesitter.get_parser, buf, 'markdown')
            if not ok or not parser then return end
            local trees = parser:parse()
            if not trees or not trees[1] then return end
            local ok2, query = pcall(vim.treesitter.query.parse, 'markdown', '(fenced_code_block) @block')
            if not ok2 then return end
            local total = vim.api.nvim_buf_line_count(buf)
            for _, node in query:iter_captures(trees[1]:root(), buf) do
                local srow, _, erow = node:range()
                local n = 0
                -- 跳过上下两行 ``` 围栏
                for row = srow + 1, math.min(erow - 1, total) - 1 do
                    n = n + 1
                    pcall(vim.api.nvim_buf_set_extmark, buf, ns, row, 0, {
                        virt_text = { { string.format('%3d ', n), 'RenderMarkdownCodeLineNr' } },
                        virt_text_pos = 'inline',
                        priority = 200,
                    })
                end
            end
        end

        local pending = {}
        local function schedule_numbering(buf)
            if pending[buf] then return end
            pending[buf] = true
            vim.defer_fn(function()
                pending[buf] = nil
                number_code_blocks(buf)
            end, 120) -- 和 render-markdown 的 debounce 同量级, 流式输出时不至于狂刷
        end

        -- 必须用 buf_attach 而不是 TextChanged: avante 是用 nvim_buf_set_lines
        -- 写侧栏的, 而 TextChanged 只对用户编辑触发, API 改动一律不发.
        local attached = {}
        vim.api.nvim_create_autocmd('FileType', {
            group = vim.api.nvim_create_augroup('RenderMarkdownCodeLineNo', { clear = true }),
            pattern = opts.file_types,
            callback = function(ev)
                local buf = ev.buf
                schedule_numbering(buf)
                if attached[buf] then return end
                attached[buf] = true
                vim.api.nvim_buf_attach(buf, false, {
                    on_lines = function()
                        if not vim.api.nvim_buf_is_valid(buf) then
                            attached[buf] = nil
                            return true -- detach
                        end
                        schedule_numbering(buf)
                    end,
                    on_detach = function() attached[buf] = nil end,
                })
            end,
        })
    end,
}
