-- 引用读写分类 (gR)
-- 用法: require('core.ref_kinds').show()
--
-- 为什么要自己写: textDocument/references 只返回 Location[], 不带读写信息,
-- lspsaga finder 也只能按 method (def/ref/imp) 分组 —— 它的 retval 直接以
-- method 字符串为 key (finder/init.lua:546), filter 也按 method 索引
-- (finder/box.lua:41), 没有第二个分组维度可用. 所以另起一套.
--
-- 分四类:
--   SET   写入   赋值左侧 / := / ++ / -- / range 左侧 / 字面量字段初始化
--   GET   读取   其余表达式位置
--   CALL  调用   处在 call_expression 的函数位
--   DECL  声明   var/const/参数/字段 的声明处
--
-- 判据是 LSP 主 + treesitter 补, 两者各有盲区:
--
--   LSP (textDocument/documentHighlight) 给的是语义层的 Read/Write, 最准.
--   实测 gopls 确实返回真的 Read/Write (不是全 Text), 而且**不要求文件在
--   buffer 里打开** —— 直接用 uri 发请求就有结果, 所以一个文件一次请求,
--   完全不需要 bufload. 盲区: 部分位置 gopls 返回 Text (如 println(s.count)),
--   Text 是"不确定"而不是"纯文本匹配"; 且 LSP 协议里没有 CALL / DECL 概念.
--
--   treesitter 认识 CALL / DECL / &取址, 但只覆盖 RULES 表里写了规则的语言.
--
-- 合并规则见 build_items: LSP 说写就是写; LSP 说读时让 treesitter 把"调用"
-- 挑出来; LSP 返回 Text 或没结果时完全交给 treesitter. 两边都没结论就退化成
-- 不分组的引用列表 —— 宁可不分类, 也不假装分好了. 浮窗标题会标 [lsp]/[ts]/[none],
-- 出了怪结果能一眼看出是谁判的.
--
-- 局限 (重要): 对**函数名**执行 gR 时所有引用都落在 CALL, set/get 没有意义.
-- 这个分类真正有价值的场景是**变量和 struct 字段**.
--
-- 读文件不打开 buffer: 用 vim.uv 直接读字节 + get_string_parser,
-- 和 core/enhanced_hover.lua 一致.

local M = {}

local api = vim.api
local ts = vim.treesitter
local beacon = require('core.beacon')

local ORDER = { 'SET', 'GET', 'CALL', 'DECL' }
local BULLET = '●'

-- 分类结果的高亮: 一律 link 到 colorscheme 稳定的内置组, 不硬编码颜色
local HL_LINKS = {
    RefKindSet   = 'DiagnosticError', -- 写: 红
    RefKindGet   = 'DiagnosticHint',  -- 读: 青
    RefKindCall  = 'Function',
    RefKindDecl  = 'Type',
    RefKindPath  = 'Comment',
    RefKindCount = 'Comment',
    RefKindMark  = 'WarningMsg',
}
local HL_OF_KIND = {
    SET = 'RefKindSet', GET = 'RefKindGet', CALL = 'RefKindCall', DECL = 'RefKindDecl',
}

local function apply_hl()
    for name, target in pairs(HL_LINKS) do
        api.nvim_set_hl(0, name, { link = target, default = false })
    end
end
apply_hl()
api.nvim_create_autocmd('ColorScheme', {
    callback = apply_hl,
    desc = 'Re-link RefKind highlights on colorscheme change',
})

--------------------------------------------------------------------------------
-- 1. 语法规则表
--------------------------------------------------------------------------------

-- field_name() 会去 parent 上按这些名字找 node, 覆盖所有语言用到的字段
local FIELD_NAMES = {
    'left', 'right', 'name', 'value', 'key', 'function', 'operand',
    'field', 'table', 'pattern', 'arguments', 'object', 'property',
}

--- node 在 parent 里挂在哪个字段下
local function field_name(parent, node)
    local id = node:id()
    for _, name in ipairs(FIELD_NAMES) do
        local ok, list = pcall(parent.field, parent, name)
        if ok and list then
            for _, n in ipairs(list) do
                if n:id() == id then return name end
            end
        end
    end
    return nil
end

local function node_text(node, src)
    local ok, text = pcall(ts.get_node_text, node, src)
    return ok and text or ''
end

-- 赋值左侧 -> SET, 右侧 -> GET
local function lhs_is_set(f) return f == 'left' and 'SET' or 'GET' end

-- 复合字面量里的字段初始化 (Foo{Bar: 1}). 各版本 grammar 字段名不一致,
-- 有 key 字段就用, 否则退回"第一个命名子节点即 key"
local function keyed(f, parent, node)
    if f == 'key' then return 'SET' end
    if f then return 'GET' end
    local first = parent:named_child(0)
    if first and first:id() == node:id() then return 'SET' end
    return 'GET'
end

local RULES = {}

RULES.go = {
    -- 目标是 x.f / x[i] 的基座时, 爬到整个表达式再判定:
    -- s.count = 0 是对 count 的写, arr[i] = 1 是对 arr 的写
    climb = { selector_expression = 'field', index_expression = 'operand' },
    transparent = {
        expression_list = true, -- a, b = 1, 2
        -- 复合字面量 Foo{Bar: 1} 里的 key/value 各自还包了一层 literal_element,
        -- 不穿透的话 keyed_element 的 handler 根本看不到它们
        literal_element = true,
    },
    handlers = {
        assignment_statement   = lhs_is_set, -- 含 += -= 等复合赋值
        short_var_declaration  = lhs_is_set,
        range_clause           = lhs_is_set,
        inc_statement          = function() return 'SET' end, -- x++
        dec_statement          = function() return 'SET' end, -- x--
        var_spec               = function(f) return f == 'name' and 'DECL' or 'GET' end,
        const_spec             = function(f) return f == 'name' and 'DECL' or 'GET' end,
        call_expression        = function(f) return f == 'function' and 'CALL' or 'GET' end,
        keyed_element          = keyed,
        field_declaration      = function() return 'DECL' end,
        parameter_declaration  = function() return 'DECL' end,
        method_declaration     = function() return 'DECL' end,
        function_declaration   = function() return 'DECL' end,
        type_spec              = function() return 'DECL' end,
        unary_expression       = function(_, parent, _, src)
            -- &x 拿到可写引用, 算 SET 并在行尾标记
            local op = parent:child(0)
            if op and node_text(op, src) == '&' then return 'SET', '&' end
            return 'GET'
        end,
    },
}

RULES.lua = {
    climb = { dot_index_expression = 'field', method_index_expression = 'method',
              bracket_index_expression = 'table' },
    transparent = { variable_list = true, expression_list = true },
    handlers = {
        -- variable_list/expression_list 已被 transparent 穿透, 这里靠 field 区分
        assignment_statement = function(_, parent, node)
            local first = parent:named_child(0)
            -- 第一个命名子节点是 variable_list, node 若来自它就是写
            if first and first:id() == node:id() then return 'SET' end
            return 'GET'
        end,
        function_call        = function(f) return f == 'name' and 'CALL' or 'GET' end,
        function_declaration = function(f) return f == 'name' and 'DECL' or 'GET' end,
        field                = function(f) return f == 'name' and 'SET' or 'GET' end,
        parameters           = function() return 'DECL' end,
        for_generic_clause   = lhs_is_set,
        for_numeric_clause   = function(f) return f == 'name' and 'SET' or 'GET' end,
    },
}

RULES.python = {
    climb = { attribute = 'attribute', subscript = 'value' },
    transparent = { pattern_list = true, expression_list = true, tuple_pattern = true },
    handlers = {
        assignment            = lhs_is_set,
        augmented_assignment  = lhs_is_set,
        for_statement         = lhs_is_set,
        named_expression      = function(f) return f == 'name' and 'SET' or 'GET' end,
        call                  = function(f) return f == 'function' and 'CALL' or 'GET' end,
        keyword_argument      = function(f) return f == 'name' and 'SET' or 'GET' end,
        function_definition   = function(f) return f == 'name' and 'DECL' or 'GET' end,
        class_definition      = function(f) return f == 'name' and 'DECL' or 'GET' end,
        parameters            = function() return 'DECL' end,
        default_parameter     = function(f) return f == 'name' and 'DECL' or 'GET' end,
        typed_parameter       = function() return 'DECL' end,
    },
}

RULES.rust = {
    climb = { field_expression = 'field', index_expression = 'index' },
    handlers = {
        assignment_expression      = lhs_is_set,
        compound_assignment_expr   = lhs_is_set,
        let_declaration            = function(f) return f == 'pattern' and 'SET' or 'GET' end,
        call_expression            = function(f) return f == 'function' and 'CALL' or 'GET' end,
        field_initializer          = function(f) return f == 'field' and 'SET' or 'GET' end,
        parameter                  = function() return 'DECL' end,
        function_item              = function(f) return f == 'name' and 'DECL' or 'GET' end,
        field_declaration          = function() return 'DECL' end,
        reference_expression       = function(_, parent, _, src)
            -- &mut x 才是可写引用; 只读的 &x 归 GET
            if node_text(parent, src):match('^&%s*mut') then return 'SET', '&mut' end
            return 'GET'
        end,
    },
}

local ts_like = {
    climb = { member_expression = 'property', subscript_expression = 'object' },
    handlers = {
        assignment_expression           = lhs_is_set,
        augmented_assignment_expression = lhs_is_set,
        variable_declarator             = function(f) return f == 'name' and 'SET' or 'GET' end,
        update_expression               = function() return 'SET' end, -- x++ / x--
        call_expression                 = function(f) return f == 'function' and 'CALL' or 'GET' end,
        pair                            = keyed,
        for_in_statement                = lhs_is_set,
        function_declaration            = function(f) return f == 'name' and 'DECL' or 'GET' end,
        formal_parameters               = function() return 'DECL' end,
        required_parameter              = function() return 'DECL' end,
        public_field_definition         = function(f) return f == 'name' and 'DECL' or 'GET' end,
    },
}
RULES.javascript = ts_like
RULES.typescript = ts_like
RULES.tsx = ts_like

--------------------------------------------------------------------------------
-- 2. 单个引用位置的判定
--------------------------------------------------------------------------------

--- @return string kind, string|nil mark
local function classify(rule, node, src)
    -- 2.1 爬到完整目标表达式
    while true do
        local p = node:parent()
        if not p then break end
        local want = rule.climb and rule.climb[p:type()]
        if want and field_name(p, node) == want then
            node = p
        else
            break
        end
    end

    -- 2.2 穿透语法包装层 (Go 的 expression_list、Lua 的 variable_list 等)
    local parent = node:parent()
    while parent and rule.transparent and rule.transparent[parent:type()] do
        node = parent
        parent = node:parent()
    end
    if not parent then return 'GET', nil end

    -- 2.3 按父节点类型定性
    local handler = rule.handlers[parent:type()]
    if not handler then return 'GET', nil end
    local kind, mark = handler(field_name(parent, node), parent, node, src)
    return kind or 'GET', mark
end

--------------------------------------------------------------------------------
-- 3. 拉引用 + 按文件批量分类
--------------------------------------------------------------------------------

local function read_file(path)
    local fd = vim.uv.fs_open(path, 'r', 438)
    if not fd then return nil end
    local stat = vim.uv.fs_fstat(fd)
    if not stat then vim.uv.fs_close(fd) return nil end
    local data = vim.uv.fs_read(fd, stat.size, 0)
    vim.uv.fs_close(fd)
    return data
end

--- LSP 的 col 是 offset_encoding 单位 (默认 utf-16), treesitter 要字节列
local function to_byte_col(line, col, encoding)
    if not line or col == 0 then return col end
    local ok, byte = pcall(vim.str_byteindex, line, encoding, col, false)
    if ok and byte then return byte end
    return math.min(col, #line)
end

local function group_by_file(locations)
    local by_file, order = {}, {}
    for _, loc in ipairs(locations) do
        local uri = loc.uri or loc.targetUri
        local range = loc.range or loc.targetSelectionRange or loc.targetRange
        if uri and range then
            local path = vim.uri_to_fname(uri)
            if not by_file[path] then
                by_file[path] = {}
                table.insert(order, path)
            end
            table.insert(by_file[path], range)
        end
    end
    return by_file, order
end

-- documentHighlight 的 kind: 1=Text 2=Read 3=Write
local LSP_KIND = { [2] = 'GET', [3] = 'SET' }

--- 每个文件发一次 documentHighlight, 拿服务端算出的 Read/Write.
---
--- 实测 (gopls): 确实返回真的 Read/Write, 而且**不要求文件在 buffer 里打开** ——
--- 直接用 uri 发请求就能拿到结果, 所以不需要为每个引用文件 bufload.
--- 但 gopls 对一部分位置会返回 Text (例如 println(s.count)), Text 是"不确定"
--- 而不是"纯文本匹配"; 而且 LSP 根本没有 CALL / DECL 的概念.
--- 所以这里只作为主判据, 空缺交给 treesitter 补。
---
--- @param cb fun(hl_by_file: table<string, table<string, integer>>)
local function fetch_highlights(client, by_file, order, cb)
    local hl_by_file = {}
    if not client:supports_method('textDocument/documentHighlight') then
        return cb(hl_by_file)
    end

    local pending = #order
    if pending == 0 then return cb(hl_by_file) end

    for _, path in ipairs(order) do
        local first = by_file[path][1]
        local ok = client:request('textDocument/documentHighlight', {
            textDocument = { uri = vim.uri_from_fname(path) },
            position = { line = first.start.line, character = first.start.character },
        }, function(err, result)
            if not err and result then
                local m = {}
                for _, h in ipairs(result) do
                    if h.range and h.kind then
                        m[h.range.start.line .. ':' .. h.range.start.character] = h.kind
                    end
                end
                hl_by_file[path] = m
            end
            pending = pending - 1
            if pending == 0 then cb(hl_by_file) end
        end, 0)
        if not ok then
            pending = pending - 1
            if pending == 0 then cb(hl_by_file) end
        end
    end
end

--- 把 Location[] 分类; 返回 groups(按 kind)、flat(不分组时用)、以及判据来源
local function build_items(by_file, order, encoding, hl_by_file)
    local groups = { SET = {}, GET = {}, CALL = {}, DECL = {} }
    local flat = {}
    local classified_any = false
    local used_lsp = false
    local cwd = vim.uv.cwd() or ''

    for _, path in ipairs(order) do
        local ranges = by_file[path]
        local hl = hl_by_file[path]
        local data = read_file(path)
        if data then
            local lines = vim.split(data, '\n', { plain = true })
            local ft = vim.filetype.match({ filename = path }) or ''
            local lang = ts.language.get_lang(ft)
            local rule = lang and RULES[lang] or nil

            local root
            if rule then
                pcall(function()
                    local parser = ts.get_string_parser(data, lang)
                    local tree = parser and parser:parse(true)[1]
                    root = tree and tree:root() or nil
                end)
            end

            local rel = path:sub(1, #cwd) == cwd and path:sub(#cwd + 2) or vim.fn.fnamemodify(path, ':~')

            for _, range in ipairs(ranges) do
                local lnum = range.start.line + 1
                local raw = lines[lnum] or ''
                local bcol = to_byte_col(raw, range.start.character, encoding)
                local item = {
                    path = path,
                    rel  = rel,
                    lnum = lnum,
                    col  = bcol + 1, -- 1-based, 给 nvim_win_set_cursor 用时再 -1
                    text = vim.trim(raw),
                }

                -- treesitter 的判定 (语法层, 认识 CALL / DECL / &取址)
                local ts_kind, mark
                if root then
                    local ok, node = pcall(root.named_descendant_for_range, root,
                        range.start.line, bcol, range.start.line, bcol)
                    if ok and node then
                        ts_kind, mark = classify(rule, node, data)
                    end
                end

                -- LSP 的判定 (语义层, 读写最准)
                local lsp_kind = hl and LSP_KIND[hl[range.start.line .. ':' .. range.start.character]]

                -- 合并: LSP 说写就是写; LSP 说读时, 让 treesitter 把"调用"再挑出来;
                -- LSP 返回 Text 或没结果时, 完全交给 treesitter
                local kind
                if lsp_kind == 'SET' then
                    kind = 'SET'
                elseif lsp_kind == 'GET' then
                    kind = (ts_kind == 'CALL') and 'CALL' or 'GET'
                else
                    kind = ts_kind or 'GET'
                end
                if lsp_kind then used_lsp = true end
                if ts_kind or lsp_kind then classified_any = true end

                -- &x 传给别人: gopls 算 Read (语法上确实是读), 但被调方可以透过
                -- 指针写回来. 归类跟 LSP 走, 标记保留, 让人一眼看到
                item.mark = mark
                item.kind = kind

                table.insert(groups[kind], item)
                table.insert(flat, item)
            end
        end
    end

    local function sorter(a, b)
        if a.rel ~= b.rel then return a.rel < b.rel end
        return a.lnum < b.lnum
    end
    for _, list in pairs(groups) do table.sort(list, sorter) end
    table.sort(flat, sorter)

    return groups, flat, classified_any, used_lsp
end

--------------------------------------------------------------------------------
-- 4. 浮窗
--------------------------------------------------------------------------------

local function render(state)
    local lines, map, headers = {}, {}, {}

    if not state.grouped then
        table.insert(lines, string.format('%s References  %d', BULLET, #state.flat))
        headers[1] = 'GET'
        for _, it in ipairs(state.flat) do
            table.insert(lines, string.format('   %s:%d  %s', it.rel, it.lnum, it.text))
            map[#lines] = it
        end
        return lines, map, headers
    end

    for _, kind in ipairs(ORDER) do
        local items = state.groups[kind]
        if items and #items > 0 then
            local arrow = state.collapsed[kind] and '' or ''
            table.insert(lines, string.format('%s %s %s  %d', arrow, BULLET, kind, #items))
            headers[#lines] = kind
            if not state.collapsed[kind] then
                for _, it in ipairs(items) do
                    local mark = it.mark and ('  ' .. it.mark) or ''
                    table.insert(lines, string.format('   %s:%d  %s%s', it.rel, it.lnum, it.text, mark))
                    map[#lines] = it
                end
            end
            table.insert(lines, '')
        end
    end
    if #lines > 0 and lines[#lines] == '' then table.remove(lines) end
    return lines, map, headers
end

local ns = api.nvim_create_namespace('core_ref_kinds')

local function paint(buf, lines, map, headers)
    api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    for i, line in ipairs(lines) do
        local kind = headers[i]
        if kind then
            api.nvim_buf_set_extmark(buf, ns, i - 1, 0, {
                end_row = i - 1, end_col = #line,
                hl_group = HL_OF_KIND[kind] or 'Title',
            })
        elseif map[i] then
            -- 只把 path:lnum 染成 Comment, 代码本体保持 Normal
            local head = line:match('^(%s*[^%s]+:%d+)')
            if head then
                api.nvim_buf_set_extmark(buf, ns, i - 1, 0, {
                    end_row = i - 1, end_col = #head,
                    hl_group = 'RefKindPath',
                })
            end
            if map[i].mark then
                local s = #line - #map[i].mark
                api.nvim_buf_set_extmark(buf, ns, i - 1, s, {
                    end_row = i - 1, end_col = #line,
                    hl_group = 'RefKindMark',
                })
            end
        end
    end
end

local function open_window(state)
    local buf = api.nvim_create_buf(false, true)
    local origin_win = api.nvim_get_current_win()

    local lines, map, headers = render(state)
    local width = 0
    for _, l in ipairs(lines) do width = math.max(width, vim.fn.strdisplaywidth(l)) end
    width = math.max(60, math.min(width + 2, math.min(120, vim.o.columns - 8)))
    local height = math.max(1, math.min(#lines, math.floor(vim.o.lines * 0.6)))

    api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    paint(buf, lines, map, headers)
    vim.bo[buf].modifiable = false
    vim.bo[buf].filetype = 'refkinds'
    vim.bo[buf].bufhidden = 'wipe'

    local win = api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        row = math.floor((vim.o.lines - height) / 2) - 1,
        col = math.floor((vim.o.columns - width) / 2),
        style = 'minimal',
        border = 'rounded', -- 与全局 winborder 一致
        -- 标题带判据来源, 出了怪结果能一眼看出是谁判的
        title = string.format(' gR  %s  [%s] ', state.symbol, state.source),
        title_pos = 'center',
    })
    vim.wo[win].cursorline = true
    vim.wo[win].wrap = false

    local function close()
        if api.nvim_win_is_valid(win) then api.nvim_win_close(win, true) end
        if api.nvim_win_is_valid(origin_win) then api.nvim_set_current_win(origin_win) end
    end

    local function redraw()
        lines, map, headers = render(state)
        vim.bo[buf].modifiable = true
        api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.bo[buf].modifiable = false
        paint(buf, lines, map, headers)
    end

    local function current_item()
        return map[api.nvim_win_get_cursor(win)[1]]
    end

    local function jump(how)
        local it = current_item()
        if not it then return end
        close()
        vim.cmd("normal! m'") -- 压 jumplist, 保证 <C-o> 能回来
        local open = ({ edit = 'edit', split = 'split', vsplit = 'vsplit', tab = 'tabedit' })[how]
        vim.cmd(open .. ' ' .. vim.fn.fnameescape(it.path))
        pcall(api.nvim_win_set_cursor, 0, { it.lnum, it.col - 1 })
        vim.cmd('normal! zz')
        beacon.flash()
    end

    local function toggle_fold()
        if not state.grouped then return end
        local row = api.nvim_win_get_cursor(win)[1]
        local kind = headers[row]
        if not kind then
            -- 光标在条目上时, 折叠它所属的分组
            local it = map[row]
            kind = it and it.kind
        end
        if not kind then return end
        state.collapsed[kind] = not state.collapsed[kind]
        redraw()
        -- 把光标挪回该分组的标题行
        for i, k in pairs(headers) do
            if k == kind then pcall(api.nvim_win_set_cursor, win, { i, 0 }) break end
        end
    end

    local kopts = { buffer = buf, nowait = true, silent = true }
    vim.keymap.set('n', '<CR>', function() jump('edit') end, kopts)
    vim.keymap.set('n', 'o', function() jump('edit') end, kopts)
    vim.keymap.set('n', 's', function() jump('split') end, kopts)
    vim.keymap.set('n', 'v', function() jump('vsplit') end, kopts)
    vim.keymap.set('n', 't', function() jump('tab') end, kopts)
    vim.keymap.set('n', '<Tab>', toggle_fold, kopts)
    vim.keymap.set('n', 'q', close, kopts)
    vim.keymap.set('n', '<Esc>', close, kopts)

    api.nvim_create_autocmd('WinLeave', {
        buffer = buf, once = true,
        callback = function() vim.schedule(close) end,
    })

    -- 落在第一个条目上, 而不是标题行
    for i = 1, #lines do
        if map[i] then pcall(api.nvim_win_set_cursor, win, { i, 0 }) break end
    end
end

--------------------------------------------------------------------------------
-- 5. 入口
--------------------------------------------------------------------------------

-- 暴露给测试: 给一组 Location 直接拿分类结果, 可注入 documentHighlight 结果
function M._classify(locations, encoding, hl_by_file)
    local by_file, order = group_by_file(locations)
    return build_items(by_file, order, encoding, hl_by_file or {})
end

function M.show()
    local clients = vim.lsp.get_clients({ bufnr = 0, method = 'textDocument/references' })
    if #clients == 0 then
        vim.notify('No LSP client supports references', vim.log.levels.WARN)
        return
    end
    local client = clients[1]
    local encoding = client.offset_encoding or 'utf-16'
    local symbol = vim.fn.expand('<cword>')

    local params = vim.lsp.util.make_position_params(0, encoding)
    params.context = { includeDeclaration = true }

    client:request('textDocument/references', params, function(err, result)
        if err then
            vim.notify('references failed: ' .. tostring(err.message or err), vim.log.levels.ERROR)
            return
        end
        if not result or vim.tbl_isempty(result) then
            vim.notify('No references found for ' .. symbol, vim.log.levels.INFO)
            return
        end

        local by_file, order = group_by_file(result)
        fetch_highlights(client, by_file, order, function(hl_by_file)
            local groups, flat, classified_any, used_lsp =
                build_items(by_file, order, encoding, hl_by_file)
            vim.schedule(function()
                open_window({
                    symbol = symbol,
                    groups = groups,
                    flat = flat,
                    -- 一个位置都没能分类 (LSP 不给 kind 且语言没规则表 /
                    -- treesitter parser 缺失) 就退化成不分组列表, 不假装分好了
                    grouped = classified_any,
                    source = used_lsp and 'lsp' or (classified_any and 'ts' or 'none'),
                    collapsed = {},
                })
            end)
        end)
    end, 0)
end

return M
