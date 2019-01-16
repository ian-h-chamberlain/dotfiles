function fish_prompt --description 'Write out the prompt'
    set -l last_status $status

    set -g fish_color_cwd 'cyan'

	if not set -q __fish_prompt_normal
        set -g __fish_prompt_normal (set_color normal)
    end

    if not set -q __fish_prompt_cwd
        set -g __fish_prompt_cwd (set_color $fish_color_cwd)
    end

    set -g __fish_git_prompt_color 'bryellow' '--italics'

    if test $last_status -eq 0
        set -g __fish_prompt_status (set_color green)
    else
        set -g __fish_prompt_status (set_color red)
    end

    echo -n -s \[ "$USER" @ (prompt_hostname) \] ' ' "$__fish_prompt_cwd" (prompt_pwd) (__fish_vcs_prompt) \n "$__fish_prompt_status" '$ ' "$__fish_prompt_normal" 
end
