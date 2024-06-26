source (dirname (status --current-filename))/../bazel_vars.fish

function __tokenize_list
    string replace -r "\n" " " -- $argv | string split --no-empty " "
end

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
        if test path = /
            return 1
        end
        set path (string split --max 1 --right / $path)[1]
    end
    echo $path
    return 0
end

function __in_bazel_workspace
    __bazel_workspace &>/dev/null
end

function __bazel_output
    command bazel $argv 2>/dev/null
end

function __bazel_query
    __bazel_output query --keep_going --order_output=no $argv
end

function __bazel_targets
    if ! __in_bazel_workspace
        return 0
    end

    set line (commandline --current-process)
    set last_char (string sub --start -1 -- $line)
    set target (string split --no-empty ' ' -- $line)[-1]

    if test "$last_char" = " "; or string match --quiet --regex '^\-' -- $target
        return 0
    end

    if string match --invert --quiet '//*' -- $target
        # Only deal with absolute targets
        echo //
    else
        set dot_target (string match --regex '(.*[\/])[.]{0,3}$' -- $target)
        and echo $dot_target[2]"..."

        set target_types $argv[1] rule

        if string match --quiet '*:*' -- $target
            # OK, now find the targets in this package
            set package (string split ':' -- $target)[1]
            set all_targets "$package:all"

            set targets (__bazel_query "kind('$target_types', $all_targets)")
            if test (count $targets) -gt 1
                echo $all_targets
            end
            for target in $targets
                echo $target
            end
        else
            set cur_package (string match --regex '(.*)\/[^\/]*' -- $target)[2]
            __bazel_query "kind('$target_types', $cur_package/...:all)"
        end
    end
end

function __bazel_complete
    complete --no-files --command bazel $argv
end

function __bazel_complete_files
    complete --command bazel $argv
end

function __tokenize_options
    __tokenize_list $argv[1] | string replace -r '^--' '' --
end

function __bazel_complete_options
    set condition $argv[1]
    set options_list $$argv[2]

    set completion_varname "$argv[2]_COMPLETIONS"
    if ! set -gq $completion_varname
        set -g $completion_varname

        # Enumerate all the startup options as "long options"
        for stripped_opt in $options_list
            set completion_params --no-files

            if string match --quiet '*=' -- $stripped_opt
                set -a completion_params --require-parameter
            else if string match --quiet '=path' -- $stripped_opt
                set completion_params --require-parameter
            else if string match --quiet '=label' -- $stripped_opt
                # TODO use __bazel_targets
                set completion_params --require-parameter
            else if string match --quiet '*={*}' -- $stripped_opt
                set -a completion_params --require-parameter
                set enum_values \
                    (string replace -r '.*=\{(.*)\}$' '$1' -- $stripped_opt | string split ',' --)
                set -a completion_params --arguments="$enum_values"
            end

            set opt_completion (string replace -r '=.*' '' -- $stripped_opt)
            set escaped_completion_params (string join ';' -- $completion_params)
            set -ag $completion_varname "$opt_completion $escaped_completion_params"
        end
    end


    for completion in $$completion_varname
        # TODO: this string manipulation is what takes so long...
        set split_completion (string split ' ' -- $completion)
        set params (string split ';' -- $split_completion[2])

        if ! complete --command bazel -n "$condition" -l $split_completion[1] $params
            echo "bad stuff happened:"
            set -S split_completion
        end
    end
end

# ==============================================================================
# BEGIN COMPLETIONS
# ==============================================================================

set __bazel_command_list (__tokenize_list $__BAZEL_COMMAND_LIST)
set __bazel_info_keys (__tokenize_list $__BAZEL_INFO_KEYS)

# Naive completion of --config= options. We don't bother trying to figure out
# which configs go with which commands and just dump them all.
set -l bazelrc_files /etc/bazel.bazelrc ~/.bazelrc (__bazel_workspace)/.bazelrc (__bazel_workspace)/user.bazelrc
set -l __bazel_configs
for bazelrc in $bazelrc_files
    if test -e $bazelrc
        set -a __bazel_configs (grep -oE '^[a-z]+:\S+' -- $bazelrc | cut -d: -f2 | sort -u)
    end
end

# Generate startup options when no command is specified yet
if ! set -q $__BAZEL_STARTUP_OPTIONS
    set __STRIPPED_BAZEL_STARTUP_OPTIONS (__tokenize_options $__BAZEL_STARTUP_OPTIONS)
end
__bazel_complete_options __bazel_needs_command __STRIPPED_BAZEL_STARTUP_OPTIONS

# Help completions
# TODO: Instead of special-casing, this split/enum logic should happen for all commands
set -l help_completions (
    string split ',' -- (
        string match -r '\{(.*)\}' -- $__BAZEL_COMMAND_HELP_ARGUMENT
    )[2]
)

__bazel_complete -n '__bazel_using_command help' -a "$__bazel_command_list $help_completions"

# Per-subcommand completions
for subcommand in $__bazel_command_list
    # Make the subcommand itself a completion
    __bazel_complete -n __bazel_needs_command -a $subcommand

    set normalized_name (string upper -- $subcommand | string replace '-' '_' --)

    # Add the _FLAGS for each subcommand
    set flags_arg_name "__BAZEL_COMMAND_"$normalized_name"_FLAGS"
    set stripped_options_arg_name "__STRIPPED_BAZEL_"$normalized_name"_OPTIONS"
    if not set -q $stripped_options_arg_name
        set $stripped_options_arg_name (__tokenize_options $$flags_arg_name)
    end

    __bazel_complete_options "__bazel_using_command $subcommand" $stripped_options_arg_name

    __bazel_complete -n "__bazel_using_command $subcommand" \
        -l config --require-parameter --no-files -a "$__bazel_configs"

    # Use `bazel query` to complete _ARGUMENTS for each subcommand
    set -l argument "__BAZEL_COMMAND_"$normalized_name"_ARGUMENT"
    set -q $argument; and switch $$argument
        case info-key
            __bazel_complete -n "__bazel_using_command $subcommand" -a "$__bazel_info_keys"
        case label
            __bazel_complete -n "__bazel_using_command $subcommand" -a '(__bazel_targets ".*")'
        case label-test
            __bazel_complete -n "__bazel_using_command $subcommand" -a '(__bazel_targets "test")'
        case label-bin
            # We include aliases here, which might not be totally accurate but is nice to include just in case
            __bazel_complete -n "__bazel_using_command $subcommand" -a '(__bazel_targets "binary|test|multirun|alias")'
        case path
            __bazel_complete_files -n "__bazel_using_command $subcommand"
        case '*'
            # Don't allow file completion by default
            __bazel_complete -n "__bazel_using_command $subcommand"
    end
end

# Add descriptions for subcommands
# TODO: it would be preferable to generate these descriptions from `bazel help` output
__bazel_complete -n __bazel_needs_command -a analyze-profile -d 'Analyzes build profile data.'
__bazel_complete -n __bazel_needs_command -a build -d 'Builds the specified targets.'
__bazel_complete -n __bazel_needs_command -a coverage -d 'Runs tests and collects coverage'
__bazel_complete -n __bazel_needs_command -a canonicalize-flags -d 'Canonicalizes a list of bazel options.'
__bazel_complete -n __bazel_needs_command -a clean -d 'Removes output files and optionally stops the server.'
__bazel_complete -n __bazel_needs_command -a dump -d 'Dumps the internal state of the bazel server process.'
__bazel_complete -n __bazel_needs_command -a fetch -d 'Fetches external repositories that are prerequisites to the targets.'
__bazel_complete -n __bazel_needs_command -a help -d 'Prints help for commands, or the index.'
__bazel_complete -n __bazel_needs_command -a info -d 'Displays runtime info about the bazel server.'
__bazel_complete -n __bazel_needs_command -a mobile-install -d 'Installs targets to mobile devices.'
__bazel_complete -n __bazel_needs_command -a query -d 'Executes a dependency graph query.'
__bazel_complete -n __bazel_needs_command -a run -d 'Runs the specified target.'
__bazel_complete -n __bazel_needs_command -a shutdown -d 'Stops the bazel server.'
__bazel_complete -n __bazel_needs_command -a test -d 'Builds and runs the specified test targets.'
__bazel_complete -n __bazel_needs_command -a version -d 'Prints version information for bazel.'
