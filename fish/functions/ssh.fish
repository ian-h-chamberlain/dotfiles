# Defined in /Users/ichamberlain/.config/fish/functions/ssh.fish @ line 2
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
