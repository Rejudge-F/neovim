return {
    "milanglacier/minuet-ai.nvim",
    enabled = false,
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    event = "InsertEnter", -- 延迟加载,提升启动性能
    config = function()
        require("minuet").setup({
            provider = "gemini",
            provider_options = {
                gemini = {
                    model = "gemini-2.5-flash",
                    stream = true,
                    api_key = "GEMINI_API_KEY",
                    end_point = 'https://generativelanguage.googleapis.com/v1beta/models',
                    optional = {
                        generationConfig = {
                            maxOutputTokens = 256,
                            -- 禁用 thinking 模式以获得更快的响应
                            thinkingConfig = {
                                thinkingBudget = 0,
                            },
                        },
                        safetySettings = {
                            {
                                category = "HARM_CATEGORY_DANGEROUS_CONTENT",
                                threshold = "BLOCK_ONLY_HIGH",
                            },
                        },
                    },
                },
            },

            -- Virtual text 配置
            virtualtext = {
                -- 减少自动触发的文件类型,避免影响 LSP 补全速度
                -- 只在主要编程语言中启用 AI 补全
                auto_trigger_ft = { 'go', 'python', 'lua', 'javascript', 'typescript', 'rust', 'c', 'cpp' },
                keymap = {
                    accept = '<Tab>',        -- Tab 接受整个补全
                    accept_line = '<S-Tab>', -- Shift+Tab 接受一行
                    prev = '<C-k>',          -- Ctrl+K 上一个建议
                    next = '<C-j>',          -- Ctrl+J 下一个建议
                    dismiss = '<C-c>',       -- Ctrl+C 关闭补全
                },
            },

            -- 通知设置
            notify = "warn",
            notify_provider_error = true,
        })
    end,
}
