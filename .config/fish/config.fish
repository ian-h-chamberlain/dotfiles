# Set fish_user_paths here instead of fish_variables to expand $HOME per-machine
set -U fish_user_paths

if command -qs npm
    set -Ua fish_user_paths (npm bin)
end

set -Ua fish_user_paths ~/.cargo/bin ~/.pyenv/shims /usr/local/Cellar/pyenv-virtualenv/*/shims

if not set -q DOCKER_NAME; and test -f /etc/profile.d/docker_name.sh
    set -gx DOCKER_NAME (sed -E 's/.*DOCKER_NAME=(.+)/\1/' /etc/profile.d/docker_name.sh)
end

if status is-interactive; and status is-login
    if command -qs thefuck
        source (thefuck --alias | psub)
    end

    if command -qs pyenv
        source (pyenv init - | psub)
        source (pyenv virtualenv-init - | psub)
    end
end

# Used to ensure Docker cache hits on dev VM
umask 0002

source ~/.config/fish/iterm2_shell_integration.fish
