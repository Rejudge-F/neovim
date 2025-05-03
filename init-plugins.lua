return {
    -- 文件树类
    { import = "plugins.neo-tree" },
    { import = "plugins.nvim-tree" },

    -- 搜索/导航类
    { import = "plugins.telescope" },
    { import = "plugins.flash" },
    { import = "plugins.nvim-window-picker" },

    -- 语法/代码处理
    { import = "plugins.nvim-treesitter" },
    { import = "plugins.nvim-treesitter-textobjects" },
    { import = "plugins.nvim-treesitter-context" },
    { import = "plugins.nvim-autopairs" },
    { import = "plugins.easy-align" },
    { import = "plugins.vim-surround" },
    { import = "plugins.neogen" },

    -- LSP/DAP
    { import = "plugins.nvim-lspconfig" },
    { import = "plugins.neodim" },
    { import = "plugins.nvim-dap" },
    { import = "plugins.nvim-dap-ui" },

    -- 界面增强
    { import = "plugins.bufferline" },
    { import = "plugins.nvim-lualine" },
    { import = "plugins.indent-blankline" },
    { import = "plugins.symbols-outline" },
    { import = "plugins.codewindow" },
    { import = "plugins.seoul256" },

    -- Git相关
    { import = "plugins.gitsigns" },
    { import = "plugins.git-conflict" },
    { import = "plugins.diffview" },
    { import = "plugins.lazygit" },

    -- 格式/排版
    { import = "plugins.conform" },
    { import = "plugins.render-markdown" },

    -- 实用工具
    { import = "plugins.toggleterm" },
    { import = "plugins.project" },
    { import = "plugins.trouble" },
    { import = "plugins.nvim-lastplace" },
    { import = "plugins.nvim-ufo" },

    -- 语言特定
    { import = "plugins.thrift" },

    -- 其他
    { import = "plugins.winsurf" }
}
