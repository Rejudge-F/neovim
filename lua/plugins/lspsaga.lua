return {
    'nvimdev/lspsaga.nvim',
    config = function()
        require('lspsaga').setup({
            lightbulb = {
                enable = false,
            }
        })
        vim.keymap.set("n", "rn", ":Lspsaga rename<CR>", { noremap = true, silent = true })
        vim.keymap.set('n', 'K', ':Lspsaga peek_definition<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', 'so', ':Lspsaga outline<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', '<leader>ca', ':Lspsaga code_action<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', 'gr', ':Lspsaga incoming_calls<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', 'go', ':Lspsaga outgoing_calls<CR>', { noremap = true, silent = true })
    end,
    dependencies = {
        'nvim-treesitter/nvim-treesitter', -- optional
        'nvim-tree/nvim-web-devicons',     -- optional
    }
}
