return {
    'gorbit99/codewindow.nvim',         -- minimap
    enabled = false,  -- Disabled due to nvim-treesitter.ts_utils deprecation
    config = function()
        require('codewindow').setup()
        require('codewindow').apply_default_keybinds()
    end,
}
