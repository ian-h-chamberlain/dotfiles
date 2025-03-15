if not vim.g.vscode then
    return
end

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

    -- Completely deregister everything vscode-neovim does for highlights
    vim.api.nvim_create_augroup("vscode.treesitter", { clear = true })
    local hl_group = vim.api.nvim_create_augroup("vscode.highlight", { clear = true })

    local function fixup_highlights()
        -- And then reimplement a subset of it (i.e. just global highlights)
        -- https://github.com/vscode-neovim/vscode-neovim/blob/master/runtime/lua/vscode/highlight.lua#L25
        -- Probably this could be upstreamed as a simple config option or something...
        for name, value in pairs({
            ColorColumn = {},
            CursorColumn = {},
            CursorLine = {},
            CursorLineNr = {},
            Debug = {},
            EndOfBuffer = {},
            FoldColumn = {},
            Folded = {},
            LineNr = {},
            LineNrAbove = {},
            LineNrBelow = {},
            MatchParen = {},
            MsgArea = {},
            MsgSeparator = {},
            NonText = {},
            Normal = {},
            NormalFloat = {},
            NormalNC = {},
            NormalSB = {},
            Question = {},
            QuickFixLine = {},
            Quote = {},
            Sign = {},
            SignColumn = {},
            Substitute = {},
            Visual = {},
            VisualNC = {},
            VisualNOS = {},
            Whitespace = {},

            -- make cursor visible for plugins that use fake cursor
            Cursor = { reverse = true },

            ["@markup.link"] = {},
            ["@markup.link.label"] = {},
            ["@markup.link.url"] = {},

            ["@markup.raw.markdown_inline"] = {
                fg = "#FD971F",
                bold = false,
                italic = false,
            },
            ["@markup.strong"] = { fg = "#66D9EF", bold = true },
            ["@markup.italic"] = { fg = "#66D9EF", italic = true },
        }) do
            if vim.tbl_isempty(value) then
                vim.api.nvim_set_hl(0, name, { link = "VSCodeNone", force = true })
            else
                vim.api.nvim_set_hl(0, name, value)
            end
        end
    end

    vim.api.nvim_create_autocmd({ "ColorScheme" }, { group = hl_group, callback = fixup_highlights })

    vim.api.nvim_create_autocmd({
        "BufEnter",
        "BufLeave",
        "WinEnter",
        "WinLeave",
        "BufWinEnter",
        "BufWinLeave",
        "WinScrolled",
        "FocusGained",
        "VimEnter",
        "UIEnter",
    }, {
        group = hl_group,
        callback = function()
            -- There are still some oddities with scrolling etc. for redraw,
            -- haven't quite figured out the details yet...
            vim.cmd("mode")
            vim.cmd("redraw!")
        end,
    })

    fixup_highlights()
end)

if not success then
    vim.print("failed to do vscode-hl setup", error)
end
