return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "mfussenegger/nvim-dap-python",
        "leoluz/nvim-dap-go"
    },
    config = function()
        local dap_python = require('dap-python')
        local dap_go = require('dap-go')
        local function get_python_path()
            local cwd = vim.fn.getcwd()
            if vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
                return cwd .. '/.venv/bin/python'
            elseif vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
                return cwd .. '/venv/bin/python'
            else
                return 'python3'
            end
        end
        dap_python.setup(get_python_path())
        dap_go.setup {
            dap_configurations = {
                {
                    type = 'go',
                    name = 'Debug Entire Project',
                    request = 'launch',
                    program = '${workspaceFolder}',
                },
            },
        }
        local dap = require('dap')
        local dapui = require('dapui')
        dapui.setup()

        local original_keys = {}
        local function set_dap_keymaps()
            for _, key in ipairs({ "<Up>", "<Down>", "<Left>", "<Right>" }) do
                local existing = vim.fn.maparg(key, "n", false, true)
                original_keys[key] = next(existing) and existing or nil
            end

            vim.keymap.set("n", "<Down>", dap.step_over, { desc = "DAP Step Over", silent = true, noremap = true })
            vim.keymap.set("n", "<Right>", dap.step_into, { desc = "DAP Step Into", silent = true, noremap = true })
            vim.keymap.set("n", "<Left>", dap.step_out, { desc = "DAP Step Out", silent = true, noremap = true })
            vim.keymap.set("n", "<Up>", function()
                if dap.restart_frame then
                    dap.restart_frame()
                else
                    dap.terminate()
                    dap.run_last()
                end
            end, { desc = "DAP Restart Frame/Session", silent = true, noremap = true })
        end

        local function clear_dap_keymaps()
            for _, key in ipairs({ "<Up>", "<Down>", "<Left>", "<Right>" }) do
                pcall(vim.keymap.del, "n", key)

                if original_keys[key] then
                    local rhs = original_keys[key].rhs or original_keys[key].callback
                    local opts = {
                        noremap = original_keys[key].noremap,
                        silent = original_keys[key].silent,
                        expr = original_keys[key].expr,
                        desc = original_keys[key].desc,
                    }
                    vim.keymap.set("n", key, rhs, opts)
                end
            end
        end

        dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
            set_dap_keymaps()
        end

        dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
            clear_dap_keymaps()
        end

        dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
            clear_dap_keymaps()
        end

        vim.api.nvim_set_keymap('n', '<F5>', ':lua require"dap".continue()<CR>',
            { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<F10>', ':lua require"dap".step_over()<CR>',
            { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<F11>', ':lua require"dap".step_into()<CR>',
            { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<F12>', ':lua require"dap".step_out()<CR>',
            { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<leader>b', ':lua require"dap".toggle_breakpoint()<CR>',
            { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<leader>B',
            ':lua require"dap".set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>',
            { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<leader>du', ':lua require"dap".repl.open()<CR>',
            { noremap = true, silent = true })
    end
}
