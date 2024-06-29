-- Adapted from https://github.com/sitiom/nvim-numbertoggle

local augroup = vim.api.nvim_create_augroup("numbertoggle", {})

local function enable_relativenumber(evt)
    if vim.wo.number and vim.api.nvim_get_mode().mode ~= "i" then
        vim.wo.relativenumber = true
    end
end

local function disable_relativenumber(evt)
    local cur_win = vim.api.nvim_get_current_win()
    local window_opt = vim.wo[cur_win]

    if evt and evt.event == "WinLeave" then
        -- print(
        --     os.date("%Y-%m-%d %H:%M:%S") ..
        --     ": Got WinLeave: " .. vim.inspect(evt) ..
        --     ", current win is " .. vim.inspect(cur_win)
        -- )

        -- vim.print(
        --     os.date("%Y-%m-%d %H:%M:%S") ..
        --     "Converting vim.wo[" .. vim.inspect(cur_win)..
        --     "].relnum " .. vim.inspect(window_opt.relativenumber) ..
        --     "-> false")
    end

    if window_opt.number then
        window_opt.relativenumber = false
        if not vim.g.vscode then
            vim.cmd.redraw()
        end
    end
end

vim.api.nvim_create_autocmd(
    { "BufEnter", "FocusGained", "InsertLeave", "CmdlineLeave", "WinEnter" },
    {
        pattern = "*",
        group = augroup,
        callback = enable_relativenumber,
    })

vim.api.nvim_create_autocmd(
    { "BufLeave", "FocusLost", "InsertEnter", "CmdlineEnter", "WinLeave" },
    {
        pattern = "*",
        group = augroup,
        callback = disable_relativenumber,
    })

if vim.g.vscode then
    -- We won't get CmdlineEnter and CmdlineLeave, since vscode-neovim handles those.
    -- Also probably need something similar to FocusGained / BufEnter for the same reason
    local ns = vim.api.nvim_create_namespace("numbertoggle")
    vim.ui_attach(ns, { ext_cmdline = true }, function(event, ...)
        if event == "cmdline_show" then
            disable_relativenumber()
        end
        if event == "cmdline_hide" then
            enable_relativenumber()
        end
    end)
end
