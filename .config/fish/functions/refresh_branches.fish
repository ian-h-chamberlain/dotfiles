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
        "release/5.3" \
        "release/5.2" \
        "release/5.1" \
        "release/5.0" \
        "release/4.5"

    if test (uname) != "Darwin"
        set dlib (/usr/local/bin/gbase)"/tools/dlib.sh"
    end

    for branch in $branches
        echo "Refreshing upstream branch '$branch'"

        if ! git fetch --prune origin $branch:$branch
            echo "Failed to pull '$branch'"
            continue
        end

        echo
    end
end
