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
    set -l search_regex

    if count $argv >/dev/null
        set search_regex $argv[1]
    else
        set search_regex '.*'
    end

    set -l build_dir build
    vssh -T "if test -d $build_dir; cat $build_dir/i95_cmake_targets.txt; end" \
        | egrep $search_regex
end

function __get_build_opts
    if set build_script (gbase 2>/dev/null)/tools/env_scripts/build
        and ! test -x $build_script
        return
    end

    $build_script -h \
        | rg $rg_opts --replace '$1' -- '-(\S+)\s+[-].*$' - \
        | grep -v '\[|\]' \
        | string replace / "\n" -- \
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
