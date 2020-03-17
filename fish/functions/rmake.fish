# Defined in /Users/ichamberlain/.config/fish/functions/rmake.fish @ line 2
function rmake
	source ~/.config/fish/functions/remote_cmd.fish
	remote_cmd rmake $argv
end
