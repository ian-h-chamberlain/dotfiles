-- Adapted from https://github.com/sitiom/nvim-numbertoggle

local augroup = vim.api.nvim_create_augroup("numbertoggle", {})

vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "CmdlineLeave", "WinEnter", "BufWinEnter" }, {
    pattern = "*",
    group = augroup,
    callback = function(evt)
        -- Skip if vim.o.number is unset, for e.g. PR comment editor
        if vim.api.nvim_get_mode().mode ~= "i" and vim.o.number then
            vim.o.relativenumber = true
            -- Seems that in vscode-neovim this is not automatically
            -- executed for some reason... Possibly a neovim bug?
            vim.api.nvim_exec_autocmds("OptionSet", { pattern = "relativenumber" })
            vim.cmd.redraw()
        end
    end,
})

vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "CmdlineEnter", "WinLeave", "BufWinLeave" }, {
    pattern = "*",
    group = augroup,
    callback = function(evt)
        -- Skip if vim.o.number is unset, for e.g. PR comment editor
        if vim.o.number then
            vim.o.relativenumber = false
            vim.api.nvim_exec_autocmds("OptionSet", { pattern = "relativenumber" })
            vim.cmd.redraw()
        end
    end,
})
