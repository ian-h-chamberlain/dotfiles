# Normal git completion
complete -c yadm --wraps git

function gitconfig_completions
    # gitconfig options, copied from /usr/local/share/fish/completions/git.fish
    # Complete both options and possible parameters to `git config`
    complete -f -c yadm -n '__fish_git_using_command gitconfig' -l global -d 'Get/set global configuration'
    complete -f -c yadm -n '__fish_git_using_command gitconfig' -l system -d 'Get/set system configuration'
    complete -f -c yadm -n '__fish_git_using_command gitconfig' -l local -d 'Get/set local repo configuration'
    complete -f -c yadm -n '__fish_git_using_command gitconfig' -s f -l file -d 'Read config from file'
    complete -f -c yadm -n '__fish_git_using_command gitconfig' -l blob -d 'Read config from blob' -ra '(__fish_complete_suffix '')'

    # If no argument is specified, it's as if --get was used
    complete -c yadm -n '__fish_git_using_command gitconfig; and __fish_is_token_n 3' -fa '(__fish_git_config_keys)'
    complete -f -c yadm -n '__fish_git_using_command gitconfig; and __fish_is_first_arg' -l get -d 'Get config with name' -ra '(__fish_git_config_keys)'
    complete -f -c yadm -n '__fish_git_using_command gitconfig' -l get -d 'Get config with name' -ra '(__fish_git_config_keys)'
    complete -f -c yadm -n '__fish_git_using_command gitconfig' -l get-all -d 'Get all values matching key' -a '(__fish_git_config_keys)'
    complete -f -c yadm -n '__fish_git_using_command gitconfig' -l get-urlmatch -d 'Get value specific for the section url' -r
    complete -f -c yadm -n '__fish_git_using_command gitconfig' -l replace-all -d 'Replace all matching variables' -ra '(__fish_git_config_keys)'
    complete -f -c yadm -n '__fish_git_using_command gitconfig' -l add -d 'Add a new variable' -r
    complete -f -c yadm -n '__fish_git_using_command gitconfig' -l unset -d 'Remove a variable' -a '(__fish_git_config_keys)'
    complete -f -c yadm -n '__fish_git_using_command gitconfig' -l unset-all -d 'Remove matching variables' -a '(__fish_git_config_keys)'
    complete -f -c yadm -n '__fish_git_using_command gitconfig' -l rename-section -d 'Rename section' -r
    complete -f -c yadm -n '__fish_git_using_command gitconfig' -s l -l list -d 'List all variables'
    complete -f -c yadm -n '__fish_git_using_command gitconfig' -s e -l edit -d 'Open configuration in an editor'

    complete -f -c yadm -n '__fish_git_using_command gitconfig' -s t -l type -d 'Value is of given type'
    complete -f -c yadm -n '__fish_git_using_command gitconfig' -l bool -d 'Value is \'true\' or \'false\''
    complete -f -c yadm -n '__fish_git_using_command gitconfig' -l int -d 'Value is a decimal number'
    complete -f -c yadm -n '__fish_git_using_command gitconfig' -l bool-or-int -d 'Value is --bool or --int'
    complete -f -c yadm -n '__fish_git_using_command gitconfig' -l path -d 'Value is a path'
    complete -f -c yadm -n '__fish_git_using_command gitconfig' -l expiry-date -d 'Value is an expiry date'

    complete -f -c yadm -n '__fish_git_using_command gitconfig' -s z -l null -d 'Terminate values with NUL byte'
    complete -f -c yadm -n '__fish_git_using_command gitconfig' -l name-only -d 'Show variable names only'
    complete -f -c yadm -n '__fish_git_using_command gitconfig' -l includes -d 'Respect include directives'
    complete -f -c yadm -n '__fish_git_using_command gitconfig' -l show-origin -d 'Show origin of configuration'
    complete -f -c yadm -n '__fish_git_using_command gitconfig; and __fish_seen_argument get' -l default -d 'Use default value when missing entry'
end

# In general, piggyback off git helper functions for subcommands

# Based on output of `yadm introspect switches`:
complete -f -c yadm -n '__fish_git_needs_command' \
    -l yadm-archive -d 'yadm: Override the location of the yadm encrypted files archive'
complete -f -c yadm -n '__fish_git_needs_command' \
    -l yadm-bootstrap -d 'yadm: Override the location of the yadm bootstrap program'
complete -f -c yadm -n '__fish_git_needs_command' \
    -l yadm-config -d 'yadm: Override the location of the yadm configuration file'
complete -f -c yadm -n '__fish_git_needs_command' \
    -s Y -l yadm-dir -d 'yadm: Override the yadm directory.'
complete -f -c yadm -n '__fish_git_needs_command' \
    -l yadm-encrypt -d 'yadm: Override the location of the yadm encryption configuration'
complete -f -c yadm -n '__fish_git_needs_command' \
    -l yadm-repo -d 'yadm: Override the location of the yadm repository'

# Descriptions taken from yadm man pages
complete -f -c yadm -n '__fish_git_needs_command' \
    -a alt -d 'yadm: Create symlinks for managed files matching alt naming rules'

complete -f -c yadm -n '__fish_git_needs_command' \
    -a bootstrap -d 'yadm: Execute $HOME/.config/yadm/bootstrap if it exists.'

complete -x -c yadm -n '__fish_git_using_command clone' \
    --long-option bootstrap -d 'yadm: Automatically run bootstrap on successful clone' \
    --long-option no-bootstrap -d 'yadm: Prevent bootstrap from running on successful clone'

complete -f -c yadm -n '__fish_git_needs_command' \
    -a decrypt -d 'yadm: decrypt files stored in ~/.config/yadm/files.gpg'
complete -f -c yadm -n '__fish_git_using_command decrypt' \
    --short-option l -d 'yadm: List files without decrypting them'

complete -f -c yadm -n '__fish_git_needs_command' \
    -a encrypt -d 'yadm: Encrypt all files matching the patterns in ~/.config/yadm/encrypt'

complete -f -c yadm -n '__fish_git_needs_command' \
    -a enter -d 'yadm: Run a sub-shell with all Git variables set'

complete -f -c yadm -n '__fish_git_needs_command' \
    -a gitconfig -d 'yadm: Pass options to the "git config" command'

gitconfig_completions

complete -f -c yadm -n '__fish_git_needs_command' \
    -a help -d 'yadm: Print a summary of yadm commands'

complete -f -c yadm -n '__fish_git_needs_command' \
    -a list -d 'yadm: print a List of files managed by yadm'
complete -f -c yadm -n '__fish_git_using_command list' \
    --short-option a -d 'yadm: List all managed files, instead of current dir or below'

complete -f -c yadm -n '__fish_git_needs_command' \
    -a introspect -d 'yadm: Report internal yadm data'
complete -f -c yadm -n '__fish_git_using_command introspect' \
    -a 'commands configs repo switches'

complete -f -c yadm -n '__fish_git_needs_command' \
    -a perms -d 'yadm: Update permissions as described in the PERMISSIONS section'

complete -f -c yadm -n '__fish_git_needs_command' \
    -a upgrade -d 'yadm: Upgrade from version 1 configuration to version 2 configuration'

complete -f -c yadm -n '__fish_git_needs_command' \
    -a version -d 'yadm: Print the version of yadm'
