function fish_prompt --description 'Write out the prompt'
    set -l last_status $status

    if test $last_status -eq 0
        set -g __fish_prompt_status (set_color --bold green)
    else
        set last_status (
            fish_status_to_signal $last_status |
            string replace 'SIG' '' |
            string pad -w 4
        )
        set -g __fish_prompt_status (set_color --bold brred)'['$last_status'] '
    end

    if not set -q __fish_prompt_normal
        set -g __fish_prompt_normal (set_color normal)
    end

    if not set -q __fish_prompt_cwd
        set -g __fish_prompt_cwd (set_color cyan)
    end

    set color_chars 0

    set -g magenta (set_color magenta)
    set -g white (set_color brwhite)

    if command -qs pyenv
        set pyenv_version (pyenv version-name | string split ':')
    end

    if test -n "$pyenv_version"
        set -g __fish_prompt_pyenv "$white"'('"$pyenv_version"')'" $__fish_prompt_normal"
    else
        set -g __fish_prompt_pyenv ""
    end

    set __fish_prompt_nix ""
    if string match --quiet -- '*/nix/store/*' "$PATH"
        set __fish_prompt_nix "$white""( nix) $__fish_prompt_normal"
    end

    set -l prompt_hostname (prompt_hostname)
    # Color hostname magenta if we're in a container, otherwise just use it as-is
    if test -f /run/.containerenv # podman
        or test -f /.dockerenv # docker
        set prompt_hostname (set_color magenta)(prompt_hostname)(set_color normal)
    end

    set -l prompt_os (uname)
    if test $prompt_os = Darwin
        set prompt_os " "
    else if test $prompt_os = Linux # Maybe could special-case nixos here?
        set prompt_os " "
    else
        set prompt_os ""
    end

    set prompt_os "$white$prompt_os$__fish_prompt_normal"

    set first_line (
        echo -n -s "$prompt_os" "$__fish_prompt_pyenv" "$__fish_prompt_nix" \
            '[' "$USER" '@' "$prompt_hostname" ']'  \
            ' ' "$__fish_prompt_cwd" (prompt_pwd)
    )

    set remaining_char_count (
        math $COLUMNS + $color_chars - (string length -- "$first_line")
    )

    # Minimum branch len cannot be negative
    if test "$remaining_char_count" -lt 0
        set remaining_char_count 0
    end

    set -g __fish_git_prompt_showdirtystate true
    set -g __fish_git_prompt_showuntrackedfiles true
    set -g __fish_git_prompt_showcolorhints true
    set -g __fish_git_prompt_use_informative_chars true

    set -g __fish_git_prompt_describe_style contains
    set -g __fish_git_prompt_showupstream auto

    set -l default_color bryellow -i -b normal
    set -g __fish_git_prompt_color $default_color
    set -g __fish_git_prompt_color_branch $default_color
    set -g __fish_git_prompt_color_branch_detached brblack

    # Partial workaround for https://github.com/fish-shell/fish-shell/issues/10175
    # This ends up with two separators sometimes but better than nothing I guess
    set -g __fish_git_prompt_char_upstream_prefix (set_color $default_color)'|'(set_color green)
    # Once fixed:
    # set -g __fish_git_prompt_color_upstream green

    set -g __fish_git_prompt_shorten_branch_len $remaining_char_count

    set -l vcs_prompt (__fish_vcs_prompt)
    if string length -q -- $vcs_prompt
        set first_line "$first_line""$vcs_prompt"
    end

    set -l symbol '§'
    if test (id -u) -eq 0
        set symbol '♯'
    end

    echo -n -s "$first_line" "$__fish_prompt_normal" \n "$__fish_prompt_status" "$symbol " "$__fish_prompt_normal"
end
