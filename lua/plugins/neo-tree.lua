return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = { "Neotree" },  -- 添加懒加载：只在命令触发时加载
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
        "s1n7ax/nvim-window-picker",
    },
    config = function()
        require("neo-tree").setup({
            close_if_last_window = true,
            popup_border_style = "rounded",
            enable_git_status = true,
            enable_diagnostics = true,
            open_files_do_not_replace_types = { "terminal", "trouble", "qf", "nofile", "notify", "quickfix", },
            default_component_configs = {
                indent = {
                    indent_size = 2,
                    padding = 1,
                },
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
                        "venv/",
                        "idl",
                        "output",
                        "output**",
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
                        ["s"] = "",
                        ["sv"] = "open_vsplit",
                        ["sp"] = "open_split",
                        ["<cr>"] = "open",
                        ["o"] = "open",
                        ["oc"] = "",
                        ["od"] = "",
                        ["om"] = "",
                        ["on"] = "",
                        ["os"] = "",
                    }
                },

            },
        })

        vim.g.neo_tree_window_picker_delay = 30 -- 毫秒
        vim.keymap.set('n', '<leader>n', ':Neotree toggle<CR>', { noremap = true, silent = true })
    end
}
