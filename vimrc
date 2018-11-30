set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set autoindent
filetype indent on
set number
set backspace=indent,eol,start
syntax on
set wrapmargin=0
set ruler
highlight ColorColumn ctermbg=7
set colorcolumn=80
set whichwrap=<,>,[,],b
set mouse=a
set clipboard=unnamed
colorscheme monokai
let os = substitute(system('uname'), "\n", "", "")
if os == "Darwin"
    set termguicolors
endif

syn match   myTodo   contained   "\<\(TODO\|FIXME\):"
hi def link myTodo Todo

" parse .cnf files as ini
au BufNewFile,BufRead *.cnf set filetype=dosini
" parse .init files as json
au BufNewFile,BufRead *.init set filetype=javascript
