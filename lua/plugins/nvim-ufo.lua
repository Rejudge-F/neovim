return {
    "kevinhwang91/nvim-ufo",
    dependencies = "kevinhwang91/promise-async",
    event = "BufReadPost",
    opts = {
        provider_selector = function(_, filetype)
            return filetype == "markdown" and "indent" or { "treesitter", "indent" }
        end
    },

}
