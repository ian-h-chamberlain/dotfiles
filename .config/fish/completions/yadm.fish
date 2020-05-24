# Normal git completion
complete -c yadm --wraps git

# Piggyback off git helper functions for subcommands
# Descriptions taken from https://yadm.io/docs/common_commands
complete -f -c yadm -n '__fish_git_needs_command' \
    -a list -d "Yadm: print a list of files managed by yadm"
complete -f -c yadm -n '__fish_git_using_command list' \
    --short-option a -d "Yadm: list all managed files, instead of current dir or below"

complete -f -c yadm -n '__fish_git_needs_command' \
    -a alt -d "Yadm: create symlinks for managed files matching alt naming rules"

complete -f -c yadm -n '__fish_git_needs_command' \
    -a encrypt -d 'Yadm: encrypt all files matching the patterns in ~/.config/yadm/encrypt'

complete -f -c yadm -n '__fish_git_needs_command' \
    -a decrypt -d 'Yadm: decrypt files stored in ~/.config/yadm/files.gpg'
complete -f -c yadm -n '__fish_git_using_command decrypt' \
    --short-option l -d "Yadm: list files without decrypting them"

complete -x -c yadm -n '__fish_git_using_command clone' \
    --long-option bootstrap -d "Yadm: automatically run bootstrap on successful clone"