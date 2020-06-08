# Defined in /var/folders/4w/bjgmcfds1nv33zqkhf2q2_340000gp/T//fish.r7lxdD/refresh_branches.fish @ line 2
function refresh_branches
    date
    echo
	echo "=========================================================================="

    echo "Pruning old docker images, containers, etc."
    if type -q docker
        docker system prune --all --force --filter "until=72h"
    end
    echo

	set -l branches \
        "develop" \
        "release/4.5" \
        "release/4.4" \
        "release/4.3" \
        "release/4.2" \
        "feature/rbac"

	if test (uname) != "Darwin"
        set dlib (/usr/local/bin/gbase)"/tools/dlib.sh"
    end

    git stash push -m "temporary stash to update branches" | grep --quiet "No local changes to save"
    set stashed_git_changes $status

    function cleanup --inherit-variable stashed_git_changes
        if test $stashed_git_changes = 1
            git stash pop
        end

        echo "=========================================================================="
        echo
    end

    trap cleanup EXIT

    for branch in $branches
        echo "Refreshing upstream branch '$branch'"

        git checkout $branch
        if ! git pull --prune --ff-only origin $branch
            echo "Failed to pull '$branch'"
            git checkout -
            echo
            continue
        end

        if set -q dlib
            echo "Pulling docker images with dlib '$dlib'"
            bash -c "source $dlib && dlib_pull_release"
        end

        # Restore the previous branch
        git checkout -
        echo
    end
end
