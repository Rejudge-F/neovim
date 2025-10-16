return {
    "akinsho/toggleterm.nvim",
    cmd = { "ToggleTerm" },  -- 添加懒加载：只在命令触发时加载
    config = function()
        require("toggleterm").setup {
            shade_terminals = true,
            shading_factor = '1',
            start_in_insert = false,
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
        function _G.toggle_term_height()
            local winid = vim.api.nvim_get_current_win()
            local cur_height = vim.api.nvim_win_get_height(winid)
            local total_lines = vim.o.lines
            local target_height = cur_height < math.floor(total_lines * 0.8) and math.floor(total_lines * 0.8) or 15
            vim.api.nvim_win_set_height(winid, target_height)
        end

        vim.api.nvim_set_keymap('t', '<C-0>', [[<C-\><C-n>:lua toggle_term_height()<CR>i]],
            { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<C-0>', [[<C-\><C-n>:lua toggle_term_height()<CR>i]],
            { noremap = true, silent = true })
    end
}
