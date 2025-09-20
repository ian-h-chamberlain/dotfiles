function fork
    if test "$YADM_OS" = WSL
        set -l args
        for arg in $argv
            set -a args (wslpath -w -- $arg)
        end
        command fork.exe $args
    else
        command fork $argv
    end
end
