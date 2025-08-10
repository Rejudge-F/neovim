return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "mfussenegger/nvim-dap-python",
        "leoluz/nvim-dap-go",
    },
    config = function()
        local dap = require("dap")
        local dapui = require("dapui")

        -- ========== 1) 语言适配 ==========
        -- Python
        local function get_python_path()
            local cwd = vim.fn.getcwd()
            if vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
                return cwd .. "/.venv/bin/python"
            elseif vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
                return cwd .. "/venv/bin/python"
            else
                return "python3"
            end
        end
        require("dap-python").setup(get_python_path())

        -- Go
        require("dap-go").setup({
            dap_configurations = {
                {
                    type = "go",
                    name = "Debug Project",
                    request = "launch",
                    program = "${workspaceFolder}",
                },
            },
        })

        -- ========== 2) UI 布局（调试专用 tab 内打开）==========
        dapui.setup({
            layouts = {
                { position = "left",   size = 40, elements = { "scopes", "breakpoints", "stacks", "watches" } },
                { position = "bottom", size = 10, elements = { "repl", "console" } },
            },
            floating = { border = "rounded" },
        })

        -- ========== 3) 常用按键 ==========
        local function nmap(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { noremap = true, silent = true, desc = desc })
        end
        nmap("<F5>", function() dap.continue() end, "DAP Continue")
        nmap("<F10>", function() dap.step_over() end, "DAP Step Over")
        nmap("<F11>", function() dap.step_into() end, "DAP Step Into")
        nmap("<F12>", function() dap.step_out() end, "DAP Step Out")
        nmap("<leader>bp", function() dap.toggle_breakpoint() end, "DAP Toggle Breakpoint")
        nmap("<leader>bc", function()
            dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end, "DAP Conditional Breakpoint")
        nmap("<leader>bl", function()
            dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
        end, "DAP Logpoint")
        nmap("<leader>du", function() dapui.toggle({ reset = true }) end, "DAP UI Toggle")

        -- ========== 4) 高亮符号 ==========
        vim.fn.sign_define("DapStopped", { text = "", texthl = "DiagnosticInfo", linehl = "", numhl = "" })

        -- ========== 5) 调试专用 tab：隔离布局，避免干扰 toggleterm / neotest ==========
        local debug_tab ---@type number|nil
        local prev_tab ---@type number|nil

        local function open_debug_tab()
            prev_tab = vim.api.nvim_get_current_tabpage()
            vim.cmd("tabnew %") -- 在新 tab 打开当前 buffer
            debug_tab = vim.api.nvim_get_current_tabpage()
            dapui.open({ reset = true })
        end

        local function close_debug_tab()
            pcall(dapui.close)
            if debug_tab and vim.api.nvim_tabpage_is_valid(debug_tab) then
                pcall(vim.api.nvim_set_current_tabpage, debug_tab)
                vim.cmd("tabclose")
            end
            if prev_tab and vim.api.nvim_tabpage_is_valid(prev_tab) then
                pcall(vim.api.nvim_set_current_tabpage, prev_tab)
            end
            debug_tab, prev_tab = nil, nil
        end

        dap.listeners.after.event_initialized["dapui_tab_isolation"] = function()
            if debug_tab and vim.api.nvim_tabpage_is_valid(debug_tab) then
                pcall(vim.api.nvim_set_current_tabpage, debug_tab)
                dapui.open({ reset = true })
            else
                open_debug_tab()
            end
        end
        dap.listeners.before.event_terminated["dapui_tab_isolation"] = function() close_debug_tab() end
        dap.listeners.before.event_exited["dapui_tab_isolation"]     = function() close_debug_tab() end

        -- ========== 6) 可选：调试时临时把方向键当 DAP 控制，用完自动恢复 ==========
        local saved_arrow_maps                                       = {}

        local function set_debug_arrows()
            local keys = { "<Up>", "<Down>", "<Left>", "<Right>" }
            for _, k in ipairs(keys) do
                saved_arrow_maps[k] = vim.fn.maparg(k, "n", false, true)
            end
            vim.keymap.set("n", "<Down>", dap.step_over, { noremap = true, silent = true, desc = "DAP Step Over" })
            vim.keymap.set("n", "<Right>", dap.step_into, { noremap = true, silent = true, desc = "DAP Step Into" })
            vim.keymap.set("n", "<Left>", dap.step_out, { noremap = true, silent = true, desc = "DAP Step Out" })
            vim.keymap.set("n", "<Up>", function()
                if dap.restart_frame then
                    dap.restart_frame()
                else
                    dap.terminate()
                    dap.run_last()
                end
            end, { noremap = true, silent = true, desc = "DAP Restart Frame/Session" })
        end

        local function clear_debug_arrows()
            local keys = { "<Up>", "<Down>", "<Left>", "<Right>" }
            for _, k in ipairs(keys) do
                pcall(vim.keymap.del, "n", k)
                local m = saved_arrow_maps[k]
                if m and next(m) then
                    local rhs = m.rhs or m.callback
                    if rhs then
                        vim.keymap.set("n", k, rhs, {
                            noremap = m.noremap, silent = m.silent, expr = m.expr, desc = m.desc
                        })
                    end
                end
            end
            saved_arrow_maps = {}
        end

        dap.listeners.after.event_initialized["debug_arrows"] = function() set_debug_arrows() end
        dap.listeners.before.event_terminated["debug_arrows"] = function() clear_debug_arrows() end
        dap.listeners.before.event_exited["debug_arrows"] = function() clear_debug_arrows() end
    end,
}
