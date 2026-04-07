-- 跳转高亮 (beacon)
-- 在光标位置短暂闪烁一次, 用于跳转后视觉提示
-- 效果: 半透明粉色 (alpha=0.5) 覆盖光标右侧一段, 随时间淡出到完全透明
-- 实现: 终端没有真 alpha, 用粉色与 Normal fg/bg 做线性插值模拟
-- 用法: require('core.beacon').flash()
--      require('core.beacon').wrap(fn)

local M = {}

local ns = vim.api.nvim_create_namespace("core_beacon")
local hl_group = "CoreBeacon"

-- 粉色起点
local PINK = "#f21f5b"
-- 起始不透明度 (0 完全透明 / 1 完全不透明), 0.9 = 接近完全覆盖
local START_ALPHA = 0.9

local function hex_to_rgb(hex)
    hex = hex:gsub("#", "")
    return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
end

-- 线性插值两个颜色, t ∈ [0, 1]
local function blend(hex_a, hex_b, t)
    local ar, ag, ab = hex_to_rgb(hex_a)
    local br, bg, bb = hex_to_rgb(hex_b)
    local r = math.floor(ar + (br - ar) * t + 0.5)
    local g = math.floor(ag + (bg - ag) * t + 0.5)
    local b = math.floor(ab + (bb - ab) * t + 0.5)
    return string.format("#%02x%02x%02x", r, g, b)
end

-- 获取 Normal 的 bg/fg, 用于混合目标
local function normal_colors()
    local hl = vim.api.nvim_get_hl(0, { name = "Normal" })
    local bg = hl.bg and string.format("#%06x", hl.bg)
        or (vim.o.background == "dark" and "#000000" or "#ffffff")
    local fg = hl.fg and string.format("#%06x", hl.fg)
        or (vim.o.background == "dark" and "#ffffff" or "#000000")
    return bg, fg
end

-- alpha ∈ [0, 1]: 按 alpha 不透明度生成 bg/fg
-- alpha=0: 完全透明 (字符看起来和原样一样, 但我们也会把 extmark 清掉)
-- alpha=1: 完全不透明, 纯粉色覆盖一切
local function set_hl(alpha)
    local nbg, nfg = normal_colors()
    -- bg = PINK 与 Normal bg 按 alpha 混合
    -- fg = PINK 与 Normal fg 按 alpha 混合 (字符颜色也被"染"上粉色)
    local bg = blend(nbg, PINK, alpha)
    local fg = blend(nfg, PINK, alpha)
    vim.api.nvim_set_hl(0, hl_group, { bg = bg, fg = fg })
end

-- 初始化 (用 START_ALPHA, 保证 ColorScheme 事件后也有合理值)
set_hl(START_ALPHA)

vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function() set_hl(START_ALPHA) end,
    desc = "Re-apply CoreBeacon highlight on colorscheme change",
})

-- 当前活跃的 fade timer, 用于跳转连打时中断上一次
local active_timer = nil

--- 在光标位置闪烁一段半透明粉色, 淡出到完全透明
--- @param duration integer? 总淡出时长 (毫秒), 默认 400
--- @param width integer?    高亮宽度 (字符), 默认 24
function M.flash(duration, width)
    duration = duration or 400
    width = width or 24

    local buf = vim.api.nvim_get_current_buf()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    row = row - 1

    if active_timer then
        active_timer:stop()
        active_timer:close()
        active_timer = nil
    end

    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

    local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ""
    local end_col = math.min(#line, col + width)
    if end_col <= col then return end

    vim.api.nvim_buf_set_extmark(buf, ns, row, col, {
        end_row = row,
        end_col = end_col,
        hl_group = hl_group,
        hl_mode = "replace",
        priority = 10000,
        strict = false,
    })

    -- alpha 从 START_ALPHA 线性衰减到 0
    local frames = 20
    local frame = 0
    local interval = math.max(16, math.floor(duration / frames))
    set_hl(START_ALPHA)

    local timer = vim.uv.new_timer()
    active_timer = timer
    timer:start(interval, interval, vim.schedule_wrap(function()
        frame = frame + 1
        if frame >= frames then
            timer:stop()
            timer:close()
            if active_timer == timer then active_timer = nil end
            if vim.api.nvim_buf_is_valid(buf) then
                vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
            end
            set_hl(START_ALPHA) -- 重置, 供下次使用
            return
        end
        local alpha = START_ALPHA * (1 - frame / frames)
        set_hl(alpha)
    end))
end

--- 包装一个会移动光标的函数, 调用后自动 flash
--- @param fn function 真正执行跳转的函数
--- @return function
function M.wrap(fn)
    return function(...)
        local prev_buf = vim.api.nvim_get_current_buf()
        local prev_pos = vim.api.nvim_win_get_cursor(0)
        fn(...)
        vim.schedule(function()
            vim.defer_fn(function()
                local new_buf = vim.api.nvim_get_current_buf()
                local new_pos = vim.api.nvim_win_get_cursor(0)
                if new_buf ~= prev_buf or new_pos[1] ~= prev_pos[1] or new_pos[2] ~= prev_pos[2] then
                    M.flash()
                end
            end, 50)
        end)
    end
end

return M
