return {
    "milanglacier/minuet-ai.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    -- event = "InsertEnter",
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
                -- 使用 '*' 表示所有文件类型都自动触发
                auto_trigger_ft = { '*' },
                keymap = {
                    accept = '<Tab>',          -- Tab 接受整个补全
                    accept_line = '<S-Tab>',   -- Shift+Tab 接受一行
                    prev = '<C-k>',            -- Ctrl+K 上一个建议
                    next = '<C-j>',            -- Ctrl+J 下一个建议
                    dismiss = '<C-c>',         -- Ctrl+C 关闭补全
                },
            },

            -- 通知设置
            notify = "warn",
            notify_provider_error = true,
        })
    end,
}
