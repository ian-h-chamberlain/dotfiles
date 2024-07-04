function tmux
    if test "$TERM_PROGRAM" = "iTerm.app"
        command tmux -CC $argv
    else
        command tmux $argv
    end
end
