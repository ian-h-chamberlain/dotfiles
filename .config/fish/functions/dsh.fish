function dsh
    set -l dlib "tools/dlib.sh"

    if ! test -f "$dlib"
        echo "'"(pwd)"/$dlib' does not exist!"
        return 1
    end

    bash -c '
        set -o nounset

        source tools/dlib.sh
        dlib_args="$(dlib_parse_args $@)"
        shift $?

        dlib_workflow $dlib_args -- "$@"
    ' -- $argv
end
