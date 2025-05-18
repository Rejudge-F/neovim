return {
    "s1n7ax/nvim-window-picker",
    name = 'window-picker',
    version = "2.*",
    event = 'VeryLazy',
    config = function()
        require("window-picker").setup({
            autoselect_one = true,
            include_current = true,
            other_win_hl_color = "#087c9c",
            selection_chars = "ABCDEFGHJKLMNOPQRSTUVWXYZ",
            filter_rules = {
                bo = {
                    filetype = { "neo-tree", "neo-tree-popup", "notify", "quickfix" },
                    buftype = { "quickfix" },
                },
            },
        })
        _G.jump_to_window = function()
            local picked_window_id = require("window-picker").pick_window()
            if picked_window_id then
                vim.api.nvim_set_current_win(picked_window_id)
            end
        end
        vim.keymap.set("n", "<leader>w", ":lua jump_to_window()<CR>",
            {
                noremap = true,
                silent = true,
                desc = "Pick window"
            })
    end
}
