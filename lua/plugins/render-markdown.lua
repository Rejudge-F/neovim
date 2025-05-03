return {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },         -- if you prefer nvim-web-devicons
    config = function(_, opts)
        require('render-markdown').setup({
            completion = {
                lsp = {
                    enabled = true,
                }
            }
        })
    end
}
