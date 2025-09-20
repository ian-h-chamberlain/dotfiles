set subcommands \
    switch boot test build dry-build dry-activate edit repl build-vm \
    build-vm-with-bootloader build-image list-generations

complete -c nixos-rebuild -n "not __fish_seen_subcommand_from $subcommands" \
    -a "$subcommands"
