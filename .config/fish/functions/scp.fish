function scp
    set -l should_exec 0
    for arg in $argv
        if string match --quiet '*:*' -- $arg
            set should_exec 1
        end
    end

    # Apparently these are undocumented options which are used by the *server*
    # instance of scp as part of its file transfer protocol, and for some reason
    # it uses the shell instead of just the scp binary. So in these cases we
    # also just run the command verbatim.
    if contains -- '-f' $argv; or contains -- '-t' $argv;
        set should_exec 1
    end

    if test $should_exec -eq 0
        echo "Error: command `scp $argv` missing colon. If you really meant to"
        echo "do that, you can run `command scp $argv` instead"
        return 1
    end

    command scp $argv
end
