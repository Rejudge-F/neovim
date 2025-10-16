vim.opt.encoding       = 'utf-8'
vim.opt.guicursor      = 'n-v-c-i:block'
vim.opt.termguicolors  = true
vim.opt.clipboard      = 'unnamedplus'  -- 使用系统剪贴板
vim.opt.timeoutlen     = 300            -- 减少键位映射等待时间（毫秒），默认1000
vim.opt.sidescrolloff  = 15
vim.opt.showmatch      = true
vim.opt.undofile       = true
vim.opt.undodir        = vim.fn.expand('~/.config/nvim/undo/')
vim.opt.foldmethod     = 'expr'
vim.opt.foldexpr       = 'nvim_treesitter#foldexpr()'
vim.opt.foldlevelstart = 99
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
