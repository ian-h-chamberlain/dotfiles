-- Adapted from https://github.com/sitiom/nvim-numbertoggle

local augroup = vim.api.nvim_create_augroup("numbertoggle", {})

vim.api.nvim_create_autocmd(
    -- { "BufEnter", "FocusGained", "InsertLeave", "CmdlineLeave", "WinEnter", "BufWinEnter" },
    "WinEnter",
    {
        pattern = "*",
        group = augroup,
        callback = function(evt)
            -- vim.print("enable relnu", evt)
            if vim.api.nvim_get_mode().mode ~= "i" then
                vim.opt_local.relativenumber = true
                -- Seems that in vscode-neovim this is not automatically
                -- executed for some reason... Possibly a neovim bug?
                vim.api.nvim_exec_autocmds("OptionSet", { pattern = "relativenumber" })
                vim.cmd.redraw()
            end
        end,
    }
)

vim.api.nvim_create_autocmd(
    -- { "BufLeave", "FocusLost", "InsertEnter", "CmdlineEnter", "WinLeave", "BufWinLeave", },
    "WinLeave",
    {
        pattern = "*",
        group = augroup,
        callback = function(evt)
            -- vim.print("disable relnu", evt)
            vim.opt_local.relativenumber = false
            vim.api.nvim_exec_autocmds("OptionSet", { pattern = "relativenumber" })
            vim.cmd.redraw()
        end,
    }
)
