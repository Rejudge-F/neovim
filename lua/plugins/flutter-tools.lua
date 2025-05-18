return {
    {
        'nvim-flutter/flutter-tools.nvim',
        requires = {
            'nvim-lua/plenary.nvim',
            'stevearc/dressing.nvim', -- optional for vim.ui.select
        },
        config = function()
            require("flutter-tools").setup({
                debugger = { enabled = true },
                device = { show_emulators = true },
                dev_log = {
                    enabled = true,
                },
                lsp = {
                    on_attach = function(client, bufnr)
                        local opts = { noremap = true, silent = true, buffer = bufnr }
                        vim.keymap.set("n", "<leader>r", ":FlutterHotReload<CR>", opts)
                        vim.keymap.set("n", "<leader>R", ":FlutterHotRestart<CR>", opts)
                        vim.keymap.set("n", "<leader>dv", ":FlutterDevices<CR>", opts)
                        vim.keymap.set("n", "<leader>e", ":FlutterEmulators<CR>", opts)
                    end,
                }
            })
        end
    }
}
