function dsh
    set -l denv (gbase)/tools/denv

    if not test -f "$denv"
        echo "'$denv' does not exist!"
        return 1
    end

    if test (uname) = Darwin
        echo "dsh not supported on macOS!"
        return 1
    end

    DOCKER_BUILDKIT=0 $denv $argv -- "/bin/bash --rcfile /etc/bashrc --rcfile ~/.bashrc"
end
