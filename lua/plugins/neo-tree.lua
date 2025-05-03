return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons", -- 注意：这里仍然使用 nvim-web-devicons
        "MunifTanjim/nui.nvim",
        {
            "s1n7ax/nvim-window-picker", -- for open_with_window_picker keymaps
            version = "2.*",
            config = function()
                require("window-picker").setup({
                    filter_rules = {
                        include_current_win = false,
                        autoselect_one = true,
                        -- filter using buffer options
                        bo = {
                            -- if the file type is one of following, the window will be ignored
                            filetype = { "neo-tree", "neo-tree-popup", "notify" },
                            -- if the buffer type is one of following, the window will be ignored
                            buftype = { "terminal", "quickfix" },
                        },
                    },
                })
            end,
        },
    },
    config = function()
        require("neo-tree").setup({
            close_if_last_window = true,
            popup_border_style = "rounded",
            enable_git_status = true,
            enable_diagnostics = true,
            default_component_configs = {
                indent = {
                    indent_size = 2,
                    padding = 1,
                },
                git_status = {
                    symbols = {
                        -- 更改 git 状态符号
                        added     = "✚",
                        deleted   = "✖",
                        modified  = "",
                        renamed   = "➜",
                        untracked = "?",
                        ignored   = "◌",
                        unstaged  = "",
                        staged    = "✓",
                        conflict  = "",
                    }
                },
            },
            modified = {
                symbol = "[+]",
                highlight = "NeoTreeModified",
            },
            filesystem = {
                filtered_items = {
                    visible = false, -- 默认不显示隐藏文件
                    hide_dotfiles = true,
                    hide_gitignored = true,
                    hide_by_name = {
                        "__pycache__",
                        ".DS_Store",
                    },
                    always_show_by_pattern = {
                        ".gitignore",
                        "*codebase*",
                        ".venv",
                    },
                },
                follow_current_file = {
                    enabled = true, -- 自动跟随当前文件
                },
                hijack_netrw_behavior = "open_current",
                use_libuv_file_watcher = true,
                window = {
                    width = 30,
                    mappings = {
                        ["sv"] = "open_vsplit",
                        ["sp"] = "open_split",
                        ["o"] = "open_with_window_picker",
                        ["<cr>"] = "open",
                    }
                },

            },
        })

        vim.g.neo_tree_window_picker_delay = 100 -- 毫秒
        vim.keymap.set('n', '<leader>n', ':Neotree toggle<CR>', { noremap = true, silent = true })
    end
}
