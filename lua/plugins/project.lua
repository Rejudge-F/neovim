return {
    "ahmedkhalf/project.nvim",
    lazy = true,  -- 只在使用 Telescope projects 时加载
    config = function()
        require("project_nvim").setup {}
    end
}
