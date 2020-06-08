# Defined in /var/folders/4w/bjgmcfds1nv33zqkhf2q2_340000gp/T//fish.Y3llUP/remote_cmd.fish @ line 2
function remote_cmd
	set -l escaped_args

    for arg in $argv[2..-1]
        switch $arg
            case '&&' '||' ';'
                set -a escaped_args $arg
            case '*'
                set -a escaped_args (string escape --no-quoted -- $arg)
        end
    end

    command $argv[1] $escaped_args
end
