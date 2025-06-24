return {
    "rcarriga/nvim-notify",
    config = function()
        vim.notify = require("notify")
        require("notify").setup({
            stages = "fade_in_slide_out",
            top_down = false,
            timeout = 5000,
        })
    end,
}
