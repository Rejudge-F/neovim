return {
    "TobinPalmer/Tip.nvim",
    event = "VimEnter",
    init = function()
        require("tip").setup({
            title = "Tip!",
            url = "https://vtip.43z.one", -- Or https://vimiscool.tech/neotip
        })
    end,
}
