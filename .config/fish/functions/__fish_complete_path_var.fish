function __fish_complete_path_var
    # Self-implementation in lieu of https://github.com/fish-shell/fish-shell/issues/5798
    set possible (complete --do-complete)

    if test (count $possible) != 1
        return 1
    end

    # If the completion would be a single varname that exists, complete it without a trailing space
    set -l var (string replace -r '\s' ' ' --  $possible[1] | string split ' ')

    if test "$var[2]" = "Variable:"
        and set -l varname (string trim -c '$' --left "$var[1]")
        and test -d "$$varname"
        # --current-token seems to automatically insert a space unless we add characters to the end,
        # and since we know this is a directory it should be fine to just append a /
        commandline --replace --current-token \$"$varname/"
        return 0
    end

    return 1
end
