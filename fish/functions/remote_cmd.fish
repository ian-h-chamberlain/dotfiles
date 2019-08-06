# Defined in /var/folders/4w/bjgmcfds1nv33zqkhf2q2_340000gp/T//fish.RKL6LI/remote_cmd.fish @ line 2
function remote_cmd
	set -x RHOST (basename (gbase))
    command $argv
end
