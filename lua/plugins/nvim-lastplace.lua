return {
    'ethanholz/nvim-lastplace',
    event = "BufRead", -- 改为 BufRead，不需要 Pre
    config = function()
        require 'nvim-lastplace'.setup {
            lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
            lastplace_ignore_filetype = { "gitcommit", "gitrebase", "svn", "hgcommit" },
            lastplace_open_folds = true
        }
        require 'nvim-lastplace'.setup {}
    end
}
