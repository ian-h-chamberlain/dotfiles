if begin
        ! functions -q __fish_git_using_command
        and test -f /usr/local/share/fish/completions/git.fish
    end
    source /usr/local/share/fish/completions/git.fish
end

if functions -q __fish_git_using_command
    # Add completion for --no-verify
    complete -x -c git -n '__fish_git_using_command commit' \
        --long no-verify --short n --description 'Bypass the pre-commit and commit-msg hooks'

    # Add branch completions for custom aliases
    complete -x -c git -n '__fish_git_using_command bpull' \
        --arguments '(__fish_git_ranges)'

    # Force file and revision completion, after `--` exclude revisions
    complete -F -c git -n '__fish_git_using_command ld ; and not contains -- -- (commandline -opc)' \
        --arguments '(__fish_git_ranges)'

    # ls only accepts a single revision argument
    complete -x -c git -n '__fish_git_using_command ls' --arguments '(__fish_git_ranges)'
end
