HOME = os.getenv("HOME") or os.getenv("USERPROFILE") or os.getenv("LocalAppData")

local sep = package.config:sub(1, 1)

-- Skip in favor of nvim-surround
vim.g.loaded_textobj_quotes = true

-- Load all the vim-compatible plugins
--
-- ugh, joinpath is 0.10.0+ so need to use ..
vim.opt.runtimepath:prepend(HOME .. sep .. ".vim")
vim.opt.runtimepath:append(HOME .. sep .. ".vim" .. sep .. "after")
vim.opt.packpath = vim.opt.runtimepath:get()

local vimrc = HOME .. sep .. ".vimrc"
local f = io.open(vimrc, "r")
if f ~= nil then
    io.close(f)
    vim.cmd.source(vimrc)
end

-- https://github.com/neovim/neovim/issues/2437#issuecomment-522236703
vim.g.python_host_prog = HOME .. "/.pyenv/shims/python2"
vim.g.python3_host_prog = HOME .. "/.pyenv/shims/python3"

require("nvim-surround").setup()
require("ns-textobject").setup()

-- There might be a vimrc way to do this but Lua is easy.
-- This also might not be perfect and I might want to limit filetypes but let's try it out.
vim.keymap.set("n", "C", function()
    local cur_line = vim.api.nvim_get_current_line()
    local has_terminator = vim.list_contains({ ";", "," }, string.sub(cur_line, -1))
    -- Delete only until terminating char if there is one at the end of the line.
    return has_terminator and "cv$" or "c$"
end, { expr = true })

-- Global, used in ./after/lua/vscode-custom.lua
VSCODE_INJECTED_LANGS = {}

-- Wrap this in a pcall in case treesitter isn't installed
local success, error = pcall(function()
    -- langs without vscode equivalent, always enable highlights for these

    if vim.g.vscode then
        -- TODO: I'd love to figure out how to disable these at the top-level and only enable for injections
        -- Maybe possible now with https://github.com/neovim/neovim/pull/32790
        VSCODE_INJECTED_LANGS = {
            "fish",
            "bash",
            "javascript",
            "vim",
            "regex",
            "markdown_inline",
            "markdown",
            "lua",
            "json",
        }
    end

    vim.treesitter.query.add_predicate("vscode?", function()
        return vim.g.vscode and true or false
    end, { force = true, all = true })

    vim.treesitter.query.add_predicate("injected?", function(_match, _pattern, buf, pred)
        if type(buf) ~= "number" then
            return
        end

        local parser_ft = vim.filetype.match({ buf = buf })
        local buf_ft = vim.filetype.match({ buf = vim.fn.bufnr() })

        return buf_ft ~= parser_ft
    end, { force = true, all = true })

    require("nvim-treesitter.configs").setup({
        highlight = {
            enable = true,
            -- These can be disabled at the top level like this, but they're still allowed
            -- as injected languages so e.g. vim.cmd and nix injections work, without
            -- taking over highlights in vscode
            disable = VSCODE_INJECTED_LANGS,
        },
    })
end)

if not success then
    vim.print("Failed to pcall hl setup!", error)
end

-- TODO: convert remainder of this to proper Lua config

-- Even though vscode should be doing its own highlights, this also
-- enables monokai for e.g. :help highlighting and matches a little better when
-- vscode-neovim tries to highlight things it shouldn't.
-- TODO I should maybe file another issue about the highlight stuff...
require("monokai-nightasty").setup({
    on_highlights = function(highlights, colors)
        -- It seems like most syntaxes just use String for quotes, but
        -- for some (e.g. JSON) they are highlighted differently.
        -- This just forces them back to regular String highlight
        highlights.Quote = highlights.String

        -- More like the old vim highlighting:
        highlights.gitcommitSummary, highlights.gitcommitOverflow =
            highlights.gitcommitOverflow, highlights.gitcommitSummary
    end,
})

vim.cmd.colorscheme("monokai-nightasty")

if not vim.g.vscode then
    -- Default to dark mode if unset
    vim.opt.background = os.getenv("COLOR_THEME") or "dark"

    if vim.fn.has("wsl") ~= 0 then
        vim.g.clipboard = {
            name = "WslClipboard",
            copy = {
                ["+"] = "clip.exe",
                ["*"] = "clip.exe",
            },
            paste = {
                -- yeesh, is this really the only way to deal with this? See :h clipboard-wsl
                -- fish_clipboard_paste looks like it's doing basically the same thing too
                ["+"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
                ["*"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
            },
            cache_enabled = false,
        }
    end

    -- TODO: https://github.com/akinsho/git-conflict.nvim
else
    -- vscode-neovim
    local vscode = require("vscode")

    -- vim.opt.cmdheight = 1

    local group = vim.api.nvim_create_augroup("vscode-custom", {})

    -- rust-analyzer commands doesn't play super nice with neovim join/match brace; this autocmd
    -- setups up bindings to use the builtin motion commands in operator-pending mode
    vim.api.nvim_create_autocmd({ "FileType" }, {
        pattern = { "*.rs" },
        group = group,
        callback = function()
            vim.keymap.set({ "n", "v" }, "%", function()
                if vim.fn.state("o") ~= "" then
                    vscode.action("rust-analyzer.matchingBrace")
                    return ""
                end

                return "%"
            end, { silent = true, remap = true, expr = true })

            vim.keymap.set({ "n", "v" }, "J", function()
                if vim.fn.state("o") ~= "" then
                    vscode.action("rust-analyzer.joinLines")
                    return ""
                end

                return "J"
            end, { silent = true, remap = true, expr = true })
        end,
    })

    -- https://github.com/vscode-neovim/vscode-neovim/issues/1718#issuecomment-2078380657

    -- Fix comment handling for AHK
    vim.api.nvim_create_autocmd({ "BufEnter" }, {
        pattern = { "*.ahk", "*.ahk2" },
        group = group,
        callback = function(args)
            vim.opt.comments = {
                "s1:/*",
                "mb:*",
                "ex:*/",
                ":;;",
                ":;",
            }
        end,
    })

    -- For whatever reason, nvim buffers sometimes open without line numbers:
    vim.opt.number = true

    -- Handle folds a little nicer. <C-J>,<NL> and arrow keys can still be used to navigate into fold.
    -- https://github.com/vscode-neovim/vscode-neovim/issues/58#issuecomment-1879583457
    -- Unclear why a normal vim.keymap.set doesn't work in this case
    local function mapMove(key, direction)
        vim.keymap.set("n", key, function()
            local count = vim.v.count
            local v = 1
            local style = "wrappedLine"
            if count > 0 then
                v = count
                style = "line"
            end
            vscode.action("cursorMove", {
                args = {
                    to = direction,
                    by = style,
                    value = v,
                },
            })
        end, { silent = true })
    end

    mapMove("k", "up")
    mapMove("j", "down")

    vim.cmd([[
    xnoremap <silent> <Esc> :<C-u>call VSCodeNotify('closeFindWidget')<CR>

    nnoremap <silent> <Esc> :<C-u>call VSCodeNotify('closeFindWidget')<CR>

    " Disable airline by pretending it's already loaded
    let g:loaded_airline = 1

    set linebreak
    set textwidth=0

    " This one interferes with normal syntax highlighting especially in Markdown
    highlight! link Title None

    " intercept :cq so it doesn't actually quit neovim, just closes. This is
    " slightly different from default :cq behavior but basically does what I want
    command! -bang Cquit call VSCodeNotify('workbench.action.revertAndCloseActiveEditor')
    AlterCommand cq[uit] Cquit

    xmap gc  <Plug>VSCodeCommentary
    nmap gc  <Plug>VSCodeCommentary
    omap gc  <Plug>VSCodeCommentary
    nmap gcc <Plug>VSCodeCommentaryLine

    xmap <C-/> <Plug>VSCodeCommentarygv
    nmap <C-/> <Plug>VSCodeCommentaryLine

    nmap <D-a> ggVG

    " Remap for append/insert with multi-cursor to avoid extra keystroke
    xmap <expr> a visualmode() ==# 'v' ? 'a' : 'ma'
    xmap <expr> A visualmode() ==# 'v' ? 'A' : 'mA'
    xmap <expr> i visualmode() ==# 'v' ? 'i' : 'mi'
    xmap <expr> I visualmode() ==# 'v' ? 'I' : 'mI'
    ]])

    -- Equivalent of https://stackoverflow.com/a/5563142/14436105 for vscode tabs
    vim.keymap.set("n", "<Tab>", function()
        vscode.action("workbench.action.nextEditorInGroup")
    end, { silent = true })
    vim.keymap.set("n", "<S-Tab>", function()
        vscode.action("workbench.action.previousEditorInGroup")
    end, { silent = true })
end

-- firenvim
vim.g.firenvim_config = {
    localSettings = {
        -- Default options for all pages
        [".*"] = {
            takeover = "never",
            priority = 0,
            selector = 'textarea:not([readonly], [aria-readonly="true"])',
            cmdline = "neovim",
        },

        -- Opt-in to takeover on some URLs
        ["https?://(www[.])?shadertoy[.]com/?.*"] = {
            takeover = "once",
            priority = 5,
        },
        ["https?://(pkg[.])?go[.]dev"] = {
            takeover = "once",
            priority = 5,
        },
    },
}

if vim.g.started_by_firenvim then
    -- TODO: different devices need different font sizes here:
    -- https://github.com/glacambre/firenvim/issues/e565
    -- h9 is probably ok for a 1080p screen, but hiDPI is different
    -- and seems like 18~20 is about right? Lua could probably figure it out
    -- using some yadm / os commands

    require("lspconfig").glsl_analyzer.setup({})

    vim.cmd([[
    " For whatever reason this doesn't needs explicit keybinding:
    " https://github.com/glacambre/firenvim/issues/332
    inoremap <D-v> <Esc>"+pa

    set mouse=

    autocmd BufEnter github.com_*.txt           set filetype=markdown
    autocmd BufEnter www.shadertoy.com_*.txt    set filetype=glsl
    autocmd BufEnter pkg.go.dev_*.txt           set filetype=go
    autocmd BufEnter go.dev_*.txt               set filetype=go

    " TODO: maybe set this after a delay for UIEnter, like in
    " https://github.com/glacambre/firenvim/issues/972#issuecomment-1048209573
    set guifont=Monaspace\ Argon:h18

    let g:loaded_airline = 1
    ]])
end

-- Do this at the end so ColorScheme autocmds work:

---@diagnostic disable-next-line: missing-fields
require("monokai-nightasty").setup({
    on_highlights = function(highlights, colors)
        -- It seems like most syntaxes just use String for quotes, but
        -- for some (e.g. JSON) they are highlighted differently.
        -- This just forces them back to regular String highlight
        highlights.Quote = highlights.String

        -- More like the old vim highlighting:
        highlights.gitcommitSummary, highlights.gitcommitOverflow =
            highlights.gitcommitOverflow, highlights.gitcommitSummary
    end,
})

vim.cmd.colorscheme("monokai-nightasty")
