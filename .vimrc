set tabstop=4
set shiftwidth=4
set softtabstop=4

set expandtab
set autoindent
set smartindent
set backspace=indent,eol,start

set whichwrap=<,>,[,],b
set wrapmargin=0

filetype indent on

syntax on

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
endif


augroup CustomTodo
  autocmd!
  autocmd Syntax * syntax match CustomTodo /\v<(TODO|FIXME|NOTE)/ containedin=.*Comment
augroup END
highlight link CustomTodo Todo