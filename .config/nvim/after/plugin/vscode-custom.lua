if not vim.g.vscode then
    return
end

-- Trim off the filename that is shown in default statusline; also remove some defaults I don't use
-- Example: `[Help][Preview][-][RO] | -- VISUAL --`
vim.o.statusline = "%<%h%w%m%r %=%k"

-- Disable regular syntax highlights, we only care about treesitter
vim.cmd("syntax off")

-- Languages without vscode highlighting:
local enabled_langs = { "vimdoc", "query" }
-- These languages have a vscode grammar/LSP, but not injection support; we can
-- use treesitter's injection to supplement syntax highlighting (nice!)
local injected_langs = VSCODE_INJECTED_LANGS

local injection_disabled = { "markdown" }

-- Wrap this whole thing in a pcall in case treesitter isn't installed

local success, error = pcall(function()
    local ts_parsers = require("nvim-treesitter.parsers")

    for _, lang in pairs(ts_parsers.available_parsers()) do
        if ts_parsers.has_parser(lang) and not vim.list_contains(enabled_langs, lang) then
            -- Disable everything but injections + nvim-surround
            for _, query in ipairs({ "locals", "folds", "indents" }) do
                vim.treesitter.query.set(lang, query, "")
            end

            -- Keep highlights active for injected langs, that's the whole point
            if not vim.list_contains(injected_langs, lang) then
                vim.treesitter.query.set(lang, "highlights", "")
            end

            -- would love to do something like this but there doesn't seem to be
            -- a way to go back to parsed query from query info...
            -- https://github.com/neovim/neovim/issues/32729
            --[[
                local q = vim.treesitter.query.get(lang, "highlights")
                for _, pattern in pairs(q.info.patterns) do
                    table.insert(pattern, { "injected?" })
                end
            ]]

            if vim.list_contains(injection_disabled, lang) then
                vim.treesitter.query.set(lang, "injections", "")
            end
        end
    end

    -- Clear everything vscode-neovim does for treesitter highlights
    local ns = vim.api.nvim_create_namespace("vscode.highlight")
    for name in pairs(vim.api.nvim_get_hl(ns, {})) do
        vim.api.nvim_set_hl(ns, name, { link = nil, force = true })
    end

    -- Collect all the VSCodeNone highlights to add some customizations to them
    local highlights = {}
    for name, value in pairs(vim.api.nvim_get_hl(0, {})) do
        if value.link == "VSCodeNode" then
            highlights[name] = value
        end
    end

    for name, value in pairs(highlights) do
        vim.api.nvim_set_hl(0, name, value)
    end

    -- Clear the autocmds set up by vscode-neovim
    -- https://github.com/vscode-neovim/vscode-neovim/blob/master/runtime/lua/vscode/highlight.lua
    local hl_group = vim.api.nvim_create_augroup("vscode.highlight", { clear = true })
    -- force a redraw for highlights when we open a buffer, not positive why this is needed
    -- but it makes TS highlighting work on files that weren't before. It does have a weird side effect
    -- of turning on highlights for unfocused buffers, which I would have thought FileType should cover
    vim.api.nvim_create_autocmd({ "FileType", "WinEnter", "BufEnter", "BufWinEnter" }, {
        group = hl_group,
        callback = function()
            pcall(function()
                -- re-parse with the new queries we've setup
                vim.treesitter.start()
            end)
            vim.cmd("mode")
        end,
    })
end)

if not success then
    vim.print("failed to do vscode-hl setup", error)
end
