function rdbuild
    # Based on /usr/local/bin/rdbuild
    bash -c "
        set -e
        source /usr/local/bin/rgit_utilities.sh
        rgit_push 'Invoking dbuild on the remote' 'tmux -CC new \"tools/dbuild $argv\"'"
end
