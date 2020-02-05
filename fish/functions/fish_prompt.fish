# Defined in /var/folders/4w/bjgmcfds1nv33zqkhf2q2_340000gp/T//fish.zqBdWR/fish_prompt.fish @ line 2
function fish_prompt --description 'Write out the prompt'
	set -l last_status $status

    if test $last_status -eq 0
        set -g __fish_prompt_status (set_color green)
    else
        set -g __fish_prompt_status (set_color red)
    end

	if not set -q __fish_prompt_normal
        set -g __fish_prompt_normal (set_color normal)
    end

    if not set -q __fish_prompt_cwd
        set -g __fish_prompt_cwd (set_color cyan)
    end

    set -g __fish_git_prompt_color 'bryellow' '--italics'

    set color_chars 0

    set -g magenta (set_color magenta)
    set -g white (set_color white)

    if set -q DOCKER_NAME
        set -g __fish_prompt_docker "$magenta"'('"$DOCKER_NAME"')'" $__fish_prompt_normal"

        set color_chars (math $color_chars + (string length -- "$magenta""$__fish_prompt_normal""$color_chars"))
    else
        set --erase __fish_prompt_docker
    end

    if set -q PYENV_VERSION
        set -g __fish_prompt_pyenv "$white"'('"$PYENV_VERSION"')'" $__fish_prompt_normal"

        set color_chars (math $color_chars + (string length -- "$white""$__fish_prompt_normal""$color_chars"))
    else
        set --erase __fish_prompt_pyenv
    end

    set first_line (
        echo -n -s "$__fish_prompt_docker" "$__fish_prompt_pyenv" \
            '[' "$USER" '@' (prompt_hostname) ']' \
            ' ' "$__fish_prompt_cwd" (prompt_pwd)
    )

    set remaining_char_count (
        math $COLUMNS + $color_chars - (string length -- "$first_line")
    )

    set -g __fish_git_prompt_shorten_branch_len $remaining_char_count

    set -l vcs_prompt (__fish_vcs_prompt)
    if string length -q -- $vcs_prompt
        set first_line "$first_line""$vcs_prompt"
    end

    echo -n -s "$first_line" "$__fish_prompt_normal" \n "$__fish_prompt_status" '$ ' "$__fish_prompt_normal"
end
