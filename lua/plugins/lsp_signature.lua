return {
    "ray-x/lsp_signature.nvim",
    event = "LspAttach",
    config = function()
        require("lsp_signature").setup({
            debug = true,
            bind = true,
            extra_trigger_chars = { "," }, -- 添加逗号作为额外触发字符
            hint_enable = false,
            floating_window = true,
            floating_window_above_cur_line = true,
            hi_parameter = "LspSignatureActiveParameter",
            handler_opts = {
                border = "rounded"
            },
        })
    end
}
