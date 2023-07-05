function __fish_bind_star
    switch (commandline --current-token)[-1]
        case "*!\\"
            # This case lets us still type a literal `!*` if we need to (by
            # typing `!\*`). Probably overkill.
            commandline --insert '*'
        case "*!" "!"
            set -l last_cmdline $history[1]

            # pull out the last command's argv[0] plus any whitespace
            echo $last_cmdline | read --tokenize --array tokenized_last_cmd
            set -l cmd '^'(string escape --style=regex $tokenized_last_cmd[1])'\s+'

            commandline --current-token -- (string replace --regex $cmd '' -- $last_cmdline)
            commandline --function repaint
        case "*"
            commandline --insert '*'
    end
end
