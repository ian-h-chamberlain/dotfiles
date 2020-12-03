function vssh
    function print_help
        set -l cmd (status current-command)
        echo $cmd": connect to dev VM and optionally run a command."
        echo
        echo "USAGE: $cmd [options] [command]"
        echo
        echo "The working directory will be changed to match \$PWD as long as"
        echo "that directory exists on the dev VM as well."
        echo
        echo "OPTIONS:"
        echo "  -T              disable pseudo-tty allocation. Useful for scripting"
        echo "  -h, --help      Show this help"
        echo
    end


    # Allow disabling pseudo-tty via '-T' arg
    set -l options \
        (fish_opt --short=h --long=help) \
        (fish_opt --short=T)

    set -l cmd (status current-command)
    argparse --name=$cmd $options -- $argv; or return $status

    if test "$_flag_help" != ""
        print_help >&2
        return
    end

    set -l host "dev"
    if set repo_path (gbase)
        set host (basename (gbase))

        if ping -c 1 -W 1 $RHOST >/dev/null 2>&1
            set host $RHOST
        end
    end

    set -l ssh_args
    if test "$_flag_T" != ""
        set -a ssh_args "-T"
    else
        set -a ssh_args "-t"
    end

    if ! count $argv >/dev/null
        # Just run the default login shell
        set cmd 'exec $SHELL -li'
    else
        # Run the command specified after cd to working dir
        set cmd "$argv"
    end

    set working_dir (pwd)
    set ssh_cmd "test -d $working_dir && cd $working_dir; $cmd"

    command ssh $ssh_args $host "$ssh_cmd"
end
