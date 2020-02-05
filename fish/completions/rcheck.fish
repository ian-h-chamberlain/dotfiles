source (dirname (status --current-filename))/../i95_cmake_targets.fish

function __test_targets
    __list_targets 'add_executable_128\((?P<target>\S+Test)'
    __list_targets 'add_pdm_test\((?P<target>\S+Test)'
end

__complete_cmd rcheck -a '(__test_targets)'

# TODO: put in after --build-arg
# __complete_build_opts rcheck

# TODO: complete test args (annoying but meh)
