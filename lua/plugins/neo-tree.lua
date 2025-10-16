vim.keymap.set('n', '<leader>n', ':Neotree toggle<CR>', { noremap = true, silent = true })
return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = { "Neotree" }, -- 添加懒加载：只在命令触发时加载
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
            enable_refresh_on_write = true, -- 保存文件时自动刷新
            open_files_do_not_replace_types = { "terminal", "trouble", "qf", "nofile", "notify", "quickfix", },
            event_handlers = {
                {
                    event = "neo_tree_buffer_enter",
                    handler = function()
                        vim.cmd("setlocal relativenumber")
                    end,
                },
                {
                    event = "git_event",
                    handler = function()
                        require("neo-tree.sources.manager").refresh("filesystem")
                    end,
                },
            },
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

        -- 添加自动刷新命令：当焦点回到 nvim 时刷新 neo-tree
        vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
            pattern = "*",
            callback = function()
                if vim.fn.getcmdwintype() == "" then
                    vim.cmd("checktime")
                end
            end,
        })

        -- 当检测到文件变化时，刷新 neo-tree
        vim.api.nvim_create_autocmd({ "FileChangedShellPost" }, {
            pattern = "*",
            callback = function()
                local manager = require("neo-tree.sources.manager")
                local state = manager.get_state("filesystem")
                if state and state.tree then
                    manager.refresh("filesystem")
                end
            end,
        })
    end
}
