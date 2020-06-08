# Defined in /var/folders/4w/bjgmcfds1nv33zqkhf2q2_340000gp/T//fish.marwk0/vscode_ext.fish @ line 2
function vscode_ext

    function print_help
        set -l cmd (status current-command)
        echo $cmd": Run VSCode with only specific extensions enabled"
        echo
        echo "USAGE: $cmd [options] <extension-id> [extension-id ...]"
        echo
        echo "OPTIONS:"
        echo "  -d, --dry-run                   Print the command that would be run, instead"
        echo "                                  of actually running it"
        echo
        echo "  -h, --help                      Show this help"
        echo
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
        echo code $code_args
    else
        code $code_args
    end
end
