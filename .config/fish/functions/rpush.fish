function rpush
	source ~/.config/fish/functions/remote_cmd.fish
	remote_cmd rpush $argv && greset
end
