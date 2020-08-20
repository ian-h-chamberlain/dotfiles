set rg_opts \
    --only-matching \
    --no-column \
    --no-line-number \
    --color never \
    --no-filename

function __complete_cmd
    complete --no-files --command $argv
end

function __list_targets
    set -l search_regex $argv[1]

    set -l build_dir (gbase)"/build"

    vssh "if test -d $build_dir; cd $build_dir && cat i95_cmake_targets.txt; end" | egrep "$search_regex"
end

function __get_build_opts
    set build_script (gbase)/tools/env_scripts/build
    if ! test -x $build_script
        return
    end

    $build_script -h \
        | rg $rg_opts --replace '$1' -- '-(\S+)\s+[-].*$' - \
        | grep -v '\[|\]' \
        | string replace '/' "\n" -- \
        | string trim --
end

function __complete_build_opts
    set cmd $argv[1]

    for build_opt in (__get_build_opts)
        if string match --quiet "*=*" -- $build_opt
            set split_opt (string split "=" $build_opt)
            __complete_cmd $cmd --old-option $split_opt[1] -x
        else if string match "(no)*" -- $build_opt
            set positive_opt (string replace "(no)" "" -- $build_opt)
            __complete_cmd $cmd --old-option $positive_opt
            __complete_cmd $cmd --old-option "no$positive_opt"
        else
            __complete_cmd $cmd --old-option "$build_opt"
        end
    end
end
