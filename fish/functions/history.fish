# Defined in /var/folders/4w/bjgmcfds1nv33zqkhf2q2_340000gp/T//fish.Q0gu4Z/history.fish @ line 2
function history --description alias\ history\ \'history\ --show-time=\"\%F\ \%T\ \"\'
	builtin history --reverse --show-time="%F %T " $argv;
end
