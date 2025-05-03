return {
    "simrat39/symbols-outline.nvim",
    cmd = { "SymbolsOutline", "SymbolsOutlineOpen" },
    keys = {
        { "<leader>so", "<cmd>SymbolsOutline<CR>", desc = "Toggle Symbols Outline" }
    },
    config = function()
        require("symbols-outline").setup({
            show_symbol_details = true,
        })
    end,
}
