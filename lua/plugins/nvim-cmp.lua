return {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter", -- 只在进入插入模式时加载
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
    },
    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")

        require("luasnip.loaders.from_vscode").lazy_load()

        cmp.setup({
            preselect = require('cmp').PreselectMode.Item,
            completion = {
                completeopt = 'menu,menuone,noinsert',
                autocomplete = {
                    require('cmp.types').cmp.TriggerEvent.TextChanged,
                },
            },
            -- 性能优化: 减少补全延迟
            performance = {
                debounce = 60,              -- 降低 debounce 时间 (默认 60ms)
                throttle = 30,              -- 降低 throttle 时间 (默认 30ms)
                fetching_timeout = 200,     -- 降低获取超时 (默认 500ms)
                confirm_resolve_timeout = 80,
                async_budget = 1,
                max_view_entries = 50,      -- 限制显示的条目数量
            },
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            formatting = {
                format = function(entry, vim_item)
                    if entry.completion_item then
                        entry.completion_item.preselect = false
                    end
                    return vim_item
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ["<CR>"] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete(),
            }),
            sources = cmp.config.sources({
                {
                    name = "nvim_lsp",
                    priority = 1000,
                    -- 性能优化: 限制 LSP 补全结果数量
                    max_item_count = 50,
                },
                {
                    name = "luasnip",
                    priority = 750,
                    max_item_count = 20,
                },
                {
                    name = "buffer",
                    priority = 500,
                    max_item_count = 15, -- 减少到 15
                    keyword_length = 3, -- 增加关键词最小长度，减少触发频率
                    -- 只在小文件中启用 buffer 补全
                    option = {
                        get_bufnrs = function()
                            local buf = vim.api.nvim_get_current_buf()
                            local byte_size = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
                            if byte_size > 1024 * 1024 then -- 1MB
                                return {}
                            end
                            return { buf }
                        end,
                        keyword_pattern = [[\k\+]], -- 优化关键词匹配
                    },
                },
                {
                    name = "path",
                    priority = 250,
                    max_item_count = 20,
                },
                { name = "render-markdown" },
            }),
            experimental = {
                ghost_text = false,
            },
        })
    end,
}
