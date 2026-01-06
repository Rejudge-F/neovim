return {
    "neovim/nvim-lspconfig",
    -- 使用 FileType 事件：在检测到文件类型时加载，更精准且优雅
    ft = { "c", "cpp", "lua", "python", "javascript", "typescript", "go", "rust", "java", "bash", "sh", "json", "yaml", "toml", "dart", "thrift" },
    dependencies = {
        { "williamboman/mason.nvim", config = true },
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp", -- 只保留 LSP capabilities 需要的
    },
    config = function()
        -- 1. 配置 Mason（延迟到后台加载，不阻塞 LSP 启动）
        vim.defer_fn(function()
            require("mason").setup({
                ui = {
                    border = "rounded",
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗"
                    }
                }
            })

            require("mason-lspconfig").setup({
                -- 自动安装这些 LSP 服务器
                ensure_installed = {
                    "jsonls", "clangd", "pyright", "gopls",
                    "rust_analyzer", "lua_ls", "bashls"
                },
                -- 自动安装打开文件类型对应的 LSP
                automatic_installation = false,
            })
        end, 500) -- 延迟 500ms 在后台初始化 Mason

        -- 获取 LSP capabilities（cmp 会在 InsertEnter 时设置）
        local capabilities = vim.tbl_deep_extend(
            'force',
            vim.lsp.protocol.make_client_capabilities(),
            require('cmp_nvim_lsp').default_capabilities()
        )

        -- 2. LSP 服务器配置
        local servers = {
            jsonls = {},
            clangd = {
                cmd = {
                    "clangd",
                    "--background-index",
                    "--clang-tidy",
                    "--header-insertion=iwyu",
                    "--completion-style=detailed",
                    "--function-arg-placeholders",
                },
            },
            dartls = {
                cmd = { "dart", "language-server", "--protocol=lsp" },
            },
            thriftls = {},
            jdtls = {
                cmd = { "jdtls" },
            },
            pyright = {
                settings = {
                    python = {
                        analysis = {
                            diagnosticSeverityOverrides = {
                                reportOptionalMemberAccess = "none", -- 禁用可选成员访问问题
                                reportOptionalSubscript = "none",    -- 禁用可选下标问题
                                reportGeneralTypeIssues = "none",    -- 禁用一般类型问题
                                reportArgumentType = "none",         -- 禁用参数类型问题
                                reportCallIssue = "none",
                                reportReturnType = "none",
                                reportAttributeAccessIssue = "none",
                            },
                        },
                    },
                },
            },
            gopls = {
                -- 使用 daemon 模式，让 gopls 常驻后台
                cmd = { "gopls", "-remote=auto" },
                settings = {
                    gopls = {
                        analyses = {
                            unusedparams = true, -- 确保参数分析启用
                        },
                        -- staticcheck = true,
                        buildFlags = { "-tags=wireinject" },
                        -- 性能优化
                        directoryFilters = {
                            "-**/node_modules",
                            "-**/.git",
                            "-**/vendor",
                            "-**/tmp",
                        },
                        semanticTokens = true,
                        -- 减少内存使用
                        expandWorkspaceToModule = false,
                        -- 禁用一些不必要的 codelens
                        codelenses = {
                            generate = false,
                            gc_details = false,
                            regenerate_cgo = false,
                            tidy = false,
                            upgrade_dependency = false,
                            vendor = false,
                        },
                    }
                }
            },
            rust_analyzer = {},
            lua_ls = {
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = { "vim" },
                        },
                    },
                },
            },
            bashls = {},
        }

        -- 3. 增强的 on_attach 函数（作为 lspsaga 的备用）
        local on_attach = function(client, bufnr)
            -- 定义缓冲区局部快捷键
            local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
            local opts = { noremap = true, silent = true }

            -- 格式化命令
            vim.api.nvim_buf_create_user_command(bufnr, "Format", function()
                vim.lsp.buf.format({ async = true })
            end, { desc = "Format current buffer with LSP" })

            -- 文档高亮已禁用（光标下同一单词高亮功能）
            -- 如需启用，取消注释以下代码
            -- if client.server_capabilities.documentHighlightProvider then
            --     vim.api.nvim_create_augroup("lsp_document_highlight", { clear = false })
            --     vim.api.nvim_clear_autocmds({ buffer = bufnr, group = "lsp_document_highlight" })
            --     vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            --         buffer = bufnr,
            --         group = "lsp_document_highlight",
            --         callback = vim.lsp.buf.document_highlight,
            --     })
            --     vim.api.nvim_create_autocmd({ "CursorMoved" }, {
            --         buffer = bufnr,
            --         group = "lsp_document_highlight",
            --         callback = vim.lsp.buf.clear_references,
            --     })
            -- end
        end

        -- 4. 使用 Neovim 0.11+ 的新 API 配置 LSP 服务器
        -- 参考: :help lspconfig-nvim-0.11
        for server_name, server_config in pairs(servers) do
            -- 合并配置
            local config = vim.tbl_deep_extend("force", {
                capabilities = capabilities,
                on_attach = on_attach,
            }, server_config)

            -- 使用新的 vim.lsp.config API
            vim.lsp.config[server_name] = config

            -- 启用 LSP 服务器
            vim.lsp.enable(server_name)
        end

        -- Auto-restart gopls when go.mod or go.sum changes
        vim.api.nvim_create_autocmd({ "BufWritePost", "FileChangedShellPost" }, {
            pattern = { "go.mod", "go.sum" },
            callback = function()
                -- Find all gopls clients
                for _, client in ipairs(vim.lsp.get_clients({ name = "gopls" })) do
                    -- Restart the gopls client
                    vim.schedule(function()
                        client.stop()
                        vim.defer_fn(function()
                            vim.cmd("edit") -- Reload current buffer to trigger LSP reattach
                        end, 500)
                    end)
                end
            end,
            desc = "Auto-restart gopls when go.mod or go.sum changes",
        })
    end,
}
