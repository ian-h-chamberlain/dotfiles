function github_set_pr
    git config branch.(git branch --show-current).github-pr-owner-number \
      (gh pr view --json url | jq -r .url | sed 's@https://github.com/@@; s@/pull/@#@; s@/@#@g')
end
