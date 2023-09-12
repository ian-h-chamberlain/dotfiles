HOME = os.getenv("HOME")
vim.opt.runtimepath:prepend(HOME .. "/.vim")
vim.opt.runtimepath:append(HOME .. "/.vim/after")
vim.cmd.source(HOME .. "/.vimrc")
