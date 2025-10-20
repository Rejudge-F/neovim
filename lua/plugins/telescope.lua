return {
    "nvim-telescope/telescope.nvim",
    branch = "master", -- 使用 master 分支获取废弃 API 修复
    dependencies = {
        "nvim-lua/plenary.nvim" },
    config = function()
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")
        local function telescope_open_with_picker(prompt_bufnr)
            local picker = action_state.get_current_picker(prompt_bufnr)
            local entry = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            local win = require("window-picker").pick_window({})
            if not win or not entry then return end
            vim.api.nvim_set_current_win(win)
            if picker.prompt_title:match("Buffer") then
                vim.cmd("buffer " .. entry.bufnr)
            else
                local path = entry.path or entry.filename
                vim.cmd("edit " .. vim.fn.fnameescape(path))
            end
        end
        require("telescope").setup({
            defaults = {
                layout_strategy = "bottom_pane",
                layout_config = {
                    bottom_pane = {
                        height = 0.4,
                        prompt_position = "bottom",
                    },
                },
                mappings = {
                    n = {
                        ["sv"] = actions.select_vertical,
                        ["sp"] = actions.select_horizontal,
                        ["<leader>w"] = telescope_open_with_picker,
                    }
                },
                file_ignore_patterns = {
                    "^.git/",
                    "^node_modules/",
                    "^__pycache__/",
                    "^venv/",
                    "^.venv/",
                    "undo",
                    "%.pyc$",
                    "%.DS_Store$",
                },
            },
            pickers = {
                find_files = {
                    hidden = true,
                    no_ignore = true,
                },
                live_grep = {
                    hidden = true,
                    no_ignore = true
                },
            },
            extensions = {
                projects = {

                }
            }
        })
        vim.keymap.set("n", "<leader>f", ":Telescope find_files<CR>",
            { noremap = true, silent = true, desc = "Find files" })
        vim.keymap.set("n", "<leader>ss", ":Telescope live_grep<CR>",
            { noremap = true, silent = true, desc = "Live grep" })
        vim.keymap.set("n", "<leader>p", ":Telescope neovim-project discover<CR>", -- 使用新的项目管理
            { noremap = true, silent = true, desc = "Find projects" })
        vim.keymap.set("n", "<leader>bf", ":Telescope buffers<CR>",
            { noremap = true, silent = true, desc = "Find buffers" })
        vim.keymap.set("n", "<leader>fr", ":Telescope frecency<CR>",
            { noremap = true, silent = true, desc = "Frecency files" })
        vim.keymap.set("n", "<leader>th", ":Telescope colorscheme<CR>",
            { noremap = true, silent = true, desc = "Switch colorscheme" })
    end
}
