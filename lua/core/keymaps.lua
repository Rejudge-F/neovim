vim.g.mapleader = ';'
vim.g.maplocalleader = '\''
vim.api.nvim_set_keymap('n', '<leader>q', ':q<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>Q', ':qa<CR>', { noremap = true, silent = true })
vim.keymap.set('n', 'q', '<Nop>', { noremap = true, silent = true }) -- 取消 q 的宏录制功能
vim.keymap.set('v', 'q', '<Nop>', { noremap = true, silent = true }) -- 取消 q 的宏录制功能
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.api.nvim_set_keymap('v', '<', '<gv', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '>', '>gv', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'Q', 'gq', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'Q', 'gqap', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'sp', ':split<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'sv', ':vsplit<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'sc', '<C-w>c', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'so', '<C-w>o', { noremap = true, silent = true })
vim.api.nvim_set_keymap('x', '<leader>y', '"+y<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>ln', function()
    local filepath = vim.fn.expand('%')
    local linenr = vim.fn.line('.')
    vim.fn.setreg('+', string.format('%s:%d', filepath, linenr))
    vim.notify(string.format('%s:%d', filepath, linenr), vim.log.levels.INFO)
end, { desc = "Show relative file path and line number" })

vim.keymap.set('n', '<leader>Ln', function()
    local filepath = vim.fn.expand('%:p')
    local linenr = vim.fn.line('.')
    vim.fn.setreg('+', string.format('%s:%d', filepath, linenr))
    vim.notify(string.format('%s:%d', filepath, linenr), vim.log.levels.INFO)
end, { desc = "Show absolute file path and line number" })

-- 跳转列表 <C-o>/<C-i> 跳转后高亮目标行
local beacon = require('core.beacon')
local function feed_normal(keys)
    local termcodes = vim.api.nvim_replace_termcodes(keys, true, false, true)
    vim.api.nvim_feedkeys(termcodes, 'n', false)
end
vim.keymap.set('n', '<C-o>', beacon.wrap(function() feed_normal('<C-o>') end),
    { desc = "Jump back with beacon" })
vim.keymap.set('n', '<C-i>', beacon.wrap(function() feed_normal('<C-i>') end),
    { desc = "Jump forward with beacon" })

-- Nvim 0.12 内置 undotree 可视化插件 (lazy load)
vim.keymap.set('n', '<leader>u', function()
    vim.cmd('packadd nvim.undotree')
    vim.cmd('Undotree')
end, { desc = "Toggle undo tree" })
