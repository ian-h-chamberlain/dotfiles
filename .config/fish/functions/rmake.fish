function rmake
    source ~/.config/fish/functions/remote_cmd.fish
    set -ax PATH ~/Documents/tools
    remote_cmd rmake $argv
end
