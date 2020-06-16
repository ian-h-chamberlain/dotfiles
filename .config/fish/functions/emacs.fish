function emacs
    # Emacs.app requires its $argv[0] to be the real path to find its own libs, etc.
    eval (realpath (which emacs))
end
