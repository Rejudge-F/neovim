-- avante.nvim: Cursor-style AI sidebar (select code -> describe -> diff -> accept/reject)
--
-- Default provider is ACP (Agent Client Protocol) rather than a direct API
-- connection: it drives the local `claude` CLI, so auth/proxy/quota all come
-- from Claude Code itself. No credentials to configure.
--
-- The built-in claude-code ACP provider defaults to command "claude-agent-acp",
-- a package that does not exist on npm. The real adapter is
-- @zed-industries/claude-code-acp (binary: claude-code-acp), installed globally.

return {
    -- Repo moved to the avante-corp org, but the README still uses the
    -- yetone/* spec string everywhere. GitHub redirects; leave it.
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false, -- upstream explicitly warns: never set this to "*"
    build = vim.fn.has("win32") ~= 0
        and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
        or "make",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        -- Optional deps, all already installed here
        "nvim-telescope/telescope.nvim",             -- pickers (see selector.provider)
        "hrsh7th/nvim-cmp",                          -- input completion
        "nvim-tree/nvim-web-devicons",               -- icons
        "MeanderingProgrammer/render-markdown.nvim", -- sidebar markdown (file_types has "Avante")
        {
            -- Paste/drag images into the prompt. Without it
            -- Config.support_paste_image() is always false and the
            -- support_paste_from_clipboard flag below is dead config.
            "HakonHarnes/img-clip.nvim",
            event = "VeryLazy",
            opts = {
                default = {
                    embed_image_as_base64 = false,
                    prompt_for_file_name = false,
                    drag_and_drop = { insert_mode = true },
                    use_absolute_path = true,
                },
            },
        },
    },
    opts = {
        instructions_file = "AGENTS.md", -- reuse the repo's agent file, not a second avante.md

        provider = "opencode",
        -- Must be set, and must be a non-ACP provider. suggestion.lua:176 looks
        -- up `auto_suggestions_provider or provider` in Config.providers, so
        -- with the default nil it resolves to "claude-code" -- an ACP provider,
        -- absent from that table -- and ;as throws "Failed to find provider"
        -- from providers/init.lua:169.
        -- Caveat: this only decides *which* provider suggest() asks for. The
        -- dispatch at llm.lua:1781 keys off Config.provider alone and ignores
        -- opts.provider, so while an ACP provider is active every request goes
        -- to ACP and suggestions come back as chat prose that fails to decode.
        -- Suggestions only work after :AvanteSwitchProvider to an HTTP provider.
        auto_suggestions_provider = "llmbox-fast",
        acp_providers = {
            ["claude-code"] = {
                command = "claude-code-acp", -- built-in default (claude-agent-acp) does not exist
                args = {},
                -- NOTE: this env table is deep-merged with the built-in defaults,
                -- not a replacement. config.lua:558 already passes
                -- ANTHROPIC_API_KEY / ANTHROPIC_BASE_URL from os.getenv, so
                -- commenting them out below does not stop them being forwarded.
                env = {
                    NODE_NO_WARNINGS = "1",
                    -- HOME/USER are mandatory. acp_client.lua:420 claims to start
                    -- from the system environment but only passes PATH plus this
                    -- table to uv.spawn, which replaces the environment wholesale.
                    -- Without them the claude CLI cannot read the macOS keychain,
                    -- prints "Not logged in", and the adapter raises authRequired.
                    HOME = vim.uv.os_homedir(),
                    USER = vim.uv.os_get_passwd().username,
                    -- claude-code-acp reads CLAUDE_CODE_EXECUTABLE, not the
                    -- ACP_PATH_TO_* name avante passes. With the wrong name it
                    -- falls back to the cli.js bundled in claude-agent-sdk, whose
                    -- newest models are Opus 4.6 / Sonnet 4.5.
                    CLAUDE_CODE_EXECUTABLE = vim.fn.exepath("claude"),
                    ACP_PATH_TO_CLAUDE_CODE_EXECUTABLE = vim.fn.exepath("claude"),
                    ACP_PERMISSION_MODE = "bypassPermissions",
                },
            },
            -- opencode's ACP server. avante ships this provider (config.lua:580)
            -- but without env. Gives access to every model in
            -- ~/.config/opencode/opencode.json; session/new reports
            -- TraeV2/gpt-5.5 as current, TraeSol/gpt-5.6-sol among the options.
            ["opencode"] = {
                command = "opencode",
                -- Never add "--pure": it skips ~/.config/opencode/plugins/, and
                -- gpt-5.5 / gpt-5.6-sol are not OpenAI-protocol gateways -- the
                -- traesol/traev2 shims there do the URL rewrite, Cloud-CLI-JWT
                -- auth, body transform and SSE normalisation.
                args = { "acp" },
                env = {
                    NODE_NO_WARNINGS = "1",
                    -- Same spawn-env trap as above, different symptom: without
                    -- HOME opencode never reads opencode.json and only offers its
                    -- built-in free models.
                    HOME = vim.uv.os_homedir(),
                    USER = vim.uv.os_get_passwd().username,
                },
            },
        },

        -- Non-ACP providers. These use avante's own tools, so they get the
        -- in-buffer diff with A/a accept-reject that ACP mode does not have
        -- (ACP agents write straight to disk, llm.lua:1306).
        -- Internal llmbox speaks plain OpenAI; no gpt-5.5/5.6 there.
        providers = {
            ["llmbox-gpt54"] = {
                __inherited_from = "openai",
                endpoint = "https://llmbox.bytedance.net/v1",
                model = "gpt-5.4",
                -- api_key_name supports a "cmd:" prefix (providers/init.lua:53),
                -- so reuse the sk cache opencode's auto-jwt-refresh maintains.
                api_key_name = "cmd:jq -r .sk ~/.delta/auth/sk-cache.json",
                timeout = 120000,
                context_window = 272000,
            },
            ["llmbox-codex"] = {
                __inherited_from = "openai",
                endpoint = "https://llmbox.bytedance.net/v1",
                model = "gpt-5.3-codex",
                api_key_name = "cmd:jq -r .sk ~/.delta/auth/sk-cache.json",
                timeout = 120000,
                context_window = 272000,
            },
            -- Inline completion needs latency, not depth. Measured round trips
            -- on this gateway: gpt-5.2 at effort "low" 2.0s, deepseek-v4-flash
            -- 4.6s (it burns time on reasoning_content). "minimal" effort is
            -- rejected upstream (unsupported_value).
            ["llmbox-fast"] = {
                __inherited_from = "openai",
                endpoint = "https://llmbox.bytedance.net/v1",
                model = "gpt-5.2",
                api_key_name = "cmd:jq -r .sk ~/.delta/auth/sk-cache.json",
                timeout = 30000,
                extra_request_body = { reasoning_effort = "low" },
                -- Mandatory here: the suggesting flow still ships avante's tool
                -- schemas, and the model answers with a `view` tool call instead
                -- of the <suggestions> block, which then fails to decode.
                disable_tools = true,
                hide_in_model_selector = true,
            },
            -- Fallback if the sk expires: modelhub at
            -- https://6elo122h.sg-fn.tiktok-row.net/v1/gpt54 needs no API key,
            -- just extra_headers = { ["X-LBS-USER"] = <username> }, but it only
            -- speaks the Responses API, so it also needs use_response_api = true.
        },

        behaviour = {
            -- Belongs under behaviour (config.lua:850); at the top level it is
            -- dead config. Default is already true.
            acp_follow_agent_locations = true,
            support_paste_from_clipboard = true, -- needs img-clip above
        },

        mappings = {
            -- Default is <C-s> in insert mode. Enter is the muscle memory from
            -- every chat UI, so submit on it and move newline to Shift/Alt-Enter
            -- (bound on the input buffer below).
            submit = {
                normal = "<CR>",
                insert = "<CR>",
            },
            sidebar = {
                -- Upstream defaults this to <S-Tab>, the same key as
                -- reverse_switch_windows (config.lua:930 vs :938), both on the
                -- result buffer. The expand mapping is bound whenever the cursor
                -- enters a tool block and deleted on the way out -- which takes
                -- the reverse-switch mapping with it. za is free here (the buffer
                -- has no real folds) and is the vim verb for "toggle fold",
                -- which is exactly what this does.
                expand_tool_use = "za",
            },
        },

        -- Default is "native" (vim.ui.select). file_selector is deprecated
        -- (file_selector.lua:201 warns); file picking goes through this too.
        selector = {
            provider = "telescope",
        },
        -- input.provider stays "native": health.lua:38 marks dressing deprecated.
    },
    config = function(_, opts)
        require("avante").setup(opts)

        -- Workaround (cd66452): config.lua:266 assigns the default straight onto
        -- the module table (M.instructions_file), while reads go through the
        -- __index metamethod at config.lua:1383. __index only fires for missing
        -- keys, so that field permanently shadows whatever setup() merged in.
        local cfg = require("avante.config")
        if opts.instructions_file and cfg.instructions_file ~= opts.instructions_file then
            cfg.instructions_file = opts.instructions_file
        end

        -- Inline markdown markers (**bold**, `code`, links) are concealed by the
        -- treesitter markdown_inline queries, not by render-markdown -- which
        -- only draws block elements (headings, bullets, code blocks) with its own
        -- extmarks. No parser is registered for the Avante filetypes, so the
        -- highlighter never starts and every marker stays visible. Verified:
        -- vim.treesitter.highlighter.active[bufnr] is nil before this, set after.
        -- The result window already has conceallevel=3, so registering is enough.
        vim.treesitter.language.register("markdown", { "Avante", "AvanteInput" })
        vim.api.nvim_create_autocmd("FileType", {
            pattern = { "Avante", "AvanteInput" },
            callback = function(ev) pcall(vim.treesitter.start, ev.buf, "markdown") end,
        })

        -- Enter submits now (mappings.submit above), so multi-line prompts need
        -- their own key. noremap, otherwise <CR> would hit the submit mapping
        -- sidebar.lua:3122 puts on this same buffer.
        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("AvanteInputNewline", { clear = true }),
            pattern = "AvanteInput",
            callback = function(ev)
                for _, key in ipairs({ "<S-CR>", "<M-CR>" }) do
                    vim.keymap.set("i", key, "<CR>", { buffer = ev.buf, desc = "avante: newline" })
                end
            end,
        })

        -- Todos land in their own bottom split (sidebar.lua:3492) as plain text:
        -- "[x] 1. thing", no colour, "~~cancelled~~" shows its literal tildes,
        -- and the window is pinned to 3 lines so a longer plan needs scrolling.
        -- Re-skin the buffer after avante fills it and size the window to fit.
        local Sidebar = require("avante.sidebar")
        local Path = require("avante.path")
        local todo_ns = vim.api.nvim_create_namespace("avante_todo_skin")
        local TODO_MARK = {
            ["x"] = { "✓", "AvanteTaskCompleted", "AvanteThoughtDim" }, -- glyph, glyph hl, text hl
            ["-"] = { "▶", "AvanteTaskRunning", nil },
            [" "] = { "○", "AvanteThoughtDim", nil },
        }

        local get_todos_container_height = Sidebar.get_todos_container_height
        function Sidebar:get_todos_container_height()
            if get_todos_container_height(self) == 0 then return 0 end
            local ok, history = pcall(Path.history.load, self.code.bufnr)
            if not ok or not history or not history.todos then return 3 end
            return math.max(1, math.min(#history.todos, 10))
        end

        local create_todos_container = Sidebar.create_todos_container
        function Sidebar:create_todos_container()
            create_todos_container(self)
            local container = self.containers and self.containers.todos
            if not container or not require("avante.utils").is_valid_container(container, true) then return end
            local ok, buf = pcall(vim.api.nvim_win_get_buf, container.winid)
            if not ok then return end

            local Utils = require("avante.utils")
            local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
            local out, marks = {}, {}
            for i, line in ipairs(lines) do
                local cancelled = line:match("^~~(.*)~~$")
                local body = cancelled or line
                local box, rest = body:match("^%[(.)%]%s*(.*)$")
                if box then
                    local mark = cancelled and { "✗", "AvanteTaskFailed", "AvanteThoughtDim" }
                        or (TODO_MARK[box] or TODO_MARK[" "])
                    out[i] = mark[1] .. " " .. rest
                    marks[i] = { glyph = mark[2], text = mark[3] }
                else
                    out[i] = line
                end
            end

            Utils.unlock_buf(buf)
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, out)
            vim.api.nvim_buf_clear_namespace(buf, todo_ns, 0, -1)
            for i, mark in pairs(marks) do
                pcall(vim.api.nvim_buf_set_extmark, buf, todo_ns, i - 1, 0, {
                    end_col = #(out[i]:match("^%S+") or ""), -- glyph is multi-byte
                    hl_group = mark.glyph,
                    priority = 200,
                })
                if mark.text then
                    pcall(vim.api.nvim_buf_set_extmark, buf, todo_ns, i - 1, 0, {
                        end_col = #out[i],
                        hl_group = mark.text,
                        priority = 199,
                    })
                end
            end
            Utils.lock_buf(buf)
        end

        local Render = require("avante.history.render")

        -- Tool headers are unreadable: history/render.lua:401 concatenates the
        -- ACP title with vim.inspect(param), so a heredoc git commit renders its
        -- whole body into the header line and every path shows up twice. Collapse
        -- to one line and drop the duplicated argument.
        local get_tool_display_name = Render.get_tool_display_name
        Render.get_tool_display_name = function(message)
            local name, err = get_tool_display_name(message)
            if err or type(name) ~= "string" then return name, err end
            name = name:gsub("%s+", " ") -- heredocs and multi-line commands
            -- Split off the vim.inspect(param) suffix. ACP titles already spell
            -- the command or path out, so there it is a duplicate; avante's own
            -- tools name only the verb, so there it is the only useful part.
            local prefix, arg = name:match('^(.-) ?%("(.*)"%)$')
            if not prefix then prefix, arg = name:match("^(.-) ?%('(.*)'%)$") end
            if prefix then
                name = prefix:find(arg, 1, true) and prefix or (prefix .. " " .. arg)
            end
            if vim.fn.strchars(name) > 200 then name = vim.fn.strcharpart(name, 0, 199) .. "…" end
            return name, nil
        end

        -- Rewrite the tool header into
        --   ╭─ BASH succeeded
        --   │   git diff master...origin/feat/x -- hook.go
        --   │   <output>
        -- history/render.lua:437 builds it as
        --   { "╭─ " } { " <name> ", STATE_HL } { " <state>" }
        -- where <name> is the whole command and STATE_HL is a badge (dark fg on a
        -- solid bg), so any real command wraps and drags a block of colour across
        -- two rows, ending mid-word. Keep only the tool kind up there, colour the
        -- state word with a foreground-only group, and move the command down into
        -- the body. The header is never the last line of a tool block
        -- (render.lua:518 always appends one), so the ╰─ rewrite at :530 still
        -- lands where it should.
        local Line = require("avante.ui.line")
        local STATE_HL = {
            succeeded = "AvanteTaskCompleted", -- green
            failed = "AvanteTaskFailed",       -- red
            generating = "AvanteTaskRunning",  -- purple, still running
        }

        -- Real tool name, e.g. Bash / Edit / Glob. claude-code-acp reports it
        -- under _meta (Read arrives as "mcp__acp__Read"); ACP `kind` is the
        -- coarse fallback ("execute", "read"), then avante's own tool name.
        local function tool_label(message)
            local acp = message and message.acp_tool_call
            local name = acp and acp._meta and acp._meta.claudeCode and acp._meta.claudeCode.toolName
            if type(name) == "string" then name = name:gsub("^mcp__.-__", "") end
            if not name or name == "" then name = acp and acp.kind end
            if not name or name == "" then
                local content = message and message.message and message.message.content
                if type(content) == "table" and vim.islist(content) and type(content[1]) == "table" then
                    name = content[1].name
                end
            end
            return tostring(name or "tool"):upper()
        end

        -- Clip to the sidebar width so neither row wraps. Display width, not
        -- character count: paths and ACP titles can carry double-width characters.
        local function sidebar_width()
            local ok, sidebar = pcall(function() return require("avante").get() end)
            local container = ok and sidebar and sidebar.containers and sidebar.containers.result
            local winid = container and container.winid
            if winid and vim.api.nvim_win_is_valid(winid) then return vim.api.nvim_win_get_width(winid) end
            return vim.o.columns
        end

        -- Binary search on the assembled string, not on a width budget: the
        -- display width of prefix .. text is not the sum of the two parts.
        local function clip(prefix, text)
            local width = sidebar_width()
            if vim.fn.strdisplaywidth(prefix .. text) <= width then return text end
            local lo, hi = 0, vim.fn.strchars(text)
            while lo < hi do
                local mid = math.floor((lo + hi + 1) / 2)
                if vim.fn.strdisplaywidth(prefix .. vim.fn.strcharpart(text, 0, mid) .. "…") <= width then
                    lo = mid
                else
                    hi = mid - 1
                end
            end
            return vim.fn.strcharpart(text, 0, lo) .. "…"
        end

        local function rewrite_tool_header(lines, message)
            local out = {}
            for _, line in ipairs(lines) do
                local s = type(line) == "table" and line.sections
                if
                    type(s) == "table"
                    and #s >= 3
                    and type(s[1]) == "table"
                    and s[1][1] == "╭─ "
                    and type(s[2]) == "table"
                    and type(s[3]) == "table"
                    and type(s[3][1]) == "string"
                then
                    local state = vim.trim(s[3][1])
                    local label = tool_label(message)
                    table.insert(out, Line:new({ s[1], { label .. " " }, { state, STATE_HL[state] } }))

                    -- Command line: drop the backticks ACP wraps commands in, and
                    -- the leading verb when it just repeats the label above.
                    -- Strip the backticks separately: a long title is already
                    -- truncated, so the closing one is often gone.
                    local arg = vim.trim(s[2][1]):gsub("^`", ""):gsub("`$", "")
                    local without_verb = arg:gsub("^%a+%s+", "")
                    if arg:upper():find(label, 1, true) == 1 and without_verb ~= "" then arg = without_verb end
                    if arg ~= "" then
                        table.insert(out, Line:new({ { "│   " }, { clip("│   ", arg) } }))
                    end
                else
                    table.insert(out, line)
                end
            end
            return out
        end

        -- Reasoning is background noise, not the answer: drop the
        -- "🤔 Thought content:" header (render.lua:98) with the blank line under
        -- it and dim the body. The text is emitted as "> " quoted lines, so
        -- treesitter paints it @markup.quote; Line:set_highlights goes through
        -- vim.highlight.range at user priority (200), which outranks treesitter
        -- (100), so this wins without touching any shared group.
        local function set_thought_color()
            -- Normal is #d9d9d9 and NonText #727272; go below both so reasoning
            -- clearly recedes behind the answer.
            vim.api.nvim_set_hl(0, "AvanteThoughtDim", { fg = "#5c5c5c" })
        end
        set_thought_color()
        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("AvanteThoughtColors", { clear = true }),
            callback = vim.schedule_wrap(set_thought_color),
        })

        local function dim_thoughts(lines)
            local out = {}
            for _, line in ipairs(lines) do
                local text = tostring(line)
                local header = text:find("Thought content:", 1, true) ~= nil
                -- #out == 0 means the blank line that trailed the dropped header
                if not header and not (#out == 0 and vim.trim(text) == "") then
                    local sections = {}
                    for _, sec in ipairs(line.sections or {}) do
                        sections[#sections + 1] = { sec[1], sec[2] or "AvanteThoughtDim" }
                    end
                    out[#out + 1] = Line:new(sections)
                end
            end
            return out
        end

        -- ACP agents also emit thought chunks with no text at all; those used to
        -- render as a bare header plus a blank line. Returning {} is already how
        -- hidden messages are handled (sidebar.lua:2020).
        local message_to_lines = Render.message_to_lines
        Render.message_to_lines = function(message, messages, expanded)
            local content = message and message.message and message.message.content
            local thinking, blank = false, false
            if type(content) == "table" then
                local items = vim.islist(content) and content or { content }
                if #items > 0 then
                    thinking, blank = true, true
                    for _, item in ipairs(items) do
                        local text
                        if type(item) == "table" and item.type == "thinking" then
                            text = item.thinking or item.data
                        end
                        if type(text) ~= "string" then
                            thinking, blank = false, false
                            break
                        end
                        if text:match("%S") then blank = false end
                    end
                end
            end
            if thinking and blank then return {} end
            local lines = message_to_lines(message, messages, expanded)
            if thinking then return dim_thoughts(lines) end
            return rewrite_tool_header(lines, message)
        end
    end,
    -- Keys (leader = ";"):
    --   ;az Zen Mode (full-screen chat)   ;aa ask   ;an new chat   ;ah history
    --   ;aM ACP model   ;am ACP mode   ;ac add current file
    --   In sidebar: x toggle code window, @ add file, A/a apply diff,
    --   <S-Tab> expand tool call, <C-s> submit from insert, q close
    --
    -- :AvanteSwitchProvider {claude-code|opencode|llmbox-gpt54|llmbox-codex}
    --   claude-code  default; fastest (initialize 224ms, session/new 437ms)
    --   opencode     only route to gpt-5.5 / gpt-5.6-sol, pick with ;aM;
    --                slow to start (2.4s + 7.8s) since it loads opencode.json,
    --                10 plugins and MCP
    --   llmbox-*     non-ACP, so in-buffer diff and A/a accept-reject work
}
