return {
    "lewis6991/gitsigns.nvim",
    config = function()
        require('gitsigns').setup({
            signcolumn                   = true,
            numhl                        = false,
            linehl                       = false,
            word_diff                    = false,
            watch_gitdir                 = {
                interval = 1000,  -- 优化：从 100ms 改为 1000ms，减少 CPU 占用
                follow_files = true
            },
            attach_to_untracked          = true,
            current_line_blame           = true,
            current_line_blame_opts      = {
                virt_text = true,
                virt_text_pos = 'eol',
                ignore_whitespace = false,
                delay = 10,
                virt_text_priority = 1,
                use_focus = false,
            },
            current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
            sign_priority                = 6,
            update_debounce              = 300,  -- 优化：从 100ms 改为 300ms，减少更新频率

            status_formatter             = nil,
            max_file_length              = 40000,
            preview_config               = {
                border = 'single',
                style = 'minimal',
                relative = 'cursor',
                row = 0,
                col = 1
            },
            on_attach                    = function(bufnr)
                local gitsigns = require('gitsigns')

                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end


                map('n', ']h', function()
                    if vim.wo.diff then
                        vim.cmd.normal({ ']h', bang = true })
                    else
                        gitsigns.nav_hunk('next')
                    end
                end)

                map('n', '[h', function()
                    if vim.wo.diff then
                        vim.cmd.normal({ '[h', bang = true })
                    else
                        gitsigns.nav_hunk('prev')
                    end
                end)
            end
        })
    end
}
