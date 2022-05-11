source /usr/local/share/fish/completions/cargo.fish

# https://github.com/fish-shell/fish-shell/issues/8429
function __list_cargo_examples
    if not test -d ./examples
        return
    end

    cargo run --example 2>&1 | string replace -rf '^\s+' ''
end