-- avante.nvim: Cursor 风格的 AI 侧栏 (选中代码 -> 描述需求 -> diff -> 接受/拒绝)
--
-- 走 ACP (Agent Client Protocol) 而不是直连 API, 原因是本机没有
-- ANTHROPIC_API_KEY, 只有 ANTHROPIC_BASE_URL + ANTHROPIC_AUTH_TOKEN (内部代理),
-- 而 avante 的 claude provider 把 key 当 x-api-key 发, 代理认不认得实测才知道.
-- ACP 模式直接驱动本机已经能用的 claude CLI, 认证/代理/配额全部沿用 Claude Code
-- 自己那套, 零凭证配置.
--
-- 注意: avante 内置的 claude-code ACP provider 默认 command = "claude-agent-acp",
-- 这个包在公共 npm 上不存在 (404). 真正的适配器是
-- @zed-industries/claude-code-acp, 二进制名 claude-code-acp, 已全局安装:
--   npm install -g @zed-industries/claude-code-acp
-- 所以下面显式覆盖了 command 和 env.

return {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false, -- 官方明确警告: 绝对不要设成 "*"
    build = "make",  -- 拉预编译二进制 (走 curl+tar), 失败时用 cargo 本地编译
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        -- 以下都是可选依赖, 但本配置里已经装了, 直接接上
        "nvim-telescope/telescope.nvim",             -- 文件/模型 picker
        "hrsh7th/nvim-cmp",                          -- 输入框补全
        "nvim-tree/nvim-web-devicons",               -- 图标
        "MeanderingProgrammer/render-markdown.nvim", -- 侧栏 markdown 渲染
        -- (file_types 已加 "Avante")
    },
    opts = {
        -- 项目级指令文件. 沿用 CLAUDE.md, 免得同一个仓库维护两份说明
        instructions_file = "CLAUDE.md",

        provider = "claude-code", -- 用下面这个 ACP provider, 不是直连 API
        acp_providers = {
            ["claude-code"] = {
                command = "claude-code-acp", -- 覆盖内置的 claude-agent-acp (不存在)
                args = {},
                env = {
                    NODE_NO_WARNINGS = "1",
                    -- 必须手动补 HOME / USER, 否则 ACP 一律报 "Authentication required".
                    -- acp_client.lua:422 那句注释 "Start with system environment" 是骗人的:
                    -- 它只往 final_env 里塞了 PATH + 本表的内容, 然后交给 uv.spawn ——
                    -- uv.spawn 给了 env 就是整个替换, 不是叠加. 于是子进程里没有 HOME/USER,
                    -- claude CLI 找不到 macOS 钥匙串里的 OAuth 凭据, 输出
                    -- "Not logged in · Please run /login", claude-code-acp 的
                    -- acp-agent.js:381/451 匹配到这句话就抛 RequestError.authRequired().
                    -- 实测 (env -i PATH=... claude -p): 只给 HOME 不够, HOME+USER 才 OK.
                    HOME = vim.uv.os_homedir(),
                    USER = vim.uv.os_get_passwd().username,
                    -- 本机是 AUTH_TOKEN 而非 API_KEY, 两个都透传,
                    -- 让 claude CLI 自己按它的优先级去挑
                    -- ANTHROPIC_AUTH_TOKEN = os.getenv("ANTHROPIC_AUTH_TOKEN"),
                    -- ANTHROPIC_API_KEY    = os.getenv("ANTHROPIC_API_KEY"),
                    -- ANTHROPIC_BASE_URL   = os.getenv("ANTHROPIC_BASE_URL"),
                    -- 必须是 CLAUDE_CODE_EXECUTABLE, 不是 avante 内置的那个名字!
                    -- claude-code-acp 0.16.2 的 acp-agent.js:794 读的是
                    -- process.env.CLAUDE_CODE_EXECUTABLE; avante 内置配置传的
                    -- ACP_PATH_TO_CLAUDE_CODE_EXECUTABLE 它根本不读. 名字对不上时
                    -- pathToClaudeCodeExecutable 为 undefined, agent-sdk 会回退到
                    -- 自己内嵌的那份 cli.js (claude-agent-sdk 0.2.44, 被 acp 钉死),
                    -- 那份的模型最高只到 Opus 4.6 / Sonnet 4.5 —— 这就是 ;aM
                    -- 里全是旧模型的原因. 实测: 不设这个变量拿到 0 个模型,
                    -- 设了拿到 6 个 (opus[1m] / fable-5[1m] / sonnet[1m] / haiku ...).
                    CLAUDE_CODE_EXECUTABLE = vim.fn.exepath("claude"),
                    -- 保留一份, 万一以后版本改成读这个名字
                    ACP_PATH_TO_CLAUDE_CODE_EXECUTABLE = vim.fn.exepath("claude"),
                    ACP_PERMISSION_MODE = "bypassPermissions",
                },
            },
        },

        -- ACP agent 改文件时自动跳过去看
        acp_follow_agent_locations = true,
    },
    config = function(_, opts)
        require("avante").setup(opts)

        -- avante bug workaround (实测于 cd66452):
        -- config.lua:266 把默认值直接赋在模块表上 (M.instructions_file = "avante.md"),
        -- 而读取靠的是 config.lua:1383 的 __index 元方法 —— Lua 的 __index 只在 key
        -- 不存在时触发, 所以 setup() 合并进 M._options 的值被那个字段永久遮蔽,
        -- 表现为 instructions_file 怎么配都不生效. 这里直接把字段盖掉.
        local cfg = require("avante.config")
        if opts.instructions_file and cfg.instructions_file ~= opts.instructions_file then
            cfg.instructions_file = opts.instructions_file
        end
    end,
}
