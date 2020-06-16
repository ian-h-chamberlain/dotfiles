function vscode_ext --description 'Run VSCode with only specific extensions enabled'

    function print_help
        set -l cmd (status current-command)
        echo $cmd": Run VSCode with only specific extensions enabled"
        echo
        echo "USAGE: $cmd [options] <extension-id> [extension-id ...] [-- code-args ...]"
        echo
        echo "OPTIONS:"
        echo "  -d, --dry-run                   Print the command that would be run, instead"
        echo "                                  of actually running it"
        echo
        echo "  -h, --help                      Show this help"
        echo
    end

    set -l passthrough_args
    if set -l arg_index (contains --index -- '--' $argv)
        set passthrough_args $argv[(math $arg_index + 1)..-1]
        set -e argv[$arg_index..-1]
    end

    set -l options \
        (fish_opt --short=h --long=help) \
        (fish_opt --short=d --long=dry-run)

    set -l funcname (status current-command)

    argparse --name=$funcname $options -- $argv
    or return $status

    if test "$_flag_help" != ""
        print_help >&2
        return
    end

    if test (count $argv) -lt 1
        echo $funcname": Expected at least 1 args, got 0"
        return 1
    end

    set -l extensions (code --list-extensions | grep -v $argv)
    set -l code_args "--new-window" --disable-extension={$extensions}

    if test "$_flag_dry_run" != ""
        echo code $code_args $passthrough_args
    else
        code $code_args $passthrough_args
    end
end
