function stat
    if status is-command-substitution
        or test (uname) = Linux

        # make sure e.g. tab-completion works as expected
        command stat $argv
    else
        command stat -x $argv
    end
end
