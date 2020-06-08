# Defined in /Users/ichamberlain/.config/fish/functions/dsh.fish @ line 2
function dsh
	if test (uname) = "Darwin"
        echo "dsh not supported on macOS!"
        return 1
    end

    pushd ~/Documents/workspace

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

    popd
end
