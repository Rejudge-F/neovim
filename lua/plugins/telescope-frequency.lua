return {
  "nvim-telescope/telescope-frecency.nvim",
  -- install the latest stable version
  version = "*",
  lazy = true,  -- 让 telescope 加载时再加载这个扩展
  config = function()
    require("telescope").load_extension "frecency"
  end,
}
