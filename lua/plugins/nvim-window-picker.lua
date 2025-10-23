return {
    "s1n7ax/nvim-window-picker",
    name = 'window-picker',
    version = "2.*",
    event = 'VeryLazy',
    config = function()
        require("window-picker").setup({
            autoselect_one = true,
            include_current = false, -- 不包含当前窗口，避免选择到自己
            other_win_hl_color = "#087c9c",
            selection_chars = "ABCDEFGHJKLMNOPQRSTUVWXYZ",
            filter_rules = {
                -- 使用更精确的过滤规则
                bo = {
                    -- 通过 filetype 过滤特殊窗口
                    filetype = {
                        "neo-tree",
                        "neo-tree-popup",
                        "notify",
                        "quickfix",
                        "qf",
                        "toggleterm",
                        "TelescopePrompt",
                        "TelescopeResults",
                        "Trouble",
                        "trouble",
                        "alpha",
                        "dashboard",
                        "lspsagaoutline",
                        "Outline",
                        "aerial",
                    },
                    -- 只过滤真正不应该打开文件的 buftype
                    buftype = {
                        "terminal",
                        "quickfix",
                        "prompt",
                    },
                },
                -- 添加额外的窗口过滤规则
                wo = {},
                -- 自定义过滤函数
                filter_func = function(window_id)
                    local bufnr = vim.api.nvim_win_get_buf(window_id)
                    local buftype = vim.api.nvim_buf_get_option(bufnr, 'buftype')
                    local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')

                    -- 额外检查：确保不在浮动窗口中打开
                    local win_config = vim.api.nvim_win_get_config(window_id)
                    if win_config.relative ~= "" then
                        return false -- 排除浮动窗口
                    end

                    return true
                end,
            },
        })
        -- 跳转到选择的窗口
        _G.jump_to_window = function()
            local picked_window_id = require("window-picker").pick_window()
            if picked_window_id then
                vim.api.nvim_set_current_win(picked_window_id)
            end
        end

        -- 在选择的窗口中打开文件
        _G.open_file_in_picked_window = function(filepath)
            local picked_window_id = require("window-picker").pick_window()
            if picked_window_id then
                vim.api.nvim_set_current_win(picked_window_id)
                vim.cmd('edit ' .. vim.fn.fnameescape(filepath))
            end
        end

        -- 智能窗口选择：获取最合适的窗口来打开文件
        _G.get_smart_window = function()
            local current_win = vim.api.nvim_get_current_win()
            local current_buf = vim.api.nvim_win_get_buf(current_win)
            local current_buftype = vim.api.nvim_buf_get_option(current_buf, 'buftype')
            local current_filetype = vim.api.nvim_buf_get_option(current_buf, 'filetype')

            -- 如果当前窗口是普通编辑窗口，直接使用
            if current_buftype == '' and not vim.tbl_contains({
                'neo-tree', 'toggleterm', 'Trouble', 'qf', 'quickfix'
            }, current_filetype) then
                return current_win
            end

            -- 否则尝试找到一个普通编辑窗口
            local windows = vim.api.nvim_list_wins()
            for _, win in ipairs(windows) do
                local buf = vim.api.nvim_win_get_buf(win)
                local buftype = vim.api.nvim_buf_get_option(buf, 'buftype')
                local filetype = vim.api.nvim_buf_get_option(buf, 'filetype')
                local win_config = vim.api.nvim_win_get_config(win)

                -- 找到普通的非浮动窗口
                if buftype == '' and win_config.relative == '' and
                    not vim.tbl_contains({
                        'neo-tree', 'toggleterm', 'Trouble', 'qf', 'quickfix'
                    }, filetype) then
                    return win
                end
            end

            -- 如果没找到，返回 nil，让调用者决定如何处理
            return nil
        end

        vim.keymap.set("n", "<leader>w", ":lua jump_to_window()<CR>",
            {
                noremap = true,
                silent = true,
                desc = "Pick window"
            })
    end
}
