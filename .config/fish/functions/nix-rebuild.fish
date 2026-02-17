function nix-rebuild
    # TODO completions, --wraps probably won't do the trick here although maybe could do some tricks with it...
    if command -q nixos-rebuild
        nixos-rebuild --use-remote-sudo $argv
    else if command -q darwin-rebuild
        sudo darwin-rebuild $argv
    else if command -q home-manager
        home-manager $argv
    else
        echo >&2 "None of nixos-rebuild, darwin-rebuild, home-manager commands were found"
        return 1
    end
end
