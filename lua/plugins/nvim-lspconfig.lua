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
                    "--function-arg-placeholders=1",
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
                        semanticTokens = false,
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

        -- 3. on_attach: 每个 buffer 的 LSP keymap + 自动 signature help
        local on_attach = function(client, bufnr)
            local opts = { noremap = true, silent = true, buffer = bufnr }

            -- 格式化命令
            vim.api.nvim_buf_create_user_command(bufnr, "Format", function()
                vim.lsp.buf.format({ async = true })
            end, { desc = "Format current buffer with LSP" })

            -- 自动 signature help (替代 lsp_signature.nvim)
            -- 不直接调 vim.lsp.buf.signature_help, 因为 nvim 0.12 在
            -- process_signature_help_results 里对 sig.activeParameter 用了
            -- `or` 短路, 当 server 同时返回 sig.activeParameter=0 和
            -- result.activeParameter=N 时, sig 的 0 会覆盖动态值, 导致
            -- 高亮卡在第一个参数. 这里自己请求并渲染, 优先用 result 的值.
            if client:supports_method("textDocument/signatureHelp") then
                local trigger_chars = vim.tbl_get(
                    client.server_capabilities or {},
                    "signatureHelpProvider",
                    "triggerCharacters"
                ) or { "(", "," }
                local retrigger_chars = vim.tbl_get(
                    client.server_capabilities or {},
                    "signatureHelpProvider",
                    "retriggerCharacters"
                ) or {}
                local trigger_set = {}
                for _, c in ipairs(trigger_chars) do trigger_set[c] = true end
                for _, c in ipairs(retrigger_chars) do trigger_set[c] = true end

                local sig_ns = vim.api.nvim_create_namespace("lsp_auto_signature")

                local function show_signature()
                    local cur_buf = vim.api.nvim_get_current_buf()
                    local params = vim.lsp.util.make_position_params(0, client.offset_encoding or "utf-16")
                    client:request("textDocument/signatureHelp", params, function(err, result)
                        if err or not result or not result.signatures or #result.signatures == 0 then
                            return
                        end
                        if vim.api.nvim_get_current_buf() ~= cur_buf then return end

                        local active_sig_idx = (result.activeSignature or 0) + 1
                        if active_sig_idx > #result.signatures then active_sig_idx = 1 end
                        local sig = result.signatures[active_sig_idx]
                        if not sig then return end

                        -- 关键: 优先用 result.activeParameter (动态), 回退到 sig.activeParameter (静态)
                        local active_param = result.activeParameter
                        if active_param == nil or active_param == vim.NIL then
                            active_param = sig.activeParameter
                        end

                        local label = sig.label
                        local lines = { label }
                        local hl_range
                        if active_param and active_param ~= vim.NIL and sig.parameters and sig.parameters[active_param + 1] then
                            local param = sig.parameters[active_param + 1]
                            local plabel = param.label
                            if type(plabel) == "table" then
                                hl_range = { 0, plabel[1], 0, plabel[2] }
                            elseif type(plabel) == "string" then
                                local s = label:find(plabel, 1, true)
                                if s then hl_range = { 0, s - 1, 0, s - 1 + #plabel } end
                            end
                        end

                        local float_buf = vim.api.nvim_create_buf(false, true)
                        vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, lines)
                        vim.bo[float_buf].filetype = vim.bo[cur_buf].filetype
                        if hl_range then
                            vim.hl.range(float_buf, sig_ns, "LspSignatureActiveParameter",
                                { hl_range[1], hl_range[2] }, { hl_range[3], hl_range[4] })
                        end

                        -- 关掉旧的浮窗
                        local prev = vim.b[cur_buf].lsp_auto_sig_win
                        if prev and vim.api.nvim_win_is_valid(prev) then
                            pcall(vim.api.nvim_win_close, prev, true)
                        end

                        local width = math.min(#label + 2, math.floor(vim.o.columns * 0.6))
                        local win = vim.api.nvim_open_win(float_buf, false, {
                            relative = "cursor",
                            anchor = "NW",
                            row = 1,
                            col = 0,
                            width = width,
                            height = 1,
                            style = "minimal",
                            focusable = false,
                            noautocmd = true,
                        })
                        vim.b[cur_buf].lsp_auto_sig_win = win

                        -- 离开插入模式或换行时关闭
                        vim.api.nvim_create_autocmd({ "InsertLeave", "BufLeave" }, {
                            buffer = cur_buf,
                            once = true,
                            callback = function()
                                if vim.api.nvim_win_is_valid(win) then
                                    pcall(vim.api.nvim_win_close, win, true)
                                end
                            end,
                        })
                    end, bufnr)
                end

                local group = vim.api.nvim_create_augroup("LspAutoSignatureHelp_" .. bufnr, { clear = true })
                vim.api.nvim_create_autocmd("TextChangedI", {
                    group = group,
                    buffer = bufnr,
                    callback = function()
                        local col = vim.api.nvim_win_get_cursor(0)[2]
                        if col == 0 then return end
                        local line = vim.api.nvim_get_current_line()
                        local prev_char = line:sub(col, col)
                        if trigger_set[prev_char] then
                            show_signature()
                        end
                    end,
                    desc = "Auto-trigger signature help on trigger characters",
                })
                vim.api.nvim_create_autocmd("BufDelete", {
                    group = group,
                    buffer = bufnr,
                    callback = function() vim.api.nvim_del_augroup_by_id(group) end,
                    once = true,
                })
            end

            -- LSP 跳转和操作 keymap
            --
            -- 绝大多数走 lspsaga (浮窗 UI), 用 core/saga.lua 包一层, 每次调用前
            -- 清掉残留的 pending_request, 避免"按了没反应".
            -- lspsaga 自带 beacon.enable=true, 所以这里不再套 core/beacon.lua,
            -- 否则跳转后会闪两次.
            --
            -- 两个例外, 都是 lspsaga 没有的能力:
            --   K   自写的 enhanced_hover, 在 hover 文档下方拼接目标函数源码.
            --       不用 Lspsaga hover_doc: 它只给签名+注释, 内容是 enhanced_hover
            --       的真子集 (后者 hover 失败时还能只显示代码), 两个都绑纯属重复
            --   gR  自写的 ref_kinds, 把引用按 set/get 分类. lspsaga finder 只能
            --       按 def/ref/imp 分组 (内部以 method 字符串为 key, 没有第二个
            --       分组维度), 所以这件事塞不进 gr, 只能另起一个键
            local saga = require('core.saga')
            local map = function(lhs, rhs, desc)
                vim.keymap.set('n', lhs, rhs, vim.tbl_extend('force', opts, { desc = desc }))
            end
            map('K',          require('core.enhanced_hover').show,            'LSP hover (with definition source)')
            map('gd',         saga.cmd('Lspsaga goto_definition'),            'LSP definition')
            map('gp',         saga.cmd('Lspsaga peek_definition'),            'LSP peek definition')
            map('gtd',        saga.cmd('Lspsaga goto_type_definition'),       'LSP type definition')
            map('gi',         saga.cmd('Lspsaga finder imp'),                 'LSP implementation')
            -- lspsaga finder 若在 0.12 上出问题, 这行换回 vim.lsp.buf.references 即可
            map('gr',         saga.cmd('Lspsaga finder'),                     'LSP references (finder)')
            map('gR',         require('core.ref_kinds').show,                 'LSP references by set/get')
            map('go',         saga.cmd('Lspsaga outgoing_calls'),             'LSP outgoing calls')
            map('rn',         saga.cmd('Lspsaga rename'),                     'LSP rename')
            map('<leader>ca', saga.cmd('Lspsaga code_action'),                'LSP code action')
            map('<leader>so', saga.cmd('Lspsaga outline'),                    'LSP outline')
            map(']e',         saga.cmd('Lspsaga diagnostic_jump_next'),       'Next diagnostic')
            map('[e',         saga.cmd('Lspsaga diagnostic_jump_prev'),       'Prev diagnostic')
            map('<leader>db', saga.cmd('Lspsaga show_buf_diagnostics'),       'Buf diagnostics')
            map('<leader>dw', saga.cmd('Lspsaga show_workspace_diagnostics'), 'Workspace diagnostics')
        end

        -- 4. 使用 Neovim 0.11+ 的新 API 配置 LSP 服务器
        -- 参考: :help lspconfig-nvim-0.11
        -- 全局默认 capabilities, 无需为每个 server 重复 merge
        vim.lsp.config('*', {
            capabilities = capabilities,
        })
        -- on_attach 通过 LspAttach autocmd 触发:
        -- config('*').on_attach 在部分 nvim 版本下不会被调用, 用 autocmd 保证生效
        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('UserLspAttach', { clear = true }),
            callback = function(args)
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                if client then
                    on_attach(client, args.buf)
                end
            end,
        })
        for server_name, server_config in pairs(servers) do
            if next(server_config) ~= nil then
                vim.lsp.config(server_name, server_config)
            end
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
