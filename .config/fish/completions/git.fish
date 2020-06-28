if begin
        ! functions -q __fish_git_using_command
        and test -f /usr/local/share/fish/completions/git.fish
    end
    source /usr/local/share/fish/completions/git.fish
end

if functions -q __fish_git_using_command
    # Add completion for --no-verify
    complete -x -c git -n '__fish_git_using_command commit' \
        -l no-verify -s n -d 'Bypass the pre-commit and commit-msg hooks'
end
