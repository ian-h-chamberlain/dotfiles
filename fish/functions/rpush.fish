# Defined in /Users/ichamberlain/.config/fish/functions/rpush.fish @ line 2
function rpush
	source ~/.config/fish/functions/remote_cmd.fish
	remote_cmd rpush $argv
	greset
end
