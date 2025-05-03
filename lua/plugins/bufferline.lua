return {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    opts = {
        options = {
            mode = "buffers",
            numbers = "ordinal",
            close_command = "Bdelete! %d",
            offsets = {
                {
                    filetype = "NvimTree",
                    text = "File Explorer",
                    highlight = "Directory",
                    text_align = "left",
                },
            },
            color_icons = true,
            show_buffer_icons = true,
            show_buffer_close_icons = false,
            separator_style = "thin",
        }
    },
    keys = {
        { "<Tab>",      "<Cmd>BufferLineCycleNext<CR>",            desc = "Next buffer" },
        { "<S-Tab>",    "<Cmd>BufferLineCyclePrev<CR>",            desc = "Previous buffer" },
        { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>",            desc = "Pin buffer" },
        { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete non-pinned buffers" },
    },
}
