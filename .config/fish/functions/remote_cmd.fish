function remote_cmd
    if ! git rev-parse HEAD &>/dev/null
        echo "Error: not in a git repository" >&2
        return 1
    end

    set -l escaped_args

    for arg in $argv[2..-1]
        switch $arg
            case '&&' '||' ';'
                set -a escaped_args $arg
            case '*'
                set -a escaped_args (string escape --no-quoted -- $arg)
        end
    end

    # Remote commands require RHOST to be set
    set -x RHOST dev

    if test -d (gbase 2>/dev/null)/tools/rgit
        set rgit_path (gbase 2>/dev/null)/tools/{rgit,env_scripts}
    else
        set rgit_path ~/Documents/workspace/tools/{rgit,env_scripts}
    end

    for add_path in $rgit_path
        if ! contains $add_path $PATH
            set -x --prepend PATH $add_path
        end
    end

    if command -q $argv[1]
        command $argv[1] $escaped_args
    else
        $argv[1] $escaped_args
    end
end
