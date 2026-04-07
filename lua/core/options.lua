vim.opt.encoding      = 'utf-8'
vim.opt.guicursor     = 'n-v-c-i:block'
vim.opt.termguicolors = true
-- 不在 cmdline 显示 progress 消息（LSP 进度等），交由 statusline (lualine) 显示
vim.opt.messagesopt   = 'hit-enter,history:500'
-- vim.opt.clipboard      = 'unnamedplus'  -- 使用系统剪贴板
vim.opt.timeoutlen    = 300 -- 减少键位映射等待时间（毫秒），默认1000
vim.opt.sidescrolloff = 15
vim.opt.showmatch     = true
vim.opt.undofile      = true
vim.opt.undodir       = vim.fn.expand('~/.config/nvim/undo/')
vim.o.autoread        = true


-- 自动清理 30 天前的 undo 文件（延迟执行，避免影响启动速度）
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        -- 延迟 5 秒执行，确保启动完成后再执行清理
        vim.defer_fn(function()
            local undo_dir = vim.fn.expand('~/.config/nvim/undo/')
            vim.fn.jobstart(string.format("find %s -type f -mtime +30 -delete 2>/dev/null", undo_dir), {
                detach = true,
            })
        end, 5000)
    end,
    desc = "Auto-cleanup old undo files (30+ days)",
    once = true, -- 只执行一次
})

-- 注意：折叠配置已移至 nvim-treesitter.lua 和 nvim-ufo.lua
-- vim.opt.foldmethod     = 'expr'
-- vim.opt.foldexpr       = 'nvim_treesitter#foldexpr()'
-- vim.opt.foldlevelstart = 99
vim.opt.wildmenu     = true
vim.opt.wildmode     = { 'longest:list', 'full' }
vim.opt.vb           = true
vim.opt.number       = true
vim.opt.history      = 700
vim.opt.undolevels   = 700
vim.opt.tabstop      = 4
vim.opt.softtabstop  = 4
vim.opt.shiftwidth   = 4
vim.opt.shiftround   = true
vim.opt.expandtab    = true
vim.opt.hlsearch     = true
vim.opt.incsearch    = true
vim.opt.ignorecase   = true
vim.opt.smartcase    = true
vim.opt.backup       = false
vim.opt.writebackup  = false
vim.opt.swapfile     = false
vim.opt.autoread     = true -- 自动读取外部文件变化
vim.opt.updatetime   = 2000 -- 更新时间（毫秒），用于触发 CursorHold 等事件

-- 性能优化选项
vim.opt.lazyredraw   = false -- 禁用延迟重绘，避免黑屏
vim.opt.ttyfast      = true  -- 快速终端连接
vim.opt.redrawtime   = 1500  -- 语法高亮超时时间

-- 平滑滚动设置
vim.opt.scrolloff    = 8    -- 光标上下保留 8 行
vim.opt.smoothscroll = true -- 启用平滑滚动 (Neovim 0.10+)

vim.diagnostic.config({
    virtual_text = false, -- 禁用行内文本（如错误信息）
    underline = false,    -- 禁用下划线
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "✗",
            [vim.diagnostic.severity.WARN]  = "⚠",
            [vim.diagnostic.severity.HINT]  = "󱧣",
            [vim.diagnostic.severity.INFO]  = "",
        },
    },
})
