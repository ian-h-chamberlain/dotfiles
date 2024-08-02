function tmux_attach
    if test (uname) = Darwin
        vssh tmux_attach
    else
        # `command` because https://gitlab.com/gnachman/iterm2/-/issues/11728
        if command tmux ls
            if test "$TERM_PROGRAM" = "iTerm.app"
                command tmux -CC attach $argv
            else
                command tmux attach $argv
            end
        end
    end
end
