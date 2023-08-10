" TODO: modularize this more

" Universal options

set encoding=utf-8

set tabstop=4
set shiftwidth=4
set softtabstop=4

set expandtab
set backspace=indent,eol,start

set whichwrap=<,>,[,],b
set matchpairs+=<:>
set wrapmargin=0

set iskeyword-=_

set autoindent
filetype plugin indent on

" Prevent '#' from forcing 0-indent for e.g. python + bash comments
" This should be used instead of smartindent
set cindent
set cinkeys-=0#
set indentkeys-=0#


if &diff
    set diffopt+=iwhite
endif

" Enable leader-keymaps for DirDiff
let g:DirDiffEnableMappings = 1

set hlsearch
syntax on

" Unbind case-changing with u/U to avoid accidentally press when trying to undo
" For explicitly changing case, ~ can be used instead
vnoremap u <Undo>
vnoremap U <Undo>

noremap gu <Nop>
noremap guu <Nop>
noremap gU <Nop>
noremap gUU <Nop>

" System copy-paste
map <C-C> "+ygv

" Use newer info than the macOS builtin
let g:infoprg = '/usr/local/opt/texinfo/bin/info'

" Keybinds for info files
augroup InfoFile
    autocmd!
    autocmd FileType info nmap <buffer> gu <Plug>(InfoUp)
    autocmd FileType info nmap <buffer> gn <Plug>(InfoNext)
    autocmd FileType info nmap <buffer> gp <Plug>(InfoPrev)

    autocmd FileType info nmap <buffer> gm <Plug>(InfoMenu)
    autocmd FileType info nmap <buffer> gf <Plug>(InfoFollow)
    autocmd FileType info nmap <buffer> go <Plug>(InfoGoto)
augroup END

" Augroups, must be before `syntax on`
augroup CustomTodo
    autocmd!
    autocmd Syntax * syntax match CustomTodo /\v<(TODO|FIXME|NOTE)/ containedin=.*Comment
augroup END

highlight link CustomTodo Todo

autocmd FileType yaml,json,nix setlocal shiftwidth=2 tabstop=2

" Automatically add +x for shebang + script files
autocmd BufWritePost *
    \ if getline(1) =~ "^#!" |
        \ if getline(1) =~ "/bin/" |
            \ if !exists("$SUDO_COMMAND") |
                \ silent execute "!chmod a+x <afile>" |
            \ endif |
        \ endif |
    \ endif

" Editor-specific settings

" vscode-neovim specific settings
if exists('g:vscode')
    xnoremap <silent> <Esc> :<C-u>call VSCodeNotify('closeFindWidget')<CR>
    nnoremap <silent> <Esc> :<C-u>call VSCodeNotify('closeFindWidget')<CR>

    " Disable airline by pretending it's already loaded
    let g:loaded_airline = 1

    " TODO Make word wrap behave better with vscode
    " Try opening a JSON file with long lines for example
    set wrap
    set linebreak
    set textwidth=0

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

    " Call VSCode commands using a visual selection from nvim
    function! s:vscodeNotifyVisualSelection(cmd) abort
        normal! gv

        let vmode = visualmode()
        if vmode ==# "V"
            let startLine = line("v")
            let endLine = line(".")
            call VSCodeNotifyRange(a:cmd, startLine, endLine, 1)
        else
            let [startLine, startColumn] = getpos("v")[1:2]
            let [endLine, endColumn] = getpos(".")[1:2]
            call VSCodeNotifyRangePos(a:cmd, startLine, endLine, startColumn, endColumn, 1)
        endif
    endfunction

    xnoremap <silent> <Leader>f :<C-u>call <SID>vscodeNotifyVisualSelection("actions.find")<CR>
    xnoremap <silent> <Leader>r :<C-u>call <SID>vscodeNotifyVisualSelection("editor.action.startFindReplaceAction")<CR>

    " TODO: Make neovim use vscode builtin search
    " This is commented out because it doesn't really work well with cursor
    " movement, and using nvim's builtin search with / is better. It would be
    " nice to have though.
    " " probably can write a function that sets a variable forward or reverse search
    " " For now n and N will always go in the same direction
    " noremap <silent> ? :<C-u>call VSCodeNotify('actions.find')<CR>
    " noremap <silent> / :<C-u>call VSCodeNotify('actions.find')<CR>

    " " Sending `i<Esc>l` is a hack to force neovim to use the VSCode
    " " cursor location after perfoming the next/prev command, since a mode change
    " " results in a cursor update
    " noremap <silent> N :<C-u>
    "     \call VSCodeCall('editor.action.previousMatchFindAction')<CR>
    "     \call VSCodeCall('cursorMove', {'to': 'right', 'by': 'character'})<CR>
    " noremap <silent> n :<C-u>
    "     \call VSCodeCall('editor.action.nextMatchFindAction')<CR>
    "     \call VSCodeCall('cursorMove', {'to': 'right', 'by': 'character'})<CR>

else
    " Ordinary vim/neovim settings that don't apply in VSCode
    set mouse=a

    highlight ColorColumn ctermbg=7
    set colorcolumn=80
    set ruler

    set number

    if has('termguicolors') && !exists("$TMUX")
        set termguicolors
    endif

    colorscheme Monokai

    highlight! link Search IncSearch

    if exists("$TMUX")
        " Apparently powerline just totally breaks vim in tmux, so have to
        " completely disable it for now, until it's fixed or I find a workaround
        let g:loaded_airline = 1
    else
        " vim-airline options
        let g:airline_powerline_fonts = 1

        " let g:airline_extensions = []
        let g:airline_highlighting_cache = 1
        let g:airline#extensions#whitespace#enabled = 1
        let g:airline#extensions#tabline#enabled = 1
    endif

    " Code from:
    " http://stackoverflow.com/questions/5585129/pasting-code-into-terminal-window-into-vim-on-mac-os-x
    " then https://coderwall.com/p/if9mda
    " and then https://github.com/aaronjensen/vimfiles/blob/59a7019b1f2d08c70c28a41ef4e2612470ea0549/plugin/terminaltweaks.vim
    " to fix the escape time problem with insert mode.
    "
    " Docs on bracketed paste mode:
    " http://www.xfree86.org/current/ctlseqs.html
    " Docs on mapping fast escape codes in vim
    " http://vim.wikia.com/wiki/Mapping_fast_keycodes_in_terminal_Vim

    if exists("g:loaded_bracketed_paste")
        finish
    endif
    let g:loaded_bracketed_paste = 1

    let &t_ti .= "\<Esc>[?2004h"
    let &t_te = "\e[?2004l" . &t_te

    function! XTermPasteBegin(ret)
        set pastetoggle=<f29>
        set paste
        return a:ret
    endfunction

    execute "set <f28>=\<Esc>[200~"
    execute "set <f29>=\<Esc>[201~"
    map <expr> <f28> XTermPasteBegin("i")
    imap <expr> <f28> XTermPasteBegin("")
    vmap <expr> <f28> XTermPasteBegin("c")
    cmap <f28> <nop>
    cmap <f29> <nop>
endif

" Firenvim settings
if !has('nvim')
    " skip loading when running vanilla vim to avoid startup errors
    let g:firenvim_loaded = 1
endif
if exists('g:started_by_firenvim')
    let fc = g:firenvim_config['localSettings']
    let fc['.*'] = {
        \ 'selector': 'textarea:not([readonly], [aria-readonly="true"])',
        \ 'cmdline': 'neovim',
    \ }

    " On GitHub, there aren't really any text boxes worth taking over tbh
    let fc['https?://github[.]com'] = { 'takeover': 'never', 'priority': 1, }
    " Disable for google search editor
    let fc['https?://(www[.])?google[.]com'] = { 'takeover': 'never', 'priority': 1 }
    " Disable entirely for Jira/Confluence
    let fc['https?://[^.]+[.]atlassian[.]net'] = { 'takeover': 'never', 'priority': 1 }

    set mouse=

    autocmd BufEnter github.com_*.txt set filetype=markdown
    autocmd BufEnter www.shadertoy.com_*.txt set filetype=glsl

    " TODO: maybe set this after a delay for UIEnter, like in
    " https://github.com/glacambre/firenvim/issues/972#issuecomment-1048209573
    set guifont=InputMono\ ExLight:h9

    let g:loaded_airline = 1
    " let g:airline#extensions#tabline#enabled=0
endif
