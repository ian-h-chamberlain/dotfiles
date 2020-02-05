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
    set search_regex $argv[1]

    rg $rg_opts --glob 'CMakeLists.txt' --replace '$target' -- $search_regex'.*$' (gbase) \
        | string trim -- \
        | string replace '${PROJECT_NAME}' '128T' -- \
        | egrep -v '\$|#.*' # exclude things with unexpanded variables or commented out
end

function __complete_build_opts
    set cmd $argv[1]

    set build_script (gbase)/tools/env_scripts/build
    if ! test -x $build_script
        return
    end

    set build_opts (
        $build_script -h \
        | rg $rg_opts --replace '$1' -- '-(\S+)\s+[-].*$' - \
        | grep -v '\[|\]' \
        | string replace '/' "\n" -- \
        | string trim --
    )

    for build_opt in $build_opts
        if string match --quiet "*=*" -- $build_opt
            set split_opt (string split "=" $build_opt)
            __complete_cmd $cmd --old-option $split_opt[1] -x
        else if string match "(no)*" -- $build_opt
            set positive_opt (string replace "(no)" "" -- $build_opt)
            __complete_cmd $cmd --old-option $positive_opt
            __complete_cmd $cmd --old-option "no$positive_opt"
        else
            __complete_cmd $cmd --old-option $build_opt
        end
    end
end
