source (dirname (status --current-filename))/bazel_vars.fish

function __tokenize_list
    string replace -r "\n" " " -- $argv | string split --no-empty " "
end

set __bazel_command_list (__tokenize_list $__BAZEL_COMMAND_LIST)

function __bazel_needs_command
    set cmd (commandline -opc)
    if test (count $cmd) -eq 1
        return 0
    end

    for arg in $cmd[2..-1]
        if contains -- $arg $__bazel_command_list
            return 1
        end
    end

    return 0
end

function __bazel_using_command
    set cmd (commandline -opc)
    if test (count $cmd) -gt 1
        if contains -- $argv[1] $cmd
            return 0
        end
    end
    return 1
end

function __bazel_workspace
    set path (pwd)
    while ! test -f $path/WORKSPACE
        if test path = "/"
            return 1
        end
        set path (string split --max 1 --right / $path)[1]
    end
    return 0
end

function __bazel_output
    command bazel $argv 2>/dev/null
end

function __bazel_query
   __bazel_output query --keep_going --order_output=no $argv
end

function __bazel_targets
    if ! __bazel_workspace
        return 0
    end

    set line (commandline --current-process)
    set last_char (string sub --start -1 -- $line)
    set target (string split --no-empty ' ' -- $line)[-1]

    if test $last_char = " "; or string match --quiet --regex '^\-' -- $target
        return 0
    end

    if ! string match --quiet '//*' -- $target
        # Only deal with absolute targets
        echo '//'
    else
        set dot_target (string match --regex '(.*[\/])[.]{0,3}$' -- $target)
        and echo $dot_target[2]"..."

        set target_types $argv[1] "rule"

        if string match --quiet '*:*' -- $target
            # OK, now find the targets in this package
            set package (string split ':' -- $target)[1]
            set all_targets "$package:all"

            echo $all_targets
            __bazel_query "kind('$target_types', $all_targets)"
        else
            set cur_package (string match --regex '(.*)\/[^\/]*' -- $target)[2]
            __bazel_query "kind('$target_types', $cur_package/...:all)"
        end
    end
end

function __bazel_complete
    complete --no-files --command bazel $argv
end

function __bazel_complete_options
    set condition $argv[1]
    set options_list (__tokenize_list $argv[2])

    # Enumerate all the startup options as "long options"
    for option in $options_list
        set stripped_opt (string replace -r '^--' '' -- $option)
        set completion_params --no-files

        if string match -r '=$' -- $stripped_opt
            set -a completion_params --require-parameter
        else if string match '=path' -- $stripped_opt
            set completion_params --require-parameter
        else if string match '={' -- $stripped_opt
            set -a completion_params --require-parameter
            set enum_values \
                (string replace -r '.*=\{(.*)\}$' '$1' -- $stripped_opt | string split ',' --)
            set -a completion_params --arguments="$enum_values"
        end

        set stripped_opt (string replace -r '=.*' '' -- $stripped_opt)

        complete --command bazel -n "$condition" -l $stripped_opt $completion_params
    end

end


# Generate startup options when no command is specified yet
__bazel_complete_options '__bazel_needs_command' $__BAZEL_STARTUP_OPTIONS

# TODO __bazel_complete_options for the following:
# __BAZEL_INFO_KEYS
# __BAZEL_COMMAND_*_FLAGS
# somehow deal with __BAZEL_COMMAND_*_ARGUMENT


__bazel_complete_options '__bazel_using_command build'  $__BAZEL_COMMAND_BUILD_FLAGS
__bazel_complete_options '__bazel_using_command test'   $__BAZEL_COMMAND_TEST_FLAGS
# __BAZEL_COMMAND_LIST
# __BAZEL_COMMAND_ANALYZE_PROFILE_ARGUMENT
# __BAZEL_COMMAND_ANALYZE_PROFILE_FLAGS
# __BAZEL_COMMAND_AQUERY_ARGUMENT
# __BAZEL_COMMAND_AQUERY_FLAGS
# __BAZEL_COMMAND_BUILD_ARGUMENT
# __BAZEL_COMMAND_BUILD_FLAGS
# __BAZEL_COMMAND_CANONICALIZE_FLAGS_FLAGS
# __BAZEL_COMMAND_CLEAN_FLAGS
# __BAZEL_COMMAND_CONFIG_ARGUMENT
# __BAZEL_COMMAND_CONFIG_FLAGS
# __BAZEL_COMMAND_COVERAGE_ARGUMENT
# __BAZEL_COMMAND_COVERAGE_FLAGS
# __BAZEL_COMMAND_CQUERY_ARGUMENT
# __BAZEL_COMMAND_CQUERY_FLAGS
# __BAZEL_COMMAND_DUMP_FLAGS
# __BAZEL_COMMAND_FETCH_ARGUMENT
# __BAZEL_COMMAND_FETCH_FLAGS
# __BAZEL_COMMAND_HELP_ARGUMENT
# __BAZEL_COMMAND_HELP_FLAGS
# __BAZEL_COMMAND_INFO_ARGUMENT
# __BAZEL_COMMAND_INFO_FLAGS
# __BAZEL_COMMAND_LICENSE_FLAGS
# __BAZEL_COMMAND_MOBILE_INSTALL_ARGUMENT
# __BAZEL_COMMAND_MOBILE_INSTALL_FLAGS
# __BAZEL_COMMAND_PRINT_ACTION_ARGUMENT
# __BAZEL_COMMAND_PRINT_ACTION_FLAGS
# __BAZEL_COMMAND_QUERY_ARGUMENT
# __BAZEL_COMMAND_QUERY_FLAGS
# __BAZEL_COMMAND_RUN_ARGUMENT
# __BAZEL_COMMAND_RUN_FLAGS
# __BAZEL_COMMAND_SHUTDOWN_FLAGS
# __BAZEL_COMMAND_SYNC_FLAGS
# __BAZEL_COMMAND_TEST_ARGUMENT
# __BAZEL_COMMAND_TEST_FLAGS
# __BAZEL_COMMAND_VERSION_FLAGS


__bazel_complete -n '__bazel_needs_command' -a analyze-profile    -d 'Analyzes build profile data.'
__bazel_complete -n '__bazel_needs_command' -a build              -d 'Builds the specified targets.'
__bazel_complete -n '__bazel_needs_command' -a coverage           -d 'Runs tests and collects coverage'
__bazel_complete -n '__bazel_needs_command' -a canonicalize-flags -d 'Canonicalizes a list of bazel options.'
__bazel_complete -n '__bazel_needs_command' -a clean              -d 'Removes output files and optionally stops the server.'
__bazel_complete -n '__bazel_needs_command' -a dump               -d 'Dumps the internal state of the bazel server process.'
__bazel_complete -n '__bazel_needs_command' -a fetch              -d 'Fetches external repositories that are prerequisites to the targets.'
__bazel_complete -n '__bazel_needs_command' -a help               -d 'Prints help for commands, or the index.'
__bazel_complete -n '__bazel_needs_command' -a info               -d 'Displays runtime info about the bazel server.'
__bazel_complete -n '__bazel_needs_command' -a mobile-install     -d 'Installs targets to mobile devices.'
__bazel_complete -n '__bazel_needs_command' -a query              -d 'Executes a dependency graph query.'
__bazel_complete -n '__bazel_needs_command' -a run                -d 'Runs the specified target.'
__bazel_complete -n '__bazel_needs_command' -a shutdown           -d 'Stops the bazel server.'
__bazel_complete -n '__bazel_needs_command' -a test               -d 'Builds and runs the specified test targets.'
__bazel_complete -n '__bazel_needs_command' -a version            -d 'Prints version information for bazel.'


__bazel_complete -n '__bazel_using_command help'     -a '(__tokenize_list $__BAZEL_COMMAND_LIST)'

__bazel_complete -n '__bazel_using_command build'    -a '(__bazel_targets ".*")'
__bazel_complete -n '__bazel_using_command coverage' -a '(__bazel_targets "binary|test")'
__bazel_complete -n '__bazel_using_command test'     -a '(__bazel_targets "test")'
__bazel_complete -n '__bazel_using_command run'      -a '(__bazel_targets "test|binary")'
