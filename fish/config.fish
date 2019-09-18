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
