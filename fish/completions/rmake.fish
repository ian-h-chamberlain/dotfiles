source (dirname (status --current-filename))/../i95_cmake_targets.fish

function __build_targets
    __list_targets 'add_executable_128\((?P<target>\S+)'
    __list_targets 'add_library_128\((?P<target>\S+)'
end

__complete_cmd rmake -a '(__build_targets)'
__complete_build_opts rmake
