source $__fish_data_dir/functions/funced.fish
functions --copy funced __fish_builtin_funced

function funced --wraps __fish_builtin_funced
    set -l funcname
    set -l save
    for arg in $argv
        switch $arg
            case -s --save
                set save 1
            case '-*'
                continue
            case '*'
                set funcname $arg
        end
    end

    if test -z $funcname
        __fish_builtin_funced $argv
        return
    end

    if test -n $save
        set -l saved_func $__fish_config_dir/functions/$funcname.fish
        if test -f $saved_func
            # Re-source the config-dir function to make this path be the one that
            # builtin funced will use for editing the definition. This is useful
            # for things like shell integration that override definitions when loaded
            source $saved_func
        else if test -f $__fish_data_dir/functions/$funcname.fish
            echo "source \$__fish_data_dir/functions/$funcname.fish
functions --copy $funcname __fish_builtin_$funcname
function $funcname --wraps __fish_builtin_$funcname

end" >$saved_func
            source $saved_func
        end
    end

    __fish_builtin_funced $argv
end
