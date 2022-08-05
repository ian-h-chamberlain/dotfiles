function rdsh
    set -l tmux_cmd tmux

    if test $TERM_PROGRAM = "iTerm.app"
        set -a tmux_cmd -CC
    end

    set -a tmux_cmd new "'dsh $argv'"

    rpush && vssh -t $tmux_cmd
end
