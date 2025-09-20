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

    set -l nix_icon ""

    # Simple heuristic to tell if we're in a `nix shell` or `nix develop`.
    # Normally PATH would only contain nix profiles or `current-system`,
    # so references to the nix store most likely indicate this.
    set -l __fish_prompt_nix ""
    if string match --quiet -- '*/nix/store/*' "$PATH"
        set __fish_prompt_nix "$white""($nix_icon nix) $__fish_prompt_normal"
    end

    set -l __fish_prompt_direnv ""
    if set -q DIRENV_USED
        set -l direnv_dir (basename "$DIRENV_USED")
        if string match -q "flake:*" -- "$DIRENV_USED"
            set direnv_dir "$nix_icon $direnv_dir"
            set __fish_prompt_nix ""
        else
            set direnv_dir " $direnv_dir"
        end
        set -l direnv_dir (string shorten --max 15 -- "$direnv_dir")
        set __fish_prompt_direnv "$white""($direnv_dir) $__fish_prompt_normal"
    end

    set -l prompt_hostname (prompt_hostname)
    # Color hostname magenta if we're in a container, otherwise just use it as-is
    if test -f /run/.containerenv # podman
        or test -f /.dockerenv # docker
        set prompt_hostname (set_color magenta)(prompt_hostname)(set_color normal)
    end

    set -l prompt_os (uname)
    if test "$YADM_DISTRO" = nixos
        set prompt_os "$nix_icon"
    else if test $prompt_os = Darwin
        set prompt_os ""
    else if test $prompt_os = Linux
        set prompt_os ""
    else
        set prompt_os ""
    end
    if test "$YADM_OS" = WSL
        set prompt_os "$prompt_os  "
    end

    set prompt_os "$white$prompt_os$__fish_prompt_normal"

    set first_line (
        echo -n -s "$prompt_os" \
            "$__fish_prompt_pyenv" "$__fish_prompt_nix" "$__fish_prompt_direnv" \
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

    if string match -q '4*' $FISH_VERSION
        set -g __fish_git_prompt_color_upstream green
    else
        # Partial workaround for https://github.com/fish-shell/fish-shell/issues/10175
        # This ends up with two separators sometimes but better than nothing I guess
        # and the proposed fix didn't actually work :(
        set -g __fish_git_prompt_char_upstream_prefix (set_color $default_color)'|'(set_color green)
    end

    set -g __fish_git_prompt_shorten_branch_len $remaining_char_count

    set -l vcs_prompt
    if test "$YADM_OS" = WSL; and string match -q --regex '^/mnt/[a-z]/' $PWD
        # WSL is super slow to eval prompt, just put in a placeholder
        if git rev-parse --show-toplevel &>/dev/null
            set vcs_prompt (set_color bryellow)" (-WSL-)"(set_color normal)
        end
    else
        set vcs_prompt (__fish_vcs_prompt)
    end
    if string length -q -- $vcs_prompt
        set first_line "$first_line""$vcs_prompt"
    end

    set -l symbol '§'
    if test (id -u) -eq 0
        set symbol '♯'
    end

    echo -n -s "$first_line" "$__fish_prompt_normal" \n "$__fish_prompt_status" "$symbol " "$__fish_prompt_normal"
end
