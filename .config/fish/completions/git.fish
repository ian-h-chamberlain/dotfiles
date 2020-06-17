if begin
        ! command -q __fish_git_using_command
        and test -f /usr/local/share/fish/completions/git.fish
    end
    source /usr/local/share/fish/completions/git.fish
end

# Add completion for --no-verify
complete -x -c git -n '__fish_git_using_command commit' \
    -l no-verify -s n -d 'Bypass the pre-commit and commit-msg hooks'
