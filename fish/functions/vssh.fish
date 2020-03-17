# Defined in /Users/ichamberlain/.config/fish/functions/vssh.fish @ line 2
function vssh
	set -x RHOST (basename (gbase))

    if ping -c 1 -W 1 $RHOST >/dev/null 2>&1
        ssh $RHOST $argv
    else
        ssh vm1 $argv
    end
end
