set encoding=utf-8

set tabstop=4
set shiftwidth=4
set softtabstop=4
set shiftround " lmao where has this been all my life T_T

set expandtab
set backspace=indent,eol,start

set whichwrap=<,>,[,],b
set matchpairs+=<:>
set wrapmargin=0

" TBD if this is exactly what I want, but it seems better so far...
set selection=old

set autoindent
filetype plugin indent on

set ignorecase
set smartcase

" Prevent '#' from forcing 0-indent for e.g. python + bash comments
" This should be used instead of smartindent
set cindent
set cinkeys-=0#
set indentkeys-=0#

set wildmode=longest:full,full
set wildoptions+=fuzzy
cnoremap <M-BS> <C-w>
cnoremap <M-d> <C-d>

if &diff
    set diffopt+=iwhite
endif

let g:mapleader = ' '

" Enable leader-keymaps for DirDiff
let g:DirDiffEnableMappings = 1

" System copy-paste on linux
map <C-C> "+ygv

" Use newer info than the macOS builtin
let g:infoprg = '/usr/local/bin/info'

" Common typos I make while trying to save a file. It's very unlikely i'll ever need to
" name a file something like "\" or "'" and if I do I can use a space or :saveas
cabbrev w\ w
cabbrev w' w
cabbrev w] w

" Don't set textwidth to 99 by default. Rustfmt does the heavy lifting anyway
let g:rust_recommended_style = 0

" filetype matching
augroup CustomFiletypes
    autocmd!
    autocmd BufRead,BufNewFile */.ssh/config*       set filetype=sshconfig
    autocmd BufRead,BufNewFile */.gitconfig*        set filetype=gitconfig

    autocmd BufRead,BufNewFile *.yaml               set nocindent
    autocmd BufRead,BufNewFile *.yml                set nocindent

    autocmd BufRead,BufNewFile */Code/User/*.json   set filetype=jsonc
    autocmd BufRead,BufNewFile */.vscode/*.json     set filetype=jsonc
    autocmd BufRead,BufNewFile *.code-workspace     set filetype=jsonc
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
" TODO maybe disable this for vscode-nvim
augroup CustomTodo
    autocmd!
    autocmd Syntax * syntax match CustomTodo /\v<(TODO|FIXME|NOTE)/ containedin=.*Comment
augroup END

highlight link CustomTodo Todo

augroup CustomColors
    autocmd!
    " annoying to have to hard code this, but it seems easier than trying to
    " copy attributes from the default 'Comment' highlight group.
    autocmd ColorScheme Monokai hi! SpecialComment cterm=bold gui=bold ctermfg=242 guifg=#75715e
augroup END

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

set hlsearch
syntax on

if exists('g:vscode')
    finish
endif

" =============================================================================
" Ordinary vim/neovim settings that don't apply in VSCode after this point
" =============================================================================
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
    let g:airline#extensions#tabline#fnamemod = ':p:~'

    let g:airline#extensions#tabline#show_buffers = 1
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

if !exists("g:loaded_bracketed_paste")
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

" https://stackoverflow.com/a/5563142/14436105
nnoremap  <silent>  <Tab>   :if &modifiable && !&readonly && &modified <CR>
\                           :write<CR> :endif<CR>:bnext<CR>
nnoremap  <silent>  <S-Tab> :if &modifiable && !&readonly && &modified <CR>
\                           :write<CR> :endif<CR>:bprevious<CR>
nmap <silent> <Leader>n <Tab>
nmap <silent> <Leader>p <S-Tab>
nmap <silent> <Leader>N <S-Tab>

" May want to adjust these to close window sometimes... idk
nnoremap  <silent> <Leader>wd   :if &modifiable && !&readonly && &modified <CR>
\                               :write<CR> :endif<CR>:bdelete<CR>
nnoremap  <silent> <Leader>d    :bdelete<CR>
