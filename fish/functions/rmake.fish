# Defined in /var/folders/4w/bjgmcfds1nv33zqkhf2q2_340000gp/T//fish.4rNgel/rmake.fish @ line 2
function rmake
	source ~/.config/fish/functions/remote_cmd.fish
	remote_cmd rmake $argv
end
