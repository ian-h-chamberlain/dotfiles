# Set fish_user_paths here instead of fish_variables to expand $HOME per-machine
set -U fish_user_paths ~/.cargo/bin $fish_user_paths

# Run nvm to update fish_user_paths for npm installs. Allow failure if running
# outside home directory (no .nvmrc found), and run in background to avoid
# blocking the shell from starting
functions -q nvm; and nvm &>/dev/null & || true

if not set -q DOCKER_NAME; and test -f /etc/profile.d/docker_name.sh
    set -gx DOCKER_NAME (sed -E 's/.*DOCKER_NAME=(.+)/\1/' /etc/profile.d/docker_name.sh)
end

if status is-interactive; and status is-login
    if command -qs thefuck
        thefuck --alias | source
    end

    if command -qs pyenv
        pyenv init - | source
        pyenv virtualenv-init - | source
    end
end

# Used to ensure Docker cache hits on dev VM
umask 0002
