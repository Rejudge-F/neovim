return {
    'nvimdev/lspsaga.nvim',
    config = function()
        require('lspsaga').setup({
            lightbulb = {
                enable = false,
            },
            definition = {
                keys = {
                    edit = 'o',
                    vsplit = 'sv',
                    split = 'sp',
                    tabe = 't',
                    quit = 'q'
                }
            },
            finder = {
                keys = {
                    vsplit = 'sv',
                    split = 'sp',
                    tabe = 't',
                    quit = 'q'
                }
            },
            symbol_in_winbar = {
                enable = false,
            }
        })
        vim.keymap.set("n", "rn", ":Lspsaga rename<CR>", { noremap = true, silent = true })
        vim.keymap.set('n', 'K', ':Lspsaga peek_definition<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', '<leader>so', ':Lspsaga outline<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', '<leader>ca', ':Lspsaga code_action<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', 'gr', ':Lspsaga finder<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', 'go', ':Lspsaga outgoing_calls<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', 'gd', ':Lspsaga goto_definition<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', 'gtd', ':Lspsaga goto_type_definition<CR>', { noremap = true, silent = true })
    end,
    dependencies = {
        'nvim-treesitter/nvim-treesitter', -- optional
        'nvim-tree/nvim-web-devicons',     -- optional
    }
}
