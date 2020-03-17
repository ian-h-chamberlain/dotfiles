# Defined in /Users/ichamberlain/.config/fish/functions/dsh.fish @ line 2
function dsh
	set tools_dsh (gbase)/tools/dsh

	if test (uname) = "Darwin"
        echo "dsh not supported on macOS!"
        return 1
    end
    
    if ! test -x $tools_dsh
        echo "'$tools_dsh' is not executable!"
        return 1
    end

    $tools_dsh $argv
end
