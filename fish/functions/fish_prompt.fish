# Defined in /var/folders/4w/bjgmcfds1nv33zqkhf2q2_340000gp/T//fish.pxGVcU/fish_prompt.fish @ line 2
function fish_prompt --description 'Write out the prompt'
	set -l last_status $status

	if not set -q __fish_prompt_normal
        set -g __fish_prompt_normal (set_color normal)
    end

    if not set -q __fish_prompt_cwd
        set -g __fish_prompt_cwd (set_color cyan)
    end

    set -g __fish_git_prompt_color 'bryellow' '--italics'

    if test $last_status -eq 0
        set -g __fish_prompt_status (set_color green)
    else
        set -g __fish_prompt_status (set_color red)
    end

    set color_sequence_chars \
        (echo -s -n "$__fish_prompt_cwd" "$__fish_git_prompt_color" "$__fish_prompt_normal" | wc -c)

    if set -q DOCKER_NAME
        set -g magenta (set_color magenta)
        set -g __fish_prompt_docker "$magenta"'('"$DOCKER_NAME"')'" $__fish_prompt_normal"

        # TODO: this still gets too long for some terminals
        set color_sequence_chars \
            (math $color_sequence_chars + (echo -s -n "$magenta" "$__fish_prompt_normal" | wc -c))
    end

    set first_line (
        echo -n -s "$__fish_prompt_docker" '[' "$USER" '@' (prompt_hostname) ']' \
        ' ' "$__fish_prompt_cwd" (prompt_pwd) (__fish_vcs_prompt)
    )

    set allowed_chars (math $COLUMNS + $color_sequence_chars - 1)
    set first_line (string sub --length $allowed_chars $first_line)

    echo -n -s "$first_line" "$__fish_prompt_normal" \n "$__fish_prompt_status" '$ ' "$__fish_prompt_normal"
end
