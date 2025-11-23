return {
    "ray-x/lsp_signature.nvim",
    event = "LspAttach",
    config = function()
        require("lsp_signature").setup({
            debug = false,
            bind = true,

            -- 触发字符配置
            doc_lines = 10,
            max_height = 12,
            max_width = 80,
            wrap = true,

            -- 关键：启用自动触发和参数跟踪
            floating_window = true,
            floating_window_above_cur_line = true,
            always_trigger = true, -- 始终触发签名帮助
            auto_close_after = nil, -- 不自动关闭
            extra_trigger_chars = { "(", ",", " " }, -- 左括号、逗号、空格都会触发
            zindex = 200,

            -- 参数高亮配置
            hi_parameter = "LspSignatureActiveParameter",
            hint_enable = false, -- 禁用虚拟文本提示
            hint_prefix = "🐼 ",
            hint_scheme = "String",

            -- 处理器配置
            handler_opts = {
                border = "rounded"
            },

            -- 启用实时更新
            timer_interval = 500, -- 优化：从 200ms 改为 500ms，减少更新频率
            toggle_key = nil, -- 不需要手动切换键
            select_signature_key = nil, -- 不需要选择签名键
            move_cursor_key = nil, -- 不需要移动光标键

            -- 修复参数高亮不移动的问题
            cursorhold_update = true, -- CursorHold 时更新
            trigger_on_newline = false, -- 换行时不触发
        })
    end
}
