return {
   "amitds1997/remote-nvim.nvim",
   version = "*", -- Pin to GitHub releases
   cmd = { "RemoteStart", "RemoteStop", "RemoteInfo" },  -- 仅在使用远程命令时加载
   dependencies = {
       "nvim-lua/plenary.nvim", -- For standard functions
       "MunifTanjim/nui.nvim", -- To build the plugin UI
       "nvim-telescope/telescope.nvim", -- For picking b/w different remote methods
   },
   config = true,
}
