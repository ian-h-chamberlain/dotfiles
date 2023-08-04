function gh-diff-pr
    # Based on https://daisy.wtf/writing/github-changes-since-last-review

    # Use the GitHub API to get the references we need
    set -l PR_NUMBER $argv[1]
    set -l MY_USER_ID (gh api "/user" -q '.id')
    set -l PR_SHAS (gh api "/repos/{owner}/{repo}/pulls/$PR_NUMBER" -q '.head.sha,.base.sha')
    set -l PR_HEAD_SHA $PR_SHAS[1]
    set -l PR_BASE_SHA $PR_SHAS[2]
    set -l PR_LAST_REVIEW_SHA (gh api "/repos/{owner}/{repo}/pulls/$PR_NUMBER/reviews" \
                     -q "map(select(.user.id == $MY_USER_ID) | .commit_id)[-1]")

    # Fetch the commits we want to compare, unless we already have
    if test (git cat-file -t $PR_LAST_REVIEW_SHA; or echo 'none') != commit \
            -o $(git cat-file -t $PR_HEAD_SHA; or echo 'none') != commit

        git fetch origin $PR_LAST_REVIEW_SHA $PR_HEAD_SHA
    end

    # Compare the ranges
    git range-diff $PR_BASE_SHA $PR_LAST_REVIEW_SHA $PR_HEAD_SHA
end
