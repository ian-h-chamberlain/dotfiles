# Override function in /usr/local/share/fish/completions/cargo.fish
function __list_cargo_examples
    if not test -d ./examples
        return
    end

    find ./examples -mindepth 1 \( \
        -type f -name "*.rs" -or -type d \
        \) -exec basename '{}' \; | string replace '.rs' ''
end
