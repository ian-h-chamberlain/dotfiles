# Defined in /var/folders/4w/bjgmcfds1nv33zqkhf2q2_340000gp/T//fish.0SuvcA/rcheck.fish @ line 2
function rcheck --description 'Build and validate C++ unity targets with rmake and validate'
	source ~/.config/fish/functions/remote_cmd.fish

    set -l build_args
    set -l build_targets
    set -l test_args
    set -l test_targets
    set -l dry_run false

    function print_help
        echo "rcheck: Build and validate C++ unity targets with rmake and validate"
        echo
        echo "USAGE: rcheck [options] [--] [<target> ...]"
        echo
        echo "OPTIONS:"
        echo
        echo "  -d | --dry-run=<true|false>     Only print the command that would be run,"
        echo "                                  instead of running it"
        echo
        echo "  -b <arg> | --build-arg=<arg>    Argument to pass to the build command. May be"
        echo "                                  specified multiple times, once per argument"
        echo
        echo "  -t <arg> | --test-arg=<arg>     Argument to pass to the validate command. May be"
        echo "                                  specified multiple times, once per argument"
        echo
        echo "  -h, --help                      Show this help"
        echo
    end

    getopts $argv | while read -l key value
        switch $key
            case _
                set -a build_targets $value"_unity"
                set -a test_targets $value

            case d dry-run
                set dry_run $value

            case b build-arg
                set -a build_args $value

            case t test-arg
                set -a test_args $value

            case h help
                print_help >&2
                return
        end
    end

    if not count $build_targets >/dev/null
        echo "No targets specified: $build_targets"
        return 1
    end

    set build_command rmake $build_args $build_targets '&&' tools/dvalidate -c -run $test_targets $test_args

    if test "$dry_run" = "true"
        echo $build_command
    else
        remote_cmd $build_command
    end
end
