# Defined in /var/folders/4w/bjgmcfds1nv33zqkhf2q2_340000gp/T//fish.5lI4yj/rcheck.fish @ line 2
function rcheck
	source ~/.config/fish/functions/remote_cmd.fish
    set -l build_targets
    set -l test_targets

    for target in $argv
        if string match -q -- '-*' $target
            set -a build_targets $target
        else
            set -a build_targets $target"_unity"
            set -a test_targets $target
        end
    end

	remote_cmd rmake $build_targets '&&' validate -Vc -run $test_targets
end
