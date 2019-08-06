function __bazel_needs_command
    set cmd (commandline -opc)
    if [ (count $cmd) -eq 1 ]
        return 0
    else
        return 1
    end
end

function __bazel_using_command
    set cmd (commandline -opc)
    if [ (count $cmd) -gt 1 ]
        if [ $argv[1] = $cmd[2] ]
            return 0
        end
    end
    return 1
end

function __bazel_workspace
    set path (pwd)
    while ! [ -f $path/WORKSPACE ]
        if [ $path = "/" ]
            return 1
        end
        set path (string split --max 1 --right / $path)[1]
    end
    echo $path
end

function __bazel_output
    command bazel $argv --keep_going 2>/dev/null
end

function __bazel_targets
    # Not in a workspace
    if ! __bazel_workspace
        return 0
    end

    set target (commandline --tokenize --current-process)[-1]

    if string match --quiet --regex '^\-\-' -- $target
        return 0
    end

    if ! string match --quiet --regex '^//' -- $target
        # Only deal with absolute targets
        echo '//'
    else if string match --quiet '*:*' -- $target
        # OK, now find the targets in this package
        set local_part (string split ':' -- $target)[1]
        echo 'all'
        __bazel_output query "kind(\"$argv[1] rule\", $local_part/...:all)"
        echo $local_part:all
    else
        # I think this query can be optimized more, and probably cached somehow too
        __bazel_output query "kind(\"$argv[1] rule\", //...:all)"
    end
end

function __bazel_complete
    complete --no-files --command bazel $argv
end


# TODO dynamically generate this list from bazel itself
# Ideally, this would be done only once and cached
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


# TODO complete 'help' with the possible commands
__bazel_complete -n '__bazel_using_command build'    -a '(__bazel_targets ".*")'
__bazel_complete -n '__bazel_using_command coverage' -a '(__bazel_targets ".*_bin|_.*test|.*binary")'
__bazel_complete -n '__bazel_using_command test'     -a '(__bazel_targets ".*_test")'
__bazel_complete -n '__bazel_using_command run'      -a '(__bazel_targets ".*_bin|_.*test|.*binary")'
