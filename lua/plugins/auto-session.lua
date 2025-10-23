return {
  "rmagatti/auto-session",
  lazy = false, -- 确保在启动时加载
  opts = {
    -- Session 保存目录
    auto_session_root_dir = vim.fn.stdpath("data") .. "/sessions/",

    -- 自动保存 session
    auto_save_enabled = true,

    -- 自动恢复 session（关键配置）
    auto_restore_enabled = true,

    -- 即使传入文件参数也恢复 session
    auto_restore_lazy_delay_enabled = true,

    -- 允许在指定目录时也恢复 session
    args_allow_single_directory = true,

    -- 允许即使打开文件时也恢复 session
    args_allow_files_auto_save = true,

    -- 按当前工作目录自动管理 session
    auto_session_use_git_branch = false,

    -- 在这些目录不自动保存/恢复
    auto_session_suppress_dirs = {
      "~/",
      "~/Downloads",
      "~/Desktop",
      "/",
    },

    -- 保存前关闭某些窗口类型
    auto_session_close_on_save = true,

    -- session 搜索界面配置
    session_lens = {
      buftypes_to_ignore = {},
      load_on_setup = true,
      theme_conf = { border = true },
      previewer = false,
    },
  },

  keys = {
    -- 保存当前 session
    {
      "<leader>ses",
      "<cmd>SessionSave<cr>",
      desc = "Session: Save",
    },
    -- 恢复 session
    {
      "<leader>ser",
      "<cmd>SessionRestore<cr>",
      desc = "Session: Restore",
    },
    -- 搜索并切换 session
    {
      "<leader>sef",
      "<cmd>SessionSearch<cr>",
      desc = "Session: Find/Search",
    },
    -- 删除 session
    {
      "<leader>sed",
      "<cmd>SessionDelete<cr>",
      desc = "Session: Delete",
    },
  },
}
