function __fish_bind_dollar
    switch (commandline --current-token)[-1]
        case "*!\\"
            # This case lets us still type a literal `!$` if we need to (by
            # typing `!\$`). Probably overkill.
            commandline --insert '$'
        case "!" "*!"
            echo $history[1] | read --list --tokenize last_cmdline
            commandline --current-token -- (string escape --no-quoted -- $last_cmdline[-1])
            commandline --function repaint
        case "*"
            commandline --insert '$'
    end
end
