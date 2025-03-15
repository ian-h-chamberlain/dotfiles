if test -f $__fish_data_dir/completions/cargo.fish
    source $__fish_data_dir/completions/cargo.fish
end

if false
    # TODO: this works, but it breaks regular subcommand completion since
    # +xyz appears like a subcommand. Probably this would take some upstream fix
    # to work properly.

    function __fish_in_subcommand_from
        set -l token (commandline -pt)
        string match $argv"*" $token
    end

    if command -q rustup; and test -f $__fish_data_dir/completions/rustup.fish
        source $__fish_data_dir/completions/rustup.fish

        # Also taken from rustup.fish, but can't reuse since they are locals:
        set -l __rustup_toolchains (rustup toolchain list | string replace -r "\s+.*" '')
        set -l __rustup_toolchains_short (__rustup_strip_common_suffix_strict $__rustup_toolchains)

        # Stripped prefix still doesn't reflect the fact that +nightly +beta etc. work:
        set -a __rustup_toolchains_short nightly beta stable

        complete -c cargo -f -c cargo -n '__fish_in_subcommand_from +' -a (printf '+%s ' $__rustup_toolchains_short)
    end
end

# Check command works the same as b/build basically so we can reuse those completions. Fixed in 4.0
# https://github.com/fish-shell/fish-shell/pull/10499
for x in check c
    complete -c cargo -x -n "__fish_seen_subcommand_from $x" -l bench -a "(cargo bench --bench 2>&1 | string replace -rf '^\s+' '')"
    complete -c cargo -n "__fish_seen_subcommand_from $x" -l lib -d 'Only this package\'s library'
    complete -c cargo -x -n "__fish_seen_subcommand_from $x" -l test -a "(cargo test --test 2>&1 | string replace -rf '^\s+' '')"
end

for x in c check
    complete -c cargo -x -n "__fish_seen_subcommand_from $x" -l bin -a "(cargo run --bin 2>&1 | string replace -rf '^\s+' '')"
    complete -c cargo -x -n "__fish_seen_subcommand_from $x" -l example -a "(cargo run --example 2>&1 | string replace -rf '^\s+' '')"
end

# Yoinked directly from cargo.fish, since it's a local variable we can't reuse:
set -l __fish_cargo_subcommands (cargo --list 2>&1 | string replace -rf '^\s+([^\s]+)\s*(.*)' '$1\t$2' | string escape)
# Append user-installed extensions (e.g. cargo-foo, invokable as `cargo foo`) to the list of subcommands (à la git)
set -la __fish_cargo_subcommands (complete -C'cargo-' | string replace -rf '^cargo-(\w+).*' '$1')

complete -c cargo -n "__fish_seen_subcommand_from 3ds" -f -a "$__fish_cargo_subcommands"

# This might be easier with https://github.com/fish-shell/fish-shell/issues/7107
function __fish_cmdline_replace_cmd -a orig_cmd new_cmd
    set -l cmd
    # Not sure exactly why this works, but sudo.fish completion also uses this pattern:
    set -l toks (commandline -opc) (commandline -ct)
    for tok in $toks
        if test "$tok" = $orig_cmd
            set tok $new_cmd
        end
        set -a cmd $tok
    end
    string join -- " " $cmd
end


# Aliases / clippy
# Just sub in `check` for `clippy` and fallback to regular completions
complete -c cargo -n "__fish_seen_subcommand_from clippy" \
    -a '(complete --do-complete (__fish_cmdline_replace_cmd clippy check))'

complete -c cargo -n "__fish_seen_subcommand_from t" \
    -a '(complete --do-complete (__fish_cmdline_replace_cmd t test))'
