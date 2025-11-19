return {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  -- 只在无参数启动时加载 Dashboard（不打开文件时）
  cond = function()
    return vim.fn.argc() == 0
  end,
  config = function()
    require('dashboard').setup {
      -- config
    }
  end,
  dependencies = { {'nvim-tree/nvim-web-devicons'}}
}
