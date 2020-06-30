function rdsh
    set -l tmux_cmd tmux new dsh
    if test $TERM_PROGRAM = "iTerm.app";
        set tmux_cmd tmux -CC new dsh
    end
    rpush && vssh -t "$tmux_cmd"
end
