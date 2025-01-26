# Skip changelog because I never use it and I want to complete `darwin-rebuild c`
set command_names edit switch activate build check

# subcommands and command-like longargs
complete -c darwin-rebuild -n "not __fish_seen_subcommand_from $command_names" \
    -f -a "$command_names"
complete -c darwin-rebuild -n "not __fish_seen_subcommand_from $command_names" \
    -f \
    -l rollback \
    -l list-generations

# It would be nice to complete generation numbers here, but --list-generations
# requires sudo to obtain the profile lockfile. Maybe could just extract
# from `ls /nix/var/nix/profiles/system-*-link` as "close enough", otherwise
# making the profile dir writable might be sufficient...
complete -c darwin-rebuild -n "not __fish_seen_subcommand_from $command_names" \
    -f \
    -s G -l switch-generation -x

# Options that require args
complete -c darwin-rebuild -n "__fish_seen_subcommand_from $command_names" \
    -l flake -x \
    -s I -r \
    -l substituters -x \
    -l profile-name -x -s p \
    -l override-input -r \
    -l update-input -x \
    -l arg -l argstr -l option -x \
    -l max-jobs -s j -l core -s I -x

# Flags
complete -c darwin-rebuild -n "__fish_seen_subcommand_from $command_names" \
    -l no-flake \
    -s v -l verbose \
    -l no-build-hook \
    -s Q \
    -l dry-run \
    -l keep-going -s k \
    -l keep-failed -s k \
    -l fallback \
    -l show-trace \
    -l impure \
    -l recreate-lock-file \
    -l no-update-lock-file \
    -l refresh \
    -l offline
