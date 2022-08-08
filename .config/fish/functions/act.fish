function act
    set -x DOCKER_HOST "unix://$HOME/.colima/docker.sock"
    command act $argv
end
