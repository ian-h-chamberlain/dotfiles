function stat
    if status is-command-substitution
        # make sure e.g. tab-completion works as expected
        command stat $argv
    else
        command stat -x $argv
    end
end
