if not functions -q __fish_git_using_command; and test -f $__fish_data_dir/completions/git.fish
    source $__fish_data_dir/completions/git.fish
end

if functions -q __fish_git_using_command
    # Add completion for --no-verify
    complete -x -c git -n '__fish_git_using_command commit' \
        --long no-verify --short n --description 'Bypass the pre-commit and commit-msg hooks'

    # Add branch completions for custom !sh aliases
    for cmd in bpull sswitch ssw ls merge-latest
        complete -x -c git -n "__fish_git_using_command $cmd" \
            --keep-order --arguments '(__fish_git_unique_remote_branches)' \
            --description 'Unique Remote Branches'

        complete -x -c git -n "__fish_git_using_command $cmd" \
            --keep-order --arguments '(__fish_git_local_branches)'
    end

    complete -x -c git -n "__fish_git_using_command ls" --arguments '(__fish_git_ranges)'

    # Force file and revision completion, after `--` exclude revisions
    complete -F -c git -n '__fish_git_using_command ld ; and not contains -- -- (commandline -opc)' \
        --arguments '(__fish_git_ranges)'
end
