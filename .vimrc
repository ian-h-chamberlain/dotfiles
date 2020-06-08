set tabstop=4
set shiftwidth=4
set softtabstop=4

set expandtab
set autoindent
set backspace=indent,eol,start

set whichwrap=<,>,[,],b
set wrapmargin=0

filetype indent on

set number
syntax on
set ruler
highlight ColorColumn ctermbg=7
set colorcolumn=80

set mouse=a

colorscheme Monokai

" Custom highlighting
augroup CustomTodo
  autocmd!
  autocmd Syntax * syntax match CustomTodo /\v<(TODO|FIXME|NOTE)/ containedin=.*Comment
augroup END
highlight link CustomTodo Todo

let os = substitute(system('uname'), "\n", "", "")
if os == "Darwin"
    set termguicolors
endif

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
    " ordinary vim
endif

let g:PreserveNoEOL = 1

au BufNewFile,BufRead *.frag,*.vert,*.fp,*.vp,*.glsl,*.fs,*.vs set syntax=glsl
au BufNewFile,BufRead *.rs set syntax=rust
au BufNewFile,BufRead *.cnf set filetype=dosini
au BufNewFile,BufRead *.init set filetype=javascript

let redcode_highlight_numbers=1
