return {
    "rcarriga/nvim-dap-ui",
    tag = "v4.0.0",
    lazy = true,  -- DAP 启动时才加载
    dependencies = {
        "nvim-neotest/nvim-nio",
        "mfussenegger/nvim-dap"
    },
    config = function()
    end
}
