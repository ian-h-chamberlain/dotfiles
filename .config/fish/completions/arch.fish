# This is basically what `command` and `exec` do for their flags
complete -c arch -n 'test (count (commandline -opc)) -eq 1' \
    -o x86_64 -d "64-bit intel architecture"
complete -c arch -n 'test (count (commandline -opc)) -eq 1' \
    -o arm64 -d "64-bit arm architecture"
# We could add other archs here too but meh, these are the common ones

complete -c arch -xa "(__fish_complete_subcommand)"
