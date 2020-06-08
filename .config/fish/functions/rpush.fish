# Defined in /var/folders/4w/bjgmcfds1nv33zqkhf2q2_340000gp/T//fish.3j2hva/rpush.fish @ line 2
function rpush
	source ~/.config/fish/functions/remote_cmd.fish
	remote_cmd rpush $argv && greset
end
