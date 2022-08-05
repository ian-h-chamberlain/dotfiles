source (dirname (status --current-filename))/../i95_cmake_targets.fish

function __test_targets
    __list_targets '.*Test$'
end

__complete_cmd rcheck -a '(__test_targets)'


# Options to rcheck
__complete_cmd rcheck --short-option=h
__complete_cmd rcheck --long-option="help"

function __complete_rcheck_opt
    set -l opt $argv[1]
    set -e argv[1]
    __complete_cmd rcheck --long-option="$opt" --exclusive $argv
end

__complete_rcheck_opt test-arg

# TODO: use opts parsed from build script:
# __complete_build_opts "rcheck --build-arg"
__complete_rcheck_opt build-arg

__complete_cmd rcheck --short-option=d
__complete_rcheck_opt dry-run
