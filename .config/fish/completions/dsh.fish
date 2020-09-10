function __fish_dsh_complete_docker_containers
    docker ps --format '{{.Names}}\t{{.ID}}'
end

complete -x -c dsh \
    --short-option=n \
    --description "Start or attach to a named container" \
    --arguments '(__fish_dsh_complete_docker_containers)'

complete -c dsh --short-option=b \
    --description "Use build cache"

complete -c dsh --short-option=i \
    --description "Specify docker image"

complete -c dsh --short-option=f \
    --description "Specify dockerfile"

complete -c dsh --short-option=s \
    --description "Specify SSH port to publish"

complete -c dsh --short-option=- \
    --description "Forward remaining args to shell in container"

