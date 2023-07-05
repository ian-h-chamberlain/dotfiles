function docker --wraps=podman --description 'alias docker=podman'
    if command -q podman
        command podman $argv
    else
        command docker $argv
    end
end
