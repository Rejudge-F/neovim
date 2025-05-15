return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile", "BufEnter" },
    dependencies = {
        { "williamboman/mason.nvim", config = true },
        "williamboman/mason-lspconfig.nvim",


        {
            "hrsh7th/nvim-cmp",
            dependencies = {
                "hrsh7th/cmp-nvim-lsp",
                "hrsh7th/cmp-buffer",
                "hrsh7th/cmp-path",
                "hrsh7th/cmp-cmdline",
                "L3MON4D3/LuaSnip",
                "saadparwaiz1/cmp_luasnip"
            },
        },
    },
    config = function()
        require("mason").setup()

        local capabilities = require("cmp_nvim_lsp").default_capabilities()


        local cmp = require("cmp")
        local luasnip = require("luasnip")

        require("luasnip.loaders.from_vscode").lazy_load()

        cmp.setup({
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ["<CR>"] = cmp.mapping.confirm({ select = true }),
            }),
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = "buffer" },
                { name = "path" },
                { name = "render-markdown" },
            }),
        })


        local lspconfig = require("lspconfig")
        local servers = {
            jsonls = {},
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
                            },
                        },
                    },
                },
            },
            gopls = {},
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
        }

        local on_attach = function(_, bufnr)
            local nmap = function(keys, func, desc)
                vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
            end

            nmap("rn", vim.lsp.buf.rename, "[LSP] Rename")
            nmap("gd", vim.lsp.buf.definition, "[LSP] Go to Definition")
            nmap("gy", vim.lsp.buf.type_definition, "[LSP] Type Definition")
            nmap("gi", vim.lsp.buf.implementation, "[LSP] Implementation")
            nmap("gr", vim.lsp.buf.references, "[LSP] References")
            nmap("gf", vim.lsp.buf.code_action, "[LSP] Code Action")
            nmap("<leader>ca", vim.lsp.buf.code_action, "[LSP] Code Action")

            vim.api.nvim_buf_create_user_command(bufnr, "Format", function()
                vim.lsp.buf.format({ async = true })
            end, { desc = "Format current buffer with LSP" })
        end

        for server, config in pairs(servers) do
            config.capabilities = capabilities
            config.on_attach = on_attach
            lspconfig[server].setup(config)
        end
    end,
}
