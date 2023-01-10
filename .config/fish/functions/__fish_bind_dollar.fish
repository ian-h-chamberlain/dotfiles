function __fish_bind_dollar
    switch (commandline --current-token)[-1]
        case "*!\\"
            # This case lets us still type a literal `!$` if we need to (by
            # typing `!\$`). Probably overkill.
            commandline --insert '$'
        case "!" "*!"
            set -l last_cmd $history[1]
            set -l tokenized (string split ' ' -- $last_cmd)
            commandline --current-token -- $tokenized[-1]
            commandline --function repaint
        case "*"
            commandline --insert '$'
    end
end
