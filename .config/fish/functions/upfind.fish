function upfind --description 'Finds a file with the given name, upwards'
    set dir $PWD
    if set -q argv[2]
        set dir $argv[2]
    end

    test (realpath $dir) != /
    or return 1

    if test -e $dir/$argv[1]
        realpath $dir/$argv[1]
    else
        upfind $argv[1] $dir/..
    end
end
