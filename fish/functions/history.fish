# Defined in /Users/ichamberlain/.config/fish/functions/history.fish @ line 2
function history --description alias\ history\ \'history\ --show-time=\"\%F\ \%T\ \"\'
	builtin history --reverse --show-time="%F %T \$ " $argv;
end
