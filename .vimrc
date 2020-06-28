" TODO: modularize this more

" Universal options

set tabstop=4
set shiftwidth=4
set softtabstop=4

set expandtab
set autoindent
set smartindent
set backspace=indent,eol,start

set whichwrap=<,>,[,],b
set wrapmargin=0

set iskeyword-=_

filetype indent on

if &diff
    set diffopt+=iwhite
endif

set hlsearch
syntax on


" Augroups, must be before `syntax on`

augroup CustomTodo
    autocmd!
    autocmd Syntax * syntax match CustomTodo /\v<(TODO|FIXME|NOTE)/ containedin=.*Comment
augroup END

highlight link CustomTodo Todo

autocmd FileType yaml,json,nix setlocal shiftwidth=2 tabstop=2

" Editor-specific settings

if exists('g:vscode')
    " vscode-neovim specific settings
    xnoremap <silent> <Esc> :<C-u>call VSCodeNotify('closeFindWidget')<CR>
    nnoremap <silent> <Esc> :<C-u>call VSCodeNotify('closeFindWidget')<CR>

    xmap gc  <Plug>VSCodeCommentary
    nmap gc  <Plug>VSCodeCommentary
    omap gc  <Plug>VSCodeCommentary
    nmap gcc <Plug>VSCodeCommentaryLine

    xmap <C-/> <Plug>VSCodeCommentarygv
    nmap <C-/> <Plug>VSCodeCommentaryLine

    " Move cursor to end of line when making visual selection so % works as expected
    nmap V V$

    " This allows wrapping + code folding to work
    xmap j gj
    nmap j gj

    xmap k gk
    nmap k gk

    " " Make neovim use vscode builtin search
    " " TODO: probably can write a function that sets a variable forward or reverse search
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
    " ordinary vim/neovim settings that don't apply in VSCode
    set mouse=a

    highlight ColorColumn ctermbg=7
    set colorcolumn=80
    set ruler

    set number

    let os = substitute(system('uname'), "\n", "", "")
    if os == "Darwin"
        set termguicolors
    endif

    colorscheme Monokai

    highlight! link Search IncSearch


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

