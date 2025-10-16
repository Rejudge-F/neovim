return {
    "michaelb/sniprun",
    branch = "master",
    build = "sh install.sh",
    cmd = { "SnipRun", "SnipRunOperator" },  -- 只在使用命令时加载
    keys = { "<leader>r" },  -- 如果有快捷键的话
    -- do 'sh install.sh 1' if you want to force compile locally
    -- (instead of fetching a binary from the github release). Requires Rust >= 1.65
    config = function()
        require("sniprun").setup({
            display = { "Classic" },
        })
    end,
}
