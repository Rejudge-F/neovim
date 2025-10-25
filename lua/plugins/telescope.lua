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
                    -- project.nvim 的 telescope 扩展配置
                    display_type = 'full', -- 显示完整路径
                    hidden_files = true, -- 显示隐藏文件
                    theme = 'dropdown', -- 使用下拉主题
                    order_by = 'asc', -- 排序方式
                    search_by = 'title', -- 按标题搜索
                }
            }
        })

        -- 加载 project.nvim 的 telescope 扩展
        require('telescope').load_extension('projects')

        vim.keymap.set("n", "<leader>f", ":Telescope find_files<CR>",
            { noremap = true, silent = true, desc = "Find files" })
        vim.keymap.set("n", "<leader>ss", ":Telescope live_grep<CR>",
            { noremap = true, silent = true, desc = "Live grep" })
        vim.keymap.set("n", "<leader>p", ":Telescope projects<CR>", -- 使用 project.nvim 的 telescope 扩展
            { noremap = true, silent = true, desc = "Find projects" })
        vim.keymap.set("n", "<leader>bf", ":Telescope buffers<CR>",
            { noremap = true, silent = true, desc = "Find buffers" })
        vim.keymap.set("n", "<leader>fr", ":Telescope frecency<CR>",
            { noremap = true, silent = true, desc = "Frecency files" })
        vim.keymap.set("n", "<leader>th", ":Telescope colorscheme<CR>",
            { noremap = true, silent = true, desc = "Switch colorscheme" })
    end
}
