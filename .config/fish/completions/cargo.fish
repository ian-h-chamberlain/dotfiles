if test -f /usr/local/share/fish/completions/cargo.fish
    source /usr/local/share/fish/completions/cargo.fish
else if test -f /usr/share/fish/completions/cargo.fish
    source /usr/share/fish/completions/cargo.fish
end

# https://github.com/fish-shell/fish-shell/issues/8429
function __list_cargo_examples
    if not test -d ./examples
        return
    end

    cargo run --example 2>&1 | string replace -rf '^\s+' ''
end
