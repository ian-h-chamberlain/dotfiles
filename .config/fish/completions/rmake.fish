source (dirname (status --current-filename))/../i95_cmake_targets.fish

function __build_targets
    __list_targets '.+'
end

__complete_cmd rmake -a '(__build_targets)'
__complete_build_opts rmake
