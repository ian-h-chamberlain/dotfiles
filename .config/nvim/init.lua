HOME = os.getenv("HOME") or os.getenv("LocalAppData")

sep = package.config:sub(1,1)

-- Load all the vim-compatible plugins
vim.opt.runtimepath:prepend(HOME .. sep .. ".vim")
vim.opt.runtimepath:append(HOME .. sep .. ".vim" .. "after")
vim.opt.packpath = vim.opt.runtimepath:get()

vimrc = HOME .. sep .. ".vimrc"
f = io.open(vimrc, "r")
if f ~= nil then
    io.close(f)
    vim.cmd.source()
end

-- https://github.com/neovim/neovim/issues/2437#issuecomment-522236703
vim.g.python_host_prog  = HOME .. "/.pyenv/shims/python2"
vim.g.python3_host_prog = HOME .. "/.pyenv/shims/python3"


-- TODO: convert remainder of this to proper Lua config

-- vscode-neovim
vim.cmd([[
if exists('g:vscode')
    xnoremap <silent> <Esc> :<C-u>call VSCodeNotify('closeFindWidget')<CR>
    nnoremap <silent> <Esc> :<C-u>call VSCodeNotify('closeFindWidget')<CR>

    " Disable airline by pretending it's already loaded
    let g:loaded_airline = 1

    set linebreak
    set textwidth=0

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
endif
]])

-- FireNvim
vim.cmd([[
if exists('g:started_by_firenvim')
    " For whatever reason this doesn't needs explicit keybinding:
    " https://github.com/glacambre/firenvim/issues/332
    inoremap <D-v> <Esc>"+pa

    let fc = g:firenvim_config['localSettings']
    let fc['.*'] = {
        \ 'selector': 'textarea:not([readonly], [aria-readonly="true"])',
        \ 'cmdline': 'neovim',
    \ }

    let disabled_urls = [
        \ 'https?://github[.]com',
        \ 'https?://demangler[.]com',
        \ 'https?://(www[.])?google[.]com',
        \ 'https?://[^.]+[.]atlassian[.]net',
        \ 'https?://play[.]rust-lang[.]org',
        \ 'https?://app[.]circleci[.]com',
    \ ]
    for disabled_url in disabled_urls
        let fc[disabled_url] = { 'takeover': 'never', 'priority': 1 }
    endfor

    set mouse=

    autocmd BufEnter github.com_*.txt           set filetype=markdown
    autocmd BufEnter www.shadertoy.com_*.txt    set filetype=glsl
    autocmd BufEnter pkg.go.dev_*.txt           set filetype=go
    autocmd BufEnter go.dev_*.txt               set filetype=go

    " TODO: maybe set this after a delay for UIEnter, like in
    " https://github.com/glacambre/firenvim/issues/972#issuecomment-1048209573
    set guifont=InputMono\ ExLight:h9

    let g:loaded_airline = 1
    " let g:airline#extensions#tabline#enabled=0
endif
]])
