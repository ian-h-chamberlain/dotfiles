# Defined in /var/folders/4w/bjgmcfds1nv33zqkhf2q2_340000gp/T//fish.iwiyKy/tmux_attach.fish @ line 2
function tmux_attach
	if test (uname) = "Darwin"
        vssh -t tmux_attach
    else
        if tmux ls
            if test $TERM_PROGRAM = "iTerm.app"
                command tmux -CC attach $argv
            else
                command tmux attach $argv
            end
        end
    end
end
