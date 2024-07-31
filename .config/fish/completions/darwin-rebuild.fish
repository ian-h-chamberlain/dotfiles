# Skip changelog because I never use it and I want to complete `darwin-rebuild c`
set command_names edit switch activate build check

complete -c darwin-rebuild -n "not __fish_seen_subcommand_from $command_names" -fa "$command_names"
complete -c darwin-rebuild -n "__fish_seen_subcommand_from $command_names" \
    -l flake -x \
    -s I -r \
    -l substituters -x

complete -c darwin-rebuild -n "__fish_seen_subcommand_from $command_names" \
    -l no-flake \
    -s v -l verbose \
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
