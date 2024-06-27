HOME = os.getenv("HOME") or os.getenv("LocalAppData")

local sep = package.config:sub(1, 1)

-- Load all the vim-compatible plugins
vim.opt.runtimepath:prepend(HOME .. sep .. ".vim")
vim.opt.runtimepath:append(HOME .. sep .. ".vim" .. "after")
vim.opt.packpath = vim.opt.runtimepath:get()

local vimrc = HOME .. sep .. ".vimrc"
local f = io.open(vimrc, "r")
if f ~= nil then
    io.close(f)
    vim.cmd.source(vimrc)
end

-- https://github.com/neovim/neovim/issues/2437#issuecomment-522236703
vim.g.python_host_prog  = HOME .. "/.pyenv/shims/python2"
vim.g.python3_host_prog = HOME .. "/.pyenv/shims/python3"

-- TODO: convert remainder of this to proper Lua config

if not vim.g.vscode then
    -- Default to dark mode if unset
    vim.opt.background = os.getenv("COLOR_THEME") or "dark"

    require("monokai-nightasty").setup({
        on_highlights = function(highlights, colors)
            -- It seems like most syntaxes just use String for quotes, but
            -- for some (e.g. JSON) they are highlighted differently.
            -- This just forces them back to regular String highlight
            highlights.Quote = highlights.String
        end,
    })
    vim.cmd.colorscheme("monokai-nightasty")
else
    -- vscode-neovim
    local vscode_neovim = require("vscode-neovim")

    vim.opt.cmdheight = 0

    local group = vim.api.nvim_create_augroup("vscode-custom", {})

    -- https://github.com/vscode-neovim/vscode-neovim/issues/1718
    vim.api.nvim_create_autocmd({ "VimEnter", "ModeChanged" }, {
        pattern = "*",
        group = group,
        callback = function(args)
            vscode_neovim.call("setContext", {
                args = { "neovim.fullMode", vim.fn.mode(1) },
            })
        end,
    })

    -- https://github.com/vscode-neovim/vscode-neovim/issues/1718#issuecomment-2078380657
    vim.keymap.set("n", "r", function()
        vscode_neovim.call("setContext", {
            args = { "neovim.fullMode", vim.fn.mode(1) .. "r" },
        })

        vim.api.nvim_feedkeys("r", "n", true)
    end)

    -- For whatever reason, nvim buffers sometimes open without line numbers:
    vim.opt.number = true

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

    " Move cursor to end of line when making visual selection so % works as expected
    nmap V V$

    " This allows wrapping + code folding to work a little nicer
    nmap j gj
    nmap k gk

    " Remap for append/insert with multi-cursor to avoid extra keystroke
    xmap <expr> a visualmode() ==# 'v' ? 'a' : 'ma'
    xmap <expr> A visualmode() ==# 'v' ? 'A' : 'mA'
    xmap <expr> i visualmode() ==# 'v' ? 'i' : 'mi'
    xmap <expr> I visualmode() ==# 'v' ? 'I' : 'mI'
    ]])
end

-- firenvim
vim.g.firenvim_config = {
    localSettings = {
        -- Default options for all pages
        [".*"] = {
            takeover = "never",
            priority = 0,
            selector = 'textarea:not([readonly], [aria-readonly="true"])',
            cmdline  = "neovim",
        },

        -- Opt-in to takeover on some URLs
        ["https?://(www[.])?shadertoy[.]com"] = {
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
    set guifont=Monaspace\ Argon:h9

    let g:loaded_airline = 1
    ]])
end
