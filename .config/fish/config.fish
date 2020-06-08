if not set -q DOCKER_NAME; and test -f /etc/profile.d/docker_name.sh
    set -gx DOCKER_NAME (sed -E 's/.*DOCKER_NAME=(.+)/\1/' /etc/profile.d/docker_name.sh)
end

if status is-interactive; and status is-login
    command -sq thefuck; and source (thefuck --alias | psub)

    if command -qs pyenv
        source (pyenv init - | psub)
        source (pyenv virtualenv-init - | psub)
    end
end

# Used to ensure Docker cache hits on dev VM
umask 0002

source ~/.config/fish/iterm2_shell_integration.fish
