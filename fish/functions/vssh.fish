# Defined in /var/folders/4w/bjgmcfds1nv33zqkhf2q2_340000gp/T//fish.qsQKCF/vssh.fish @ line 2
function vssh
	set RHOST (basename (gbase))
    ssh $RHOST $argv
end
