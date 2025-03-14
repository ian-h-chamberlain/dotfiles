function upfind --description 'Finds a file with the given name, upwards'
    set -l usage "Usage:
    upfind [-a|--all] [-d DIR|--from=DIR] FILE"

    argparse --min-args=1 a/all d/from= -- $argv
    or begin
        echo $usage
        return
    end

    set dir $PWD
    if set -q _flag_from
        set dir $_flag_from
    end

    test (builtin realpath --no-symlinks $dir) != /
    or return 1

    if test -e $dir/$argv[1]
        builtin realpath --no-symlinks $dir/$argv[1]
        if not set -ql _flag_all
            return
        end
    end

    upfind $argv[1] --from=$dir/..
end
