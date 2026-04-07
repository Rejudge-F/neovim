return {
  dir = "~/projects/md-preview.nvim",
  ft = "markdown",
  cmd = { "MarkdownPreview", "MarkdownPreviewToggle", "MarkdownPreviewBuild" },
  build = "cd server && npm install",
  keys = { { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown preview" } },
  opts = {},
}
