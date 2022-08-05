function __fish_bind_bang
    switch (commandline --current-token)[-1]
        case "!"
            # Without the `--`, the functionality can break when completing
            # flags used in the history (since, in certain edge cases
            # `commandline` will assume that *it* should try to interpret
            # the flag)
            commandline --current-token -- $history[1]
            commandline --function repaint
        case "*"
            commandline --insert !
    end
end
