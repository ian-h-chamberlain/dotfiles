function cargo --wraps cargo
    # Helper alias to pick up any extra configuration files, in lieu of a cargo feature that does
    # this kind of thing (config.local.toml or whatever).
    set -l rustup_arg
    if string match -q '+*' -- "$argv[1]"
        set rustup_arg "$argv[1]"
        set --erase argv[1]
    end

    # Dang, this won't work for e.g. cargo aliases to external subcommands, since they won't be passed
    # the config flag, and we can't really know whether they need `--` to separate args or what.
    # Is there maybe an env var we can set to force cargo to pickup this config?
    for extra_config_file in ~/.config/cargo/config.*.toml ~/.cargo/config.*.toml
        set -p argv --config "$extra_config_file"
    end

    echo >&2 + cargo $rustup_arg $argv
    command cargo $rustup_arg $argv
end
