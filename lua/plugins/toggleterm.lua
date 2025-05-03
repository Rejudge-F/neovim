return {
    "akinsho/toggleterm.nvim",
    config = function()
        require("toggleterm").setup {
            shade_terminals = true,
            shading_factor = '1',
            start_in_insert = true,
            persist_size = true,
            direction = 'horizontal',
        }
        vim.api.nvim_set_keymap('n', '<leader>t', ':ToggleTerm<CR>',
            { noremap = true, silent = true })
        vim.api.nvim_set_keymap('t', '<Esc>', '<C-\\><C-n>',
            { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<C-1>', ':1ToggleTerm<CR>',
            { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<C-2>', ':2ToggleTerm<CR>',
            { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<C-3>', ':3ToggleTerm<CR>',
            { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<C-4>', ':4ToggleTerm<CR>',
            { noremap = true, silent = true })
    end
}
