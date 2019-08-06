# Defined in /var/folders/4w/bjgmcfds1nv33zqkhf2q2_340000gp/T//fish.PKB8ot/ls.fish @ line 2
function ls --description 'List contents of directory, including hidden files in directory using long format'
	if test (uname) = "Darwin"
        set ls_args "-G"
    else
        set ls_args "--color=auto"
    end
	command ls -Flah $ls_args $argv
end
