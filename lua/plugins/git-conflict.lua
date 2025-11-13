return {
    'akinsho/git-conflict.nvim',
    event = "BufReadPost",  -- 打开文件后才加载
    config = function()
        require('git-conflict').setup()
    end
}
