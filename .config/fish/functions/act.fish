function act
    set -x DOCKER_HOST "unix://$HOME/.colima/x86/docker.sock"
    arch -x86_64 act --container-architecture linux/amd64 $argv
end
