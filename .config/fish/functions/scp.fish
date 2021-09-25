function scp
    set -l HAS_COLON 0
    for arg in $argv
        if string match --quiet '*:*' $arg
            set HAS_COLON 1
        end
    end

    if test $HAS_COLON -ne 1
        echo "Possibly missing colon in args!"
        echo "Use `command scp` if you really want to run it like this."
        return 1
    end

    command scp $argv
end
