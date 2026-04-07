-- Enhanced LSP hover: 在原 hover 文档下方拼接函数源码
-- 用法: require('core.enhanced_hover').show()
--
-- 工作流程:
--   1. 并发发起 textDocument/hover 和 textDocument/definition 请求
--   2. hover 拿 markdown 文档 (signature + docstring)
--   3. definition 拿目标位置, 然后读取目标文件读出整个函数体源码
--   4. 把代码作为代码块拼到 hover markdown 末尾, 一次性 open_floating_preview
--
-- 失败退化: hover 失败但 definition 成功 -> 只显示代码; 都失败 -> notify

local M = {}

local lsp_util = vim.lsp.util

-- 把 hover.contents (五种 LSP shape 之一) 转成 markdown 行
local function contents_to_lines(contents)
    if type(contents) == "string" then
        return vim.split(contents, "\n", { trimempty = true })
    end
    if type(contents) == "table" then
        if contents.kind then
            -- MarkupContent
            return vim.split(contents.value or "", "\n", { trimempty = true })
        end
        if contents.language then
            -- MarkedString-pair
            local lines = { "```" .. contents.language }
            vim.list_extend(lines, vim.split(contents.value or "", "\n", { trimempty = true }))
            table.insert(lines, "```")
            return lines
        end
        -- MarkedString[] (string 或 pair)
        local lines = {}
        for _, item in ipairs(contents) do
            vim.list_extend(lines, contents_to_lines(item))
        end
        return lines
    end
    return {}
end

-- 给定文件 URI 和 LSP Range, 读取 range 范围内的代码
-- 如果 range 是单行 (只覆盖标识符), 用 treesitter 找包围函数节点
local function read_definition_source(uri, range, max_lines)
    max_lines = max_lines or 60
    local fname = vim.uri_to_fname(uri)
    if vim.fn.filereadable(fname) == 0 then return nil, nil end

    local fd = vim.uv.fs_open(fname, "r", 438)
    if not fd then return nil, nil end
    local stat = vim.uv.fs_fstat(fd)
    if not stat then vim.uv.fs_close(fd) return nil, nil end
    local data = vim.uv.fs_read(fd, stat.size, 0)
    vim.uv.fs_close(fd)
    if not data then return nil, nil end

    local all_lines = vim.split(data, "\n", { plain = true })
    local start_line = range.start.line + 1 -- 1-indexed
    local end_line = range["end"].line + 1
    local ft = vim.filetype.match({ filename = fname }) or ""

    -- 如果 LSP 给的 range 已经覆盖多行 (>=2 行), 说明就是完整 range, 直接用
    -- 否则尝试用 treesitter 扩展到包围函数节点
    if end_line - start_line < 1 then
        pcall(function()
            if not vim.treesitter.language.get_lang(ft) then return end
            local parser = vim.treesitter.get_string_parser(data, ft)
            if not parser then return end
            local tree = parser:parse(true)[1]
            if not tree then return end
            local root = tree:root()

            -- 判断节点是否是"函数级别"的定义节点 (排除 parameter_declaration 等)
            local function is_function_node(t)
                return t == "function_declaration"        -- Go
                    or t == "method_declaration"          -- Go
                    or t == "function_definition"         -- C/C++/Python
                    or t == "method_definition"           -- TS/JS
                    or t == "function_item"               -- Rust
                    or t == "method_item"                 -- Rust
                    or t == "function"                    -- Lua
                    or t == "local_function"              -- Lua
                    or t == "function_declaration_statement" -- some grammars
                    or t == "arrow_function"              -- TS/JS
                    or t == "function_expression"         -- JS
                    or t == "constructor_declaration"     -- Java/C#
                    or t == "func_definition"             -- misc
            end

            -- 自顶向下找包围 start_line 的最外层 function 节点
            local found
            local function visit(node)
                local sr, _, er, _ = node:range()
                sr, er = sr + 1, er + 1
                if sr > start_line or start_line > er then return end
                if is_function_node(node:type()) then
                    found = node
                    return -- 找到外层就停, 不再往里钻 (避免嵌套函数取到内层)
                end
                for child in node:iter_children() do
                    if found then return end
                    visit(child)
                end
            end
            visit(root)

            if found then
                local sr, _, er, _ = found:range()
                start_line = sr + 1
                end_line = er + 1
            end
        end)
    end

    -- 限制最大行数
    if end_line - start_line + 1 > max_lines then
        end_line = start_line + max_lines - 1
    end
    end_line = math.min(#all_lines, end_line)

    local snippet = {}
    for i = start_line, end_line do
        table.insert(snippet, all_lines[i] or "")
    end
    return snippet, ft
end

-- 主入口: 自定义 K
function M.show()
    local clients = vim.lsp.get_clients({ bufnr = 0, method = "textDocument/hover" })
    if #clients == 0 then
        vim.lsp.buf.hover() -- 无 hover capability, 走原生 (会 notify)
        return
    end
    local client = clients[1]
    local params = vim.lsp.util.make_position_params(0, client.offset_encoding or "utf-16")

    local hover_done, def_done = false, false
    local hover_lines, def_lines, def_ft

    local function maybe_render()
        if not (hover_done and def_done) then return end
        local contents = {}
        if hover_lines and #hover_lines > 0 then
            vim.list_extend(contents, hover_lines)
        end
        if def_lines and #def_lines > 0 then
            if #contents > 0 then
                table.insert(contents, "")
                table.insert(contents, "---")
                table.insert(contents, "")
            end
            table.insert(contents, "**Definition:**")
            table.insert(contents, "```" .. (def_ft or ""))
            vim.list_extend(contents, def_lines)
            table.insert(contents, "```")
        end
        if #contents == 0 then
            vim.notify("No hover or definition", vim.log.levels.INFO)
            return
        end
        lsp_util.open_floating_preview(contents, "markdown", {
            focus_id = "enhanced_hover",
            max_width = 100,
            max_height = 30,
        })
    end

    -- hover request
    client:request("textDocument/hover", params, function(err, result)
        if not err and result and result.contents then
            hover_lines = contents_to_lines(result.contents)
        end
        hover_done = true
        vim.schedule(maybe_render)
    end, 0)

    -- definition request
    client:request("textDocument/definition", params, function(err, result)
        if not err and result then
            -- result 可以是 Location | LocationLink | 数组
            local first
            if result.uri or result.targetUri then
                first = result
            elseif type(result) == "table" and #result > 0 then
                first = result[1]
            end
            if first then
                local uri = first.uri or first.targetUri
                -- LocationLink: targetRange 是完整范围 (含函数体), targetSelectionRange 只是标识符
                -- 优先用 targetRange 才能拿到整个函数
                local range = first.targetRange or first.range or first.targetSelectionRange
                if uri and range then
                    def_lines, def_ft = read_definition_source(uri, range)
                end
            end
        end
        def_done = true
        vim.schedule(maybe_render)
    end, 0)
end

return M
