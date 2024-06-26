function sync_file
    set -l scp_args

    if test (count -- $argv) != 3
        set -l cmd (status current-command)

        echo "$cmd: Copy a file to or from a remote using scp"
        echo
        echo "USAGE: $cmd {REMOTE FILE | FILE REMOTE}"
        echo
        echo "Examples:"
        echo
        echo "  Copy local file to remote:"
        echo "    $cmd my/local/file.txt root@1.1.1.1"
        echo
        echo "  Copy remote file to local:"
        echo "    $cmd myhost.com my/local/file.txt"
        echo

        return 1
    end

    if test -f $argv[1]
        set -l dest (dirname "$argv[1]")
        echo "Copying '$argv[1]' to '$argv[2]:$dest'"
        ssh "$argv[2]" "mkdir -p "(pwd)"/$dest"
        set -a scp_args "$argv[1]" "$argv[2]:"(pwd)"/$dest"
    else
        set -l dest (dirname "$argv[2]")
        echo "Copying from '$argv[1]:$argv[2]' to $dest"
        mkdir -p $dest
        set -a scp_args "$argv[1]:"(pwd)"/$argv[2]" (dirname "$argv[2]")
    end

    scp $scp_args
end
