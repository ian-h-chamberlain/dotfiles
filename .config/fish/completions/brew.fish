if not command -sa brew | grep -q -v '\.local'
    return
end

# Find and source the upstream completions, whichever completion dir they live in
for vendor_dir in $fish_complete_path
    if test $vendor_dir != (realpath (status dirname)); and test -e $vendor_dir/brew.fish
        source $vendor_dir/brew.fish
    end
end

# Overrides to make flag suggestions faster.
# TODO: maybe upstream this or something equivalent?
# It's a way better user experience and probably applies everywhere
for brew_suggest in (functions -a | string split ',' | string match '__fish_brew_suggest_*')
    functions -c "$brew_suggest" "__orig$brew_suggest"
    # Use `source` here to "inline" the $brew_suggest variable into the function definition
    echo "function $brew_suggest
        if commandline -t | string match -q -- '-*'
            # If the cursor is in the middle of a flag, return immediately
            return
        else
            # Otherwise, call the original function
            __orig$brew_suggest \$argv
        end
    end" | source
end

# For upstream could probably do something cleaner like this:
# function __fish_brew_complete_arg -a cond -d "A shortcut for defining arguments completion for brew commands"
#     if contains -- -a $argv; or contains -- --arguments $argv
#         # There's no need to run -a completions if we're mid-flag
#         set cond "$cond; and commandline -pt | string match -vq -- -\*"
#     end
#     __orig_fish_brew_complete_arg $cond $argv[2..]
# end


# Custom completions for superatomic/bundle-extensions
__fish_brew_complete_cmd add "Add one or more formulae and/or casks to a Brewfile"
__fish_brew_complete_cmd drop "Drop one or more formulae and/or casks from a Brewfile"

__fish_brew_complete_arg add -s v -l verbose -d "Make some output more verbose"
__fish_brew_complete_arg drop -s v -l verbose -d "Make some output more verbose"

# __fish_brew_complete_arg uses -f so we can't use it with -F
function __fish_brew_complete_file_arg -a cond -d "A shortcut for defining file argument completion for brew commands"
    set -e argv[1]
    # NOTE: $cond can be just a name of a command (or several) or additionally any other condition
    complete -r -F -c brew -n "__fish_brew_command $cond" $argv
end

for cmd in add drop
    __fish_brew_complete_arg $cmd -s g -l global -d "Read the Brewfile from ~/.Brewfile"
    __fish_brew_complete_arg $cmd -l formula -l formulae -d "Treat all named arguments as formulae"
    __fish_brew_complete_arg $cmd -l cask -l casks -d "Treat all named arguments as casks"
    __fish_brew_complete_arg $cmd -s d -l debug -d "Display any debugging information"
    __fish_brew_complete_arg $cmd -s q -l quiet -d "Make some output more quiet"
    __fish_brew_complete_arg $cmd -s v -l verbose -d "Make some output more verbose"
    __fish_brew_complete_arg $cmd -s h -l help -d "Show help message"

    __fish_brew_complete_file_arg $cmd -l file -d "Read the Brewfile from this location"
end

__fish_brew_complete_arg add -l describe -d "Add a descriptive comment above each line"
# Stolen from... somewhere
__fish_brew_complete_arg 'add; and not __fish_seen_argument -l cask -l casks' -a '(__fish_brew_suggest_formulae_all)'
__fish_brew_complete_arg 'add; and not __fish_seen_argument -l formula -l formulae' -a '(__fish_brew_suggest_casks_all)'

function __fish_brew_suggest_bundle -d 'List formulae/casks present in the given Brewfile'
    set bundle_args

    set current_args (commandline --current-process --tokenize --cut-at-cursor)
    argparse --ignore-unknown file= -- $current_args
    if set -q _flag_file
        set -a bundle_args --file="$_flag_file"
    end

    for flag in --global/-g --cask/--casks --formula/--formulae
        set passthrough (string split '/' -- $flag)
        if __fish_brew_opt >/dev/null $passthrough
            set -a bundle_args $passthrough[1]
        end
    end

    if not __fish_brew_opt --formula --formulae --cask --casks >/dev/null
        # The default `bundle list` only does formula but we want to do both
        set -a bundle_args --cask --formula
    end

    # TODO: If we know the file, it might be faster to actually just do a simple
    # grep rather than invoking `brew bundle list`. These completions take a
    brew bundle $bundle_args list 2>/dev/null
end

__fish_brew_complete_arg drop -a '(__fish_brew_suggest_bundle)'
