set encoding=utf-8

set tabstop=4
set shiftwidth=4
set softtabstop=4

set expandtab
set backspace=indent,eol,start

set whichwrap=<,>,[,],b
set matchpairs+=<:>
set wrapmargin=0

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

" System copy-paste on linux
map <C-C> "+ygv

" Use newer info than the macOS builtin
let g:infoprg = '/usr/local/bin/info'

" filetype matching
augroup CustomFiletypes
    autocmd!
    autocmd BufRead,BufNewFile */.ssh/config*   set filetype=sshconfig
    autocmd BufRead,BufNewFile */.gitconfig*    set filetype=gitconfig
augroup END

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
if !exists('g:vscode')
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
