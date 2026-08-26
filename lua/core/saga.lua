-- lspsaga 调用守卫
-- 用法: require('core.saga').cmd("Lspsaga finder")  -> 返回可直接绑键的函数
--
-- 背景: lspsaga 的 codeaction/definition/finder/callhierarchy/typehierarchy
-- 各自维护一个 pending_request 标志. 当请求超时、被中断、或 nvim 改了 LSP
-- 内部导致回调没跑完时, 这个标志会永久停在 true, 之后所有调用直接静默返回,
-- 表现为"按了没反应", 只能重启 nvim.
--
-- 这里在每次调用前检查: 如果标志是 true 但屏幕上并没有 lspsaga:// 窗口,
-- 说明是残留的脏状态, 直接清掉. 有窗口时不动 (那是正常的进行中请求).

local M = {}

local STATEFUL_MODULES = {
    'lspsaga.codeaction',
    'lspsaga.definition',
    'lspsaga.finder',
    'lspsaga.callhierarchy',
    'lspsaga.typehierarchy',
}

-- 屏幕上是否存在 lspsaga 自己的窗口
local function has_saga_window()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_is_valid(win) then
            local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
            if bufname:match("lspsaga://") then
                return true
            end
        end
    end
    return false
end

--- 清理残留的 pending_request 状态
function M.clear_stale_state()
    if has_saga_window() then return end
    for _, mod_name in ipairs(STATEFUL_MODULES) do
        local ok, mod = pcall(require, mod_name)
        if ok and type(mod) == 'table' and mod.pending_request == true then
            mod.pending_request = false
        end
    end
end

--- 包装一条 Lspsaga 命令, 调用前先清脏状态
--- @param cmd string 例如 "Lspsaga finder"
--- @return function
function M.cmd(cmd)
    return function()
        M.clear_stale_state()
        vim.cmd(cmd)
    end
end

return M
