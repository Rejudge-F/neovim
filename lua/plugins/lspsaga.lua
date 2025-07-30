return {
    'nvimdev/lspsaga.nvim',
    config = function()
        require('lspsaga').setup({
            beacon = {
                enable = true
            },
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
        vim.keymap.set('n', 'gi', ':Lspsaga finder imp<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', 'go', ':Lspsaga outgoing_calls<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', 'gd', ':Lspsaga goto_definition<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', 'gtd', ':Lspsaga goto_type_definition<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', ']e', ':Lspsaga diagnostic_jump_next<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', '[e', ':Lspsaga diagnostic_jump_next<CR>', { noremap = true, silent = true })

        local function with_beacon(fn)
            return function()
                vim.schedule(function()
                    local beacon_width = 7
                    local row = vim.fn.line('.') - 1
                    local curson_index = vim.fn.col('.')
                    local col_start = curson_index - beacon_width
                    if col_start < 0 then
                        col_start = 0
                    end
                    local col_end = curson_index + beacon_width
                    if col_end > vim.fn.col('$') then
                        col_end = vim.fn.col('$')
                    end
                    local width = col_end - col_start + 1
                    require('lspsaga.beacon').jump_beacon({ row, col_start }, width)
                end)
                return fn()
            end
        end

        vim.keymap.set("n", "<C-o>", with_beacon(function() return "<C-o>" end), { expr = true })
        vim.keymap.set("n", "<C-i>", with_beacon(function() return "<C-i>" end), { expr = true })
    end,
    dependencies = {
        'nvim-treesitter/nvim-treesitter', -- optional
        'nvim-tree/nvim-web-devicons',     -- optional
    }
}
