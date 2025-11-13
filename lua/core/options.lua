-- 暂时禁用废弃 API 警告
-- 原因：以下插件使用了废弃的 vim.lsp.buf_get_clients() 或 vim.lsp.get_active_clients()
-- 1. project.nvim - 使用 buf_get_clients()
-- 2. nvim-dap-go - 使用 buf_get_clients()
-- 3. lsp-progress.nvim - 使用 get_active_clients()
-- 4. conform.nvim - 使用 get_active_clients()
-- 等待这些插件更新后可以移除此配置
vim.deprecate = function() end

vim.opt.encoding       = 'utf-8'
vim.opt.guicursor      = 'n-v-c-i:block'
vim.opt.termguicolors  = true
-- vim.opt.clipboard      = 'unnamedplus'  -- 使用系统剪贴板
vim.opt.timeoutlen     = 300 -- 减少键位映射等待时间（毫秒），默认1000
vim.opt.sidescrolloff  = 15
vim.opt.showmatch      = true
vim.opt.undofile       = true
vim.opt.undodir        = vim.fn.expand('~/.config/nvim/undo/')

-- 自动清理 30 天前的 undo 文件（启动时异步执行）
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        local undo_dir = vim.fn.expand('~/.config/nvim/undo/')
        vim.fn.jobstart(string.format("find %s -type f -mtime +30 -delete 2>/dev/null", undo_dir), {
            detach = true,
        })
    end,
    desc = "Auto-cleanup old undo files (30+ days)",
})

-- 注意：折叠配置已移至 nvim-treesitter.lua 和 nvim-ufo.lua
-- vim.opt.foldmethod     = 'expr'
-- vim.opt.foldexpr       = 'nvim_treesitter#foldexpr()'
-- vim.opt.foldlevelstart = 99
vim.opt.wildmenu       = true
vim.opt.wildmode       = { 'longest:list', 'full' }
vim.opt.vb             = true
vim.opt.number         = true
vim.opt.history        = 700
vim.opt.undolevels     = 700
vim.opt.tabstop        = 4
vim.opt.softtabstop    = 4
vim.opt.shiftwidth     = 4
vim.opt.shiftround     = true
vim.opt.expandtab      = true
vim.opt.hlsearch       = true
vim.opt.incsearch      = true
vim.opt.ignorecase     = true
vim.opt.smartcase      = true
vim.opt.backup         = false
vim.opt.writebackup    = false
vim.opt.swapfile       = false
vim.opt.autoread       = true  -- 自动读取外部文件变化
vim.opt.updatetime     = 1000  -- 更新时间（毫秒），用于触发 CursorHold 等事件

vim.diagnostic.config({
    virtual_text = false, -- 禁用行内文本（如错误信息）
    signs = true,         -- 启用左侧图标
    underline = false,    -- 禁用下划线
})

local signs = { Error = "✗", Warn = "⚠", Hint = "󱧣", Info = "" }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end
