function dsh
    set -l dlib "tools/dlib.sh"

    if ! test -f "$dlib"
        echo "'"(pwd)"/$dlib' does not exist!"
        return 1
    end

    if test (uname) = Darwin
        echo "dsh not supported on macOS!"
        return 1
    end

    DOCKER_BUILDKIT=0 bash -c '
        set -o nounset

        source tools/dlib.sh
        dlib_args="$(dlib_parse_args $@)"
        shift $?

        dlib_workflow $dlib_args -- "/bin/bash --rcfile /etc/bashrc --rcfile ~/.bashrc"
    ' -- $argv
end
