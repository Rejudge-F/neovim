return {
    "greggh/claude-code.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim", -- Required for git operations
    },
    config = function()
        require("claude-code").setup()
        vim.keymap.set("n", "<leader>cd", ":ClaudeCode<CR>", { desc = "Open Claude Code" })
    end
}
