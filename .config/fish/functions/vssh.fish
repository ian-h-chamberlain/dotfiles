function vssh
	set -x RHOST (basename (gbase))

    set -l host

    if ping -c 1 -W 1 $RHOST >/dev/null 2>&1
        set host $RHOST
    else
        set host dev
    end

    if ! count $argv >/dev/null
        set -l working_dir (pwd)
        set -l cmd "test -d $working_dir && cd $working_dir; exec \$SHELL -li"

        command ssh -t $host "$cmd"
    else
        command ssh $host $argv
    end
end
