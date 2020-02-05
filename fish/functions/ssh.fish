# Defined in /var/folders/4w/bjgmcfds1nv33zqkhf2q2_340000gp/T//fish.PmOWeN/ssh.fish @ line 2
function ssh
	command bash -lc "ssh $argv"
	# if not string match --regex '@' "$argv[1]"
    #         and test (count $argv) -eq 1
    #         and test (uname) == "Darwin"
    #     command ssh "$argv"
    # else
    #     set pwd (pwd)
    #     echo "pwd=$pwd"
    #     command ssh -t "$argv" \
    #         "test -d $pwd; and cd $pwd; fish -l"
    # end
end
