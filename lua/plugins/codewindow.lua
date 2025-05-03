return {
    'gorbit99/codewindow.nvim',         -- minimap
    config = function()
        require('codewindow').setup()
        require('codewindow').apply_default_keybinds()
    end,
}
