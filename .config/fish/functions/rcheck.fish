function rcheck --description 'Build and validate C++ unity targets with rmake and validate'
	source ~/.config/fish/functions/remote_cmd.fish

    function print_help
        set -l cmd (status current-command)
        echo $cmd": Build and validate C++ unity targets with rmake and validate"
        echo
        echo "USAGE: $cmd [options] <target> [target ...]"
        echo
        echo "OPTIONS:"
        echo
        echo "  -d | --dry-run                  Only print the command that would be run,"
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

    set -l options \
        (fish_opt --short=d --long=dry-run) \
        (fish_opt --short=b --long=build-arg --required-val --multiple-vals) \
        (fish_opt --short=t --long=test-arg --required-val --multiple-vals) \
        (fish_opt --short=h --long=help) \

    set -l cmd (status current-command)
    argparse --name=$cmd $options -- $argv; or return $status

    if test "$_flag_help" != ""
        print_help >&2
        return
    end

    if test (count $argv) -lt 1
        echo $cmd": Expected at least 1 args, got 0" >&2
        return 1
    end

    set -l build_targets
    set -l test_targets
    # Remaining unparsed arguments are build/test targets
    for target in $argv
        set -a build_targets $target"_unity"
        set -a test_targets $target
    end

    set build_command \
        rmake $_flag_build_arg $build_targets \
        '&&' \
        tools/dvalidate -c -run $test_targets $_flag_test_arg

    if test "$_flag_dry_run" != ""
        echo "Would have run command: '$build_command'"
    else
        remote_cmd $build_command
    end
end
