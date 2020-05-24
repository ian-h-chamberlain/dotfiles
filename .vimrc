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
set clipboard=unnamed

colorscheme Monokai

let os = substitute(system('uname'), "\n", "", "")
if os == "Darwin"
    set termguicolors
endif

syn match myTodo contained "\<\(TODO\|FIXME\):"
hi def link myTodo Todo

let g:PreserveNoEOL = 1

au BufNewFile,BufRead *.frag,*.vert,*.fp,*.vp,*.glsl,*.fs,*.vs set syntax=glsl
au BufNewFile,BufRead *.rs set syntax=rust
au BufNewFile,BufRead *.cnf set filetype=dosini
au BufNewFile,BufRead *.init set filetype=javascript

"let redcode_88_only=1
"let redcode_94_only=1
let redcode_highlight_numbers=1
