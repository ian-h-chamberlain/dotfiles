function tmux_attach
    if test (uname) = Darwin
        vssh tmux_attach
    else
        if tmux ls
            if test $TERM_PROGRAM = "iTerm.app"
                command tmux -CC attach $argv
            else
                command tmux attach $argv
            end
        end
    end
end
