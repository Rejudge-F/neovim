return {
    "rcarriga/nvim-dap-ui",
    tag = "v4.0.0",
    dependencies = {
        "nvim-neotest/nvim-nio",
        "mfussenegger/nvim-dap"
    },
    config = function()
        local dap = require('dap')
        local dapui = require('dapui')
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
        dap_go.setup()
        dapui.setup()
        dap.listeners.after.event_initialized["dapui_config"] = function()
            require("dapui").open()
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
            require("dapui").close()
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
            require("dapui").close()
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
        vim.api.nvim_set_keymap('n', '<leader>dr', ':lua require"dap".repl.open()<CR>',
            { noremap = true, silent = true })
    end
}
